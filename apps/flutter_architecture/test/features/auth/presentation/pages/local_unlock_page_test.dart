import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_architecture/features/auth/presentation/pages/local_unlock_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('locked surface exposes retry and server login actions', (
    tester,
  ) async {
    var retries = 0;
    var loginEscapes = 0;

    await tester.pumpWidget(
      _TestApp(
        child: LocalUnlockView(
          state: StartupLocalUnlockState.rejected,
          onRetry: () async => retries += 1,
          onUseLogin: () async => loginEscapes += 1,
        ),
      ),
    );

    expect(find.text('Unlock saved session'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Log in with account instead'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.tap(find.text('Log in with account instead'));
    expect(retries, 1);
    expect(loginEscapes, 1);
  });

  testWidgets('surface remains usable at large text in narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _TestApp(
          child: LocalUnlockView(
            state: StartupLocalUnlockState.unavailable,
            onRetry: () async {},
            onUseLogin: () async {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Log in with account instead'), findsOneWidget);
  });

  testWidgets('prompting disables duplicate actions', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: LocalUnlockView(
          state: StartupLocalUnlockState.prompting,
          onRetry: () async {},
          onUseLogin: () async {},
        ),
      ),
    );

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
