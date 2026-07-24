import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/database_fixture_copy.dart';

void main() {
  sqfliteFfiInit();

  for (var version = 1; version <= 6; version++) {
    test('v$version fixture具有正確版本、schema與sentinel data', () async {
      final path = appTestPath(
        p.join('app', 'database', 'fixtures', 'v$version.db'),
      );
      expect(File(path).existsSync(), isTrue, reason: path);

      final database = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      addTearDown(database.close);

      expect(
        (await database.rawQuery('PRAGMA user_version')).single.values.single,
        version,
      );
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
      );
      expect(tables.map((row) => row['name']), contains('auth_user'));
      expect(await database.query('auth_user'), isNotEmpty);
      if (version >= 2) {
        expect(
          tables.map((row) => row['name']),
          containsAll(<String>[
            'catalog_cache_page',
            'catalog_cache_page_item',
          ]),
        );
        expect(await database.query('catalog_cache_page'), isNotEmpty);
        expect(await database.query('catalog_cache_page_item'), isNotEmpty);
      }
    });
  }
}
