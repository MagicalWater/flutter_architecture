/// API request 開始送出時，記下當下使用的是哪一個登入 Session。
///
/// [generation] 讓 401 refresh 流程可以判斷「現在還是不是同一次登入」；如果使用者已經
/// 登出再登入，就不能拿新 Session 的 token 去重送舊 request。
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

/// 讓 API interceptor 取得目前 Session，而不用知道 Session 實際存在哪裡或怎麼保存。
abstract interface class AuthTokenProvider {
  AuthSessionSnapshot? getCurrentSession();
}
