import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';

enum AuthNavigationDestination { login, otp, profile }

/// App-owned Auth startup與navigation transition coordinator。
final class AuthNavigationCoordinator {
  AuthNavigationCoordinator({
    required AuthState initialState,
    required Stream<AuthState> states,
    required void Function() restoreSession,
    required void Function(AuthNavigationDestination destination) navigate,
  }) : _lastDestination = _destinationFor(initialState),
       _states = states,
       _restoreSession = restoreSession,
       _navigate = navigate;

  final Stream<AuthState> _states;
  final void Function() _restoreSession;
  final void Function(AuthNavigationDestination destination) _navigate;
  AuthNavigationDestination _lastDestination;
  bool _isDisposed = false;
  StreamSubscription<AuthState>? _subscription;

  void start() {
    if (_subscription != null || _isDisposed) return;
    _subscription = _states.listen(_onStateChanged);
    if (_lastDestination != AuthNavigationDestination.login) {
      _navigate(_lastDestination);
    }
    _restoreSession();
  }

  void _onStateChanged(AuthState state) {
    if (_isDisposed) return;
    final destination = _destinationFor(state);
    if (destination == _lastDestination) return;
    _lastDestination = destination;
    _navigate(destination);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _subscription?.cancel();
    _subscription = null;
  }
}

PageRouteInfo routeForAuthDestination(AuthNavigationDestination destination) {
  return switch (destination) {
    AuthNavigationDestination.login => const ShellRoute(
      children: <PageRouteInfo>[LoginRoute()],
    ),
    AuthNavigationDestination.otp => const OtpRoute(),
    AuthNavigationDestination.profile => const ShellRoute(
      children: <PageRouteInfo>[ProfileRoute()],
    ),
  };
}

AuthNavigationDestination _destinationFor(AuthState state) {
  if (state.isAuthenticated) return AuthNavigationDestination.profile;
  if (state.otpChallenge != null) return AuthNavigationDestination.otp;
  return AuthNavigationDestination.login;
}

Future<void> reconcileAuthDestination(
  AppRouter router,
  AuthNavigationDestination destination,
) {
  return router.replaceAll(<PageRouteInfo>[
    routeForAuthDestination(destination),
  ]);
}
