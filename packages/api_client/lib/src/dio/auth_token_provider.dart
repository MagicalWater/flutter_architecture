/// Interceptor request admission 所需的 immutable Session identity snapshot。
class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.accessToken,
    required this.userId,
    required this.generation,
  });

  final String accessToken;
  final String userId;
  final int generation;
}

/// 提供目前 Auth Session snapshot，隔離 interceptor 與 credential persistence 實作。
abstract interface class AuthTokenProvider {
  AuthSessionSnapshot? getCurrentSession();
}
