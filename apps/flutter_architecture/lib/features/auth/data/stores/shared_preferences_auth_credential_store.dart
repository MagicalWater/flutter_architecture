import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 以 SharedPreferences 保存目前權威 credential 的暫時 adapter。
///
/// Milestone 19-1 只搬移 plugin ownership，不改變 production authority；
/// Milestone 19-2 會以 Secure Storage adapter 取代此 binding。
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
