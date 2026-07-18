import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';

Future<LocaleController> restoreLocaleController({
  required LocalePreferenceStorage storage,
}) async {
  final store = LocalePreferenceStore(storage, const LocalePreferenceCodec());
  final restore = await store.restore();
  return LocaleController(
    store: store,
    initialPreference: restore.preference,
    restoreDiagnostic: restore.diagnostic,
  );
}
