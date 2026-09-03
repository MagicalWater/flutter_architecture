/// Access token 過期後，嘗試 refresh 的最終結果。
enum AuthRefreshResult {
  /// Refresh 成功，可以重新送出原本失敗的 request。
  success,

  /// Refresh credential 已失效，這個 Session 應視為登出。
  sessionExpired,

  /// 暫時無法 refresh，例如網路或服務短暫失敗；之後可以再試。
  temporarilyUnavailable,

  /// Refresh 期間 Session 已被其他流程替換，舊 request 不應再重送。
  sessionChanged,

  /// 本機 credential／Session 狀態讀寫失敗，無法安全繼續 refresh。
  localStateFailure,
}

/// 負責在 access token 過期時刷新 Session。
///
/// Caller 必須傳入「當時失效的 access token」，讓實作確認現在仍是同一個 Session；
/// 如果 Session 已經換掉，就不能拿新的 credential 去重送舊 Session 的 request。
abstract interface class AuthRefresher {
  Future<AuthRefreshResult> refresh({required String failedAccessToken});
}
