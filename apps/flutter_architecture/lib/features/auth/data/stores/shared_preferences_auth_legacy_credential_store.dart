import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 讀取與清理舊版SharedPreferences credential keys。
final class SharedPreferencesAuthLegacyCredentialStore
    implements AuthLegacyCredentialStore {
  const SharedPreferencesAuthLegacyCredentialStore(this._preferences);

  static const String _tokenPairKey = 'auth.tokens';
  static const String _singleAccessTokenKey = 'auth.accessToken';

  final SharedPreferences _preferences;

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    try {
      final raw = _preferences.get(_tokenPairKey);
      if (raw != null) {
        return _decodeCredential(raw);
      }
      if (_preferences.containsKey(_singleAccessTokenKey)) {
        final removed = await _preferences.remove(_singleAccessTokenKey);
        if (!removed) {
          throw const AppException(
            kind: AppExceptionKind.localStorage,
            message: '清除舊 Auth access token 失敗',
          );
        }
      }
      return const AuthCredentialReadAbsent();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '讀取舊 Auth credential 失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> clearLegacyCredential() async {
    Object? expectedError;
    StackTrace? expectedStackTrace;
    Object? unexpectedError;
    StackTrace? unexpectedStackTrace;

    void captureError(Object error, StackTrace stackTrace) {
      if (error is AppException &&
          error.kind == AppExceptionKind.localStorage) {
        expectedError ??= error;
        expectedStackTrace ??= stackTrace;
        return;
      }
      unexpectedError ??= error;
      unexpectedStackTrace ??= stackTrace;
    }

    Future<void> remove(String key) async {
      try {
        final success = await _preferences.remove(key);
        if (!success) {
          throw const AppException(
            kind: AppExceptionKind.localStorage,
            message: '清除舊 Auth credential 失敗',
          );
        }
      } catch (error, stackTrace) {
        captureError(error, stackTrace);
      }
    }

    await remove(_tokenPairKey);
    await remove(_singleAccessTokenKey);

    final capturedUnexpectedError = unexpectedError;
    if (capturedUnexpectedError != null) {
      Error.throwWithStackTrace(capturedUnexpectedError, unexpectedStackTrace!);
    }
    final capturedExpectedError = expectedError;
    if (capturedExpectedError != null) {
      Error.throwWithStackTrace(capturedExpectedError, expectedStackTrace!);
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
