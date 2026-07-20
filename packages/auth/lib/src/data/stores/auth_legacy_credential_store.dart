import 'package:auth/src/data/stores/auth_credential_read_result.dart';

/// Legacy Auth credential persistence boundary。
abstract interface class AuthLegacyCredentialStore {
  Future<AuthCredentialReadResult> readLegacyCredential();

  Future<void> clearLegacyCredential();
}
