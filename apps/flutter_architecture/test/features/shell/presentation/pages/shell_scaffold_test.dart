import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/features/shell/presentation/pages/shell_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShellScaffold wires themed chrome and callbacks', (
    tester,
  ) async {
    var appearanceCount = 0;
    var localeCount = 0;
    var protectedCount = 0;
    var localUnlockCount = 0;
    int? selectedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: OceanThemeDefinition().createDarkTheme(),
        home: ShellScaffold(
          selectedIndex: 1,
          onDestinationSelected: (value) => selectedIndex = value,
          onOpenAppearance: () => appearanceCount += 1,
          onOpenLocale: () => localeCount += 1,
          onOpenProtected: () => protectedCount += 1,
          onOpenLocalUnlock: () => localUnlockCount += 1,
          title: 'Flutter Architecture',
          localeTooltip: 'Language',
          appearanceTooltip: 'Appearance',
          protectedTooltip: 'Protected Page',
          localUnlockTooltip: 'Local unlock settings',
          loginLabel: 'Login',
          catalogLabel: 'Catalog',
          profileLabel: 'Profile',
          child: const Text('Shell body'),
        ),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);

    await tester.tap(find.byTooltip('Language'));
    await tester.tap(find.byTooltip('Appearance'));
    await tester.tap(find.byTooltip('Protected Page'));
    await tester.tap(find.byTooltip('Local unlock settings'));
    await tester.tap(find.text('Profile'));

    expect(localeCount, 1);
    expect(appearanceCount, 1);
    expect(protectedCount, 1);
    expect(localUnlockCount, 1);
    expect(selectedIndex, 2);
  });

  for (final themeCase in _themeCases) {
    testWidgets('ShellScaffold renders under ${themeCase.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeCase.theme,
          home: ShellScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onOpenAppearance: () {},
            onOpenLocale: () {},
            onOpenProtected: () {},
            onOpenLocalUnlock: () {},
            title: 'Flutter Architecture',
            localeTooltip: 'Language',
            appearanceTooltip: 'Appearance',
            protectedTooltip: 'Protected Page',
            localUnlockTooltip: 'Local unlock settings',
            loginLabel: 'Login',
            catalogLabel: 'Catalog',
            profileLabel: 'Profile',
            child: const Text('Shell body'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Shell body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ShellScaffold rebuilds English and zh_TW chrome at runtime', (
    tester,
  ) async {
    final controller = LocaleController(
      store: LocalePreferenceStore(
        _LocaleStorage(),
        const LocalePreferenceCodec(),
      ),
      initialPreference: AppLocalePreference.english,
      errorReporter: const NoopErrorReporter(),
    );

    await tester.pumpWidget(_LocalizedShellHarness(controller: controller));

    expect(find.text('Flutter Architecture'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byTooltip('Appearance'), findsOneWidget);

    controller.select(AppLocalePreference.traditionalChinese);
    await tester.pumpAndSettle();

    expect(find.text('Flutter 架構模板'), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('目錄'), findsOneWidget);
    expect(find.text('個人資料'), findsOneWidget);
    expect(find.byTooltip('外觀'), findsOneWidget);
    expect(find.byTooltip('受保護頁面'), findsOneWidget);
  });
}

final _themeCases = <({String name, ThemeData theme})>[
  (name: 'Default Light', theme: DefaultThemeDefinition().createLightTheme()),
  (name: 'Default Dark', theme: DefaultThemeDefinition().createDarkTheme()),
  (name: 'Ocean Light', theme: OceanThemeDefinition().createLightTheme()),
  (name: 'Ocean Dark', theme: OceanThemeDefinition().createDarkTheme()),
];

final class _LocalizedShellHarness extends StatelessWidget {
  const _LocalizedShellHarness({required this.controller});

  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          locale: controller.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return ShellScaffold(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                onOpenAppearance: () {},
                onOpenLocale: () {},
                onOpenProtected: () {},
                onOpenLocalUnlock: () {},
                title: l10n.shellTitle,
                localeTooltip: l10n.localeSelectorTooltip,
                appearanceTooltip: l10n.shellAppearanceTooltip,
                protectedTooltip: l10n.shellProtectedTooltip,
                localUnlockTooltip: l10n.localUnlockSettingsTooltip,
                loginLabel: l10n.navigationLoginLabel,
                catalogLabel: l10n.navigationCatalogLabel,
                profileLabel: l10n.navigationProfileLabel,
                child: const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}

final class _LocaleStorage implements LocalePreferenceStorage {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {}
}
