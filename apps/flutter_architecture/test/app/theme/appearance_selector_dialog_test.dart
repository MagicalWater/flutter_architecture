import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/theme/presentation/appearance_selector_dialog.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
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
    );

    await tester.pumpWidget(
      MaterialApp(
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
}

final class _MemoryStorage implements ThemePreferenceStorage {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {}
}
