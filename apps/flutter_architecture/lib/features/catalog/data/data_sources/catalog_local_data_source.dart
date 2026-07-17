import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
import 'package:sqflite/sqflite.dart';

/// Catalog Offline Cache 的 SQLite boundary。
class CatalogLocalDataSource {
  const CatalogLocalDataSource(this._database);

  static const String _pageTable = 'catalog_cache_page';
  static const String _itemTable = 'catalog_cache_page_item';
  static const String _firstPageCursor = '';

  final Database _database;

  Future<CatalogCachePageEntity?> readPage({
    required String query,
    required String? cursor,
    required int limit,
    required DateTime now,
    required Duration retainFor,
  }) async {
    _validateCursor(cursor);
    _validateLimit(limit);
    return _guardLocal(() async {
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
        final updatedAt = DateTime.fromMillisecondsSinceEpoch(
          pageRows.single['updated_at']! as int,
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
          nextCursor: _parseOptionalCursor(pageRows.single['next_cursor']),
          updatedAt: updatedAt,
          items: <CatalogCacheItemEntity>[
            for (final row in itemRows) _parseItem(row),
          ],
        );
        _validatePage(page);
      } on _CorruptedCatalogCacheException {
        await deletePage(query: normalizedQuery, cursor: cursor, limit: limit);
        return null;
      } on AppException {
        await deletePage(query: normalizedQuery, cursor: cursor, limit: limit);
        return null;
      } on TypeError {
        await deletePage(query: normalizedQuery, cursor: cursor, limit: limit);
        return null;
      }

      final updatedAt = page.updatedAt;
      if (now.toUtc().difference(updatedAt) > retainFor) {
        await deletePage(query: normalizedQuery, cursor: cursor, limit: limit);
        return null;
      }

      return page;
    }, message: '讀取 Catalog Cache 失敗');
  }

  Future<void> replacePage(
    CatalogCachePageEntity page, {
    required bool resetFollowingPages,
  }) async {
    _validateCursor(page.requestCursor);
    _validateLimit(page.requestLimit);
    _validatePage(page);
    if (resetFollowingPages && page.requestCursor != null) {
      throw const AppException(
        message: '只有 Catalog 第一頁可以重設 cursor chain',
        code: 'invalid_catalog_cache_chain_reset',
      );
    }
    await _guardLocal(() async {
      final normalizedQuery = page.query.trim();
      final storedCursor = _encodeCursor(page.requestCursor);

      await _database.transaction((transaction) async {
        if (resetFollowingPages) {
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
        }, conflictAlgorithm: ConflictAlgorithm.replace);

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
      });
    }, message: '儲存 Catalog Cache 失敗');
  }

  /// 只有 requested cursor 仍由目前 Cache chain 指向時才寫入 Append page。
  ///
  /// 可避免舊 Append request 在第一頁 replacement 後完成，重新污染已失效的
  /// cursor chain；同時拒絕 nextCursor 指回已存在 page identity 的 cycle。
  Future<bool> replaceAppendPageIfLinked(CatalogCachePageEntity page) async {
    _validateCursor(page.requestCursor);
    _validateLimit(page.requestLimit);
    _validatePage(page);
    if (page.requestCursor == null) {
      throw const AppException(
        message: 'Catalog Append Cache 必須提供 request cursor',
        code: 'invalid_catalog_append_cache_cursor',
      );
    }

    return _guardLocal(() async {
      final normalizedQuery = page.query.trim();
      final storedCursor = _encodeCursor(page.requestCursor);

      return _database.transaction((transaction) async {
        final predecessorRows = await transaction.query(
          _pageTable,
          columns: const <String>['request_cursor'],
          where: 'query = ? AND request_limit = ? AND next_cursor = ?',
          whereArgs: <Object?>[
            normalizedQuery,
            page.requestLimit,
            page.requestCursor,
          ],
          limit: 1,
        );
        if (predecessorRows.isEmpty) {
          return false;
        }

        final nextCursor = page.nextCursor;
        if (nextCursor != null) {
          final existingNextRows = await transaction.query(
            _pageTable,
            columns: const <String>['request_cursor'],
            where: 'query = ? AND request_limit = ? AND request_cursor = ?',
            whereArgs: <Object?>[
              normalizedQuery,
              page.requestLimit,
              _encodeCursor(nextCursor),
            ],
            limit: 1,
          );
          if (existingNextRows.isNotEmpty) {
            return false;
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
        }, conflictAlgorithm: ConflictAlgorithm.replace);

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
      });
    }, message: '儲存 Catalog Append Cache 失敗');
  }

  Future<void> deletePage({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    _validateCursor(cursor);
    _validateLimit(limit);
    await _guardLocal(() async {
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
    }, message: '清除 Catalog Cache 失敗');
  }

  String _encodeCursor(String? cursor) => cursor ?? _firstPageCursor;

  String? _decodeCursor(String cursor) =>
      cursor == _firstPageCursor ? null : cursor;

  void _validateCursor(String? cursor) {
    if (cursor != null && cursor.trim().isEmpty) {
      throw const AppException(
        message: 'Catalog Cache cursor 不可為空字串',
        code: 'invalid_catalog_cache_cursor',
      );
    }
  }

  void _validatePage(CatalogCachePageEntity page) {
    _validateOptionalCursor(page.nextCursor);
    if (page.requestCursor != null && page.nextCursor == page.requestCursor) {
      throw const AppException(
        message: 'Catalog Cache cursor 無法前進',
        code: 'non_advancing_catalog_cache_cursor',
      );
    }

    final positions = <int>{};
    for (final item in page.items) {
      if (item.id.trim().isEmpty || item.name.trim().isEmpty) {
        throw const AppException(
          message: 'Catalog Cache item 欄位不合法',
          code: 'invalid_catalog_cache_item',
        );
      }
      if (item.position < 0 || !positions.add(item.position)) {
        throw const AppException(
          message: 'Catalog Cache item position 不合法',
          code: 'invalid_catalog_cache_item_position',
        );
      }
    }

    for (var index = 0; index < page.items.length; index++) {
      if (!positions.contains(index)) {
        throw const AppException(
          message: 'Catalog Cache item position 必須連續',
          code: 'invalid_catalog_cache_item_position',
        );
      }
    }
  }

  void _validateLimit(int limit) {
    if (limit <= 0) {
      throw const AppException(
        message: 'Catalog Cache limit 必須大於 0',
        code: 'invalid_catalog_cache_limit',
      );
    }
  }

  void _validateOptionalCursor(String? cursor) {
    if (cursor != null && cursor.trim().isEmpty) {
      throw const AppException(
        message: 'Catalog Cache next cursor 不可為空字串',
        code: 'invalid_catalog_cache_next_cursor',
      );
    }
  }

  String? _parseOptionalCursor(Object? value) {
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
  }) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(message: message, cause: error),
        stackTrace,
      );
    }
  }
}

class _CorruptedCatalogCacheException implements Exception {
  const _CorruptedCatalogCacheException();
}
