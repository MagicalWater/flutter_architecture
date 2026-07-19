import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';

enum AuthNavigationDestination { login, profile }

/// App-owned Auth startup與navigation transition coordinator。
final class AuthNavigationCoordinator {
  AuthNavigationCoordinator({
    required AuthState initialState,
    required Stream<AuthState> states,
    required void Function() restoreSession,
    required void Function(AuthNavigationDestination destination) navigate,
  }) : _wasAuthenticated = initialState.isAuthenticated,
       _states = states,
       _restoreSession = restoreSession,
       _navigate = navigate;

  final Stream<AuthState> _states;
  final void Function() _restoreSession;
  final void Function(AuthNavigationDestination destination) _navigate;
  bool _wasAuthenticated;
  StreamSubscription<AuthState>? _subscription;

  void start() {
    if (_subscription != null) return;
    _subscription = _states.listen(_onStateChanged);
    _restoreSession();
  }

  void _onStateChanged(AuthState state) {
    final isAuthenticated = state.isAuthenticated;
    if (isAuthenticated == _wasAuthenticated) return;

    _wasAuthenticated = isAuthenticated;
    _navigate(
      isAuthenticated
          ? AuthNavigationDestination.profile
          : AuthNavigationDestination.login,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

PageRouteInfo routeForAuthDestination(AuthNavigationDestination destination) {
  return switch (destination) {
    AuthNavigationDestination.login => const ShellRoute(
      children: <PageRouteInfo>[LoginRoute()],
    ),
    AuthNavigationDestination.profile => const ShellRoute(
      children: <PageRouteInfo>[ProfileRoute()],
    ),
  };
}
