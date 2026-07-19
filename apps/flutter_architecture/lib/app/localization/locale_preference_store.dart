import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
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
  Future<String?> read() async {
    try {
      final value = _preferences.get(key);
      if (value == null || value is String) return value as String?;
      final stackTrace = StackTrace.current;
      Error.throwWithStackTrace(
        PreferenceCorruptionException(
          preference: PreferenceKind.locale,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    } on PreferenceException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PreferenceStorageException.read(
          preference: PreferenceKind.locale,
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
            preference: PreferenceKind.locale,
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
          preference: PreferenceKind.locale,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
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

    late final Object? value;
    try {
      value = jsonDecode(raw);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PreferenceCorruptionException(
          preference: PreferenceKind.locale,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }

    if (value is! Map<String, dynamic> || value['version'] != version) {
      throw const PreferenceCorruptionException(
        preference: PreferenceKind.locale,
      );
    }

    final rawLocale = value['locale'];
    if (rawLocale is! String) {
      throw const PreferenceCorruptionException(
        preference: PreferenceKind.locale,
      );
    }

    return AppLocalePreference.values
            .where((candidate) => candidate.storageValue == rawLocale)
            .firstOrNull ??
        (throw const PreferenceCorruptionException(
          preference: PreferenceKind.locale,
        ));
  }
}

final class LocalePreferenceRestoreResult {
  const LocalePreferenceRestoreResult({
    required this.preference,
    this.diagnostic,
  });

  final AppLocalePreference preference;
  final PreferenceDiagnostic? diagnostic;
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
    } on PreferenceException catch (error, stackTrace) {
      if (!_isExpectedLocaleRestoreFailure(error)) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return LocalePreferenceRestoreResult(
        preference: AppLocalePreference.system,
        diagnostic: PreferenceDiagnostic(error: error, stackTrace: stackTrace),
      );
    }
  }

  Future<void> save(AppLocalePreference preference) {
    return _storage.write(_codec.encode(preference));
  }
}

bool _isExpectedLocaleRestoreFailure(PreferenceException error) {
  return error.preference == PreferenceKind.locale &&
      switch (error) {
        PreferenceCorruptionException() => true,
        PreferenceStorageException(operation: PreferenceOperation.read) => true,
        PreferenceStorageException() => false,
      };
}
