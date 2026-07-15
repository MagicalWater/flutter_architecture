/// 代表目前 App 的登入 Session。
///
/// ## 為什麼 Session 不放在 Bloc？
///
/// Bloc 是 Presentation Layer 的狀態管理工具，生命週期跟畫面或 App 啟動流程有關。
///
/// Token 與 Session 屬於跨畫面的登入狀態，應該由獨立的 session 管理物件負責。
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.generation,
  });

  final String accessToken;
  final String userId;
  final int generation;

  bool get isAuthenticated => accessToken.isNotEmpty;
}
