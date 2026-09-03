import 'package:auth/src/data/models/stored_auth_tokens.dart';

/// 從 credential storage 讀取時，明確區分「沒有資料」和「資料壞掉」。
///
/// 沒資料和資料損壞都屬於可預期狀態；如果 storage 本身壞掉或無法存取，則直接拋例外。
sealed class AuthCredentialReadResult {
  const AuthCredentialReadResult();
}

/// Storage 裡沒有任何可用 credential。
final class AuthCredentialReadAbsent extends AuthCredentialReadResult {
  const AuthCredentialReadAbsent();
}

/// Credential 存在，而且格式與必要欄位都有效。
final class AuthCredentialReadPresent extends AuthCredentialReadResult {
  const AuthCredentialReadPresent(this.tokens);

  final StoredAuthTokens tokens;

  @override
  String toString() => 'AuthCredentialReadPresent()';
}

/// Storage 裡有資料，但內容已損壞、格式不對或缺必要欄位。
final class AuthCredentialReadCorrupted extends AuthCredentialReadResult {
  const AuthCredentialReadCorrupted();
}
