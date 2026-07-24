import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/database_fixture_copy.dart';
import 'support/database_schema_report.dart';

void main() {
  sqfliteFfiInit();

  for (var version = 1; version <= 6; version++) {
    test('Drift將v$version fixture升級為canonical v6', () async {
      final copy = await _copyFixture(version);
      final database = AppDatabase(NativeDatabase(copy));
      await database.customSelect('SELECT 1').getSingle();
      await database.close();

      final reopened = await databaseFactoryFfi.openDatabase(
        copy.path,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      addTearDown(reopened.close);
      final report = await DatabaseSchemaReport.capture(reopened);

      expect(report.value['userVersion'], 6);
      expect(report.value['foreignKeyCheck'], isEmpty);
      expect(
        (report.value['master']! as List<Object?>)
            .whereType<Map<String, Object?>>()
            .map((row) => row['name']),
        contains('catalog_cache_page_item_position_idx'),
      );

      final authRows = await reopened.query('auth_user');
      expect(authRows, version == 1 ? isEmpty : hasLength(1));
      if (version == 2 || version == 5) {
        expect(
          await reopened.query(
            'catalog_cache_page_item',
            where: 'query = ?',
            whereArgs: const <Object?>['orphan'],
          ),
          isEmpty,
        );
      }
    });
  }

  test('migration failure不會留下partial schema或推進user_version', () async {
    final copy = await _copyFixture(2);
    final database = AppDatabase(
      NativeDatabase(copy),
      migrationFailureInjector: (completedVersion) {
        if (completedVersion == 3) {
          throw StateError('injected migration failure');
        }
      },
    );

    await expectLater(
      database.customSelect('SELECT 1').getSingle(),
      throwsA(isA<StateError>()),
    );
    await database.close();

    final reopened = await databaseFactoryFfi.openDatabase(
      copy.path,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(reopened.close);
    expect(
      (await reopened.rawQuery('PRAGMA user_version')).single.values.single,
      2,
    );
    final indexes = await reopened.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );
    expect(
      indexes.map((row) => row['name']),
      contains('catalog_cache_page_item_order_idx'),
    );
    expect(
      indexes.map((row) => row['name']),
      isNot(contains('catalog_cache_page_item_position_idx')),
    );
  });
}

Future<File> _copyFixture(int version) async {
  final temporary = await Directory.systemTemp.createTemp('drift-v$version-');
  addTearDown(() => temporary.delete(recursive: true));
  return copyDatabaseFixture(
    fixturePath: appTestPath(
      p.join('app', 'database', 'fixtures', 'v$version.db'),
    ),
    destinationDirectory: temporary,
  );
}
