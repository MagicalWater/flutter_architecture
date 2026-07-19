import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('fresh production-style connection啟用foreign keys並執行cascade', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onConfigure: AppDatabaseSchema.onConfigure,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    addTearDown(database.close);

    expect((await database.rawQuery('PRAGMA foreign_keys')).single.values.single, 1);

    await database.insert('catalog_cache_page', _pageRow());
    await database.insert('catalog_cache_page_item', _itemRow());
    await database.delete(
      'catalog_cache_page',
      where: 'query = ? AND request_cursor = ? AND request_limit = ?',
      whereArgs: const <Object?>['flutter', '', 20],
    );

    expect(await database.query('catalog_cache_page_item'), isEmpty);
    await expectLater(
      database.insert('catalog_cache_page_item', _itemRow()),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('v5 upgrade清除existing orphan並啟用foreign keys', () async {
    final directory = await databaseFactoryFfi.getDatabasesPath();
    final path = '$directory/catalog-foreign-key-v5-upgrade.db';
    await databaseFactoryFfi.deleteDatabase(path);
    addTearDown(() => databaseFactoryFfi.deleteDatabase(path));

    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 5,
        onCreate: (database, version) async {
          await AppDatabaseSchema.onCreate(database, version);
        },
      ),
    );
    await old.insert('catalog_cache_page_item', _itemRow());
    await old.close();

    final upgraded = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onConfigure: AppDatabaseSchema.onConfigure,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    addTearDown(upgraded.close);

    expect((await upgraded.rawQuery('PRAGMA foreign_keys')).single.values.single, 1);
    expect(await upgraded.query('catalog_cache_page_item'), isEmpty);
    expect(await upgraded.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });
}

Map<String, Object?> _pageRow() => <String, Object?>{
      'query': 'flutter',
      'request_cursor': '',
      'request_limit': 20,
      'next_cursor': null,
      'updated_at': DateTime.utc(2026, 7, 20).millisecondsSinceEpoch,
      'chain_revision': 0,
    };

Map<String, Object?> _itemRow() => const <String, Object?>{
      'query': 'flutter',
      'request_cursor': '',
      'request_limit': 20,
      'item_id': 'item-1',
      'item_position': 0,
      'item_name': 'Item',
      'item_description': 'Description',
    };
