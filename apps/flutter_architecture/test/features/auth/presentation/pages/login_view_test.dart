import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginView uses themed fields and loading button content', (
    tester,
  ) async {
    final account = TextEditingController(text: 'demo');
    final password = TextEditingController(text: 'password');
    addTearDown(account.dispose);
    addTearDown(password.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: OceanThemeDefinition().createDarkTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginView(
          accountController: account,
          passwordController: password,
          isLoading: true,
          failureMessage: 'Login failed',
          onLogin: _noop,
          onOpenProtected: _noop,
        ),
      ),
    );

    expect(find.byType(DsConstrainedContent), findsOneWidget);
    expect(find.byType(DsButtonContent), findsOneWidget);
    expect(find.bySemanticsLabel('Login progress'), findsOneWidget);
    expect(find.text('Login failed'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets(
    'LoginView supports keyboard inset narrow viewport and 2.0 text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final account = TextEditingController();
      final password = TextEditingController();
      addTearDown(account.dispose);
      addTearDown(password.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: DefaultThemeDefinition().createLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2),
              viewInsets: EdgeInsets.only(bottom: 280),
            ),
            child: LoginView(
              accountController: account,
              passwordController: password,
              isLoading: false,
              onLogin: _noop,
              onOpenProtected: _noop,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('LoginView wires login submit and protected callbacks', (
    tester,
  ) async {
    final account = TextEditingController();
    final password = TextEditingController();
    addTearDown(account.dispose);
    addTearDown(password.dispose);
    var loginCount = 0;
    var protectedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DefaultThemeDefinition().createLightTheme(),
        locale: const Locale('zh', 'TW'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginView(
          accountController: account,
          passwordController: password,
          isLoading: false,
          onLogin: () => loginCount += 1,
          onOpenProtected: () => protectedCount += 1,
        ),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    expect(loginCount, 1);

    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(loginCount, 2);

    await tester.tap(find.text('開啟需要登入的頁面'));
    expect(protectedCount, 1);
  });
}

void _noop() {}
