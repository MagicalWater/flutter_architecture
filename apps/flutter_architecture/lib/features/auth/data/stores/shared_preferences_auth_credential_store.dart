import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Legacy／regression compatibility用的SharedPreferences credential adapter。
/// Production credential authority是FlutterSecureStorage，不由此class承擔。
final class SharedPreferencesAuthCredentialStore
    implements AuthCredentialStore {
  const SharedPreferencesAuthCredentialStore(this._preferences);

  static const String _credentialKey = 'auth.tokens';

  final SharedPreferences _preferences;

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    try {
      final raw = _preferences.get(_credentialKey);
      if (raw == null) {
        return const AuthCredentialReadAbsent();
      }
      return _decodeCredential(raw);
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '讀取 Auth credential 失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {
    try {
      final success = await _preferences.setString(
        _credentialKey,
        jsonEncode(tokens.toJson()),
      );
      if (!success) {
        throw const AppException(
          kind: AppExceptionKind.localStorage,
          message: '儲存 Auth credential 失敗',
        );
      }
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '儲存 Auth credential 失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> clearCredential() async {
    try {
      final success = await _preferences.remove(_credentialKey);
      if (!success) {
        throw const AppException(
          kind: AppExceptionKind.localStorage,
          message: '清除 Auth credential 失敗',
        );
      }
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '清除 Auth credential 失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

AuthCredentialReadResult _decodeCredential(Object raw) {
  if (raw is! String) {
    return const AuthCredentialReadCorrupted();
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const AuthCredentialReadCorrupted();
    }
    return AuthCredentialReadPresent(StoredAuthTokens.fromJson(decoded));
  } on FormatException {
    return const AuthCredentialReadCorrupted();
  }
}
