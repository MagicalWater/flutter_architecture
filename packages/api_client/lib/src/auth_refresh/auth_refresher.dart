sealed class AuthRefreshResult {
  const AuthRefreshResult();
}

final class AuthRefreshSuccess extends AuthRefreshResult {
  const AuthRefreshSuccess();
}

final class AuthRefreshSessionExpired extends AuthRefreshResult {
  const AuthRefreshSessionExpired();
}

final class AuthRefreshTemporarilyUnavailable extends AuthRefreshResult {
  const AuthRefreshTemporarilyUnavailable();
}

final class AuthRefreshSessionChanged extends AuthRefreshResult {
  const AuthRefreshSessionChanged();
}

final class AuthRefreshLocalStateFailure extends AuthRefreshResult {
  const AuthRefreshLocalStateFailure();
}

abstract interface class AuthRefresher {
  Future<AuthRefreshResult> refresh({required String failedAccessToken});
}
