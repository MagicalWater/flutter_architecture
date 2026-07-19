import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/presentation/locale_selector_dialog.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/theme/presentation/appearance_selector_dialog.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/features/shell/presentation/shell_tab.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    final l10n = AppLocalizations.of(context);

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
          onOpenLocale: () {
            final controller = LocaleControllerScope.of(context);
            showDialog<void>(
              context: context,
              builder: (_) => LocaleSelectorDialog(controller: controller),
            );
          },
          onOpenProtected: () => context.pushRoute(const ProtectedRoute()),
          title: l10n.shellTitle,
          localeTooltip: l10n.localeSelectorTooltip,
          appearanceTooltip: l10n.shellAppearanceTooltip,
          protectedTooltip: l10n.shellProtectedTooltip,
          loginLabel: l10n.navigationLoginLabel,
          catalogLabel: l10n.navigationCatalogLabel,
          profileLabel: l10n.navigationProfileLabel,
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
    required this.onOpenLocale,
    required this.onOpenProtected,
    required this.title,
    required this.localeTooltip,
    required this.appearanceTooltip,
    required this.protectedTooltip,
    required this.loginLabel,
    required this.catalogLabel,
    required this.profileLabel,
    required this.child,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onOpenAppearance;
  final VoidCallback onOpenLocale;
  final VoidCallback onOpenProtected;
  final String title;
  final String localeTooltip;
  final String appearanceTooltip;
  final String protectedTooltip;
  final String loginLabel;
  final String catalogLabel;
  final String profileLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            tooltip: localeTooltip,
            onPressed: onOpenLocale,
            icon: const Icon(Icons.language_outlined),
          ),
          IconButton(
            tooltip: appearanceTooltip,
            onPressed: onOpenAppearance,
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: protectedTooltip,
            onPressed: onOpenProtected,
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.login),
            label: loginLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.view_list_outlined),
            label: catalogLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: profileLabel,
          ),
        ],
      ),
    );
  }
}
