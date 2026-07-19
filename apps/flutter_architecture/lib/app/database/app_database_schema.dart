import 'package:sqflite/sqflite.dart';

/// App SQLite schema 與 migration 入口。
abstract final class AppDatabaseSchema {
  static const int version = 6;

  static Future<void> onConfigure(Database db) {
    return db.execute('PRAGMA foreign_keys = ON');
  }

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
    if (oldVersion < 5) {
      await _upgradeAuthUserToSingleActiveRecord(db);
    }
    if (oldVersion < 6) {
      await _removeCatalogCacheOrphans(db);
    }
  }

  static Future<void> _createAuthUserTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE auth_user (
        slot INTEGER PRIMARY KEY CHECK (slot = 1),
        id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _upgradeAuthUserToSingleActiveRecord(
    DatabaseExecutor db,
  ) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      const <Object?>['auth_user'],
    );
    if (tables.isEmpty) {
      await _createAuthUserTable(db);
      return;
    }

    final rows = await db.query('auth_user');
    await db.execute('ALTER TABLE auth_user RENAME TO auth_user_legacy');
    await _createAuthUserTable(db);

    if (rows.length == 1) {
      await db.insert('auth_user', <String, Object?>{
        'slot': 1,
        'id': rows.single['id'],
        'name': rows.single['name'],
      });
    }

    await db.execute('DROP TABLE auth_user_legacy');
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

  static Future<void> _removeCatalogCacheOrphans(
    DatabaseExecutor db,
  ) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name IN ('catalog_cache_page', 'catalog_cache_page_item')",
    );
    if (tables.length != 2) return;

    await db.execute('''
      DELETE FROM catalog_cache_page_item
      WHERE NOT EXISTS (
        SELECT 1
        FROM catalog_cache_page
        WHERE catalog_cache_page.query = catalog_cache_page_item.query
          AND catalog_cache_page.request_cursor =
            catalog_cache_page_item.request_cursor
          AND catalog_cache_page.request_limit =
            catalog_cache_page_item.request_limit
      )
    ''');
  }
}
