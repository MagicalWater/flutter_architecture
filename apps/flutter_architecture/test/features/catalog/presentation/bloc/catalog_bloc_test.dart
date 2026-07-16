import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initial state 尚未載入時不視為 empty result', () {
    expect(CatalogState.initial().isEmpty, isFalse);
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

    repository.completeSuccess(1, _page('new-generation'));
    await bloc.stream.firstWhere((state) => !state.isInitialLoading);
    repository.completeSuccess(0, _page('old-generation'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state.items.single.id, 'item-new-generation');

    await bloc.close();
  });

  test('Initial failure 與 empty result 可分開表達', () async {
    final failureRepository = _CatalogRepositoryStub(
      resultBuilder: (_) => const FailureResult<CatalogPage>(
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
      resultBuilder: (_) =>
          const Success<CatalogPage>(CatalogPage(items: <CatalogItem>[])),
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

CatalogPage _page(String query) => CatalogPage(
  items: <CatalogItem>[
    CatalogItem(id: 'item-$query', name: query, description: query),
  ],
  nextCursor: 'cursor-$query',
);

class _CatalogRequest {
  const _CatalogRequest({
    required this.query,
    required this.cursor,
    required this.limit,
  });

  final String query;
  final String? cursor;
  final int limit;
}

class _CatalogRepositoryStub implements CatalogRepository {
  _CatalogRepositoryStub({this.resultBuilder});

  final Result<CatalogPage> Function(_CatalogRequest request)? resultBuilder;
  final List<_CatalogRequest> requests = <_CatalogRequest>[];

  @override
  Future<Result<CatalogPage>> searchCatalog({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    final request = _CatalogRequest(query: query, cursor: cursor, limit: limit);
    requests.add(request);
    return resultBuilder?.call(request) ?? Success<CatalogPage>(_page(query));
  }
}

class _ControlledCatalogRepository implements CatalogRepository {
  final List<_CatalogRequest> requests = <_CatalogRequest>[];
  final List<Completer<Result<CatalogPage>>> _completers =
      <Completer<Result<CatalogPage>>>[];

  @override
  Future<Result<CatalogPage>> searchCatalog({
    required String query,
    required String? cursor,
    required int limit,
  }) {
    requests.add(_CatalogRequest(query: query, cursor: cursor, limit: limit));
    final completer = Completer<Result<CatalogPage>>();
    _completers.add(completer);
    return completer.future;
  }

  Future<void> waitForRequestCount(int count) async {
    await _waitUntil(() => requests.length >= count);
  }

  void completeSuccess(int index, CatalogPage page) {
    _completers[index].complete(Success<CatalogPage>(page));
  }
}
