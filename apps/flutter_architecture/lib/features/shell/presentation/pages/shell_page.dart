import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/theme/presentation/appearance_selector_dialog.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/features/shell/presentation/shell_tab.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// ShellPage，也就是需求中的 A 頁面。
///
/// ## 頁面關係
///
/// ```txt
/// ShellPage(A)
///   ├── LoginPage(B)
///   ├── CatalogPage(C)
///   ├── ProfilePage(D)
///   └── ProtectedPage(E)
/// ```
///
/// LoginPage、CatalogPage 與 ProfilePage 位於 ShellPage 的 body 區域。
/// ProtectedPage 透過 AppBar action 開啟，並由 Route Guard 保護。
@RoutePage()
class ShellPage extends HookWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = useBloc<AuthBloc>();

    useEffect(() {
      authBloc.add(const AuthEvent.started());
      return null;
    }, const <Object?>[]);

    return AutoTabsRouter(
      routes: const <PageRouteInfo>[
        LoginRoute(),
        CatalogRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return ShellScaffold(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) {
            tabsRouter.setActiveIndex(ShellTab.values[index].index);
          },
          onOpenAppearance: () {
            final controller = ThemeControllerScope.of(context);
            showDialog<void>(
              context: context,
              builder: (_) => AppearanceSelectorDialog(controller: controller),
            );
          },
          onOpenProtected: () => context.pushRoute(const ProtectedRoute()),
          child: child,
        );
      },
    );
  }
}

final class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onOpenAppearance,
    required this.onOpenProtected,
    required this.child,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onOpenAppearance;
  final VoidCallback onOpenProtected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Architecture'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Appearance',
            onPressed: onOpenAppearance,
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: 'Protected Page',
            onPressed: onOpenProtected,
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.login), label: 'Login'),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined),
            label: 'Catalog',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
