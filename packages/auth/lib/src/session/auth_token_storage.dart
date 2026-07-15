import 'package:auth/src/data/models/stored_auth_tokens.dart';

abstract interface class AuthTokenStorage {
  Future<void> saveTokens(StoredAuthTokens tokens);
  Future<StoredAuthTokens?> readTokens();
  Future<void> clearTokens();
}
