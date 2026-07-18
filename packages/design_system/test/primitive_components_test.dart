import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final definitions = <DsThemeDefinition>[
    DefaultThemeDefinition(),
    OceanThemeDefinition(),
  ];

  group('DsStatusBanner', () {
    testWidgets('renders under both identities and brightness variants', (
      tester,
    ) async {
      for (final definition in definitions) {
        for (final theme in <ThemeData>[
          definition.createLightTheme(),
          definition.createDarkTheme(),
        ]) {
          await tester.pumpWidget(
            _TestApp(
              theme: theme,
              child: const DsStatusBanner(
                tone: DsStatusTone.info,
                title: 'Cached data',
                message: 'Showing locally stored results.',
              ),
            ),
          );

          expect(find.text('Cached data'), findsOneWidget);
          expect(find.text('Showing locally stored results.'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('exposes semantics and invokes optional action', (
      tester,
    ) async {
      var actionCount = 0;
      await tester.pumpWidget(
        _TestApp(
          theme: DefaultThemeDefinition().createLightTheme(),
          child: DsStatusBanner(
            tone: DsStatusTone.warning,
            title: 'Offline',
            message: 'Some information may be outdated.',
            action: DsStatusBannerAction(
              label: 'Retry',
              onPressed: () => actionCount += 1,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Offline. Some information may be outdated.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry'));
      expect(actionCount, 1);
    });

    testWidgets('supports long text in a narrow viewport without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _TestApp(
          theme: OceanThemeDefinition().createDarkTheme(),
          child: const DsStatusBanner(
            tone: DsStatusTone.success,
            title: 'A deliberately long status title that must wrap safely',
            message:
                'This message is intentionally verbose so the primitive proves that it does not depend on a wide phone layout.',
            action: DsStatusBannerAction(
              label: 'Review details',
              onPressed: _noop,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('maps semantic tones to the active theme colors', (
      tester,
    ) async {
      final theme = OceanThemeDefinition().createDarkTheme();
      final semantic = theme.extension<DsSemanticColors>()!;
      final expectations =
          <DsStatusTone, ({Color container, Color foreground})>{
            DsStatusTone.neutral: (
              container: theme.colorScheme.surfaceContainerHigh,
              foreground: theme.colorScheme.onSurface,
            ),
            DsStatusTone.info: (
              container: semantic.infoContainer,
              foreground: semantic.onInfoContainer,
            ),
            DsStatusTone.success: (
              container: semantic.successContainer,
              foreground: semantic.onSuccessContainer,
            ),
            DsStatusTone.warning: (
              container: semantic.warningContainer,
              foreground: semantic.onWarningContainer,
            ),
            DsStatusTone.error: (
              container: theme.colorScheme.errorContainer,
              foreground: theme.colorScheme.onErrorContainer,
            ),
          };

      for (final entry in expectations.entries) {
        await tester.pumpWidget(
          _TestApp(
            theme: theme,
            child: DsStatusBanner(tone: entry.key, title: 'Status'),
          ),
        );

        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(DsStatusBanner),
            matching: find.byType(Material),
          ),
        );
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(DsStatusBanner),
            matching: find.byType(Icon),
          ),
        );

        expect(material.color, entry.value.container);
        expect(icon.color, entry.value.foreground);
      }
    });

    testWidgets('supports 2.0 text scaling in a narrow viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _TestApp(
          theme: DefaultThemeDefinition().createLightTheme(),
          textScaler: const TextScaler.linear(2),
          child: const SingleChildScrollView(
            child: DsStatusBanner(
              tone: DsStatusTone.warning,
              title: 'A long warning title that must remain readable',
              message:
                  'A long warning message that verifies accessibility text scaling without overflow or clipping.',
              action: DsStatusBannerAction(
                label: 'Review details now',
                onPressed: _noop,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('DsConstrainedContent', () {
    testWidgets('centers content and applies max width and padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          theme: DefaultThemeDefinition().createLightTheme(),
          child: const DsConstrainedContent(
            maxWidth: 480,
            padding: EdgeInsets.all(24),
            child: SizedBox(key: Key('content'), height: 40),
          ),
        ),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(DsConstrainedContent),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrained.constraints.maxWidth, 480);
      final align = tester.widget<Align>(
        find.descendant(
          of: find.byType(DsConstrainedContent),
          matching: find.byType(Align),
        ),
      );
      expect(align.alignment, Alignment.topCenter);
      expect(
        tester
            .widget<Padding>(
              find.descendant(
                of: find.byType(DsConstrainedContent),
                matching: find.byType(Padding),
              ),
            )
            .padding,
        const EdgeInsets.all(24),
      );
    });

    testWidgets('shrinks safely in a narrow viewport', (tester) async {
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _TestApp(
          theme: OceanThemeDefinition().createLightTheme(),
          child: const DsConstrainedContent(
            child: Text('Long content that should wrap instead of overflow.'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('DsButtonContent', () {
    testWidgets('shows label when idle and progress semantics when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          theme: DefaultThemeDefinition().createLightTheme(),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DsButtonContent(label: 'Idle'),
              DsButtonContent(label: 'Save', isLoading: true),
            ],
          ),
        ),
      );

      expect(find.text('Idle'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
    });

    testWidgets('works inside a disabled Material button while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          theme: OceanThemeDefinition().createDarkTheme(),
          child: const FilledButton(
            onPressed: null,
            child: DsButtonContent(label: 'Submit', isLoading: true),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports long loading labels at 2.0 text scaling', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _TestApp(
          theme: OceanThemeDefinition().createLightTheme(),
          textScaler: const TextScaler.linear(2),
          child: const SizedBox(
            width: 280,
            child: FilledButton(
              onPressed: null,
              child: DsButtonContent(
                label: 'Submitting a deliberately long request',
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Submitting a deliberately long request'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
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
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }
}
