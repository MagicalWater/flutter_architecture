import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_architecture/features/catalog/presentation/catalog_presentation_localization.dart';
import 'package:flutter_architecture/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatalogView 分離呈現 initial loading、failure 與 empty', (
    tester,
  ) async {
    await _pumpView(tester, _state(isInitialLoading: true));
    expect(find.byKey(const Key('catalog-initial-loading')), findsOneWidget);
    expect(find.byType(DsLoadingState), findsOneWidget);

    await _pumpView(
      tester,
      _state(initialFailure: const Failure(message: 'initial failed')),
    );
    expect(find.byKey(const Key('catalog-initial-failure')), findsOneWidget);
    expect(find.byType(DsBlockingErrorState), findsOneWidget);

    await _pumpView(tester, _state(hasCompletedInitialLoad: true));
    expect(find.byKey(const Key('catalog-empty')), findsOneWidget);
    expect(find.byType(DsEmptyState), findsOneWidget);
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
    expect(find.byType(DsButtonContent), findsOneWidget);

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
    expect(find.byType(DsStatusBanner), findsOneWidget);
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

  testWidgets('CatalogView 顯示 cached notice 與 lastUpdatedAt', (tester) async {
    await _pumpView(
      tester,
      _state(
        items: const <CatalogItem>[
          CatalogItem(id: '1', name: 'Cached', description: 'cached'),
        ],
        isUsingCachedData: true,
        lastUpdatedAt: DateTime.utc(2026, 7, 17, 3, 5),
      ),
    );

    expect(find.byKey(const Key('catalog-cache-status')), findsOneWidget);
    expect(find.byType(DsStatusBanner), findsOneWidget);
    expect(find.byKey(const Key('catalog-cached-notice')), findsOneWidget);
    final expected = formatCatalogUpdatedAt(
      DateTime.utc(2026, 7, 17, 3, 5),
      'en',
    );
    expect(find.text('Last updated: $expected'), findsOneWidget);
    expect(find.byKey(const Key('catalog-stale-notice')), findsNothing);
  });

  testWidgets('CatalogView 顯示 stale 與 background revalidation', (tester) async {
    await _pumpView(
      tester,
      _state(
        items: const <CatalogItem>[
          CatalogItem(id: '1', name: 'Cached', description: 'cached'),
        ],
        isUsingCachedData: true,
        isStale: true,
        lastUpdatedAt: DateTime.utc(2026, 7, 17, 3, 5),
        isRevalidating: true,
      ),
    );

    expect(find.byKey(const Key('catalog-stale-notice')), findsOneWidget);
    expect(
      find.byKey(const Key('catalog-revalidation-loading')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('catalog-revalidation-failure')), findsNothing);
    expect(find.byKey(const Key('catalog-item-1')), findsOneWidget);
  });

  testWidgets('CatalogView 顯示 non-blocking revalidation failure 並保留 items', (
    tester,
  ) async {
    await _pumpView(
      tester,
      _state(
        items: const <CatalogItem>[
          CatalogItem(id: '1', name: 'Cached', description: 'cached'),
        ],
        isUsingCachedData: true,
        isStale: true,
        revalidationFailure: const Failure(message: 'Update failed'),
      ),
    );

    expect(find.byKey(const Key('catalog-revalidation-loading')), findsNothing);
    expect(
      find.text('Unable to update the cached catalog right now.'),
      findsOneWidget,
    );
    expect(find.text('Update failed'), findsNothing);
    expect(find.byKey(const Key('catalog-item-1')), findsOneWidget);
  });

  testWidgets('CatalogView empty result 的 refresh failure 仍可見', (tester) async {
    await _pumpView(
      tester,
      _state(
        hasCompletedInitialLoad: true,
        refreshFailure: const Failure(message: 'Refresh failed'),
      ),
    );

    expect(find.byKey(const Key('catalog-empty')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('catalog-refresh-failure')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('catalog-refresh-failure')), findsOneWidget);
    expect(find.byType(DsStatusBanner), findsOneWidget);
  });

  testWidgets('CatalogView empty surface pull-to-refresh callback 可被觸發', (
    tester,
  ) async {
    var refreshCount = 0;
    await _pumpView(
      tester,
      _state(hasCompletedInitialLoad: true),
      onRefresh: () async => refreshCount += 1,
    );

    await tester.drag(
      find.byKey(const Key('catalog-empty')),
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshCount, 1);
  });

  testWidgets(
    'CatalogView empty failure supports narrow viewport and 2.0 text scaling',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpView(
        tester,
        _state(
          hasCompletedInitialLoad: true,
          refreshFailure: const Failure(
            message:
                'Refresh failed because the network is unavailable. Please check the connection and try again.',
          ),
        ),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.byKey(const Key('catalog-empty')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('catalog-refresh-failure')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('catalog-refresh-failure')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final themeCase in _themeCases) {
    testWidgets('CatalogView renders under ${themeCase.name}', (tester) async {
      await _pumpView(
        tester,
        _state(
          items: const <CatalogItem>[
            CatalogItem(id: '1', name: 'Cached', description: 'cached'),
          ],
          isUsingCachedData: true,
          isStale: true,
          lastUpdatedAt: DateTime.utc(2026, 7, 17, 3, 5),
        ),
        theme: themeCase.theme,
      );

      expect(find.byKey(const Key('catalog-item-1')), findsOneWidget);
      expect(find.byType(DsStatusBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('CatalogView fresh Remote data 不顯示 Cache notice', (tester) async {
    await _pumpView(
      tester,
      _state(
        items: const <CatalogItem>[
          CatalogItem(id: '1', name: 'Remote', description: 'fresh'),
        ],
        lastUpdatedAt: DateTime.utc(2026, 7, 17, 3, 5),
      ),
    );

    expect(find.byKey(const Key('catalog-cache-status')), findsNothing);
    expect(find.textContaining('Last updated:'), findsNothing);
  });

  testWidgets('CatalogView renders zh_TW copy and locale-aware local time', (
    tester,
  ) async {
    final timestamp = DateTime.utc(2026, 7, 17, 3, 5);
    await _pumpView(
      tester,
      _state(
        items: const <CatalogItem>[
          CatalogItem(
            id: '1',
            name: 'Server content',
            description: 'Unchanged',
          ),
        ],
        isUsingCachedData: true,
        isStale: true,
        lastUpdatedAt: timestamp,
      ),
      locale: const Locale('zh', 'TW'),
    );

    expect(find.text('正在顯示過期的快取資料'), findsOneWidget);
    final expected = formatCatalogUpdatedAt(timestamp, 'zh-TW');
    expect(find.text('最後更新：$expected'), findsOneWidget);
    expect(find.text('Server content'), findsOneWidget);
    expect(find.text('Unchanged'), findsOneWidget);
  });
}

Future<void> _pumpView(
  WidgetTester tester,
  CatalogState state, {
  VoidCallback? onRetryInitial,
  VoidCallback? onRetryAppend,
  Future<void> Function()? onRefresh,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme ?? OceanThemeDefinition().createDarkTheme(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(
          body: CatalogView(
            state: state,
            scrollController: ScrollController(),
            onRetryInitial: onRetryInitial ?? () {},
            onRetryAppend: onRetryAppend ?? () {},
            onRefresh: onRefresh ?? () async {},
          ),
        ),
      ),
    ),
  );
}

final _themeCases = <({String name, ThemeData theme})>[
  (name: 'Default Light', theme: DefaultThemeDefinition().createLightTheme()),
  (name: 'Default Dark', theme: DefaultThemeDefinition().createDarkTheme()),
  (name: 'Ocean Light', theme: OceanThemeDefinition().createLightTheme()),
  (name: 'Ocean Dark', theme: OceanThemeDefinition().createDarkTheme()),
];

CatalogState _state({
  List<CatalogItem> items = const <CatalogItem>[],
  bool isInitialLoading = false,
  bool isLoadingMore = false,
  bool hasCompletedInitialLoad = false,
  bool isUsingCachedData = false,
  bool isStale = false,
  DateTime? lastUpdatedAt,
  bool isRevalidating = false,
  Failure? initialFailure,
  Failure? revalidationFailure,
  Failure? refreshFailure,
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
    isUsingCachedData: isUsingCachedData,
    isStale: isStale,
    lastUpdatedAt: lastUpdatedAt,
    isRevalidating: isRevalidating,
    initialFailure: initialFailure,
    revalidationFailure: revalidationFailure,
    refreshFailure: refreshFailure,
    appendFailure: appendFailure,
  );
}
