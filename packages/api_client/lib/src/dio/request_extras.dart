/// Dio request extra metadata keys。
abstract final class RequestExtras {
  static const requiresAuth = 'requiresAuth';
  static const skipAuthRefresh = 'skipAuthRefresh';
  // 捕捉 request 送出時所屬的 Session lifecycle identity，避免舊 request
  // 跨 logout / relogin / session replacement boundary 被新 credential replay。
  static const authSessionGeneration = 'authSessionGeneration';
  static const authSessionUserId = 'authSessionUserId';
  // 自動 replay 最多一次；再次 401 不可重新進入 refresh flow。
  static const authRetryCount = 'authRetryCount';
  // Replay request 必須保留已核准的 Auth snapshot，不能在送出前被 header
  // interceptor 靜默換成另一個 Session 的 credential。
  static const preserveAuthSnapshot = 'preserveAuthSnapshot';
  /// 明確 opt in refresh 後的自動 replay；未 opt in 的 request 一律不重送。
  static const allowAuthReplay = 'allowAuthReplay';
}
