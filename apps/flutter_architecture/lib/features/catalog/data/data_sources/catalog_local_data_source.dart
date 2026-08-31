import 'package:core/core.dart';
import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';

/// Catalog Offline Cache 的 SQLite boundary。
class CatalogLocalDataSource {
  const CatalogLocalDataSource(this._database);

  static const String _pageTable = 'catalog_cache_page';
  static const String _itemTable = 'catalog_cache_page_item';
  static const String _firstPageCursor = '';

  final CatalogCacheDao _database;

  Future<CatalogCachePageEntity?> readPage({
    required String query,
    required String? cursor,
    required int limit,
    required DateTime now,
    required Duration retainFor,
  }) async {
    _validateCursor(cursor);
    _validateLimit(limit);
    return _guardLocal(
      () async {
        final normalizedQuery = query.trim();
        final storedCursor = _encodeCursor(cursor);
        final pageRows = await _database.query(
          _pageTable,
          where: 'query = ? AND request_cursor = ? AND request_limit = ?',
          whereArgs: <Object?>[normalizedQuery, storedCursor, limit],
          limit: 1,
        );

        if (pageRows.isEmpty) {
          return null;
        }

        late final CatalogCachePageEntity page;
        try {
          final pageRow = pageRows.single;
          final updatedAt = DateTime.fromMillisecondsSinceEpoch(
            _parseRequiredInt(pageRow['updated_at']),
            isUtc: true,
          );
          final itemRows = await _database.query(
            _itemTable,
            where: 'query = ? AND request_cursor = ? AND request_limit = ?',
            whereArgs: <Object?>[normalizedQuery, storedCursor, limit],
            orderBy: 'item_position ASC',
          );

          page = CatalogCachePageEntity(
            query: normalizedQuery,
            requestCursor: _decodeCursor(storedCursor),
            requestLimit: limit,
            nextCursor: _parsePersistedOptionalCursor(pageRow['next_cursor']),
            chainRevision: _parseRequiredInt(pageRow['chain_revision']),
            updatedAt: updatedAt,
            items: <CatalogCacheItemEntity>[
              for (final row in itemRows) _parseItem(row),
            ],
          );
          _validatePersistedPage(page);
        } on _CorruptedCatalogCacheException {
          await _deletePage(
            query: normalizedQuery,
            cursor: cursor,
            limit: limit,
            operation: CatalogCacheOperation.corruptionCleanup,
          );
          return null;
        }

        final updatedAt = page.updatedAt;
        if (now.toUtc().difference(updatedAt) > retainFor) {
          await _deletePage(
            query: normalizedQuery,
            cursor: cursor,
            limit: limit,
            operation: CatalogCacheOperation.expiredCleanup,
          );
          return null;
        }

        return page;
      },
      message: '讀取 Catalog Cache 失敗',
      details: _details(
        operation: CatalogCacheOperation.readPage,
        query: query,
        cursor: cursor,
        limit: limit,
      ),
    );
  }

  Future<int> replacePage(
    CatalogCachePageEntity page, {
    required bool resetFollowingPages,
  }) async {
    _validateCursor(page.requestCursor);
    _validateLimit(page.requestLimit);
    _validatePageForWrite(page);
    if (resetFollowingPages && page.requestCursor != null) {
      throw StateError('只有 Catalog 第一頁可以重設 cursor chain');
    }
    return _guardLocal(
      () async {
        final normalizedQuery = page.query.trim();
        final storedCursor = _encodeCursor(page.requestCursor);

        return _database.transaction((transaction) async {
          var chainRevision = page.chainRevision;
          if (resetFollowingPages) {
            // 第一頁 replacement 建立新的 cursor-chain generation。舊 append 即使
            // 稍後完成，也會因 revision/linkage 不符而失去 cache commit ownership。
            final currentRows = await transaction.query(
              _pageTable,
              columns: const <String>['chain_revision'],
              where: 'query = ? AND request_limit = ? AND request_cursor = ?',
              whereArgs: <Object?>[
                normalizedQuery,
                page.requestLimit,
                _firstPageCursor,
              ],
              limit: 1,
            );
            if (currentRows.isEmpty) {
              chainRevision = 1;
            } else {
              try {
                chainRevision =
                    _parseRequiredInt(currentRows.single['chain_revision']) + 1;
              } on _CorruptedCatalogCacheException {
                await transaction.delete(
                  _itemTable,
                  where: 'query = ? AND request_limit = ?',
                  whereArgs: <Object?>[normalizedQuery, page.requestLimit],
                );
                await transaction.delete(
                  _pageTable,
                  where: 'query = ? AND request_limit = ?',
                  whereArgs: <Object?>[normalizedQuery, page.requestLimit],
                );
                chainRevision = 1;
              }
            }
            await transaction.delete(
              _itemTable,
              where: 'query = ? AND request_limit = ? AND request_cursor <> ?',
              whereArgs: <Object?>[
                normalizedQuery,
                page.requestLimit,
                _firstPageCursor,
              ],
            );
            await transaction.delete(
              _pageTable,
              where: 'query = ? AND request_limit = ? AND request_cursor <> ?',
              whereArgs: <Object?>[
                normalizedQuery,
                page.requestLimit,
                _firstPageCursor,
              ],
            );
          }

          await transaction.delete(
            _itemTable,
            where: 'query = ? AND request_cursor = ? AND request_limit = ?',
            whereArgs: <Object?>[
              normalizedQuery,
              storedCursor,
              page.requestLimit,
            ],
          );

          await transaction.insert(_pageTable, <String, Object?>{
            'query': normalizedQuery,
            'request_cursor': storedCursor,
            'request_limit': page.requestLimit,
            'next_cursor': page.nextCursor,
            'updated_at': page.updatedAt.toUtc().millisecondsSinceEpoch,
            'chain_revision': chainRevision,
          }, replace: true);

          for (final item in page.items) {
            await transaction.insert(_itemTable, <String, Object?>{
              'query': normalizedQuery,
              'request_cursor': storedCursor,
              'request_limit': page.requestLimit,
              'item_id': item.id,
              'item_position': item.position,
              'item_name': item.name,
              'item_description': item.description,
            });
          }
          return chainRevision;
        });
      },
      message: '儲存 Catalog Cache 失敗',
      details: _details(
        operation: resetFollowingPages
            ? CatalogCacheOperation.writeFirstPage
            : CatalogCacheOperation.writePage,
        query: page.query,
        cursor: page.requestCursor,
        limit: page.requestLimit,
      ),
    );
  }

  /// 只有 requested cursor 仍由目前 Cache chain 指向時才寫入 Append page。
  ///
  /// 可避免舊 Append request 在第一頁 replacement 後完成，重新污染已失效的
  /// cursor chain；同時拒絕 nextCursor 指回已存在 page identity 的 cycle。
  Future<bool> replaceAppendPageIfLinked(
    CatalogCachePageEntity page, {
    int? expectedChainRevision,
  }) async {
    _validateCursor(page.requestCursor);
    _validateLimit(page.requestLimit);
    _validatePageForWrite(page);
    if (page.requestCursor == null) {
      throw StateError('Catalog Append Cache 必須提供 request cursor');
    }

    return _guardLocal(
      () async {
        final normalizedQuery = page.query.trim();
        final storedCursor = _encodeCursor(page.requestCursor);

        return _database.transaction((transaction) async {
          try {
            final firstRows = await transaction.query(
              _pageTable,
              columns: const <String>['chain_revision'],
              where: 'query = ? AND request_limit = ? AND request_cursor = ?',
              whereArgs: <Object?>[
                normalizedQuery,
                page.requestLimit,
                _firstPageCursor,
              ],
              limit: 1,
            );
            if (firstRows.isEmpty) {
              return false;
            }
            final currentRevision = _parseRequiredInt(
              firstRows.single['chain_revision'],
            );
            final requiredRevision = expectedChainRevision ?? currentRevision;
            if (currentRevision != requiredRevision) return false;

            final ancestors = <String>{_firstPageCursor};
            var cursorToRead = _firstPageCursor;
            var isLinked = false;
            while (true) {
              final rows = await transaction.query(
                _pageTable,
                columns: const <String>['next_cursor', 'chain_revision'],
                where: 'query = ? AND request_limit = ? AND request_cursor = ?',
                whereArgs: <Object?>[
                  normalizedQuery,
                  page.requestLimit,
                  cursorToRead,
                ],
                limit: 1,
              );
              if (rows.isEmpty ||
                  _parseRequiredInt(rows.single['chain_revision']) !=
                      currentRevision) {
                return false;
              }
              final next = _parsePersistedOptionalCursor(
                rows.single['next_cursor'],
              );
              if (next == page.requestCursor) {
                isLinked = true;
                break;
              }
              if (next == null || !ancestors.add(next)) return false;
              cursorToRead = next;
            }
            if (!isLinked ||
                (page.nextCursor != null &&
                    ancestors.contains(page.nextCursor))) {
              return false;
            }

            final nextCursor = page.nextCursor;
            if (nextCursor != null) {
              final existingNextRows = await transaction.query(
                _pageTable,
                columns: const <String>['request_cursor', 'chain_revision'],
                where: 'query = ? AND request_limit = ? AND request_cursor = ?',
                whereArgs: <Object?>[
                  normalizedQuery,
                  page.requestLimit,
                  _encodeCursor(nextCursor),
                ],
                limit: 1,
              );
              if (existingNextRows.isNotEmpty &&
                  _parseRequiredInt(
                        existingNextRows.single['chain_revision'],
                      ) !=
                      currentRevision) {
                await transaction.delete(
                  _itemTable,
                  where:
                      'query = ? AND request_limit = ? AND request_cursor = ?',
                  whereArgs: <Object?>[
                    normalizedQuery,
                    page.requestLimit,
                    _encodeCursor(nextCursor),
                  ],
                );
                await transaction.delete(
                  _pageTable,
                  where:
                      'query = ? AND request_limit = ? AND request_cursor = ?',
                  whereArgs: <Object?>[
                    normalizedQuery,
                    page.requestLimit,
                    _encodeCursor(nextCursor),
                  ],
                );
              }
            }

            await transaction.delete(
              _itemTable,
              where: 'query = ? AND request_cursor = ? AND request_limit = ?',
              whereArgs: <Object?>[
                normalizedQuery,
                storedCursor,
                page.requestLimit,
              ],
            );
            await transaction.insert(_pageTable, <String, Object?>{
              'query': normalizedQuery,
              'request_cursor': storedCursor,
              'request_limit': page.requestLimit,
              'next_cursor': page.nextCursor,
              'updated_at': page.updatedAt.toUtc().millisecondsSinceEpoch,
              'chain_revision': currentRevision,
            }, replace: true);

            for (final item in page.items) {
              await transaction.insert(_itemTable, <String, Object?>{
                'query': normalizedQuery,
                'request_cursor': storedCursor,
                'request_limit': page.requestLimit,
                'item_id': item.id,
                'item_position': item.position,
                'item_name': item.name,
                'item_description': item.description,
              });
            }
            return true;
          } on _CorruptedCatalogCacheException {
            // Chain metadata 已無法可信解析時採 fail closed：刪除整條 chain，
            // 不嘗試保留局部 page，避免後續 append 在矛盾 authority 上繼續延伸。
            await _deleteChainInTransaction(
              transaction,
              query: normalizedQuery,
              limit: page.requestLimit,
            );
            return false;
          }
        });
      },
      message: '儲存 Catalog Append Cache 失敗',
      details: _details(
        operation: CatalogCacheOperation.writeAppendPage,
        query: page.query,
        cursor: page.requestCursor,
        limit: page.requestLimit,
      ),
    );
  }

  Future<int?> readLinkedChainRevision({
    required String query,
    required String cursor,
    required int limit,
  }) async {
    _validateCursor(cursor);
    _validateLimit(limit);
    return _guardLocal(
      () async {
        final normalizedQuery = query.trim();
        final rows = await _database.query(
          _pageTable,
          columns: const <String>['chain_revision'],
          where: 'query = ? AND request_limit = ? AND next_cursor = ?',
          whereArgs: <Object?>[normalizedQuery, limit, cursor],
          limit: 1,
        );
        if (rows.isEmpty) return null;
        try {
          return _parseRequiredInt(rows.single['chain_revision']);
        } on _CorruptedCatalogCacheException {
          await _database.transaction((transaction) async {
            await _deleteChainInTransaction(
              transaction,
              query: normalizedQuery,
              limit: limit,
            );
          });
          return null;
        }
      },
      message: '讀取 Catalog chain revision 失敗',
      details: _details(
        operation: CatalogCacheOperation.readChainRevision,
        query: query,
        cursor: cursor,
        limit: limit,
      ),
    );
  }

  Future<void> deletePage({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    _validateCursor(cursor);
    _validateLimit(limit);
    await _deletePage(
      query: query,
      cursor: cursor,
      limit: limit,
      operation: CatalogCacheOperation.deletePage,
    );
  }

  Future<void> _deletePage({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogCacheOperation operation,
  }) async {
    await _guardLocal(
      () async {
        final normalizedQuery = query.trim();
        final storedCursor = _encodeCursor(cursor);
        await _database.transaction((transaction) async {
          await transaction.delete(
            _itemTable,
            where: 'query = ? AND request_cursor = ? AND request_limit = ?',
            whereArgs: <Object?>[normalizedQuery, storedCursor, limit],
          );
          await transaction.delete(
            _pageTable,
            where: 'query = ? AND request_cursor = ? AND request_limit = ?',
            whereArgs: <Object?>[normalizedQuery, storedCursor, limit],
          );
        });
      },
      message: '清除 Catalog Cache 失敗',
      details: _details(
        operation: operation,
        query: query,
        cursor: cursor,
        limit: limit,
      ),
    );
  }

  Future<void> _deleteChainInTransaction(
    CatalogCacheDao executor, {
    required String query,
    required int limit,
  }) async {
    await executor.delete(
      _itemTable,
      where: 'query = ? AND request_limit = ?',
      whereArgs: <Object?>[query, limit],
    );
    await executor.delete(
      _pageTable,
      where: 'query = ? AND request_limit = ?',
      whereArgs: <Object?>[query, limit],
    );
  }

  String _encodeCursor(String? cursor) => cursor ?? _firstPageCursor;

  String? _decodeCursor(String cursor) =>
      cursor == _firstPageCursor ? null : cursor;

  void _validateCursor(String? cursor) {
    if (cursor != null && cursor.trim().isEmpty) {
      throw ArgumentError.value(
        cursor,
        'cursor',
        'Catalog Cache cursor 不可為空字串',
      );
    }
  }

  void _validatePageForWrite(CatalogCachePageEntity page) {
    _validateOptionalCursorForWrite(page.nextCursor);
    if (page.requestCursor != null && page.nextCursor == page.requestCursor) {
      throw ArgumentError('Catalog Cache cursor 無法前進');
    }

    final positions = <int>{};
    for (final item in page.items) {
      if (item.id.trim().isEmpty || item.name.trim().isEmpty) {
        throw ArgumentError('Catalog Cache item 欄位不合法');
      }
      if (item.position < 0 || !positions.add(item.position)) {
        throw ArgumentError('Catalog Cache item position 不合法');
      }
    }

    for (var index = 0; index < page.items.length; index++) {
      if (!positions.contains(index)) {
        throw ArgumentError('Catalog Cache item position 必須連續');
      }
    }
  }

  void _validatePersistedPage(CatalogCachePageEntity page) {
    _validatePersistedOptionalCursor(page.nextCursor);
    if (page.requestCursor != null && page.nextCursor == page.requestCursor) {
      throw const _CorruptedCatalogCacheException();
    }

    final positions = <int>{};
    for (final item in page.items) {
      if (item.id.trim().isEmpty ||
          item.name.trim().isEmpty ||
          item.position < 0 ||
          !positions.add(item.position)) {
        throw const _CorruptedCatalogCacheException();
      }
    }

    for (var index = 0; index < page.items.length; index++) {
      if (!positions.contains(index)) {
        throw const _CorruptedCatalogCacheException();
      }
    }
  }

  void _validateLimit(int limit) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Catalog Cache limit 必須大於 0');
    }
  }

  void _validateOptionalCursorForWrite(String? cursor) {
    if (cursor != null && cursor.trim().isEmpty) {
      throw ArgumentError.value(
        cursor,
        'nextCursor',
        'Catalog Cache next cursor 不可為空字串',
      );
    }
  }

  void _validatePersistedOptionalCursor(String? cursor) {
    if (cursor != null && cursor.trim().isEmpty) {
      throw const _CorruptedCatalogCacheException();
    }
  }

  int _parseRequiredInt(Object? value) {
    if (value is! int) {
      throw const _CorruptedCatalogCacheException();
    }
    return value;
  }

  String? _parsePersistedOptionalCursor(Object? value) {
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw const _CorruptedCatalogCacheException();
    }
    return value;
  }

  CatalogCacheItemEntity _parseItem(Map<String, Object?> row) {
    final id = row['item_id'];
    final name = row['item_name'];
    final description = row['item_description'];
    final position = row['item_position'];
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        description is! String ||
        position is! int ||
        position < 0) {
      throw const _CorruptedCatalogCacheException();
    }
    return CatalogCacheItemEntity(
      id: id,
      name: name,
      description: description,
      position: position,
    );
  }

  Future<T> _guardLocal<T>(
    Future<T> Function() action, {
    required String message,
    required CatalogCacheFailureDetails Function(Object error) details,
  }) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } on CatalogCacheDaoException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: message,
          cause: details(error.cause),
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  CatalogCacheFailureDetails Function(Object error) _details({
    required CatalogCacheOperation operation,
    required String query,
    required String? cursor,
    required int limit,
  }) {
    return (error) => CatalogCacheFailureDetails(
      operation: operation,
      isQueryEmpty: query.trim().isEmpty,
      hasCursor: cursor != null,
      limit: limit,
      originalError: error,
    );
  }
}

class _CorruptedCatalogCacheException implements Exception {
  const _CorruptedCatalogCacheException();
}
