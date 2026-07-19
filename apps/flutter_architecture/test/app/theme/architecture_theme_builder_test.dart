import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme builder wires selected identity and mode', (tester) async {
    final defaultTheme = DefaultThemeDefinition();
    final oceanTheme = OceanThemeDefinition();
    final registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[defaultTheme, oceanTheme],
      defaultThemeId: defaultTheme.id,
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

    ThemeData? lightTheme;
    ThemeData? darkTheme;
    ThemeMode? themeMode;

    await tester.pumpWidget(
      ArchitectureThemeBuilder(
        controller: controller,
        builder: (context, light, dark, mode) {
          lightTheme = light;
          darkTheme = dark;
          themeMode = mode;
          return const SizedBox();
        },
      ),
    );

    controller.selectTheme(oceanTheme.id);
    controller.selectMode(AppThemeMode.dark);
    await tester.pump();

    expect(lightTheme!.colorScheme, oceanTheme.createLightTheme().colorScheme);
    expect(darkTheme!.colorScheme, oceanTheme.createDarkTheme().colorScheme);
    expect(themeMode, ThemeMode.dark);
  });
}

final class _MemoryStorage implements ThemePreferenceStorage {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {}
}
