import 'package:core/core.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_cache_page_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late CatalogLocalDataSource dataSource;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    dataSource = CatalogLocalDataSource(database);
  });

  tearDown(() => database.close());

  test('Local mapper 保留 item 順序與完整欄位', () {
    const page = CatalogPage(
      items: <CatalogItem>[
        CatalogItem(id: '2', name: 'Second', description: 'description-2'),
        CatalogItem(id: '1', name: 'First', description: 'description-1'),
      ],
      nextCursor: 'cursor-2',
    );

    final entity = page.toCacheEntity(
      query: ' flutter ',
      requestCursor: null,
      requestLimit: 20,
      updatedAt: DateTime.utc(2026, 7, 17, 1),
    );
    final restored = entity.toDomain();

    expect(entity.query, 'flutter');
    expect(entity.updatedAt.isUtc, isTrue);
    expect(restored, page);
  });

  test('第一頁 null cursor 會在 Local boundary 正確 round-trip', () async {
    final updatedAt = DateTime.utc(2026, 7, 17, 1);
    await dataSource.replacePage(
      _page(query: ' flutter ', cursor: null, updatedAt: updatedAt),
      resetFollowingPages: true,
    );

    final cached = await dataSource.readPage(
      query: 'flutter',
      cursor: null,
      limit: 20,
      now: updatedAt.add(const Duration(minutes: 1)),
      retainFor: const Duration(days: 7),
    );

    expect(cached, isNotNull);
    expect(cached!.query, 'flutter');
    expect(cached.requestCursor, isNull);
    expect(cached.items.single.description, 'description-old');
  });

  test('Cache identity 會隔離 query 大小寫、cursor 與 limit', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'Flutter', cursor: null, limit: 20, updatedAt: now),
      resetFollowingPages: true,
    );

    expect(
      await dataSource.readPage(
        query: 'flutter',
        cursor: null,
        limit: 20,
        now: now,
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
    expect(
      await dataSource.readPage(
        query: 'Flutter',
        cursor: 'cursor-1',
        limit: 20,
        now: now,
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
    expect(
      await dataSource.readPage(
        query: 'Flutter',
        cursor: null,
        limit: 30,
        now: now,
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
  });

  test('Local boundary 拒絕空字串 cursor，避免與第一頁 sentinel 衝突', () async {
    await expectLater(
      dataSource.readPage(
        query: '',
        cursor: '   ',
        limit: 20,
        now: DateTime.utc(2026, 7, 17),
        retainFor: const Duration(days: 7),
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          'invalid_catalog_cache_cursor',
        ),
      ),
    );
  });

  test('只有第一頁 replacement 可以重設 cursor chain', () async {
    await expectLater(
      dataSource.replacePage(
        _page(
          query: '',
          cursor: 'cursor-1',
          updatedAt: DateTime.utc(2026, 7, 17),
        ),
        resetFollowingPages: true,
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          'invalid_catalog_cache_chain_reset',
        ),
      ),
    );
  });

  test('Local boundary 拒絕 requestCursor 與 nextCursor 相同的 self-loop', () async {
    final now = DateTime.utc(2026, 7, 17);
    await expectLater(
      dataSource.replacePage(
        CatalogCachePageEntity(
          query: '',
          requestCursor: 'cursor-1',
          requestLimit: 20,
          nextCursor: 'cursor-1',
          updatedAt: now,
          items: const <CatalogCacheItemEntity>[],
        ),
        resetFollowingPages: false,
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          'non_advancing_catalog_cache_cursor',
        ),
      ),
    );
  });

  test('replacement 同一 page 不會殘留舊 item', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: '', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await dataSource.replacePage(
      CatalogCachePageEntity(
        query: '',
        requestCursor: null,
        requestLimit: 20,
        nextCursor: null,
        updatedAt: now.add(const Duration(minutes: 1)),
        items: const <CatalogCacheItemEntity>[
          CatalogCacheItemEntity(
            id: 'new',
            name: 'New',
            description: 'new-description',
            position: 0,
          ),
        ],
      ),
      resetFollowingPages: true,
    );

    final cached = await dataSource.readPage(
      query: '',
      cursor: null,
      limit: 20,
      now: now.add(const Duration(minutes: 2)),
      retainFor: const Duration(days: 7),
    );

    expect(cached!.items.map((item) => item.id), <String>['new']);
    expect(cached.nextCursor, isNull);
  });

  test('empty page 可正確 round-trip', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      CatalogCachePageEntity(
        query: '',
        requestCursor: null,
        requestLimit: 20,
        nextCursor: null,
        updatedAt: now,
        items: const <CatalogCacheItemEntity>[],
      ),
      resetFollowingPages: true,
    );

    final cached = await _read(dataSource, '', null, 20, now);
    expect(cached, isNotNull);
    expect(cached!.items, isEmpty);
    expect(cached.nextCursor, isNull);
  });

  test('duplicate position 會拒絕寫入並保留舊 page', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: '', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );

    await expectLater(
      dataSource.replacePage(
        CatalogCachePageEntity(
          query: '',
          requestCursor: null,
          requestLimit: 20,
          nextCursor: null,
          updatedAt: now.add(const Duration(minutes: 1)),
          items: const <CatalogCacheItemEntity>[
            CatalogCacheItemEntity(
              id: 'one',
              name: 'One',
              description: '',
              position: 0,
            ),
            CatalogCacheItemEntity(
              id: 'two',
              name: 'Two',
              description: '',
              position: 0,
            ),
          ],
        ),
        resetFollowingPages: true,
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          'invalid_catalog_cache_item_position',
        ),
      ),
    );

    final cached = await _read(dataSource, '', null, 20, now);
    expect(cached!.items.single.id, 'item-old');
  });

  test('Remote 第一頁 replacement 可清除同 query/limit 後續 chain', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: 'cursor-1', updatedAt: now),
      resetFollowingPages: false,
    );
    await dataSource.replacePage(
      _page(query: 'other', cursor: 'cursor-1', updatedAt: now),
      resetFollowingPages: false,
    );
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: 'cursor-1', limit: 30, updatedAt: now),
      resetFollowingPages: false,
    );

    await dataSource.replacePage(
      _page(
        query: 'flutter',
        cursor: null,
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
      resetFollowingPages: true,
    );

    expect(await _read(dataSource, 'flutter', 'cursor-1', 20, now), isNull);
    expect(await _read(dataSource, 'other', 'cursor-1', 20, now), isNotNull);
    expect(await _read(dataSource, 'flutter', 'cursor-1', 30, now), isNotNull);
  });

  test('expired page 視為 miss 並刪除該 page', () async {
    final updatedAt = DateTime.utc(2026, 7, 1);
    await dataSource.replacePage(
      _page(query: '', cursor: null, updatedAt: updatedAt),
      resetFollowingPages: true,
    );

    final expired = await dataSource.readPage(
      query: '',
      cursor: null,
      limit: 20,
      now: updatedAt.add(const Duration(days: 8)),
      retainFor: const Duration(days: 7),
    );
    final pageRows = await database.query('catalog_cache_page');
    final itemRows = await database.query('catalog_cache_page_item');

    expect(expired, isNull);
    expect(pageRows, isEmpty);
    expect(itemRows, isEmpty);
  });

  test('deletePage 只刪除指定 query/cursor/limit', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: 'cursor-1', updatedAt: now),
      resetFollowingPages: false,
    );
    await dataSource.replacePage(
      _page(query: 'other', cursor: 'cursor-1', updatedAt: now),
      resetFollowingPages: false,
    );
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: 'cursor-1', limit: 30, updatedAt: now),
      resetFollowingPages: false,
    );

    await dataSource.deletePage(
      query: 'flutter',
      cursor: 'cursor-1',
      limit: 20,
    );

    expect(await _read(dataSource, 'flutter', 'cursor-1', 20, now), isNull);
    expect(await _read(dataSource, 'flutter', null, 20, now), isNotNull);
    expect(await _read(dataSource, 'other', 'cursor-1', 20, now), isNotNull);
    expect(await _read(dataSource, 'flutter', 'cursor-1', 30, now), isNotNull);
  });

  test('損壞的 local row 會刪除 page 並視為 cache miss', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: '', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await database.update('catalog_cache_page_item', <String, Object?>{
      'item_name': '   ',
    });

    final cached = await _read(dataSource, '', null, 20, now);
    expect(cached, isNull);
    expect(await database.query('catalog_cache_page'), isEmpty);
    expect(await database.query('catalog_cache_page_item'), isEmpty);
  });

  test('readPage SQLite failure 會映射為 AppException', () async {
    await database.close();

    await expectLater(
      dataSource.readPage(
        query: '',
        cursor: null,
        limit: 20,
        now: DateTime.utc(2026, 7, 17),
        retainFor: const Duration(days: 7),
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          '讀取 Catalog Cache 失敗',
        ),
      ),
    );
  });

  test('transaction 失敗時保留 replacement 前的完整 page', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: '', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );

    await expectLater(
      dataSource.replacePage(
        CatalogCachePageEntity(
          query: '',
          requestCursor: null,
          requestLimit: 20,
          nextCursor: null,
          updatedAt: now.add(const Duration(minutes: 1)),
          items: const <CatalogCacheItemEntity>[
            CatalogCacheItemEntity(
              id: 'duplicate',
              name: 'One',
              description: '',
              position: 0,
            ),
            CatalogCacheItemEntity(
              id: 'duplicate',
              name: 'Two',
              description: '',
              position: 1,
            ),
          ],
        ),
        resetFollowingPages: true,
      ),
      throwsA(isA<AppException>()),
    );

    final cached = await _read(dataSource, '', null, 20, now);
    expect(cached!.items.single.id, 'item-old');
    expect(cached.nextCursor, 'cursor-next');
  });

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
}

Future<CatalogCachePageEntity?> _read(
  CatalogLocalDataSource dataSource,
  String query,
  String? cursor,
  int limit,
  DateTime now,
) {
  return dataSource.readPage(
    query: query,
    cursor: cursor,
    limit: limit,
    now: now.add(const Duration(minutes: 1)),
    retainFor: const Duration(days: 7),
  );
}

CatalogCachePageEntity _page({
  required String query,
  required String? cursor,
  int limit = 20,
  required DateTime updatedAt,
}) {
  return CatalogCachePageEntity(
    query: query,
    requestCursor: cursor,
    requestLimit: limit,
    nextCursor: 'cursor-next',
    updatedAt: updatedAt,
    items: const <CatalogCacheItemEntity>[
      CatalogCacheItemEntity(
        id: 'item-old',
        name: 'Old',
        description: 'description-old',
        position: 0,
      ),
    ],
  );
}
