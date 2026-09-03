import 'dart:convert';

import 'package:auth/auth_infrastructure.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 用 `flutter_secure_storage` 保存目前正式使用的登入 Token Pair。
///
/// 新的登入憑證都存這裡；舊版 SharedPreferences credential 只在 migration 時讀取，
/// 不會再拿來當正式登入來源。
final class FlutterSecureAuthCredentialStore implements AuthCredentialStore {
  const FlutterSecureAuthCredentialStore(this._storage);

  static const String _credentialKey = 'auth.tokens';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    final raw = await _runStorageOperation(
      message: '讀取 Secure Auth credential 失敗',
      operation: () => _storage.read(key: _credentialKey),
    );
    if (raw == null) {
      return const AuthCredentialReadAbsent();
    }
    return _decodeCredential(raw);
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) {
    if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
      throw ArgumentError('必須包含完整Token Pair', 'tokens');
    }
    final userId = tokens.userId;
    if (userId == null || userId.trim().isEmpty) {
      throw ArgumentError('必須包含有效identity', 'tokens.userId');
    }
    return _runStorageOperation(
      message: '儲存 Secure Auth credential 失敗',
      operation: () => _storage.write(
        key: _credentialKey,
        value: jsonEncode(tokens.toJson()),
      ),
    );
  }

  @override
  Future<void> clearCredential() {
    return _runStorageOperation(
      message: '清除 Secure Auth credential 失敗',
      operation: () => _storage.delete(key: _credentialKey),
    );
  }
}

Future<T> _runStorageOperation<T>({
  required String message,
  required Future<T> Function() operation,
}) async {
  try {
    return await operation();
  } on AppException {
    rethrow;
  } on PlatformException catch (error, stackTrace) {
    Error.throwWithStackTrace(
      AppException(
        kind: AppExceptionKind.localStorage,
        message: message,
        providerCode: error.code,
        cause: error,
        stackTrace: stackTrace,
      ),
      stackTrace,
    );
  } on MissingPluginException catch (error, stackTrace) {
    Error.throwWithStackTrace(
      AppException(
        kind: AppExceptionKind.localStorage,
        message: message,
        cause: error,
        stackTrace: stackTrace,
      ),
      stackTrace,
    );
  }
}

AuthCredentialReadResult _decodeCredential(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const AuthCredentialReadCorrupted();
    }

    final userId = decoded['userId'];
    if (userId is! String || userId.trim().isEmpty) {
      return const AuthCredentialReadCorrupted();
    }

    return AuthCredentialReadPresent(StoredAuthTokens.fromJson(decoded));
  } on FormatException {
    return const AuthCredentialReadCorrupted();
  }
}
