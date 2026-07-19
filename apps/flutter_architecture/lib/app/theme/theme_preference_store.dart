import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
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
  Future<String?> read() async {
    try {
      final value = _preferences.get(key);
      if (value == null || value is String) return value as String?;
      final stackTrace = StackTrace.current;
      Error.throwWithStackTrace(
        PreferenceCorruptionException(
          preference: PreferenceKind.theme,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    } on PreferenceException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PreferenceStorageException.read(
          preference: PreferenceKind.theme,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> write(String value) async {
    try {
      final saved = await _preferences.setString(key, value);
      if (!saved) {
        final stackTrace = StackTrace.current;
        Error.throwWithStackTrace(
          PreferenceStorageException.write(
            preference: PreferenceKind.theme,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    } on PreferenceException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PreferenceStorageException.write(
          preference: PreferenceKind.theme,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
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
    if (raw == null) return ThemePreference.defaults(registry);

    late final Object? value;
    try {
      value = jsonDecode(raw);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PreferenceCorruptionException(
          preference: PreferenceKind.theme,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }

    if (value is! Map<String, dynamic> || value['version'] != version) {
      throw const PreferenceCorruptionException(
        preference: PreferenceKind.theme,
      );
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
  final PreferenceDiagnostic? diagnostic;
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
    } on PreferenceException catch (error, stackTrace) {
      if (!_isExpectedThemeRestoreFailure(error)) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return ThemePreferenceRestoreResult(
        preference: ThemePreference.defaults(_codec.registry),
        diagnostic: PreferenceDiagnostic(error: error, stackTrace: stackTrace),
      );
    }
  }

  Future<void> save(ThemePreference preference) {
    return _storage.write(_codec.encode(preference));
  }
}

bool _isExpectedThemeRestoreFailure(PreferenceException error) {
  return error.preference == PreferenceKind.theme &&
      switch (error) {
        PreferenceCorruptionException() => true,
        PreferenceStorageException(operation: PreferenceOperation.read) => true,
        PreferenceStorageException() => false,
      };
}
