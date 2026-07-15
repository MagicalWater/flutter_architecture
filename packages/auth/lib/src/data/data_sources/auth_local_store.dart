import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';

/// Auth Repository 使用的本地資料邊界。
abstract interface class AuthLocalStore {
  Future<void> saveTokens(StoredAuthTokens tokens);

  Future<StoredAuthTokens?> readTokens();

  Future<void> clearTokens();

  Future<void> saveUser(AuthUserModel user);

  Future<AuthUserModel?> readUser();

  Future<void> clearUser();
}
