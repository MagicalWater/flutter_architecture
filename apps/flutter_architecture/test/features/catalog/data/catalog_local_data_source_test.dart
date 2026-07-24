import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:drift/drift.dart' show Table, TableInfo, Variable;
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart'
    as drift_db;
import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_cache_page_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late drift_db.AppDatabase database;
  late DriftCatalogCacheDao dao;
  late CatalogLocalDataSource dataSource;

  setUp(() async {
    database = drift_db.AppDatabase.forTesting(NativeDatabase.memory());
    dao = DriftCatalogCacheDao(database);
    dataSource = CatalogLocalDataSource(dao);
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
      throwsArgumentError,
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
      throwsStateError,
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
      throwsArgumentError,
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
      throwsArgumentError,
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
    final pageRows = await dao.query('catalog_cache_page');
    final itemRows = await dao.query('catalog_cache_page_item');

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
    await database.customUpdate(
      "UPDATE catalog_cache_page_item SET item_name = '   '",
      updates: <TableInfo<Table, Object?>>{database.catalogCachePageItem},
    );

    final cached = await _read(dataSource, '', null, 20, now);
    expect(cached, isNull);
    expect(await dao.query('catalog_cache_page'), isEmpty);
    expect(await dao.query('catalog_cache_page_item'), isEmpty);
  });

  test('persisted row 型別損壞會刪除 page 並視為 cache miss', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: '', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await database.customUpdate(
      'UPDATE catalog_cache_page SET updated_at = ?',
      variables: <Variable<Object>>[const Variable<Object>('invalid')],
      updates: <TableInfo<Table, Object?>>{database.catalogCachePage},
    );

    final cached = await _read(dataSource, '', null, 20, now);

    expect(cached, isNull);
    expect(await dao.query('catalog_cache_page'), isEmpty);
    expect(await dao.query('catalog_cache_page_item'), isEmpty);
  });

  test('第一頁舊 chain revision 損壞時 replacement 會重建該 chain', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: 'cursor-1', updatedAt: now),
      resetFollowingPages: false,
    );
    await _corruptPage(database, column: 'chain_revision', value: 'invalid');

    final revision = await dataSource.replacePage(
      _page(
        query: 'flutter',
        cursor: null,
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
      resetFollowingPages: true,
    );

    expect(revision, 1);
    expect(await _read(dataSource, 'flutter', null, 20, now), isNotNull);
    expect(await _read(dataSource, 'flutter', 'cursor-1', 20, now), isNull);
  });

  test('readLinkedChainRevision 遇到損壞 revision 會清除 chain 並回 null', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await _corruptPage(database, column: 'chain_revision', value: 'invalid');

    final revision = await dataSource.readLinkedChainRevision(
      query: 'flutter',
      cursor: 'cursor-next',
      limit: 20,
    );

    expect(revision, isNull);
    expect(await _read(dataSource, 'flutter', null, 20, now), isNull);
  });

  test('Append chain revision 損壞時拒絕寫入並清除 chain', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await _corruptPage(database, column: 'chain_revision', value: 'invalid');

    final written = await dataSource.replaceAppendPageIfLinked(
      CatalogCachePageEntity(
        query: 'flutter',
        requestCursor: 'cursor-next',
        requestLimit: 20,
        nextCursor: 'cursor-after',
        updatedAt: now,
        items: const <CatalogCacheItemEntity>[],
      ),
    );

    expect(written, isFalse);
    expect(await _read(dataSource, 'flutter', null, 20, now), isNull);
    expect(await _read(dataSource, 'flutter', 'cursor-next', 20, now), isNull);
  });

  test('Append next cursor 型別損壞時拒絕寫入並清除 chain', () async {
    final now = DateTime.utc(2026, 7, 17);
    await dataSource.replacePage(
      _page(query: 'flutter', cursor: null, updatedAt: now),
      resetFollowingPages: true,
    );
    await _corruptPage(
      database,
      column: 'next_cursor',
      value: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final written = await dataSource.replaceAppendPageIfLinked(
      CatalogCachePageEntity(
        query: 'flutter',
        requestCursor: 'cursor-next',
        requestLimit: 20,
        nextCursor: 'cursor-after',
        updatedAt: now,
        items: const <CatalogCacheItemEntity>[],
      ),
    );

    expect(written, isFalse);
    expect(await _read(dataSource, 'flutter', null, 20, now), isNull);
  });

  test('unknown TypeError 不會被映射為 localStorage 或 corruption', () async {
    final error = TypeError();
    final source = CatalogLocalDataSource(_ThrowingCatalogCacheDao(error));

    await expectLater(
      source.readPage(
        query: '',
        cursor: null,
        limit: 20,
        now: DateTime.utc(2026, 7, 17),
        retainFor: const Duration(days: 7),
      ),
      throwsA(same(error)),
    );
  });

  test('readPage SQLite failure 會映射為 AppException', () async {
    final source = CatalogLocalDataSource(
      _ThrowingCatalogCacheDao(
        const CatalogCacheDaoException('database unavailable'),
      ),
    );

    await expectLater(
      source.readPage(
        query: '',
        cursor: null,
        limit: 20,
        now: DateTime.utc(2026, 7, 17),
        retainFor: const Duration(days: 7),
      ),
      throwsA(
        isA<AppException>()
            .having((error) => error.message, 'message', '讀取 Catalog Cache 失敗')
            .having(
              (error) => (error.cause! as CatalogCacheFailureDetails).operation,
              'operation',
              CatalogCacheOperation.readPage,
            )
            .having(
              (error) =>
                  (error.cause! as CatalogCacheFailureDetails).isQueryEmpty,
              'isQueryEmpty',
              isTrue,
            )
            .having(
              (error) => (error.cause! as CatalogCacheFailureDetails).hasCursor,
              'hasCursor',
              isFalse,
            )
            .having(
              (error) => (error.cause! as CatalogCacheFailureDetails).limit,
              'limit',
              20,
            ),
      ),
    );
  });

  test('Cache diagnostic 不展開 query cursor 或原始 SQLite error', () {
    final details = CatalogCacheFailureDetails(
      operation: CatalogCacheOperation.writeAppendPage,
      isQueryEmpty: false,
      hasCursor: true,
      limit: 20,
      originalError: StateError('sensitive raw sqlite context'),
    );

    final text = details.toString();

    expect(text, contains('writeAppendPage'));
    expect(text, contains('hasCursor: true'));
    expect(text, isNot(contains('sensitive raw sqlite context')));
    expect(text, isNot(contains('cursor-token')));
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
}

final class _ThrowingCatalogCacheDao implements CatalogCacheDao {
  _ThrowingCatalogCacheDao(this.error);

  final Object error;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw error;
  }
}

Future<void> _corruptPage(
  drift_db.AppDatabase database, {
  required String column,
  required Object value,
}) {
  if (column != 'chain_revision' && column != 'next_cursor') {
    throw ArgumentError.value(column, 'column');
  }
  return database
      .customUpdate(
        'UPDATE catalog_cache_page SET $column = ? '
        'WHERE query = ? AND request_cursor = ? AND request_limit = ?',
        variables: <Variable<Object>>[
          Variable<Object>(value),
          const Variable<Object>('flutter'),
          const Variable<Object>(''),
          const Variable<Object>(20),
        ],
        updates: <TableInfo<Table, Object?>>{database.catalogCachePage},
      )
      .then((_) {});
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
