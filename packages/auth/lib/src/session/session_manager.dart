import 'package:auth/src/session/auth_session.dart';
import 'package:rxdart/rxdart.dart';

/// 保存 App 目前是否已登入，以及目前登入中的 access token。
///
/// Session 會被 router、Auth UI、API client 等多個地方同時讀取，因此用
/// [BehaviorSubject] 保存最新值；新的訂閱者可以立即拿到目前 Session。
class SessionManager {
  SessionManager();

  final BehaviorSubject<AuthSession?> _sessionSubject = BehaviorSubject.seeded(null);

  Stream<AuthSession?> get sessionStream => _sessionSubject.stream;

  AuthSession? get currentSession => _sessionSubject.valueOrNull;

  // generation 用來辨識「是不是同一次登入」，不是 token 版本號。
  // Login／restore／clear 會建立新的 generation；同一次登入內只換 access token 時
  // 必須保留 generation，讓多個 401 能知道自己仍屬於同一個 Session。
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
