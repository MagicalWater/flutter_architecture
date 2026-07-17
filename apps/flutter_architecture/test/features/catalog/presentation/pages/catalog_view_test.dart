import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_architecture/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatalogView 分離呈現 initial loading、failure 與 empty', (
    tester,
  ) async {
    await _pumpView(tester, _state(isInitialLoading: true));
    expect(find.byKey(const Key('catalog-initial-loading')), findsOneWidget);

    await _pumpView(
      tester,
      _state(initialFailure: const Failure(message: 'initial failed')),
    );
    expect(find.byKey(const Key('catalog-initial-failure')), findsOneWidget);

    await _pumpView(tester, _state(hasCompletedInitialLoad: true));
    expect(find.byKey(const Key('catalog-empty')), findsOneWidget);
  });

  testWidgets('CatalogView 顯示 items、append loading 與 append retry', (
    tester,
  ) async {
    var retryCount = 0;
    final items = const <CatalogItem>[
      CatalogItem(id: '1', name: 'Flutter', description: 'Framework'),
    ];

    await _pumpView(
      tester,
      _state(items: items, isLoadingMore: true),
      onRetryAppend: () => retryCount++,
    );
    expect(find.byKey(const Key('catalog-item-1')), findsOneWidget);
    expect(find.byKey(const Key('catalog-append-loading')), findsOneWidget);

    await _pumpView(
      tester,
      _state(
        items: items,
        appendFailure: const Failure(message: 'append failed'),
      ),
      onRetryAppend: () => retryCount++,
    );
    await tester.tap(find.text('Retry load more'));
    expect(retryCount, 1);
  });

  testWidgets('CatalogView initial retry callback 可被觸發', (tester) async {
    var retryCount = 0;
    await _pumpView(
      tester,
      _state(initialFailure: const Failure(message: 'failed')),
      onRetryInitial: () => retryCount++,
    );

    await tester.tap(find.text('Retry'));
    expect(retryCount, 1);
  });
}

Future<void> _pumpView(
  WidgetTester tester,
  CatalogState state, {
  VoidCallback? onRetryInitial,
  VoidCallback? onRetryAppend,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CatalogView(
          state: state,
          scrollController: ScrollController(),
          onRetryInitial: onRetryInitial ?? () {},
          onRetryAppend: onRetryAppend ?? () {},
          onRefresh: () async {},
        ),
      ),
    ),
  );
}

CatalogState _state({
  List<CatalogItem> items = const <CatalogItem>[],
  bool isInitialLoading = false,
  bool isLoadingMore = false,
  bool hasCompletedInitialLoad = false,
  Failure? initialFailure,
  Failure? appendFailure,
}) {
  return CatalogState(
    query: '',
    items: items,
    nextCursor: null,
    isInitialLoading: isInitialLoading,
    isRefreshing: false,
    isLoadingMore: isLoadingMore,
    hasCompletedInitialLoad: hasCompletedInitialLoad,
    isUsingCachedData: false,
    isStale: false,
    lastUpdatedAt: null,
    isRevalidating: false,
    initialFailure: initialFailure,
    revalidationFailure: null,
    refreshFailure: null,
    appendFailure: appendFailure,
  );
}
