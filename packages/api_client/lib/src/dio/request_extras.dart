/// Dio request extra metadata keys。
abstract final class RequestExtras {
  static const requiresAuth = 'requiresAuth';
  static const skipAuthRefresh = 'skipAuthRefresh';
  static const authSessionGeneration = 'authSessionGeneration';
  static const authSessionUserId = 'authSessionUserId';
  static const authRetryCount = 'authRetryCount';
  static const preserveAuthSnapshot = 'preserveAuthSnapshot';
  /// Explicit opt-in for automatic replay after a successful token refresh.
  static const allowAuthReplay = 'allowAuthReplay';
}
