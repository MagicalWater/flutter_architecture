import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/auth/presentation/pages/otp_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders masked destination and submits numeric code', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var verifyCount = 0;

    await tester.pumpWidget(
      _host(
        OtpView(
          codeController: controller,
          maskedDestination: '***123',
          resendAvailableAt: DateTime.utc(2020),
          isVerifying: false,
          isResending: false,
          onVerify: () => verifyCount += 1,
          onResend: () {},
          now: () => DateTime.utc(2026),
        ),
      ),
    );

    expect(find.textContaining('***123'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('otpCodeField')), '12a34');
    await tester.tap(find.text('Verify'));
    expect(controller.text, '1234');
    expect(verifyCount, 1);
  });

  testWidgets('shows verifying state and disables actions', (tester) async {
    final controller = TextEditingController(text: '123456');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        OtpView(
          codeController: controller,
          maskedDestination: '***123',
          resendAvailableAt: DateTime.utc(2020),
          isVerifying: true,
          isResending: false,
          onVerify: () {},
          onResend: () {},
          now: () => DateTime.utc(2026),
        ),
      ),
    );

    expect(find.text('Verifying'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });

  testWidgets('renders cooldown and failure on narrow 2x text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _host(
          OtpView(
            codeController: controller,
            maskedDestination: '***123',
            resendAvailableAt: DateTime.utc(2026, 1, 1, 0, 0, 30),
            isVerifying: false,
            isResending: false,
            failureMessage: 'The verification code is incorrect.',
            onVerify: () {},
            onResend: () {},
            now: () => DateTime.utc(2026, 1, 1),
          ),
        ),
      ),
    );

    expect(find.textContaining('Resend in'), findsOneWidget);
    expect(find.text('The verification code is incorrect.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);
