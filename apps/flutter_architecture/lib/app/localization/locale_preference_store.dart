import 'dart:convert';

import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalePreferenceStorage {
  Future<String?> read();
  Future<void> write(String value);
}

final class SharedPreferencesLocalePreferenceStorage
    implements LocalePreferenceStorage {
  SharedPreferencesLocalePreferenceStorage(this._preferences);

  static const key = 'app.locale.preference';
  final SharedPreferences _preferences;

  @override
  Future<String?> read() async => _preferences.getString(key);

  @override
  Future<void> write(String value) async {
    final saved = await _preferences.setString(key, value);
    if (!saved) {
      throw StateError('Locale preference could not be persisted.');
    }
  }
}

final class LocalePreferenceCodec {
  const LocalePreferenceCodec();

  static const version = 1;

  String encode(AppLocalePreference preference) {
    return jsonEncode(<String, Object>{
      'version': version,
      'locale': preference.storageValue,
    });
  }

  AppLocalePreference decode(String? raw) {
    if (raw == null) return AppLocalePreference.system;

    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic> || value['version'] != version) {
        return AppLocalePreference.system;
      }

      final rawLocale = value['locale'];
      if (rawLocale is! String) return AppLocalePreference.system;

      return AppLocalePreference.values
              .where((candidate) => candidate.storageValue == rawLocale)
              .firstOrNull ??
          AppLocalePreference.system;
    } on Object {
      return AppLocalePreference.system;
    }
  }
}

final class LocalePreferenceRestoreResult {
  const LocalePreferenceRestoreResult({
    required this.preference,
    this.diagnostic,
  });

  final AppLocalePreference preference;
  final Object? diagnostic;
}

final class LocalePreferenceStore {
  const LocalePreferenceStore(this._storage, this._codec);

  final LocalePreferenceStorage _storage;
  final LocalePreferenceCodec _codec;

  Future<LocalePreferenceRestoreResult> restore() async {
    try {
      return LocalePreferenceRestoreResult(
        preference: _codec.decode(await _storage.read()),
      );
    } on Object catch (error) {
      return LocalePreferenceRestoreResult(
        preference: AppLocalePreference.system,
        diagnostic: error,
      );
    }
  }

  Future<void> save(AppLocalePreference preference) {
    return _storage.write(_codec.encode(preference));
  }
}
