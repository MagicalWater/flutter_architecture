import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/bootstrap.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_page.dart';
import 'package:flutter_architecture/features/shell/presentation/pages/shell_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android capture 寫前檢查 runtime screenshot', (tester) async {
    await bootstrap(AppEnvironment.development);
    await _pumpUntil(tester, find.byType(ShellPage));

    final shellContext = tester.element(find.byType(ShellPage));
    final themeController = ThemeControllerScope.of(shellContext);
    final localeController = LocaleControllerScope.of(shellContext);
    themeController.selectMode(AppThemeMode.dark);
    localeController.select(AppLocalePreference.traditionalChinese);
    await themeController.waitForPendingWrites();
    await localeController.waitForPendingWrites();

    unawaited(getIt<AppRouter>().push(const WritePrecheckRoute()));
    await _pumpUntil(tester, find.byType(WritePrecheckPage));

    final pageContext = tester.element(find.byType(WritePrecheckPage));
    final mediaQuery = MediaQuery.of(pageContext);
    final view = tester.view;
    // ignore: avoid_print
    print(
      'RUNTIME_METRICS '
      'physical=${view.physicalSize.width}x${view.physicalSize.height} '
      'dpr=${view.devicePixelRatio} '
      'logical=${mediaQuery.size.width}x${mediaQuery.size.height} '
      'textScale=${mediaQuery.textScaler.scale(1)}',
    );

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('write_precheck_android');

    expect(find.byType(WritePrecheckPage), findsOneWidget);
  });
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 120,
}) async {
  for (var frame = 0; frame < maxFrames; frame += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}
