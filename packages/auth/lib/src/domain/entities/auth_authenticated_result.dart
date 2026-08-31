import 'package:auth/src/domain/entities/auth_user.dart';

/// 帶有 credential 的 authentication success payload。
final class AuthAuthenticatedResult {
  const AuthAuthenticatedResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  @override
  String toString() => 'AuthAuthenticatedResult()';
}
