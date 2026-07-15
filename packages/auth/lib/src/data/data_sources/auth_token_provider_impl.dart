import 'package:api_client/api_client.dart';
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
/// AuthTokenProviderImpl  ← 目前所在位置
///   ↓
/// AuthLocalDataSource
///   ↓
/// SharedPreferences
/// ```
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
