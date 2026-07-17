import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart'
    as domain;
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_architecture/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('快速完成的 refresh callback 仍會正常結束', () async {
    final bloc = CatalogBloc(
      SearchCatalogUseCase(_ImmediateCatalogRepository()),
      debounceDuration: Duration.zero,
    );
    addTearDown(bloc.close);

    bloc.add(const CatalogEvent.initialRequested());
    await bloc.stream.firstWhere((state) => state.hasCompletedInitialLoad);

    await requestCatalogRefresh(bloc).timeout(const Duration(seconds: 1));

    expect(bloc.state.isRefreshing, isFalse);
    expect(bloc.state.hasCompletedInitialLoad, isTrue);
  });

  test('Refresh 已執行中時再次等待會跟隨目前 lifecycle 完成', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(
      SearchCatalogUseCase(repository),
      debounceDuration: Duration.zero,
    );
    addTearDown(bloc.close);

    bloc.add(const CatalogEvent.initialRequested());
    await repository.waitForRequestCount(1);
    repository.complete(0);
    await bloc.stream.firstWhere((state) => state.hasCompletedInitialLoad);

    final firstRefresh = requestCatalogRefresh(bloc);
    await repository.waitForRequestCount(2);
    expect(bloc.state.isRefreshing, isTrue);

    final secondRefresh = requestCatalogRefresh(bloc);
    await Future<void>.delayed(Duration.zero);
    expect(repository.requestCount, 2);

    repository.complete(1);
    await Future.wait(<Future<void>>[
      firstRefresh.timeout(const Duration(seconds: 1)),
      secondRefresh.timeout(const Duration(seconds: 1)),
    ]);

    expect(bloc.state.isRefreshing, isFalse);
    expect(repository.requestCount, 2);
  });
}

class _ImmediateCatalogRepository implements CatalogRepository {
  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) async* {
    yield Success<CatalogPageSnapshot>(
      CatalogPageSnapshot(
        page: const domain.CatalogPage(items: <CatalogItem>[]),
        source: CatalogDataSource.remote,
        freshness: CatalogFreshness.fresh,
        lastUpdatedAt: DateTime.utc(2026, 7, 17),
      ),
    );
  }
}

class _ControlledCatalogRepository implements CatalogRepository {
  final List<StreamController<Result<CatalogPageSnapshot>>> _controllers =
      <StreamController<Result<CatalogPageSnapshot>>>[];

  int get requestCount => _controllers.length;

  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) {
    final controller = StreamController<Result<CatalogPageSnapshot>>();
    _controllers.add(controller);
    return controller.stream;
  }

  Future<void> waitForRequestCount(int count) async {
    final deadline = DateTime.now().add(const Duration(seconds: 1));
    while (requestCount < count) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('Expected $count requests, got $requestCount');
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  void complete(int index) {
    final controller = _controllers[index];
    controller
      ..add(
        Success<CatalogPageSnapshot>(
          CatalogPageSnapshot(
            page: const domain.CatalogPage(items: <CatalogItem>[]),
            source: CatalogDataSource.remote,
            freshness: CatalogFreshness.fresh,
            lastUpdatedAt: DateTime.utc(2026, 7, 17),
          ),
        ),
      )
      ..close();
  }
}
