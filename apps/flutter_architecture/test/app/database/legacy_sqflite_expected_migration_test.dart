import 'dart:io';

import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/database_fixture_copy.dart';
import 'support/database_schema_report.dart';

void main() {
  sqfliteFfiInit();

  for (var version = 1; version <= 6; version++) {
    test('current sqflite contract將v$version fixture升級為canonical v6', () async {
      final temporary = await Directory.systemTemp.createTemp(
        'legacy-v$version-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final copy = await copyDatabaseFixture(
        fixturePath: appTestPath(
          p.join('app', 'database', 'fixtures', 'v$version.db'),
        ),
        destinationDirectory: temporary,
      );

      final database = await databaseFactoryFfi.openDatabase(
        copy.path,
        options: OpenDatabaseOptions(
          version: AppDatabaseSchema.version,
          singleInstance: false,
          onConfigure: AppDatabaseSchema.onConfigure,
          onCreate: AppDatabaseSchema.onCreate,
          onUpgrade: AppDatabaseSchema.onUpgrade,
        ),
      );
      addTearDown(database.close);

      final report = await DatabaseSchemaReport.capture(database);
      expect(report.value['userVersion'], 6);
      expect(report.value['foreignKeyCheck'], isEmpty);
      expect(
        (report.value['master']! as List<Object?>)
            .whereType<Map<String, Object?>>()
            .map((row) => row['name']),
        contains('catalog_cache_page_item_position_idx'),
      );

      final authRows = await database.query('auth_user');
      expect(authRows, version == 1 ? isEmpty : hasLength(1));
      if (version == 2 || version == 5) {
        expect(
          await database.query(
            'catalog_cache_page_item',
            where: 'query = ?',
            whereArgs: const <Object?>['orphan'],
          ),
          isEmpty,
        );
      }
    });
  }
}
