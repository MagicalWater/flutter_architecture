import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemePreferenceStorage {
  Future<String?> read();
  Future<void> write(String value);
}

final class SharedPreferencesThemePreferenceStorage
    implements ThemePreferenceStorage {
  SharedPreferencesThemePreferenceStorage(this._preferences);

  static const key = 'app.theme.preference';
  final SharedPreferences _preferences;

  @override
  Future<String?> read() async => _preferences.getString(key);

  @override
  Future<void> write(String value) async {
    final saved = await _preferences.setString(key, value);
    if (!saved) {
      throw StateError('Theme preference could not be persisted.');
    }
  }
}

final class ThemePreferenceCodec {
  const ThemePreferenceCodec(this.registry);

  static const version = 1;
  final DsThemeRegistry registry;

  String encode(ThemePreference preference) {
    return jsonEncode(<String, Object>{
      'version': version,
      'themeId': preference.themeId.value,
      'mode': preference.mode.storageValue,
    });
  }

  ThemePreference decode(String? raw) {
    final fallback = ThemePreference.defaults(registry);
    if (raw == null) return fallback;

    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic> || value['version'] != version) {
        return fallback;
      }

      final rawThemeId = value['themeId'];
      final rawMode = value['mode'];
      final definition = _resolveTheme(rawThemeId);
      final mode = rawMode is String
          ? AppThemeMode.values
                .where((candidate) => candidate.storageValue == rawMode)
                .firstOrNull
          : null;

      return ThemePreference(
        themeId: definition.id,
        mode: mode ?? AppThemeMode.system,
      );
    } on Object {
      return fallback;
    }
  }

  DsThemeDefinition _resolveTheme(Object? rawThemeId) {
    if (rawThemeId is! String) {
      return registry.resolve(registry.defaultThemeId);
    }

    try {
      return registry.resolve(DsThemeId(rawThemeId));
    } on ArgumentError {
      return registry.resolve(registry.defaultThemeId);
    }
  }
}

final class ThemePreferenceRestoreResult {
  const ThemePreferenceRestoreResult({
    required this.preference,
    this.diagnostic,
  });

  final ThemePreference preference;
  final Object? diagnostic;
}

final class ThemePreferenceStore {
  const ThemePreferenceStore(this._storage, this._codec);

  final ThemePreferenceStorage _storage;
  final ThemePreferenceCodec _codec;

  Future<ThemePreferenceRestoreResult> restore() async {
    try {
      return ThemePreferenceRestoreResult(
        preference: _codec.decode(await _storage.read()),
      );
    } on Object catch (error) {
      return ThemePreferenceRestoreResult(
        preference: ThemePreference.defaults(_codec.registry),
        diagnostic: error,
      );
    }
  }

  Future<void> save(ThemePreference preference) {
    return _storage.write(_codec.encode(preference));
  }
}
