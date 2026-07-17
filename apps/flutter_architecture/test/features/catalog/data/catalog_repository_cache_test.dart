import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_cache_page_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late CatalogLocalDataSource local;
  late _FixedCatalogClock clock;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    local = CatalogLocalDataSource(database);
    clock = _FixedCatalogClock(DateTime.utc(2026, 7, 17, 12));
  });

  tearDown(() async {
    if (database.isOpen) {
      await database.close();
    }
  });

  test('initial Fresh Cache 只 emit Cache，且不呼叫 Remote', () async {
    await _write(local, clock.nowUtc().subtract(const Duration(minutes: 1)));
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: ' flutter ',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(1));
    final snapshot = _success(results.single);
    expect(snapshot.source, CatalogDataSource.cache);
    expect(snapshot.freshness, CatalogFreshness.fresh);
    expect(api.callCount, 0);
  });

  test('age 等於 freshFor 時仍為 Fresh', () async {
    await _write(local, clock.nowUtc().subtract(const Duration(minutes: 5)));
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).freshness, CatalogFreshness.fresh);
    expect(api.callCount, 0);
  });

  test('age 超過 freshFor 時為 Stale 並 revalidate', () async {
    await _write(
      local,
      clock.nowUtc().subtract(const Duration(minutes: 5, milliseconds: 1)),
    );
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(2));
    expect(_success(results.first).freshness, CatalogFreshness.stale);
    expect(api.callCount, 1);
  });

  test('未來 updatedAt 不會被視為 Fresh-only', () async {
    await _write(local, clock.nowUtc().add(const Duration(minutes: 1)));
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(2));
    expect(_success(results.first).freshness, CatalogFreshness.stale);
    expect(_success(results.last).source, CatalogDataSource.remote);
  });

  test('initial Stale Cache 先 emit Cache，再 emit Remote fresh', () async {
    await _write(local, clock.nowUtc().subtract(const Duration(hours: 1)));
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(2));
    expect(_success(results.first).source, CatalogDataSource.cache);
    expect(_success(results.first).freshness, CatalogFreshness.stale);
    expect(_success(results.last).source, CatalogDataSource.remote);
    expect(api.callCount, 1);
  });

  test('initial Stale Cache + Remote failure 先 success 再 failure', () async {
    await _write(local, clock.nowUtc().subtract(const Duration(hours: 1)));
    final repository = _repository(
      _RecordingCatalogApi(
        error: const AppException(message: 'down', code: '503'),
      ),
      local,
      clock,
    );

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(2));
    expect(results.first, isA<Success<CatalogPageSnapshot>>());
    expect(results.last, isA<FailureResult<CatalogPageSnapshot>>());
  });

  test('refresh 不讀 Cache，只 emit Remote result', () async {
    await _write(local, clock.nowUtc());
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).source, CatalogDataSource.remote);
    expect(api.callCount, 1);
  });

  test('refresh Remote 第一頁會替換第一頁並失效舊後續 cursor chain', () async {
    await _write(local, clock.nowUtc(), cursor: 'cursor-old');
    final repository = _repository(
      _RecordingCatalogApi(nextCursor: 'cursor-new'),
      local,
      clock,
    );

    final result = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .single;

    expect(_success(result).page.nextCursor, 'cursor-new');
    expect(
      await local.readPage(
        query: 'flutter',
        cursor: 'cursor-old',
        limit: 20,
        now: clock.nowUtc(),
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
    final firstPage = await local.readPage(
      query: 'flutter',
      cursor: null,
      limit: 20,
      now: clock.nowUtc(),
      retainFor: const Duration(days: 7),
    );
    expect(firstPage?.nextCursor, 'cursor-new');
    expect(firstPage?.items.single.id, 'remote');
  });

  test('append retained Cache 即使 stale 也只 emit 一次 Cache', () async {
    await _write(
      local,
      clock.nowUtc().subtract(const Duration(hours: 1)),
      cursor: 'cursor-1',
    );
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-1',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).source, CatalogDataSource.cache);
    expect(api.callCount, 0);
  });

  test('append Cache miss 會走 Remote 並以 requested cursor identity 寫入', () async {
    final api = _RecordingCatalogApi(nextCursor: 'cursor-2');
    final repository = _repository(api, local, clock);

    final first = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-1',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;
    expect(_success(first).source, CatalogDataSource.remote);
    expect(api.callCount, 1);

    final second = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-1',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;
    expect(_success(second).source, CatalogDataSource.cache);
    expect(_success(second).page.nextCursor, 'cursor-2');
    expect(api.callCount, 1);
  });

  test('append expired page 會刪除舊 Cache 並以 Remote replacement 更新', () async {
    await _write(
      local,
      clock.nowUtc().subtract(const Duration(days: 8)),
      cursor: 'cursor-1',
    );
    final repository = _repository(
      _RecordingCatalogApi(nextCursor: 'cursor-2'),
      local,
      clock,
    );

    final result = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-1',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;

    expect(_success(result).source, CatalogDataSource.remote);
    final cached = await local.readPage(
      query: 'flutter',
      cursor: 'cursor-1',
      limit: 20,
      now: clock.nowUtc(),
      retainFor: const Duration(days: 7),
    );
    expect(cached?.nextCursor, 'cursor-2');
    expect(cached?.items.single.id, 'remote');
  });

  test('expired Cache 視為 miss 並改走 Remote', () async {
    await _write(local, clock.nowUtc().subtract(const Duration(days: 8)));
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).source, CatalogDataSource.remote);
  });

  test('age 等於 retainFor 時仍可使用 Cache', () async {
    await _write(
      local,
      clock.nowUtc().subtract(const Duration(days: 7)),
      cursor: 'cursor-1',
    );
    final api = _RecordingCatalogApi();
    final repository = _repository(api, local, clock);

    final results = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-1',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).source, CatalogDataSource.cache);
    expect(api.callCount, 0);
  });

  test('Cache read/write failure 不阻止 Remote success', () async {
    await database.close();
    final repository = _repository(_RecordingCatalogApi(), local, clock);

    final results = await repository
        .watchCatalog(
          query: '',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).source, CatalogDataSource.remote);
  });

  test('Cache write failure 不阻止 refresh Remote success', () async {
    await database.close();
    final repository = _repository(_RecordingCatalogApi(), local, clock);

    final results = await repository
        .watchCatalog(
          query: '',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .toList();

    expect(results, hasLength(1));
    expect(_success(results.single).source, CatalogDataSource.remote);
  });

  test('policy 與 cursor 不合法時 fail fast', () async {
    final repository = _repository(_RecordingCatalogApi(), local, clock);

    await expectLater(
      repository
          .watchCatalog(
            query: '',
            cursor: 'cursor-1',
            limit: 20,
            policy: CatalogLoadPolicy.initial,
          )
          .toList(),
      throwsArgumentError,
    );
    await expectLater(
      repository
          .watchCatalog(
            query: '',
            cursor: '   ',
            limit: 20,
            policy: CatalogLoadPolicy.append,
          )
          .toList(),
      throwsArgumentError,
    );
    await expectLater(
      repository
          .watchCatalog(
            query: '',
            cursor: null,
            limit: 20,
            policy: CatalogLoadPolicy.append,
          )
          .toList(),
      throwsArgumentError,
    );
  });

  test('Remote non-advancing cursor 不寫入 Cache', () async {
    final repository = _repository(
      _RecordingCatalogApi(nextCursor: 'cursor-1'),
      local,
      clock,
    );

    final result = await repository
        .watchCatalog(
          query: '',
          cursor: 'cursor-1',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;

    expect(result, isA<FailureResult<CatalogPageSnapshot>>());
    expect(
      await local.readPage(
        query: '',
        cursor: 'cursor-1',
        limit: 20,
        now: clock.nowUtc(),
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
  });

  test('未知 Remote 錯誤走 Stream error channel', () async {
    final error = StateError('bug');
    final repository = _repository(
      _RecordingCatalogApi(error: error),
      local,
      clock,
    );

    await expectLater(
      repository.watchCatalog(
        query: '',
        cursor: null,
        limit: 20,
        policy: CatalogLoadPolicy.refresh,
      ),
      emitsError(same(error)),
    );
  });
}

CatalogRepositoryImpl _repository(
  CatalogApi api,
  CatalogLocalDataSource local,
  CatalogClock clock,
) {
  return CatalogRepositoryImpl(
    CatalogRemoteDataSource(api),
    local,
    CatalogCachePolicy(),
    clock,
  );
}

Future<void> _write(
  CatalogLocalDataSource local,
  DateTime updatedAt, {
  String? cursor,
}) {
  const page = CatalogPage(items: [], nextCursor: 'cursor-next');
  return local.replacePage(
    page.toCacheEntity(
      query: 'flutter',
      requestCursor: cursor,
      requestLimit: 20,
      updatedAt: updatedAt,
    ),
    resetFollowingPages: cursor == null,
  );
}

CatalogPageSnapshot _success(Result<CatalogPageSnapshot> result) {
  return result.when(
    success: (value) => value,
    failure: (error) => throw StateError('unexpected failure: $error'),
  );
}

class _FixedCatalogClock implements CatalogClock {
  _FixedCatalogClock(this.value);

  DateTime value;

  @override
  DateTime nowUtc() => value;
}

class _RecordingCatalogApi implements CatalogApi {
  _RecordingCatalogApi({this.error, this.nextCursor = 'cursor-next'});

  final Object? error;
  final String? nextCursor;
  int callCount = 0;

  @override
  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    String? cursor,
    required int limit,
  }) async {
    callCount++;
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return CatalogPageResponseDto(
      items: const <CatalogItemDto>[
        CatalogItemDto(id: 'remote', name: 'Remote', description: 'fresh'),
      ],
      nextCursor: nextCursor,
    );
  }
}
