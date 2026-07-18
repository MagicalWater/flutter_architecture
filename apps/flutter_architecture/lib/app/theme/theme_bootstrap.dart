import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';

Future<ThemeController> restoreThemeController({
  required DsThemeRegistry registry,
  required ThemePreferenceStorage storage,
}) async {
  final store = ThemePreferenceStore(storage, ThemePreferenceCodec(registry));
  final restore = await store.restore();
  return ThemeController(
    registry: registry,
    store: store,
    initialPreference: restore.preference,
    restoreDiagnostic: restore.diagnostic,
  );
}
