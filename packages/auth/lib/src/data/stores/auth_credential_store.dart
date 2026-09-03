import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';

/// 讀寫目前正式使用的登入憑證。
///
/// 實作通常會把 access token、refresh token 與 user identity 存在安全 storage；
/// 舊版 SharedPreferences credential 不走這個介面，而由 [AuthLegacyCredentialStore] 處理。
abstract interface class AuthCredentialStore {
  Future<AuthCredentialReadResult> readCredential();

  Future<void> writeCredential(StoredAuthTokens tokens);

  Future<void> clearCredential();
}
