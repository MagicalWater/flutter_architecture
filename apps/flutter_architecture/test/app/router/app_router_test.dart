import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/router/auth_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter', () {
    test('ShellRoute 包含 LoginRoute 與 ProfileRoute nested routes', () {
      final sessionManager = SessionManager(_MemoryTokenStorage());
      final router = AppRouter(AuthGuard(sessionManager));
      addTearDown(sessionManager.dispose);

      final routes = router.routes;
      final shellRoute = routes.first;

      expect(shellRoute.page.name, ShellRoute.name);
      expect(shellRoute.initial, isTrue);
      final shellChildren = shellRoute.children!.toList();

      expect(shellChildren, hasLength(2));
      expect(shellChildren[0].page.name, LoginRoute.name);
      expect(shellChildren[0].initial, isTrue);
      expect(shellChildren[1].page.name, ProfileRoute.name);
    });

    test('ProtectedRoute 掛上 AuthGuard', () {
      final sessionManager = SessionManager(_MemoryTokenStorage());
      final authGuard = AuthGuard(sessionManager);
      final router = AppRouter(authGuard);
      addTearDown(sessionManager.dispose);

      final protectedRoute = router.routes.firstWhere(
        (route) => route.page.name == ProtectedRoute.name,
      );

      expect(protectedRoute.guards, contains(authGuard));
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
