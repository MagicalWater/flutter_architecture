import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/router/auth_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthGuard', () {
    test('未登入時不允許進入 ProtectedRoute', () async {
      final sessionManager = SessionManager();
      final guard = AuthGuard(sessionManager);
      addTearDown(sessionManager.dispose);

      expect(guard.canNavigateToProtected, isFalse);
    });

    test('已登入時允許進入 ProtectedRoute', () async {
      final sessionManager = SessionManager();
      final guard = AuthGuard(sessionManager);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );

      expect(guard.canNavigateToProtected, isTrue);
    });

    test('Session expiration 後不再允許進入 ProtectedRoute', () async {
      final sessionManager = SessionManager();
      final guard = AuthGuard(sessionManager);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );
      expect(guard.canNavigateToProtected, isTrue);

      sessionManager.clear();

      expect(guard.canNavigateToProtected, isFalse);
    });
  });
}
