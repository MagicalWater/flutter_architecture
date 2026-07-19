import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/theme/presentation/appearance_selector_dialog.dart';
import 'package:flutter_architecture/app/theme/presentation/theme_localization.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selector updates theme identity and mode independently', (
    tester,
  ) async {
    final registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[
        DefaultThemeDefinition(),
        OceanThemeDefinition(),
      ],
      defaultThemeId: DefaultThemeDefinition().id,
    );
    final controller = ThemeController(
      registry: registry,
      store: ThemePreferenceStore(
        _MemoryStorage(),
        ThemePreferenceCodec(registry),
      ),
      initialPreference: ThemePreference.defaults(registry),
      errorReporter: const NoopErrorReporter(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AppearanceSelectorDialog(controller: controller)),
      ),
    );

    await tester.tap(find.text('Ocean'));
    await tester.pump();
    expect(controller.preference.themeId, OceanThemeDefinition().id);
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, 'Ocean')).selected,
      isTrue,
    );
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Default'))
          .selected,
      isFalse,
    );

    await tester.tap(find.text('Dark'));
    await tester.pump();
    expect(controller.preference.mode, AppThemeMode.dark);
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, 'Dark')).selected,
      isTrue,
    );
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, 'System')).selected,
      isFalse,
    );
  });

  testWidgets('selector renders localized theme and mode labels', (
    tester,
  ) async {
    final registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[
        DefaultThemeDefinition(),
        OceanThemeDefinition(),
      ],
      defaultThemeId: DefaultThemeDefinition().id,
    );
    final controller = ThemeController(
      registry: registry,
      store: ThemePreferenceStore(
        _MemoryStorage(),
        ThemePreferenceCodec(registry),
      ),
      initialPreference: ThemePreference.defaults(registry),
      errorReporter: const NoopErrorReporter(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'TW'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AppearanceSelectorDialog(controller: controller)),
      ),
    );

    expect(find.text('外觀'), findsOneWidget);
    expect(find.text('主題'), findsOneWidget);
    expect(find.text('預設'), findsOneWidget);
    expect(find.text('海洋'), findsOneWidget);
    expect(find.text('跟隨系統'), findsOneWidget);
    expect(find.text('淺色'), findsOneWidget);
    expect(find.text('深色'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
  });

  testWidgets('selector rebuilds while locale changes at runtime', (
    tester,
  ) async {
    final registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[
        DefaultThemeDefinition(),
        OceanThemeDefinition(),
      ],
      defaultThemeId: DefaultThemeDefinition().id,
    );
    final controller = ThemeController(
      registry: registry,
      store: ThemePreferenceStore(
        _MemoryStorage(),
        ThemePreferenceCodec(registry),
      ),
      initialPreference: ThemePreference.defaults(registry),
      errorReporter: const NoopErrorReporter(),
    );
    final locale = ValueNotifier<Locale>(const Locale('en'));
    addTearDown(locale.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, value, _) => MaterialApp(
          locale: value,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppearanceSelectorDialog(controller: controller),
          ),
        ),
      ),
    );

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    locale.value = const Locale('zh', 'TW');
    await tester.pumpAndSettle();

    expect(find.text('外觀'), findsOneWidget);
    expect(find.text('預設'), findsOneWidget);
    expect(find.text('Appearance'), findsNothing);
    expect(find.text('Default'), findsNothing);
  });

  test('unknown theme uses metadata fallback display name', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh', 'TW'));
    final metadata = DsThemeMetadata(
      id: DsThemeId('partner'),
      displayName: 'Partner Theme',
    );

    expect(localizedThemeName(l10n, metadata), 'Partner Theme');
  });
}

final class _MemoryStorage implements ThemePreferenceStorage {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {}
}
