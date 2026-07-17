import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initial state 尚未載入時不視為 empty result', () {
    final state = CatalogState.initial();
    expect(state.isEmpty, isFalse);
    expect(state.isUsingCachedData, isFalse);
    expect(state.isStale, isFalse);
    expect(state.lastUpdatedAt, isNull);
    expect(state.isRevalidating, isFalse);
    expect(state.revalidationFailure, isNull);
  });

  test('CatalogBloc 拒絕非正數 pageSize', () {
    final repository = _CatalogRepositoryStub();

    expect(
      () => CatalogBloc(SearchCatalogUseCase(repository), pageSize: 0),
      throwsArgumentError,
    );
  });

  test('Initial request 使用空 query 載入預設 Catalog 清單', () async {
    final repository = _CatalogRepositoryStub();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await bloc.stream.firstWhere((state) => !state.isInitialLoading);

    expect(repository.requests.single.query, '');
    expect(repository.requests.single.cursor, isNull);
    expect(bloc.state.items.single.id, 'item-');

    await bloc.close();
  });

  test('快速輸入只搜尋最後一個 debounced query', () async {
    final repository = _CatalogRepositoryStub();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: const Duration(milliseconds: 20),
    );

    bloc
      ..add(const CatalogEvent.queryChanged('f'))
      ..add(const CatalogEvent.queryChanged('fl'))
      ..add(const CatalogEvent.queryChanged('flutter'));

    await _waitUntil(
      () => repository.requests.length == 1 && !bloc.state.isInitialLoading,
    );

    expect(repository.requests.map((request) => request.query), <String>[
      'flutter',
    ]);

    await bloc.close();
  });

  test('相同 normalized query 不重複搜尋', () async {
    final repository = _CatalogRepositoryStub();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.queryChanged(' flutter '));
    await bloc.stream.firstWhere((state) => !state.isInitialLoading);
    bloc.add(const CatalogEvent.queryChanged('flutter'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.requests, hasLength(1));
    expect(bloc.state.query, 'flutter');

    await bloc.close();
  });

  test('舊 query response 晚回來不覆蓋新 query', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.queryChanged('old'));
    await repository.waitForRequestCount(1);
    bloc.add(const CatalogEvent.queryChanged('new'));
    await repository.waitForRequestCount(2);

    repository.completeSuccess(1, _page('new'));
    await bloc.stream.firstWhere(
      (state) => !state.isInitialLoading && state.query == 'new',
    );
    repository.completeSuccess(0, _page('old'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.query, 'new');
    expect(bloc.state.items.single.id, 'item-new');

    await bloc.close();
  });

  test('同 query 的舊 generation 不覆蓋重新搜尋', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(2);
    await _waitUntil(() => repository.cancelledRequests.contains(0));

    repository.completeSuccess(1, _page('new-generation'));
    await bloc.stream.firstWhere((state) => !state.isInitialLoading);
    repository.completeSuccess(0, _page('old-generation'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.items.single.id, 'item-new-generation');

    await bloc.close();
  });

  test('Initial request 會在 Query switching 時取消舊 subscription', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.emitSuccess(
      0,
      _page('initial-cache'),
      source: CatalogDataSource.cache,
      freshness: CatalogFreshness.stale,
    );
    await _waitUntil(() => bloc.state.isRevalidating);

    bloc.add(const CatalogEvent.queryChanged('new'));
    await repository.waitForRequestCount(2);
    await _waitUntil(() => repository.cancelledRequests.contains(0));
    repository.completeSuccess(1, _page('new'));
    await _waitUntil(
      () => bloc.state.query == 'new' && !bloc.state.isInitialLoading,
    );

    expect(bloc.state.items.single.id, 'item-new');
    expect(bloc.state.isRevalidating, isFalse);
    await bloc.close();
  });

  test('Initial Stale Cache 先顯示並標記 revalidating，再由 Remote 替換', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    final cachedAt = DateTime.utc(2026, 7, 17, 10);
    repository.emitSuccess(
      0,
      _page('cached'),
      source: CatalogDataSource.cache,
      freshness: CatalogFreshness.stale,
      lastUpdatedAt: cachedAt,
    );
    await _waitUntil(() => bloc.state.isRevalidating);

    expect(bloc.state.items.single.id, 'item-cached');
    expect(bloc.state.isInitialLoading, isFalse);
    expect(bloc.state.isUsingCachedData, isTrue);
    expect(bloc.state.isStale, isTrue);
    expect(bloc.state.lastUpdatedAt, cachedAt);
    expect(bloc.state.revalidationFailure, isNull);

    repository.completeSuccess(0, _page('remote'));
    await _waitUntil(() => !bloc.state.isRevalidating);

    expect(bloc.state.items.single.id, 'item-remote');
    expect(bloc.state.isUsingCachedData, isFalse);
    expect(bloc.state.isStale, isFalse);
    expect(bloc.state.initialFailure, isNull);
    expect(bloc.state.revalidationFailure, isNull);
    await bloc.close();
  });

  test(
    'Initial Stale Cache revalidation failure 保留 Cache 並使用非阻斷 failure',
    () async {
      final repository = _ControlledCatalogRepository();
      final bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );

      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.emitSuccess(
        0,
        _page('cached'),
        source: CatalogDataSource.cache,
        freshness: CatalogFreshness.stale,
      );
      await _waitUntil(() => bloc.state.isRevalidating);
      repository.completeFailure(
        0,
        const Failure(message: 'revalidate failed', code: 'revalidate_failed'),
      );
      await _waitUntil(() => !bloc.state.isRevalidating);

      expect(bloc.state.items.single.id, 'item-cached');
      expect(bloc.state.isUsingCachedData, isTrue);
      expect(bloc.state.isStale, isTrue);
      expect(bloc.state.initialFailure, isNull);
      expect(bloc.state.revalidationFailure?.code, 'revalidate_failed');
      await bloc.close();
    },
  );

  test('Initial Stale Cache 後 Stream 關閉視為 protocol violation', () async {
    final repository = _ControlledCatalogRepository();
    late CatalogBloc bloc;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );
      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.emitSuccess(
        0,
        _page('cached'),
        source: CatalogDataSource.cache,
        freshness: CatalogFreshness.stale,
      );
      await _waitUntil(() => bloc.state.isRevalidating);
      await repository.closeRequest(0);
      await _waitUntil(() => !bloc.state.isRevalidating);
    }, (error, stackTrace) => errors.add(error));

    expect(errors.single, isA<StateError>());
    expect(bloc.state.items.single.id, 'item-cached');
    expect(bloc.state.isStale, isTrue);
    await bloc.close();
  });

  test('Query switching 取消舊 SWR subscription 並只接受新 query', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.queryChanged('old'));
    await repository.waitForRequestCount(1);
    repository.emitSuccess(
      0,
      _page('old-cache'),
      source: CatalogDataSource.cache,
      freshness: CatalogFreshness.stale,
    );
    await _waitUntil(() => bloc.state.isRevalidating);

    bloc.add(const CatalogEvent.queryChanged('new'));
    await repository.waitForRequestCount(2);
    await _waitUntil(() => repository.cancelledRequests.contains(0));
    repository.completeSuccess(1, _page('new'));
    await _waitUntil(
      () => bloc.state.query == 'new' && !bloc.state.isInitialLoading,
    );

    expect(bloc.state.items.single.id, 'item-new');
    expect(bloc.state.isUsingCachedData, isFalse);
    expect(bloc.state.isRevalidating, isFalse);
    await bloc.close();
  });

  test('Initial failure 與 empty result 可分開表達', () async {
    final failureRepository = _CatalogRepositoryStub(
      resultBuilder: (_) => const FailureResult<CatalogPageSnapshot>(
        Failure(message: 'initial failed', code: 'initial_failed'),
      ),
    );
    final failureBloc = CatalogBloc(
      SearchCatalogUseCase(failureRepository),
      debounceDuration: Duration.zero,
    );

    failureBloc.add(const CatalogEvent.initialRequested());
    await failureBloc.stream.firstWhere((state) => !state.isInitialLoading);

    expect(failureBloc.state.initialFailure?.code, 'initial_failed');
    expect(failureBloc.state.isEmpty, isFalse);

    final emptyRepository = _CatalogRepositoryStub(
      resultBuilder: (_) => Success<CatalogPageSnapshot>(
        _snapshot(const CatalogPage(items: <CatalogItem>[])),
      ),
    );
    final emptyBloc = CatalogBloc(
      SearchCatalogUseCase(emptyRepository),
      debounceDuration: Duration.zero,
    );

    emptyBloc.add(const CatalogEvent.initialRequested());
    await emptyBloc.stream.firstWhere((state) => !state.isInitialLoading);

    expect(emptyBloc.state.initialFailure, isNull);
    expect(emptyBloc.state.isEmpty, isTrue);

    await failureBloc.close();
    await emptyBloc.close();
  });

  test('Initial unknown error 不會卡在 initial loading', () async {
    final repository = _ControlledCatalogRepository();
    late CatalogBloc bloc;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );
      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.completeUnknown(0, StateError('initial unknown'));
      await _waitUntil(() => !bloc.state.isInitialLoading);
    }, (error, stackTrace) => errors.add(error));

    expect(errors.single, isA<StateError>());
    expect(bloc.state.isInitialLoading, isFalse);
    expect(bloc.state.hasCompletedInitialLoad, isFalse);
    expect(bloc.state.isEmpty, isFalse);
    await bloc.close();
  });

  test('連續 Load More 只送出一個 request，並使用正確 cursor', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc
      ..add(const CatalogEvent.loadMoreRequested())
      ..add(const CatalogEvent.loadMoreRequested())
      ..add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.requests, hasLength(2));
    expect(repository.requests[1].cursor, 'cursor-1');

    repository.completeSuccess(1, _page('append'));
    await _waitUntil(() => !bloc.state.isLoadingMore);
    await bloc.close();
  });

  test('Append 依穩定 ID 去重並保留既有順序', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(
      0,
      const CatalogPage(
        items: <CatalogItem>[
          CatalogItem(id: '1', name: 'old-1', description: 'old-1'),
          CatalogItem(id: '2', name: 'old-2', description: 'old-2'),
        ],
        nextCursor: 'cursor-1',
      ),
    );
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    repository.completeSuccess(
      1,
      const CatalogPage(
        items: <CatalogItem>[
          CatalogItem(id: '2', name: 'new-2', description: 'new-2'),
          CatalogItem(id: '3', name: 'new-3', description: 'new-3'),
        ],
      ),
    );
    await _waitUntil(() => !bloc.state.isLoadingMore);

    expect(bloc.state.items.map((item) => item.id), <String>['1', '2', '3']);
    expect(bloc.state.items[1].name, 'old-2');
    expect(bloc.state.hasMore, isFalse);
    await bloc.close();
  });

  test('Append Cache snapshot 不會污染第一頁 freshness metadata', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    final firstPageAt = DateTime.utc(2026, 7, 17, 12);
    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(
      0,
      _page('initial', nextCursor: 'cursor-1'),
      lastUpdatedAt: firstPageAt,
    );
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    repository.completeSuccess(
      1,
      _page('cached-append', nextCursor: 'cursor-2'),
      source: CatalogDataSource.cache,
      freshness: CatalogFreshness.stale,
      lastUpdatedAt: DateTime.utc(2026, 7, 10),
    );
    await _waitUntil(() => !bloc.state.isLoadingMore);

    expect(bloc.state.items.map((item) => item.id), <String>[
      'item-initial',
      'item-cached-append',
    ]);
    expect(bloc.state.nextCursor, 'cursor-2');
    expect(bloc.state.isUsingCachedData, isFalse);
    expect(bloc.state.isStale, isFalse);
    expect(bloc.state.lastUpdatedAt, firstPageAt);
    await bloc.close();
  });

  test('Append cursor cycle 不推進 nextCursor 並回傳 chain failure', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    repository.completeSuccess(1, _page('append-1', nextCursor: 'cursor-2'));
    await _waitUntil(() => !bloc.state.isLoadingMore);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(3);
    repository.completeSuccess(2, _page('append-2', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isLoadingMore);

    expect(bloc.state.nextCursor, 'cursor-2');
    expect(bloc.state.appendFailure?.code, 'cyclic_catalog_cursor');
    expect(bloc.state.items.map((item) => item.id), <String>[
      'item-initial',
      'item-append-1',
    ]);
    await bloc.close();
  });

  test('Append 多次 emission 視為 protocol violation 並清除 loading', () async {
    final repository = _ControlledCatalogRepository();
    late CatalogBloc bloc;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );
      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
      await _waitUntil(() => !bloc.state.isInitialLoading);

      bloc.add(const CatalogEvent.loadMoreRequested());
      await repository.waitForRequestCount(2);
      repository.emitSuccess(1, _page('append-1'));
      repository.completeSuccess(1, _page('append-2'));
      await _waitUntil(() => !bloc.state.isLoadingMore);
    }, (error, stackTrace) => errors.add(error));

    expect(errors.single, isA<StateError>());
    expect(bloc.state.items.single.id, 'item-initial');
    await bloc.close();
  });

  test('Append failure 保留 items 與 cursor，並允許 retry', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    repository.completeFailure(
      1,
      const Failure(message: 'append failed', code: 'append_failed'),
    );
    await _waitUntil(() => !bloc.state.isLoadingMore);

    expect(bloc.state.items.single.id, 'item-initial');
    expect(bloc.state.nextCursor, 'cursor-1');
    expect(bloc.state.appendFailure?.code, 'append_failed');

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(3);
    expect(repository.requests[2].cursor, 'cursor-1');
    repository.completeSuccess(2, _page('retry'));
    await _waitUntil(() => !bloc.state.isLoadingMore);
    expect(bloc.state.appendFailure, isNull);
    await bloc.close();
  });

  test('Append unknown error 不會卡住，並允許 retry', () async {
    final repository = _ControlledCatalogRepository();
    late CatalogBloc bloc;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );
      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
      await _waitUntil(() => !bloc.state.isInitialLoading);

      bloc.add(const CatalogEvent.loadMoreRequested());
      await repository.waitForRequestCount(2);
      repository.completeUnknown(1, StateError('append unknown'));
      await _waitUntil(() => !bloc.state.isLoadingMore);

      bloc.add(const CatalogEvent.loadMoreRequested());
      await repository.waitForRequestCount(3);
      repository.completeSuccess(2, _page('retry'));
      await _waitUntil(() => !bloc.state.isLoadingMore);
    }, (error, stackTrace) => errors.add(error));

    expect(errors.single, isA<StateError>());
    expect(bloc.state.items.last.id, 'item-retry');
    await bloc.close();
  });

  test('nextCursor 為 null 時不再請求 Load More', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('end'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(repository.requests, hasLength(1));
    await bloc.close();
  });

  test('Refresh 成功整批替換；失敗保留既有 items', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(2);
    expect(repository.requests[1].cursor, isNull);
    repository.completeSuccess(1, _page('fresh', nextCursor: 'cursor-2'));
    await _waitUntil(() => !bloc.state.isRefreshing);
    expect(bloc.state.items.single.id, 'item-fresh');

    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(3);
    repository.completeFailure(
      2,
      const Failure(message: 'refresh failed', code: 'refresh_failed'),
    );
    await _waitUntil(() => !bloc.state.isRefreshing);
    expect(bloc.state.items.single.id, 'item-fresh');
    expect(bloc.state.nextCursor, 'cursor-2');
    expect(bloc.state.refreshFailure?.code, 'refresh_failed');
    await bloc.close();
  });

  test('Refresh 取消 stale revalidation 並更新第一頁 metadata', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.emitSuccess(
      0,
      _page('cached'),
      source: CatalogDataSource.cache,
      freshness: CatalogFreshness.stale,
      lastUpdatedAt: DateTime.utc(2026, 7, 17, 10),
    );
    await _waitUntil(() => bloc.state.isRevalidating);

    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(2);
    await _waitUntil(() => repository.cancelledRequests.contains(0));
    expect(bloc.state.isRefreshing, isTrue);
    expect(bloc.state.isRevalidating, isFalse);

    final refreshedAt = DateTime.utc(2026, 7, 17, 13);
    repository.completeSuccess(1, _page('fresh'), lastUpdatedAt: refreshedAt);
    await _waitUntil(() => !bloc.state.isRefreshing);

    expect(bloc.state.items.single.id, 'item-fresh');
    expect(bloc.state.isUsingCachedData, isFalse);
    expect(bloc.state.isStale, isFalse);
    expect(bloc.state.lastUpdatedAt, refreshedAt);
    expect(bloc.state.isRevalidating, isFalse);
    expect(bloc.state.revalidationFailure, isNull);
    await bloc.close();
  });

  test('Refresh unknown error 不會卡住，並允許 retry', () async {
    final repository = _ControlledCatalogRepository();
    late CatalogBloc bloc;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );
      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
      await _waitUntil(() => !bloc.state.isInitialLoading);

      bloc.add(const CatalogEvent.refreshRequested());
      await repository.waitForRequestCount(2);
      repository.completeUnknown(1, StateError('refresh unknown'));
      await _waitUntil(() => !bloc.state.isRefreshing);

      bloc.add(const CatalogEvent.refreshRequested());
      await repository.waitForRequestCount(3);
      repository.completeSuccess(2, _page('fresh'));
      await _waitUntil(() => !bloc.state.isRefreshing);
    }, (error, stackTrace) => errors.add(error));

    expect(errors.single, isA<StateError>());
    expect(bloc.state.items.single.id, 'item-fresh');
    await bloc.close();
  });

  test('Refresh failure 保留 stale Cache 與 freshness metadata', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    final cachedAt = DateTime.utc(2026, 7, 17, 9);
    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.emitSuccess(
      0,
      _page('cached', nextCursor: 'cursor-1'),
      source: CatalogDataSource.cache,
      freshness: CatalogFreshness.stale,
      lastUpdatedAt: cachedAt,
    );
    await _waitUntil(() => bloc.state.isRevalidating);

    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(2);
    repository.completeFailure(
      1,
      const Failure(message: 'refresh failed', code: 'refresh_failed'),
    );
    await _waitUntil(() => !bloc.state.isRefreshing);

    expect(bloc.state.items.single.id, 'item-cached');
    expect(bloc.state.nextCursor, 'cursor-1');
    expect(bloc.state.isUsingCachedData, isTrue);
    expect(bloc.state.isStale, isTrue);
    expect(bloc.state.lastUpdatedAt, cachedAt);
    expect(bloc.state.refreshFailure?.code, 'refresh_failed');
    await bloc.close();
  });

  test('連續 Refresh 只建立一個 request', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc
      ..add(const CatalogEvent.refreshRequested())
      ..add(const CatalogEvent.refreshRequested())
      ..add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(2);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.requests, hasLength(2));
    repository.completeSuccess(1, _page('fresh'));
    await _waitUntil(() => !bloc.state.isRefreshing);
    await bloc.close();
  });

  test('Query switching 取消執行中的 Refresh subscription', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(2);
    bloc.add(const CatalogEvent.queryChanged('new'));
    await repository.waitForRequestCount(3);
    await _waitUntil(() => repository.cancelledRequests.contains(1));
    repository.completeSuccess(2, _page('new'));
    await _waitUntil(
      () => bloc.state.query == 'new' && !bloc.state.isInitialLoading,
    );

    expect(bloc.state.items.single.id, 'item-new');
    await bloc.close();
  });

  test('Refresh 取消執行中的 Append subscription', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(3);
    await _waitUntil(() => repository.cancelledRequests.contains(1));
    repository.completeSuccess(2, _page('fresh'));
    await _waitUntil(() => !bloc.state.isRefreshing);

    expect(bloc.state.items.single.id, 'item-fresh');
    expect(bloc.state.isLoadingMore, isFalse);
    await bloc.close();
  });

  test('Refresh 無 emission 視為 protocol violation 並清除 loading', () async {
    final repository = _ControlledCatalogRepository();
    late CatalogBloc bloc;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      bloc = CatalogBloc(
        SearchCatalogUseCase(repository),
        debounceDuration: Duration.zero,
      );
      bloc.add(const CatalogEvent.initialRequested());
      await repository.waitForRequestCount(1);
      repository.completeSuccess(0, _page('initial'));
      await _waitUntil(() => !bloc.state.isInitialLoading);

      bloc.add(const CatalogEvent.refreshRequested());
      await repository.waitForRequestCount(2);
      await repository.closeRequest(1);
      await _waitUntil(() => !bloc.state.isRefreshing);
    }, (error, stackTrace) => errors.add(error));

    expect(errors.single, isA<StateError>());
    expect(bloc.state.items.single.id, 'item-initial');
    await bloc.close();
  });

  test('Refresh 會使舊 Append response 過期', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('initial', nextCursor: 'cursor-1'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    bloc.add(const CatalogEvent.refreshRequested());
    await repository.waitForRequestCount(3);
    repository.completeSuccess(2, _page('fresh'));
    await _waitUntil(() => !bloc.state.isRefreshing);
    repository.completeSuccess(1, _page('stale-append'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.items.single.id, 'item-fresh');
    expect(bloc.state.isLoadingMore, isFalse);
    await bloc.close();
  });

  test('Query 切換會使舊 Append response 過期', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );

    bloc.add(const CatalogEvent.queryChanged('old'));
    await repository.waitForRequestCount(1);
    repository.completeSuccess(0, _page('old', nextCursor: 'cursor-old'));
    await _waitUntil(() => !bloc.state.isInitialLoading);

    bloc.add(const CatalogEvent.loadMoreRequested());
    await repository.waitForRequestCount(2);
    bloc.add(const CatalogEvent.queryChanged('new'));
    await repository.waitForRequestCount(3);
    repository.completeSuccess(2, _page('new'));
    await _waitUntil(
      () => !bloc.state.isInitialLoading && bloc.state.query == 'new',
    );
    repository.completeSuccess(1, _page('stale-append'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.query, 'new');
    expect(bloc.state.items.single.id, 'item-new');
    await bloc.close();
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 1));

  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for condition');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

CatalogPage _page(String query, {String? nextCursor}) => CatalogPage(
  items: <CatalogItem>[
    CatalogItem(id: 'item-$query', name: query, description: query),
  ],
  nextCursor: nextCursor,
);

class _CatalogRequest {
  const _CatalogRequest({
    required this.query,
    required this.cursor,
    required this.limit,
    required this.policy,
  });

  final String query;
  final String? cursor;
  final int limit;
  final CatalogLoadPolicy policy;
}

class _CatalogRepositoryStub implements CatalogRepository {
  _CatalogRepositoryStub({this.resultBuilder});

  final Result<CatalogPageSnapshot> Function(_CatalogRequest request)?
  resultBuilder;
  final List<_CatalogRequest> requests = <_CatalogRequest>[];

  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) async* {
    final request = _CatalogRequest(
      query: query,
      cursor: cursor,
      limit: limit,
      policy: policy,
    );
    requests.add(request);
    yield resultBuilder?.call(request) ??
        Success<CatalogPageSnapshot>(_snapshot(_page(query)));
  }
}

class _ControlledCatalogRepository implements CatalogRepository {
  final List<_CatalogRequest> requests = <_CatalogRequest>[];
  final List<StreamController<Result<CatalogPageSnapshot>>> _controllers =
      <StreamController<Result<CatalogPageSnapshot>>>[];
  final Set<int> cancelledRequests = <int>{};

  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) {
    requests.add(
      _CatalogRequest(
        query: query,
        cursor: cursor,
        limit: limit,
        policy: policy,
      ),
    );
    final index = _controllers.length;
    final controller = StreamController<Result<CatalogPageSnapshot>>(
      onCancel: () => cancelledRequests.add(index),
    );
    _controllers.add(controller);
    return controller.stream;
  }

  Future<void> waitForRequestCount(int count) async {
    await _waitUntil(() => requests.length >= count);
  }

  void completeSuccess(
    int index,
    CatalogPage page, {
    CatalogDataSource source = CatalogDataSource.remote,
    CatalogFreshness freshness = CatalogFreshness.fresh,
    DateTime? lastUpdatedAt,
  }) {
    emitSuccess(
      index,
      page,
      source: source,
      freshness: freshness,
      lastUpdatedAt: lastUpdatedAt,
    );
    _controllers[index].close();
  }

  void emitSuccess(
    int index,
    CatalogPage page, {
    CatalogDataSource source = CatalogDataSource.remote,
    CatalogFreshness freshness = CatalogFreshness.fresh,
    DateTime? lastUpdatedAt,
  }) {
    _controllers[index].add(
      Success<CatalogPageSnapshot>(
        _snapshot(
          page,
          source: source,
          freshness: freshness,
          lastUpdatedAt: lastUpdatedAt,
        ),
      ),
    );
  }

  void completeFailure(int index, Failure failure) {
    _controllers[index]
      ..add(FailureResult<CatalogPageSnapshot>(failure))
      ..close();
  }

  void completeUnknown(int index, Object error) {
    _controllers[index]
      ..addError(error, StackTrace.current)
      ..close();
  }

  Future<void> closeRequest(int index) => _controllers[index].close();
}

CatalogPageSnapshot _snapshot(
  CatalogPage page, {
  CatalogDataSource source = CatalogDataSource.remote,
  CatalogFreshness freshness = CatalogFreshness.fresh,
  DateTime? lastUpdatedAt,
}) {
  return CatalogPageSnapshot(
    page: page,
    source: source,
    freshness: freshness,
    lastUpdatedAt: lastUpdatedAt ?? DateTime.utc(2026, 7, 17, 12),
  );
}
