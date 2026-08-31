import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/auth/local_unlock_lifecycle_coordinator.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_scope.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_controller.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_scope.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_status_banner.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/app_locale_resolution.dart';
import 'package:flutter_architecture/app/navigation/auth_navigation_coordinator.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/ui/app_ui_design.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

/// App 入口 Widget。
///
/// ## 所屬 Layer
///
/// App composition layer 的根 Widget。
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

class _ArchitectureAppState extends State<ArchitectureApp>
    with WidgetsBindingObserver {
  late final AppRouter _router;
  late final AuthNavigationCoordinator _authNavigationCoordinator;
  late final StartupLocalUnlockCoordinator _startupLocalUnlockCoordinator;
  late final LocalUnlockLifecycleCoordinator _localUnlockLifecycleCoordinator;
  late final ConnectivityController _connectivityController;
  final Stopwatch _monotonicClock = Stopwatch()..start();
  bool _authNavigationStarted = false;

  @override
  void initState() {
    super.initState();
    _router = getIt<AppRouter>();
    _connectivityController = getIt<ConnectivityController>();
    unawaited(_connectivityController.start());
    final authBloc = getIt<AuthBloc>();
    _authNavigationCoordinator = AuthNavigationCoordinator(
      initialState: authBloc.state,
      states: authBloc.stream,
      navigate: (destination) {
        unawaited(reconcileAuthDestination(_router, destination));
      },
    );
    _startupLocalUnlockCoordinator = StartupLocalUnlockCoordinator(
      preferenceStore: getIt<LocalUnlockPreferenceStore>(),
      verifier: getIt<LocalUserPresenceVerifier>(),
      sessionManager: getIt<SessionManager>(),
      mutationCoordinator: getIt<AuthStateMutationCoordinator>(),
      restoreSession: () => authBloc.add(const AuthEvent.started()),
    );
    _startupLocalUnlockCoordinator.addListener(_onLocalUnlockStateChanged);
    _localUnlockLifecycleCoordinator = LocalUnlockLifecycleCoordinator(
      unlockCoordinator: _startupLocalUnlockCoordinator,
      preferenceStore: getIt<LocalUnlockPreferenceStore>(),
      sessionManager: getIt<SessionManager>(),
      now: () => _monotonicClock.elapsed,
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _authNavigationStarted) return;
      _authNavigationStarted = true;
      unawaited(_startAuthFlow());
    });
  }

  Future<void> _startAuthFlow() async {
    await _startupLocalUnlockCoordinator.start();
    if (!mounted) return;
    _authNavigationCoordinator.start();
    _onLocalUnlockStateChanged();
  }

  void _onLocalUnlockStateChanged() {
    if (!mounted) return;
    final state = _startupLocalUnlockCoordinator.state;
    if (_startupLocalUnlockCoordinator.requiresUnlockSurface) {
      unawaited(
        reconcileAuthDestination(_router, AuthNavigationDestination.locked),
      );
    } else if (state == StartupLocalUnlockState.serverLoginRequested) {
      unawaited(
        reconcileAuthDestination(_router, AuthNavigationDestination.login),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        _localUnlockLifecycleCoordinator.onBackgrounded();
      case AppLifecycleState.resumed:
        unawaited(_localUnlockLifecycleCoordinator.onResumed());
        unawaited(_connectivityController.recheck());
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _startupLocalUnlockCoordinator.removeListener(_onLocalUnlockStateChanged);
    _startupLocalUnlockCoordinator.dispose();
    _authNavigationCoordinator.dispose();
    unawaited(_connectivityController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StartupLocalUnlockCoordinatorScope(
      coordinator: _startupLocalUnlockCoordinator,
      child: ScreenUtilInit(
        designSize: AppUiDesign.designSize,
        splitScreenMode: false,
        child: LocaleControllerScope(
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
                      builder: (context, child) => ConnectivityScope(
                        controller: _connectivityController,
                        child: ConnectivityStatusBanner(
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                      routerConfig: _router.config(),
                    );
                  },
                );
              },
            ),
          ),
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
