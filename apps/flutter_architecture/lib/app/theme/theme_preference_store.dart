import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 只負責從本機讀寫 Theme preference 的原始字串。
///
/// Theme ID、亮暗模式解析與 fallback 規則由上層 codec 處理。
abstract interface class ThemePreferenceStorage {
  Future<String?> read();
  Future<void> write(String value);
}

/// 使用 SharedPreferences 儲存 Theme preference。
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
          providerCode: error.code,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

/// 負責把 [ThemePreference] 和可版本化的 JSON 字串互相轉換。
///
/// 未知 Theme ID 會退回 registry default；JSON 格式或 version 損壞則視為 preference corruption。
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
      themeId: definition.metadata.id,
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

/// App 啟動時還原 Theme 設定的結果。
///
/// [diagnostic] 有值代表這次因讀取失敗或資料損壞而退回預設 Theme。
final class ThemePreferenceRestoreResult {
  const ThemePreferenceRestoreResult({
    required this.preference,
    this.diagnostic,
  });

  final ThemePreference preference;
  final PreferenceDiagnostic? diagnostic;
}

/// 對外提供「還原／保存 Theme 設定」的完整流程。
///
/// 啟動時只對讀取失敗或資料損壞退回預設 Theme；寫入失敗等其他錯誤仍直接回報。
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
      // 啟動還原只允許「讀不到」或「內容損壞」退回預設值；寫入失敗等其他錯誤
      // 不能在 bootstrap 時被誤當成可恢復狀況。
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
        PreferenceStorageException(
          operation: PreferenceStorageOperation.read,
        ) => true,
        PreferenceStorageException() => false,
      };
}
