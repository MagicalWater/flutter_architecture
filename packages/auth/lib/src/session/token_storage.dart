/// Token 保存抽象。
///
/// ## 所屬責任
///
/// 它只知道如何保存與讀取 token，不知道 Login API，也不知道 UI。
abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);

  Future<String?> readAccessToken();

  Future<void> clearAccessToken();
}
