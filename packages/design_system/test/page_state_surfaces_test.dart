import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final definitions = <DsThemeDefinition>[
    DefaultThemeDefinition(),
    OceanThemeDefinition(),
  ];

  testWidgets('page state surfaces render under both themes and brightnesses', (
    tester,
  ) async {
    for (final definition in definitions) {
      for (final theme in <ThemeData>[
        definition.createLightTheme(),
        definition.createDarkTheme(),
      ]) {
        final surfaces = <Widget>[
          const DsLoadingState(
            title: 'Loading',
            progressSemanticsLabel: 'Loading progress',
          ),
          const DsEmptyState(title: 'No results'),
          const DsBlockingErrorState(title: 'Failed'),
          const DsMessageState(title: 'Welcome'),
        ];

        for (final surface in surfaces) {
          await tester.pumpWidget(_TestApp(theme: theme, child: surface));
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('loading state exposes progress semantics', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: const DsLoadingState(
          title: 'Loading profile',
          message: 'Please wait while your profile is loaded.',
          progressSemanticsLabel: 'Profile loading progress',
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Profile loading progress'), findsOneWidget);
    expect(
      find.text('Please wait while your profile is loaded.'),
      findsOneWidget,
    );
  });

  testWidgets('blocking error exposes error and retry semantics', (
    tester,
  ) async {
    var primaryCount = 0;
    var secondaryCount = 0;

    await tester.pumpWidget(
      _TestApp(
        theme: OceanThemeDefinition().createDarkTheme(),
        child: DsBlockingErrorState(
          title: 'Unable to load data',
          message: 'Check your connection and try again.',
          primaryAction: DsPageStateAction(
            label: 'Retry',
            onPressed: () => primaryCount += 1,
          ),
          secondaryAction: DsPageStateAction(
            label: 'Go back',
            onPressed: () => secondaryCount += 1,
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Error. Unable to load data. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Unable to load data'), findsNothing);
    expect(
      find.bySemanticsLabel('Check your connection and try again.'),
      findsNothing,
    );
    expect(find.bySemanticsLabel('Retry'), findsOneWidget);
    expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.tap(find.text('Go back'));
    expect(primaryCount, 1);
    expect(secondaryCount, 1);
  });

  testWidgets('empty and message states support custom icon slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createDarkTheme(),
        child: const Column(
          children: <Widget>[
            DsEmptyState(
              title: 'No results',
              icon: Icon(Icons.search_off, key: Key('empty-icon')),
            ),
            DsMessageState(
              title: 'Protected content',
              icon: Icon(Icons.lock, key: Key('message-icon')),
            ),
            DsBlockingErrorState(
              title: 'Failed',
              icon: Icon(Icons.cloud_off, key: Key('blocking-error-icon')),
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const Key('empty-icon')), findsOneWidget);
    expect(find.byKey(const Key('message-icon')), findsOneWidget);
    expect(find.byKey(const Key('blocking-error-icon')), findsOneWidget);
  });

  testWidgets('loading semantics remain distinct from visible title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: const DsLoadingState(
          title: 'Loading profile',
          progressSemanticsLabel: 'Profile loading progress',
        ),
      ),
    );

    expect(find.bySemanticsLabel('Profile loading progress'), findsOneWidget);
    expect(find.text('Loading profile'), findsOneWidget);
  });

  testWidgets('empty state can defer scrolling to its parent', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        child: const DsEmptyState(
          title: 'No results',
          message: 'Pull to refresh.',
          scrollable: false,
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('No results'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final scale in <double>[1, 1.3, 2]) {
    testWidgets('surfaces support text scale $scale in narrow viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _TestApp(
          theme: OceanThemeDefinition().createLightTheme(),
          textScaler: TextScaler.linear(scale),
          child: DsEmptyState(
            title: 'No matching results were found for this search',
            message:
                'Try changing the filters or entering a different search phrase to continue.',
            primaryAction: const DsPageStateAction(
              label: 'Clear all filters',
              onPressed: _noop,
            ),
            secondaryAction: const DsPageStateAction(
              label: 'Return to catalog',
              onPressed: _noop,
            ),
          ),
        ),
      );

      expect(
        find.text('No matching results were found for this search'),
        findsOneWidget,
      );
      expect(find.text('Clear all filters'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

void _noop() {}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.theme,
    required this.child,
    this.textScaler = TextScaler.noScaling,
  });

  final ThemeData theme;
  final Widget child;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(body: child),
      ),
    );
  }
}
