import '../../support/historical_sqflite_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('v1 到目前版本 migration 會保留 auth_user 並建立 Cache tables', () async {
    final path = await databaseFactoryFfi.getDatabasesPath();
    final databasePath = '$path/catalog-migration-test.db';
    await databaseFactoryFfi.deleteDatabase(databasePath);

    final version1 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => db.execute('''
          CREATE TABLE auth_user (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        '''),
      ),
    );
    await version1.insert('auth_user', <String, Object?>{
      'id': 'user-1',
      'name': 'User',
    });
    await version1.close();

    final version2 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );

    expect(await version2.query('auth_user'), hasLength(1));
    expect(
      await version2.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        <Object?>['catalog_cache_page'],
      ),
      hasLength(1),
    );
    expect(
      await version2.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        <Object?>['catalog_cache_page_item'],
      ),
      hasLength(1),
    );

    await version2.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
  });

  test('v2 到 v3 migration 會把 item position index 升級為 unique', () async {
    final path = await databaseFactoryFfi.getDatabasesPath();
    final databasePath = '$path/catalog-v2-v3-migration-test.db';
    await databaseFactoryFfi.deleteDatabase(databasePath);

    final version2 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await AppDatabaseSchema.onCreate(db, version);
          await db.execute('DROP INDEX catalog_cache_page_item_position_idx');
          await db.execute('''
            CREATE INDEX catalog_cache_page_item_order_idx
            ON catalog_cache_page_item (
              query,
              request_cursor,
              request_limit,
              item_position
            )
          ''');
        },
      ),
    );
    await version2.close();

    final version3 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    final indexes = await version3.rawQuery(
      "PRAGMA index_list('catalog_cache_page_item')",
    );

    expect(
      indexes.any(
        (row) =>
            row['name'] == 'catalog_cache_page_item_position_idx' &&
            row['unique'] == 1,
      ),
      isTrue,
    );

    await version3.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
  });

  test('v3 到 v4 migration 會保留 page 並加入 chain revision', () async {
    final path = await databaseFactoryFfi.getDatabasesPath();
    final databasePath = '$path/catalog-v3-v4-migration-test.db';
    await databaseFactoryFfi.deleteDatabase(databasePath);

    final version3 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE catalog_cache_page (
              query TEXT NOT NULL,
              request_cursor TEXT NOT NULL,
              request_limit INTEGER NOT NULL,
              next_cursor TEXT,
              updated_at INTEGER NOT NULL,
              PRIMARY KEY (query, request_cursor, request_limit)
            )
          ''');
        },
      ),
    );
    await version3.insert('catalog_cache_page', <String, Object?>{
      'query': 'flutter',
      'request_cursor': '',
      'request_limit': 20,
      'next_cursor': 'cursor-1',
      'updated_at': DateTime.utc(2026, 7, 17).millisecondsSinceEpoch,
    });
    await version3.close();

    final version4 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    final columns = await version4.rawQuery(
      "PRAGMA table_info('catalog_cache_page')",
    );
    final rows = await version4.query('catalog_cache_page');

    expect(columns.any((row) => row['name'] == 'chain_revision'), isTrue);
    expect(rows.single['chain_revision'], 0);
    expect(rows.single['next_cursor'], 'cursor-1');

    await version4.close();
    await databaseFactoryFfi.deleteDatabase(databasePath);
  });
}
