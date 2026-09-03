import 'package:auth/src/data/stores/auth_credential_read_result.dart';

/// 只負責讀取與清除舊版本留下的登入憑證。
///
/// Migration 成功後應把資料搬到正式的 [AuthCredentialStore]，之後這裡只剩相容與清理用途。
abstract interface class AuthLegacyCredentialStore {
  Future<AuthCredentialReadResult> readLegacyCredential();

  Future<void> clearLegacyCredential();
}
