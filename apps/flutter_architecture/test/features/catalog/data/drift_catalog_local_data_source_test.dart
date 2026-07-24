import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late CatalogLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = CatalogLocalDataSource(DriftCatalogCacheDao(database));
  });

  tearDown(() => database.close());

  test('Drift round-trip保留page identity、revision與item順序', () async {
    final now = DateTime.utc(2026, 7, 24, 8);

    final revision = await dataSource.replacePage(
      _page(updatedAt: now),
      resetFollowingPages: true,
    );
    final cached = await dataSource.readPage(
      query: 'flutter',
      cursor: null,
      limit: 20,
      now: now.add(const Duration(minutes: 1)),
      retainFor: const Duration(days: 7),
    );

    expect(revision, 1);
    expect(cached, isNotNull);
    expect(cached!.chainRevision, 1);
    expect(cached.nextCursor, 'cursor-1');
    expect(cached.items.map((item) => item.id), <String>['a', 'b']);
  });

  test('Drift first-page replacement清除舊append chain並增加revision', () async {
    final now = DateTime.utc(2026, 7, 24, 8);
    final firstRevision = await dataSource.replacePage(
      _page(updatedAt: now),
      resetFollowingPages: true,
    );
    expect(
      await dataSource.replaceAppendPageIfLinked(
        _page(
          cursor: 'cursor-1',
          nextCursor: null,
          revision: firstRevision,
          updatedAt: now,
        ),
        expectedChainRevision: firstRevision,
      ),
      isTrue,
    );

    final secondRevision = await dataSource.replacePage(
      _page(nextCursor: null, updatedAt: now.add(const Duration(minutes: 1))),
      resetFollowingPages: true,
    );

    expect(secondRevision, firstRevision + 1);
    expect(
      await dataSource.readPage(
        query: 'flutter',
        cursor: 'cursor-1',
        limit: 20,
        now: now.add(const Duration(minutes: 2)),
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
  });

  test('Drift constraint failure回滾完整replacement', () async {
    final now = DateTime.utc(2026, 7, 24, 8);
    await dataSource.replacePage(
      _page(updatedAt: now),
      resetFollowingPages: true,
    );

    await expectLater(
      dataSource.replacePage(
        CatalogCachePageEntity(
          query: 'flutter',
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
      throwsA(isA<Exception>()),
    );

    final cached = await dataSource.readPage(
      query: 'flutter',
      cursor: null,
      limit: 20,
      now: now.add(const Duration(minutes: 2)),
      retainFor: const Duration(days: 7),
    );
    expect(cached!.items.map((item) => item.id), <String>['a', 'b']);
    expect(cached.chainRevision, 1);
  });
}

CatalogCachePageEntity _page({
  String? cursor,
  String? nextCursor = 'cursor-1',
  int revision = 0,
  required DateTime updatedAt,
}) {
  return CatalogCachePageEntity(
    query: 'flutter',
    requestCursor: cursor,
    requestLimit: 20,
    nextCursor: nextCursor,
    chainRevision: revision,
    updatedAt: updatedAt,
    items: const <CatalogCacheItemEntity>[
      CatalogCacheItemEntity(
        id: 'a',
        name: 'A',
        description: 'first',
        position: 0,
      ),
      CatalogCacheItemEntity(
        id: 'b',
        name: 'B',
        description: 'second',
        position: 1,
      ),
    ],
  );
}
