import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';

/// 目前權威 Auth credential persistence boundary。
abstract interface class AuthCredentialStore {
  Future<AuthCredentialReadResult> readCredential();

  Future<void> writeCredential(StoredAuthTokens tokens);

  Future<void> clearCredential();
}
