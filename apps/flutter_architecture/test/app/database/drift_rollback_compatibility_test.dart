import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/database_fixture_copy.dart';

void main() {
  sqfliteFfiInit();

  for (var version = 1; version <= 6; version++) {
    test('Drift升級v$version後sqflite仍可讀取並維持constraints', () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rollback-v$version-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final copy = await copyDatabaseFixture(
        fixturePath: appTestPath(
          p.join('app', 'database', 'fixtures', 'v$version.db'),
        ),
        destinationDirectory: temporary,
      );

      final drift = AppDatabase(NativeDatabase(copy));
      await drift.customSelect('SELECT 1').getSingle();
      await drift.close();

      final sqflite = await databaseFactoryFfi.openDatabase(
        copy.path,
        options: OpenDatabaseOptions(
          singleInstance: false,
          onConfigure: (database) =>
              database.execute('PRAGMA foreign_keys = ON'),
        ),
      );
      addTearDown(sqflite.close);

      await sqflite.insert('catalog_cache_page', <String, Object?>{
        'query': 'rollback-check',
        'request_cursor': '',
        'request_limit': 20,
        'next_cursor': null,
        'updated_at': 1,
        'chain_revision': 0,
      });
      await sqflite.insert('catalog_cache_page_item', <String, Object?>{
        'query': 'rollback-check',
        'request_cursor': '',
        'request_limit': 20,
        'item_id': 'rollback-item',
        'item_position': 0,
        'item_name': 'Rollback Item',
        'item_description': 'Rollback compatibility fixture',
      });
      await sqflite.delete(
        'catalog_cache_page',
        where: 'query = ? AND request_cursor = ? AND request_limit = ?',
        whereArgs: const <Object?>['rollback-check', '', 20],
      );
      expect(
        await sqflite.query(
          'catalog_cache_page_item',
          where: 'query = ? AND request_cursor = ?',
          whereArgs: const <Object?>['rollback-check', ''],
        ),
        isEmpty,
      );
    });
  }
}
