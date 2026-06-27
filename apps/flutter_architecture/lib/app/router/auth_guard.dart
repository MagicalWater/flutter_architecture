import 'package:auth/auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:injectable/injectable.dart';

/// 需要登入才能進入的 Route Guard。
///
/// ## Runtime Flow
///
/// ```txt
/// 使用者點擊 ProtectedPage
///   ↓
/// AuthGuard 檢查 SessionManager.currentSession
///   ↓
/// 已登入：resolver.next(true)
///   ↓
/// 未登入：導向 ShellPage 內的 LoginRoute
/// ```
@lazySingleton
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isAuthenticated = _sessionManager.isAuthenticated;

    if (isAuthenticated) {
      resolver.next(true);
      return;
    }

    router.replace(
      const ShellRoute(
        children: <PageRouteInfo>[
          LoginRoute(),
        ],
      ),
    );
    resolver.next(false);
  }
}
