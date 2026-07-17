import 'package:sqflite/sqflite.dart';

/// App SQLite schema 與 migration 入口。
abstract final class AppDatabaseSchema {
  static const int version = 4;

  static Future<void> onCreate(Database db, int version) async {
    await _createAuthUserTable(db);
    await _createCatalogCacheTables(db);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createCatalogCacheTables(db);
    }
    if (oldVersion >= 2 && oldVersion < 3) {
      await _upgradeCatalogItemPositionIndex(db);
    }
    if (oldVersion < 4) {
      await _addCatalogChainRevision(db);
    }
  }

  static Future<void> _createAuthUserTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE auth_user (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createCatalogCacheTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE catalog_cache_page (
        query TEXT NOT NULL,
        request_cursor TEXT NOT NULL,
        request_limit INTEGER NOT NULL,
        next_cursor TEXT,
        updated_at INTEGER NOT NULL,
        chain_revision INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (query, request_cursor, request_limit)
      )
    ''');

    await db.execute('''
      CREATE TABLE catalog_cache_page_item (
        query TEXT NOT NULL,
        request_cursor TEXT NOT NULL,
        request_limit INTEGER NOT NULL,
        item_id TEXT NOT NULL,
        item_position INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_description TEXT NOT NULL,
        PRIMARY KEY (query, request_cursor, request_limit, item_id),
        FOREIGN KEY (query, request_cursor, request_limit)
          REFERENCES catalog_cache_page (query, request_cursor, request_limit)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX catalog_cache_page_item_position_idx
      ON catalog_cache_page_item (
        query,
        request_cursor,
        request_limit,
        item_position
      )
    ''');
  }

  static Future<void> _addCatalogChainRevision(DatabaseExecutor db) async {
    final columns = await db.rawQuery('PRAGMA table_info(catalog_cache_page)');
    if (columns.any((row) => row['name'] == 'chain_revision')) return;
    await db.execute(
      'ALTER TABLE catalog_cache_page '
      'ADD COLUMN chain_revision INTEGER NOT NULL DEFAULT 0',
    );
  }

  static Future<void> _upgradeCatalogItemPositionIndex(
    DatabaseExecutor db,
  ) async {
    await db.execute('DROP INDEX IF EXISTS catalog_cache_page_item_order_idx');
    await db.execute('''
      DELETE FROM catalog_cache_page_item
      WHERE rowid NOT IN (
        SELECT MIN(rowid)
        FROM catalog_cache_page_item
        GROUP BY query, request_cursor, request_limit, item_position
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX catalog_cache_page_item_position_idx
      ON catalog_cache_page_item (
        query,
        request_cursor,
        request_limit,
        item_position
      )
    ''');
  }
}
