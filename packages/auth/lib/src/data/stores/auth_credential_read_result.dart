import 'package:auth/src/data/models/stored_auth_tokens.dart';

/// Auth credential 讀取結果。
///
/// Absence 與 payload corruption 是可由呼叫端明確處理的資料狀態；
/// storage unavailable 等 operational failure 仍應以 typed exception 表達。
sealed class AuthCredentialReadResult {
  const AuthCredentialReadResult();
}

/// Credential 不存在。
final class AuthCredentialReadAbsent extends AuthCredentialReadResult {
  const AuthCredentialReadAbsent();
}

/// Credential 存在且通過 payload validation。
final class AuthCredentialReadPresent extends AuthCredentialReadResult {
  const AuthCredentialReadPresent(this.tokens);

  final StoredAuthTokens tokens;

  @override
  String toString() => 'AuthCredentialReadPresent()';
}

/// Credential payload 存在但格式或內容無效。
final class AuthCredentialReadCorrupted extends AuthCredentialReadResult {
  const AuthCredentialReadCorrupted();
}
