import 'package:auth/src/session/auth_session.dart';
import 'package:auth/src/session/token_storage.dart';
import 'package:rxdart/rxdart.dart';

/// App Session 管理者。
///
/// ## 為什麼這裡使用 RxDart？
///
/// Session 是一個跨畫面的狀態，很多地方可能會想知道目前是否已登入。
///
/// [BehaviorSubject] 可以保存最後一次狀態，新的訂閱者一訂閱就能拿到目前 session。
///
/// 第一階段不做複雜 stream 範例，只用這裡展示 RxDart 的實務用途。
class SessionManager {
  SessionManager(this._tokenStorage);

  final TokenStorage _tokenStorage;
  final BehaviorSubject<AuthSession?> _sessionSubject = BehaviorSubject.seeded(null);

  Stream<AuthSession?> get sessionStream => _sessionSubject.stream;

  AuthSession? get currentSession => _sessionSubject.valueOrNull;

  Future<void> restore() async {
    final token = await _tokenStorage.readAccessToken();

    if (token == null || token.isEmpty) {
      _sessionSubject.add(null);
      return;
    }

    _sessionSubject.add(
      AuthSession(
        accessToken: token,
        userId: 'mock-user-id',
      ),
    );
  }

  Future<void> login({
    required String accessToken,
    required String userId,
  }) async {
    await _tokenStorage.saveAccessToken(accessToken);

    _sessionSubject.add(
      AuthSession(
        accessToken: accessToken,
        userId: userId,
      ),
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clearAccessToken();
    _sessionSubject.add(null);
  }

  Future<void> dispose() async {
    await _sessionSubject.close();
  }
}
