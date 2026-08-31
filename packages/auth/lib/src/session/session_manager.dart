import 'package:auth/src/session/auth_session.dart';
import 'package:rxdart/rxdart.dart';

/// App Session 管理者。
///
/// ## 為什麼這裡使用 RxDart？
///
/// Session 是一個跨畫面的狀態，很多地方可能會想知道目前是否已登入。
///
/// [BehaviorSubject] 可以保存最後一次狀態，新的訂閱者一訂閱就能拿到目前 session。
class SessionManager {
  SessionManager();

  final BehaviorSubject<AuthSession?> _sessionSubject = BehaviorSubject.seeded(null);

  Stream<AuthSession?> get sessionStream => _sessionSubject.stream;

  AuthSession? get currentSession => _sessionSubject.valueOrNull;

  // generation 是 Session lifecycle identity，不是 access-token revision。
  // Login / restore / clear 會跨 lifecycle boundary；同一 Session 內的 token
  // rotation 必須保留 generation，讓並發 401 能辨識「同一登入生命週期」。
  int _generation = 0;

  int get generation => _generation;

  bool get isAuthenticated => currentSession?.isAuthenticated ?? false;

  void setAuthenticated({
    required String accessToken,
    required String userId,
  }) {
    _generation += 1;
    _sessionSubject.add(
      AuthSession(
        accessToken: accessToken,
        userId: userId,
        generation: _generation,
      ),
    );
  }

  void updateAccessToken(String accessToken) {
    final session = currentSession;
    if (session == null) return;
    _sessionSubject.add(
      AuthSession(
        accessToken: accessToken,
        userId: session.userId,
        generation: session.generation,
      ),
    );
  }

  void clear() {
    _generation += 1;
    _sessionSubject.add(null);
  }

  Future<void> dispose() async {
    await _sessionSubject.close();
  }
}
