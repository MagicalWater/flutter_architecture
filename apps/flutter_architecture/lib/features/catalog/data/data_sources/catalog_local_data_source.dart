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

      final updatedAt = DateTime.fromMillisecondsSinceEpoch(
        pageRows.single['updated_at']! as int,
        isUtc: true,
      );
      if (now.toUtc().difference(updatedAt) > retainFor) {
        await deletePage(query: normalizedQuery, cursor: cursor, limit: limit);
        return null;
      }

      final itemRows = await _database.query(
        _itemTable,
        where: 'query = ? AND request_cursor = ? AND request_limit = ?',
        whereArgs: <Object?>[normalizedQuery, storedCursor, limit],
        orderBy: 'item_position ASC',
      );

      return CatalogCachePageEntity(
        query: normalizedQuery,
        requestCursor: _decodeCursor(storedCursor),
        requestLimit: limit,
        nextCursor: pageRows.single['next_cursor'] as String?,
        updatedAt: updatedAt,
        items: <CatalogCacheItemEntity>[
          for (final row in itemRows)
            CatalogCacheItemEntity(
              id: row['item_id']! as String,
              name: row['item_name']! as String,
              description: row['item_description']! as String,
              position: row['item_position']! as int,
            ),
        ],
      );
    }, message: '讀取 Catalog Cache 失敗');
  }

  Future<void> replacePage(
    CatalogCachePageEntity page, {
    required bool resetFollowingPages,
  }) async {
    _validateCursor(page.requestCursor);
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

  Future<void> deletePage({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    _validateCursor(cursor);
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
