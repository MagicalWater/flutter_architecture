import 'package:auth/src/data/models/stored_auth_tokens.dart';

/// Refresh flow 所需的最小本地資料邊界。
abstract interface class AuthRefreshLocalStore {
  Future<StoredAuthTokens?> readTokens();

  Future<void> saveTokens(StoredAuthTokens tokens);

  Future<void> clearTokens();

  Future<void> clearUser();
}
