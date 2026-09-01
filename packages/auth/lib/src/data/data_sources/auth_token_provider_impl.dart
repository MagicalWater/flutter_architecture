import 'package:api_client/api_client_infrastructure.dart';
import 'package:auth/src/session/session_manager.dart';

/// Dio interceptor 使用的 token provider 實作。
///
/// ## Runtime Flow
///
/// ```txt
/// Dio request
///   ↓
/// AuthHeaderInterceptor
///   ↓
/// AuthTokenProvider
///   ↓
/// AuthTokenProviderImpl
///   ↓
/// SessionManager runtime snapshot
/// ```
///
/// 此 adapter 不讀取 durable credential；request token authority 只來自目前
/// runtime Session，避免 transport layer 繞過 Auth lifecycle 直接碰 persistence。
class AuthTokenProviderImpl implements AuthTokenProvider {
  const AuthTokenProviderImpl(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  AuthSessionSnapshot? getCurrentSession() {
    final session = _sessionManager.currentSession;
    if (session == null) return null;
    return AuthSessionSnapshot(
      accessToken: session.accessToken,
      userId: session.userId,
      generation: session.generation,
    );
  }
}
