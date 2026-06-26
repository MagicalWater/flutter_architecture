import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// ShellPage，也就是需求中的 A 頁面。
///
/// ## 頁面關係
///
/// ```txt
/// ShellPage(A)
///   ├── LoginPage(B)
///   ├── ProfilePage(C)
///   └── ProtectedPage(D)
/// ```
///
/// LoginPage 與 ProfilePage 位於 ShellPage 的 body 區域。
/// ProtectedPage 透過 AppBar action 開啟，並由 Route Guard 保護。
@RoutePage()
class ShellPage extends HookWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = useBloc<AuthBloc>();

    useEffect(
      () {
        authBloc.add(const AuthEvent.started());
        return null;
      },
      const <Object?>[],
    );

    return AutoTabsRouter(
      routes: const <PageRouteInfo>[
        LoginRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Architecture'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Protected Page',
                onPressed: () => context.pushRoute(const ProtectedRoute()),
                icon: const Icon(Icons.lock_outline),
              ),
            ],
          ),
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: tabsRouter.setActiveIndex,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.login),
                label: 'Login',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
