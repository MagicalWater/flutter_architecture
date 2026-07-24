import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fresh Drift database建立與legacy v6等價的schema', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data.values.single, 6);

    final tables = await database.customSelect('''
      SELECT name FROM sqlite_master
      WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''').get();
    expect(tables.map((row) => row.read<String>('name')), <String>[
      'auth_user',
      'catalog_cache_page',
      'catalog_cache_page_item',
    ]);

    final indexes = await database.customSelect('''
      SELECT name FROM sqlite_master
      WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''').get();
    expect(indexes.map((row) => row.read<String>('name')), <String>[
      'catalog_cache_page_item_position_idx',
    ]);
  });

  test('fresh Drift schema保留check、composite FK與cascade', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await expectLater(
      database.customStatement(
        "INSERT INTO auth_user(slot, id, name) VALUES (2, 'x', 'X')",
      ),
      throwsA(anything),
    );

    await database.customStatement('''
      INSERT INTO catalog_cache_page(
        query, request_cursor, request_limit, next_cursor,
        updated_at, chain_revision
      ) VALUES ('flutter', '', 20, NULL, 1, 0)
    ''');
    await database.customStatement('''
      INSERT INTO catalog_cache_page_item(
        query, request_cursor, request_limit, item_id,
        item_position, item_name, item_description
      ) VALUES ('flutter', '', 20, 'item-1', 0, 'Item', 'Description')
    ''');
    await database.customStatement('''
      DELETE FROM catalog_cache_page
      WHERE query = 'flutter' AND request_cursor = '' AND request_limit = 20
    ''');

    final items = await database
        .customSelect('SELECT * FROM catalog_cache_page_item')
        .get();
    expect(items, isEmpty);
  });
}
