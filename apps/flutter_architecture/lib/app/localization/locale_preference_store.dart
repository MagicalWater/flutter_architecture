import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 只負責從本機讀寫語系 preference 的原始字串。
///
/// JSON 格式解析與 fallback 規則不放在這裡，避免 storage adapter 同時承擔資料格式邏輯。
abstract interface class LocalePreferenceStorage {
  Future<String?> read();
  Future<void> write(String value);
}

/// 使用 SharedPreferences 儲存語系 preference。
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
          providerCode: error.code,
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
          providerCode: error.code,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

/// 負責把 [AppLocalePreference] 和可版本化的 JSON 字串互相轉換。
///
/// 格式錯誤或未知 version 會明確視為 [PreferenceCorruptionException]，不會偷偷猜值。
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

/// App 啟動時還原語系設定的結果。
///
/// [diagnostic] 有值代表讀取失敗或資料損壞，因此這次暫時退回 system locale。
final class LocalePreferenceRestoreResult {
  const LocalePreferenceRestoreResult({
    required this.preference,
    this.diagnostic,
  });

  final AppLocalePreference preference;
  final PreferenceDiagnostic? diagnostic;
}

/// 對外提供「還原／保存語系設定」的完整流程。
///
/// 啟動時如果只是讀不到或資料損壞，會退回 system locale 並保留 diagnostic；
/// 寫入失敗等不該被忽略的錯誤仍會往上拋。
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
      // 啟動還原只允許「讀不到」或「內容損壞」退回預設值；寫入失敗等其他錯誤
      // 不能被當成可恢復狀況吞掉。
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
        PreferenceStorageException(
          operation: PreferenceStorageOperation.read,
        ) => true,
        PreferenceStorageException() => false,
      };
}
