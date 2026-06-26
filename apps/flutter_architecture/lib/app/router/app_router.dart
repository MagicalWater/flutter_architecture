import 'package:auto_route/auto_route.dart';
import 'package:flutter_architecture/app/router/auth_guard.dart';
import 'package:flutter_architecture/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_architecture/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_architecture/features/protected/presentation/pages/protected_page.dart';
import 'package:flutter_architecture/features/shell/presentation/pages/shell_page.dart';
import 'package:injectable/injectable.dart';

part 'app_router.gr.dart';

/// App Router。
///
/// ## Runtime Flow
///
/// ```txt
/// MaterialApp.router
///   ↓
/// AppRouter
///   ↓
/// ShellRoute(A)
///   ├── LoginRoute(B)
///   ├── ProfileRoute(C)
///   └── ProtectedRoute(D, guarded)
/// ```
@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this._authGuard);

  final AuthGuard _authGuard;

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(
          page: ShellRoute.page,
          initial: true,
          children: <AutoRoute>[
            AutoRoute(page: LoginRoute.page, initial: true),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
        AutoRoute(
          page: ProtectedRoute.page,
          guards: <AutoRouteGuard>[_authGuard],
        ),
      ];
}
