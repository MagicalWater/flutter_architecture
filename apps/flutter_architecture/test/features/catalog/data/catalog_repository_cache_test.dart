import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import '../../../support/historical_sqflite_catalog_cache_dao.dart';
import '../../../support/historical_sqflite_schema.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_diagnostic_sink.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_cache_page_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
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
    local = CatalogLocalDataSource(SqfliteCatalogCacheDao(database));
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
        error: const AppException(
          kind: AppExceptionKind.transport,
          message: 'down',
          transportKind: TransportExceptionKind.response,
          httpStatus: 503,
        ),
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

  test('Refresh chain reset 後，較晚完成的舊 Append 不得寫回 Cache', () async {
    await _write(local, clock.nowUtc(), nextCursor: 'cursor-old');
    final api = _ControlledCatalogApi();
    final repository = _repository(api, local, clock);

    final appendFuture = repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-old',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;
    await api.waitForRequestCount(1);

    final refreshFuture = repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .single;
    await api.waitForRequestCount(2);

    api.complete(
      1,
      const CatalogPageResponseDto(
        items: <CatalogItemDto>[
          CatalogItemDto(id: 'fresh', name: 'Fresh', description: ''),
        ],
        nextCursor: 'cursor-new',
      ),
    );
    await refreshFuture;

    api.complete(
      0,
      const CatalogPageResponseDto(
        items: <CatalogItemDto>[
          CatalogItemDto(id: 'stale', name: 'Stale', description: ''),
        ],
        nextCursor: 'cursor-stale-next',
      ),
    );
    await appendFuture;

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
  });

  test('Refresh 重用相同 cursor 時，舊 Append 仍不得寫入新 revision', () async {
    await _write(local, clock.nowUtc(), nextCursor: 'cursor-same');
    final api = _ControlledCatalogApi();
    final repository = _repository(api, local, clock);

    final appendFuture = repository
        .watchCatalog(
          query: 'flutter',
          cursor: 'cursor-same',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;
    await api.waitForRequestCount(1);

    final refreshFuture = repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .single;
    await api.waitForRequestCount(2);

    api.complete(
      1,
      const CatalogPageResponseDto(
        items: <CatalogItemDto>[
          CatalogItemDto(id: 'fresh', name: 'Fresh', description: ''),
        ],
        nextCursor: 'cursor-same',
      ),
    );
    await refreshFuture;

    api.complete(
      0,
      const CatalogPageResponseDto(
        items: <CatalogItemDto>[
          CatalogItemDto(id: 'stale', name: 'Stale', description: ''),
        ],
        nextCursor: 'cursor-next',
      ),
    );
    await appendFuture;

    expect(
      await local.readPage(
        query: 'flutter',
        cursor: 'cursor-same',
        limit: 20,
        now: clock.nowUtc(),
        retainFor: const Duration(days: 7),
      ),
      isNull,
    );
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
    await _write(local, clock.nowUtc(), nextCursor: 'cursor-1');
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
    await _write(local, clock.nowUtc(), nextCursor: 'cursor-1');
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

  test(
    'expired Append predecessor 可在 retained successor 存在時 replacement',
    () async {
      await _write(local, clock.nowUtc(), nextCursor: 'cursor-1');
      final revision = await local.readLinkedChainRevision(
        query: 'flutter',
        cursor: 'cursor-1',
        limit: 20,
      );
      await local.replaceAppendPageIfLinked(
        const CatalogPage(items: [], nextCursor: 'cursor-2').toCacheEntity(
          query: 'flutter',
          requestCursor: 'cursor-1',
          requestLimit: 20,
          updatedAt: DateTime.utc(2026, 7, 9),
          chainRevision: revision!,
        ),
        expectedChainRevision: revision,
      );
      await local.replaceAppendPageIfLinked(
        const CatalogPage(items: [], nextCursor: null).toCacheEntity(
          query: 'flutter',
          requestCursor: 'cursor-2',
          requestLimit: 20,
          updatedAt: DateTime.utc(2026, 7, 17),
          chainRevision: revision,
        ),
        expectedChainRevision: revision,
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
      expect(
        await local.readPage(
          query: 'flutter',
          cursor: 'cursor-1',
          limit: 20,
          now: clock.nowUtc(),
          retainFor: const Duration(days: 7),
        ),
        isNotNull,
      );
      expect(
        await local.readPage(
          query: 'flutter',
          cursor: 'cursor-2',
          limit: 20,
          now: clock.nowUtc(),
          retainFor: const Duration(days: 7),
        ),
        isNotNull,
      );
    },
  );

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

  test('Cache read 非 localStorage AppException 不會被降級成 Cache miss', () async {
    final error = AppException(
      kind: AppExceptionKind.protocol,
      message: 'cache read contract violation',
      stackTrace: StackTrace.current,
    );
    final repository = _repository(
      _RecordingCatalogApi(),
      _ThrowingCatalogLocalDataSource(
        SqfliteCatalogCacheDao(database),
        readPageError: error,
      ),
      clock,
    );

    await expectLater(
      repository.watchCatalog(
        query: '',
        cursor: null,
        limit: 20,
        policy: CatalogLoadPolicy.initial,
      ),
      emitsError(same(error)),
    );
  });

  test('Chain revision 非 localStorage AppException 不會被降級成 null', () async {
    final error = AppException(
      kind: AppExceptionKind.dataCorruption,
      message: 'chain revision corruption escaped repair',
      stackTrace: StackTrace.current,
    );
    final repository = _repository(
      _RecordingCatalogApi(),
      _ThrowingCatalogLocalDataSource(
        SqfliteCatalogCacheDao(database),
        readLinkedChainRevisionError: error,
      ),
      clock,
    );

    await expectLater(
      repository.watchCatalog(
        query: '',
        cursor: 'cursor-1',
        limit: 20,
        policy: CatalogLoadPolicy.append,
      ),
      emitsError(same(error)),
    );
  });

  test(
    'Cache write 非 localStorage AppException 不會被 Remote success 掩蓋',
    () async {
      final error = AppException(
        kind: AppExceptionKind.protocol,
        message: 'cache write contract violation',
        stackTrace: StackTrace.current,
      );
      final repository = _repository(
        _RecordingCatalogApi(),
        _ThrowingCatalogLocalDataSource(
          SqfliteCatalogCacheDao(database),
          replacePageError: error,
        ),
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
    },
  );

  test('Cache unknown error 維持 Stream error channel', () async {
    final error = StateError('cache implementation bug');
    final repository = _repository(
      _RecordingCatalogApi(),
      _ThrowingCatalogLocalDataSource(
        SqfliteCatalogCacheDao(database),
        readPageError: error,
      ),
      clock,
    );

    await expectLater(
      repository.watchCatalog(
        query: '',
        cursor: null,
        limit: 20,
        policy: CatalogLoadPolicy.initial,
      ),
      emitsError(same(error)),
    );
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

  test('Cache localStorage fallback 會在吸收前送入 diagnostic sink', () async {
    final error = AppException(
      kind: AppExceptionKind.localStorage,
      message: 'cache unavailable',
      stackTrace: StackTrace.current,
      cause: const CatalogCacheFailureDetails(
        operation: CatalogCacheOperation.readPage,
        isQueryEmpty: true,
        hasCursor: false,
        limit: 20,
        originalError: 'database unavailable',
      ),
    );
    final sink = _RecordingCatalogCacheDiagnosticSink();
    final repository = _repository(
      _RecordingCatalogApi(),
      _ThrowingCatalogLocalDataSource(
        SqfliteCatalogCacheDao(database),
        readPageError: error,
      ),
      clock,
      diagnosticSink: sink,
    );

    final results = await repository
        .watchCatalog(
          query: '',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.initial,
        )
        .toList();

    expect(results, hasLength(1));
    expect(sink.errors, <AppException>[error]);
    expect(sink.stackTraces, hasLength(1));
    expect(sink.operations, <CatalogCacheOperation>[
      CatalogCacheOperation.readPage,
    ]);
  });

  test(
    'Diagnostic sink failure does not block cache miss remote fallback',
    () async {
      final error = AppException(
        kind: AppExceptionKind.localStorage,
        message: 'cache unavailable',
        cause: const CatalogCacheFailureDetails(
          operation: CatalogCacheOperation.readPage,
          isQueryEmpty: true,
          hasCursor: false,
          limit: 20,
          originalError: 'database unavailable',
        ),
      );
      final repository = _repository(
        _RecordingCatalogApi(),
        _ThrowingCatalogLocalDataSource(
          SqfliteCatalogCacheDao(database),
          readPageError: error,
        ),
        clock,
        diagnosticSink: const _ThrowingCatalogCacheDiagnosticSink(),
      );

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
    },
  );
}

CatalogRepositoryImpl _repository(
  CatalogApi api,
  CatalogLocalDataSource local,
  CatalogClock clock, {
  CatalogCacheDiagnosticSink diagnosticSink =
      const NoopCatalogCacheDiagnosticSink(),
}) {
  return CatalogRepositoryImpl(
    CatalogRemoteDataSource(api),
    local,
    CatalogCachePolicy(),
    clock,
    diagnosticSink,
  );
}

Future<void> _write(
  CatalogLocalDataSource local,
  DateTime updatedAt, {
  String? cursor,
  String? nextCursor = 'cursor-next',
}) {
  final page = CatalogPage(items: const [], nextCursor: nextCursor);
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

class _ControlledCatalogApi implements CatalogApi {
  final List<Completer<CatalogPageResponseDto>> _completers =
      <Completer<CatalogPageResponseDto>>[];

  @override
  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    String? cursor,
    required int limit,
  }) {
    final completer = Completer<CatalogPageResponseDto>();
    _completers.add(completer);
    return completer.future;
  }

  Future<void> waitForRequestCount(int count) async {
    final deadline = DateTime.now().add(const Duration(seconds: 1));
    while (_completers.length < count) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for API request');
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  void complete(int index, CatalogPageResponseDto response) {
    _completers[index].complete(response);
  }
}

class _ThrowingCatalogLocalDataSource extends CatalogLocalDataSource {
  _ThrowingCatalogLocalDataSource(
    super.dao, {
    this.readPageError,
    this.readLinkedChainRevisionError,
    this.replacePageError,
  });

  final Object? readPageError;
  final Object? readLinkedChainRevisionError;
  final Object? replacePageError;

  @override
  Future<CatalogCachePageEntity?> readPage({
    required String query,
    required String? cursor,
    required int limit,
    required DateTime now,
    required Duration retainFor,
  }) async {
    final error = readPageError;
    if (error != null) throw error;
    return super.readPage(
      query: query,
      cursor: cursor,
      limit: limit,
      now: now,
      retainFor: retainFor,
    );
  }

  @override
  Future<int?> readLinkedChainRevision({
    required String query,
    required String cursor,
    required int limit,
  }) async {
    final error = readLinkedChainRevisionError;
    if (error != null) throw error;
    return super.readLinkedChainRevision(
      query: query,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<int> replacePage(
    CatalogCachePageEntity page, {
    required bool resetFollowingPages,
  }) async {
    final error = replacePageError;
    if (error != null) throw error;
    return super.replacePage(page, resetFollowingPages: resetFollowingPages);
  }
}

final class _RecordingCatalogCacheDiagnosticSink
    implements CatalogCacheDiagnosticSink {
  final List<AppException> errors = <AppException>[];
  final List<StackTrace> stackTraces = <StackTrace>[];
  final List<CatalogCacheOperation> operations = <CatalogCacheOperation>[];

  @override
  void report({
    required AppException error,
    required StackTrace stackTrace,
    required CatalogCacheOperation operation,
  }) {
    errors.add(error);
    stackTraces.add(stackTrace);
    operations.add(operation);
  }
}

final class _ThrowingCatalogCacheDiagnosticSink
    implements CatalogCacheDiagnosticSink {
  const _ThrowingCatalogCacheDiagnosticSink();

  @override
  void report({
    required AppException error,
    required StackTrace stackTrace,
    required CatalogCacheOperation operation,
  }) {
    throw StateError('diagnostic sink failed');
  }
}
