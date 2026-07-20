import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 以 platform secure storage 保存完整Auth Token Pair的App-owned adapter。
///
/// Milestone 19-2只建立adapter與DI shape；正式production authority仍維持
/// SharedPreferences，直到後續migration與lifecycle integration完成。
final class FlutterSecureAuthCredentialStore implements AuthCredentialStore {
  const FlutterSecureAuthCredentialStore(this._storage);

  static const String _credentialKey = 'auth.tokens';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    final raw = await _storage.read(key: _credentialKey);
    if (raw == null) {
      return const AuthCredentialReadAbsent();
    }
    return _decodeCredential(raw);
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) {
    final userId = tokens.userId;
    if (userId == null || userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'tokens.userId', '必須是有效identity');
    }
    return _storage.write(
      key: _credentialKey,
      value: jsonEncode(tokens.toJson()),
    );
  }

  @override
  Future<void> clearCredential() {
    return _storage.delete(key: _credentialKey);
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
