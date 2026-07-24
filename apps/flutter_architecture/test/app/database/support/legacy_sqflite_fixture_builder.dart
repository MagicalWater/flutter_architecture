import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final class LegacySqfliteFixtureBuilder {
  LegacySqfliteFixtureBuilder() {
    sqfliteFfiInit();
  }

  Future<void> buildAll(Directory outputDirectory) async {
    await outputDirectory.create(recursive: true);
    for (var version = 1; version <= 6; version++) {
      final path = p.join(outputDirectory.path, 'v$version.db');
      await databaseFactoryFfi.deleteDatabase(path);
      final database = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      try {
        await database.execute('PRAGMA foreign_keys = OFF');
        await _createSchema(database, version);
        await _seed(database, version);
        await database.execute('PRAGMA user_version = $version');
      } finally {
        await database.close();
      }
    }
  }

  Future<void> _createSchema(Database database, int version) async {
    if (version < 5) {
      await database.execute('''
        CREATE TABLE auth_user (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL
        )
      ''');
    } else {
      await database.execute('''
        CREATE TABLE auth_user (
          slot INTEGER PRIMARY KEY CHECK (slot = 1),
          id TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL
        )
      ''');
    }

    if (version < 2) return;
    await database.execute('''
      CREATE TABLE catalog_cache_page (
        query TEXT NOT NULL,
        request_cursor TEXT NOT NULL,
        request_limit INTEGER NOT NULL,
        next_cursor TEXT,
        updated_at INTEGER NOT NULL${version >= 4 ? ',\n        chain_revision INTEGER NOT NULL DEFAULT 0' : ''},
        PRIMARY KEY (query, request_cursor, request_limit)
      )
    ''');
    await database.execute('''
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
    await database.execute('''
      CREATE ${version >= 3 ? 'UNIQUE ' : ''}INDEX
      ${version >= 3 ? 'catalog_cache_page_item_position_idx' : 'catalog_cache_page_item_order_idx'}
      ON catalog_cache_page_item (
        query, request_cursor, request_limit, item_position
      )
    ''');
  }

  Future<void> _seed(Database database, int version) async {
    if (version == 1) {
      await _insertLegacyUser(database, 'legacy-a', 'Legacy A');
      await _insertLegacyUser(database, 'legacy-b', 'Legacy B');
      return;
    }
    if (version < 5) {
      await _insertLegacyUser(database, 'legacy-single', 'Legacy Single');
    } else {
      await database.insert('auth_user', <String, Object?>{
        'slot': 1,
        'id': 'active-user',
        'name': 'Active User',
      });
    }

    await _insertPage(
      database,
      query: 'flutter',
      cursor: '',
      nextCursor: version >= 4 ? 'cursor-1' : null,
      revision: version >= 4 ? 7 : null,
    );
    await _insertItem(database, itemId: 'item-1', position: 0);

    if (version == 2) {
      await _insertItem(database, itemId: 'duplicate-position', position: 0);
    }
    if (version >= 4) {
      await _insertPage(
        database,
        query: 'flutter',
        cursor: 'cursor-1',
        nextCursor: '',
        revision: 7,
      );
      await _insertItem(
        database,
        cursor: 'cursor-1',
        itemId: 'item-2',
        position: 0,
      );
    }
    if (version == 2 || version == 5) {
      await _insertItem(
        database,
        query: 'orphan',
        itemId: 'orphan-item',
        position: 0,
      );
    }
  }

  Future<void> _insertLegacyUser(Database database, String id, String name) =>
      database.insert('auth_user', <String, Object?>{'id': id, 'name': name});

  Future<void> _insertPage(
    Database database, {
    required String query,
    required String cursor,
    required String? nextCursor,
    required int? revision,
  }) {
    final values = <String, Object?>{
      'query': query,
      'request_cursor': cursor,
      'request_limit': 20,
      'next_cursor': nextCursor,
      'updated_at': DateTime.utc(2026, 7, 20).millisecondsSinceEpoch,
    };
    if (revision != null) {
      values['chain_revision'] = revision;
    }
    return database.insert('catalog_cache_page', values);
  }

  Future<void> _insertItem(
    Database database, {
    String query = 'flutter',
    String cursor = '',
    required String itemId,
    required int position,
  }) {
    return database.insert('catalog_cache_page_item', <String, Object?>{
      'query': query,
      'request_cursor': cursor,
      'request_limit': 20,
      'item_id': itemId,
      'item_position': position,
      'item_name': 'Item $itemId',
      'item_description': 'Fixture item $itemId',
    });
  }
}
