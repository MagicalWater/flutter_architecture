import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/app/theme/theme_bootstrap.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DsThemeRegistry registry;

  setUp(() {
    final defaultTheme = DefaultThemeDefinition();
    registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[defaultTheme, OceanThemeDefinition()],
      defaultThemeId: defaultTheme.id,
    );
  });

  test(
    'restoreThemeController restores persisted preference before use',
    () async {
      final codec = ThemePreferenceCodec(registry);
      final storage = _BootstrapStorage(
        value: codec.encode(
          ThemePreference(
            themeId: OceanThemeDefinition().id,
            mode: AppThemeMode.dark,
          ),
        ),
      );

      final controller = await restoreThemeController(
        registry: registry,
        storage: storage,
      );

      expect(controller.preference.themeId, OceanThemeDefinition().id);
      expect(controller.preference.mode, AppThemeMode.dark);
      expect(controller.diagnostic, isNull);
    },
  );

  test(
    'read exception starts with fallback and keeps diagnostic without write',
    () async {
      final storage = _BootstrapStorage(readError: StateError('read failed'));

      final controller = await restoreThemeController(
        registry: registry,
        storage: storage,
      );

      expect(controller.preference, ThemePreference.defaults(registry));
      expect(controller.diagnostic, isA<StateError>());
      expect(storage.writes, isEmpty);
    },
  );
}

final class _BootstrapStorage implements ThemePreferenceStorage {
  _BootstrapStorage({this.value, this.readError});

  final String? value;
  final Object? readError;
  final List<String> writes = <String>[];

  @override
  Future<String?> read() async {
    if (readError != null) throw readError!;
    return value;
  }

  @override
  Future<void> write(String value) async {
    writes.add(value);
  }
}
