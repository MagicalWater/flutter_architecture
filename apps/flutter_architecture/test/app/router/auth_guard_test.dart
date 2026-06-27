import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/router/auth_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthGuard', () {
    test('未登入時不允許進入 ProtectedRoute', () async {
      final sessionManager = SessionManager(_MemoryTokenStorage());
      final guard = AuthGuard(sessionManager);
      addTearDown(sessionManager.dispose);

      expect(guard.canNavigateToProtected, isFalse);
    });

    test('已登入時允許進入 ProtectedRoute', () async {
      final sessionManager = SessionManager(_MemoryTokenStorage());
      final guard = AuthGuard(sessionManager);
      addTearDown(sessionManager.dispose);

      await sessionManager.login(
        accessToken: 'access-token',
        userId: 'user-1',
      );

      expect(guard.canNavigateToProtected, isTrue);
    });
  });
}

class _MemoryTokenStorage implements TokenStorage {
  String? _accessToken;

  @override
  Future<void> clearAccessToken() async {
    _accessToken = null;
  }

  @override
  Future<String?> readAccessToken() async {
    return _accessToken;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }
}
