/// 給 Dio interceptor 使用的 token provider。
///
/// ## 為什麼不讓 interceptor 直接依賴 SharedPreferences？
///
/// Interceptor 只需要知道「目前 token 是什麼」。
///
/// token 從哪裡來，應該交給外部實作決定。
abstract interface class AuthTokenProvider {
  Future<String?> getAccessToken();
}
