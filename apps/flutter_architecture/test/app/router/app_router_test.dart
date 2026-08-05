import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/router/auth_guard.dart';
import 'package:flutter_architecture/features/shell/presentation/shell_tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter', () {
    test(
      'ShellRoute 包含 LoginRoute、CatalogRoute 與 ProfileRoute nested routes',
      () {
        final sessionManager = SessionManager();
        final router = AppRouter(AuthGuard(sessionManager));
        addTearDown(sessionManager.dispose);

        final routes = router.routes;
        final shellRoute = routes.first;

        expect(shellRoute.page.name, ShellRoute.name);
        expect(shellRoute.initial, isTrue);
        final shellChildren = shellRoute.children!.toList();

        expect(shellChildren, hasLength(3));
        expect(shellChildren[0].page.name, LoginRoute.name);
        expect(shellChildren[0].initial, isTrue);
        expect(shellChildren[1].page.name, CatalogRoute.name);
        expect(shellChildren[2].page.name, ProfileRoute.name);
        expect(
          shellChildren[ShellTab.profile.index].page.name,
          ProfileRoute.name,
        );
      },
    );

    test('ProtectedRoute 掛上 AuthGuard', () {
      final sessionManager = SessionManager();
      final authGuard = AuthGuard(sessionManager);
      final router = AppRouter(authGuard);
      addTearDown(sessionManager.dispose);

      final protectedRoute = router.routes.firstWhere(
        (route) => route.page.name == ProtectedRoute.name,
      );

      expect(protectedRoute.guards, contains(authGuard));
    });

    test('WritePrecheckRoute 是獨立、無 guard 且非 initial 的 top-level route', () {
      final sessionManager = SessionManager();
      final router = AppRouter(AuthGuard(sessionManager));
      addTearDown(sessionManager.dispose);

      final route = router.routes.singleWhere(
        (candidate) => candidate.page.name == WritePrecheckRoute.name,
      );

      expect(route.initial, isFalse);
      expect(route.guards, isEmpty);
      expect(router.routes.first.page.name, ShellRoute.name);
    });
  });
}
