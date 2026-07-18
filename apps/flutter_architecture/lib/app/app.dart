import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/app_locale_resolution.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

/// App 入口 Widget。
///
/// ## 所屬 Layer
///
/// App composition layer。
///
/// 它負責把 Router、Theme、全域設定組合起來。
class ArchitectureApp extends StatefulWidget {
  const ArchitectureApp({
    required this.themeController,
    required this.localeController,
    super.key,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  State<ArchitectureApp> createState() => _ArchitectureAppState();
}

class _ArchitectureAppState extends State<ArchitectureApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = getIt<AppRouter>();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleControllerScope(
      controller: widget.localeController,
      child: ThemeControllerScope(
        controller: widget.themeController,
        child: ArchitectureThemeBuilder(
          controller: widget.themeController,
          builder: (context, lightTheme, darkTheme, themeMode) {
            return ListenableBuilder(
              listenable: widget.localeController,
              builder: (context, _) {
                return MaterialApp.router(
                  locale: widget.localeController.locale,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appTitle,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: appSupportedLocales,
                  localeListResolutionCallback: resolveAppLocale,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  routerConfig: _router.config(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

final class ArchitectureThemeBuilder extends StatelessWidget {
  const ArchitectureThemeBuilder({
    required this.controller,
    required this.builder,
    super.key,
  });

  final ThemeController controller;
  final Widget Function(
    BuildContext context,
    ThemeData lightTheme,
    ThemeData darkTheme,
    ThemeMode themeMode,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final definition = controller.definition;
        return builder(
          context,
          definition.createLightTheme(),
          definition.createDarkTheme(),
          controller.preference.mode.materialMode,
        );
      },
    );
  }
}
