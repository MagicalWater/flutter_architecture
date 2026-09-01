/// Refresh flow 的有限結果集合；各狀態沒有額外 payload，不需要 sealed hierarchy。
enum AuthRefreshResult {
  success,
  sessionExpired,
  temporarilyUnavailable,
  sessionChanged,
  localStateFailure,
}

/// 以 request 當下失效的 access token 作 refresh admission，避免跨 Session 誤重送。
abstract interface class AuthRefresher {
  Future<AuthRefreshResult> refresh({required String failedAccessToken});
}
