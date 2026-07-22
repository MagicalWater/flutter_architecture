import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_bootstrap.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_bootstrap.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_architecture/bootstrap.dart';
import 'package:flutter_architecture/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_architecture/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_architecture/features/protected/presentation/pages/protected_page.dart';
import 'package:flutter_architecture/features/shell/presentation/pages/shell_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iOS Simulator完成核心runtime smoke並保存preferences', (tester) async {
    await bootstrap(AppEnvironment.development);
    await _pumpUntil(tester, find.byType(LoginPage));

    await tester.tap(find.byIcon(Icons.lock_outline));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ProtectedPage), findsNothing);

    await tester.tap(find.byType(FilledButton).first);
    await _pumpUntil(tester, find.byType(ProfilePage));

    await tester.tap(find.byIcon(Icons.view_list_outlined));
    await _pumpUntil(tester, find.byKey(const Key('catalog-list')));
    expect(
      find.byKey(const ValueKey<String>('catalog-item-catalog-001')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('catalog-search-field')),
      'SQLite',
    );
    await _pumpUntil(
      tester,
      find.byKey(const ValueKey<String>('catalog-item-catalog-011')),
    );
    expect(
      find.byKey(const ValueKey<String>('catalog-item-catalog-001')),
      findsNothing,
    );

    await tester.tap(find.byIcon(Icons.person));
    await _pumpUntil(tester, find.byType(ProfilePage));

    await tester.tap(find.byIcon(Icons.lock_outline));
    await _pumpUntil(tester, find.byType(ProtectedPage));

    Navigator.of(tester.element(find.byType(ProtectedPage))).pop();
    await tester.pumpAndSettle();
    await _pumpUntil(tester, find.byType(ProfilePage));

    await tester.tap(find.byType(FilledButton).first);
    await _pumpUntil(tester, find.byType(LoginPage));

    final database = getIt<Database>();
    final foreignKeys = await database.rawQuery('PRAGMA foreign_keys');
    final cachedPages = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM catalog_cache_page'),
    );
    final cachedItems = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM catalog_cache_page_item'),
    );
    expect(foreignKeys.single.values.single, 1);
    expect(cachedPages, greaterThan(0));
    expect(cachedItems, greaterThan(0));

    final shellContext = tester.element(find.byType(ShellPage));
    final themeController = ThemeControllerScope.of(shellContext);
    final localeController = LocaleControllerScope.of(shellContext);
    themeController.selectTheme(OceanThemeDefinition().id);
    themeController.selectMode(AppThemeMode.dark);
    localeController.select(AppLocalePreference.traditionalChinese);
    await themeController.waitForPendingWrites();
    await localeController.waitForPendingWrites();
    await getIt<LocalUnlockPreferenceStore>().write(
      LocalUnlockPreference.enabled,
    );

    expect(themeController.preference.themeId, OceanThemeDefinition().id);
    expect(themeController.preference.mode, AppThemeMode.dark);
    expect(
      localeController.preference,
      AppLocalePreference.traditionalChinese,
    );

    final preferences = getIt<SharedPreferences>();
    await preferences.reload();
    final defaultTheme = DefaultThemeDefinition();
    final oceanTheme = OceanThemeDefinition();
    final restoredThemeController = await restoreThemeController(
      registry: DsThemeRegistry(
        definitions: <DsThemeDefinition>[defaultTheme, oceanTheme],
        defaultThemeId: defaultTheme.id,
      ),
      storage: SharedPreferencesThemePreferenceStorage(preferences),
      errorReporter: getIt(),
    );
    final restoredLocaleController = await restoreLocaleController(
      storage: SharedPreferencesLocalePreferenceStorage(preferences),
      errorReporter: getIt(),
    );
    final restoredLocalUnlock =
        await getIt<LocalUnlockPreferenceStore>().read();

    expect(restoredThemeController.preference.themeId, oceanTheme.id);
    expect(restoredThemeController.preference.mode, AppThemeMode.dark);
    expect(
      restoredLocaleController.preference,
      AppLocalePreference.traditionalChinese,
    );
    expect(restoredLocalUnlock, isA<LocalUnlockPreferenceReadPresent>());
    expect(
      (restoredLocalUnlock as LocalUnlockPreferenceReadPresent).preference,
      LocalUnlockPreference.enabled,
    );
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
