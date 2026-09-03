import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';

/// Auth 狀態改變後，App 應該停在哪一個主要畫面。
enum AuthNavigationDestination {
  /// 尚未登入，回到登入頁。
  login,

  /// 啟動／回前景流程要求先完成本機解鎖，顯示鎖定頁。
  locked,

  /// 登入流程正在等待 OTP 驗證。
  otp,

  /// 已完成登入，進入登入後的主畫面。
  profile,
}

/// 監聽 Auth state，只有在「目的頁真的改變」時才執行導航。
///
/// 這讓 Bloc 只負責狀態，不需要直接操作 Router，也避免同一個狀態重複觸發 replace。
final class AuthNavigationCoordinator {
  AuthNavigationCoordinator({
    required AuthState initialState,
    required Stream<AuthState> states,
    required void Function(AuthNavigationDestination destination) navigate,
  }) : _lastDestination = _destinationFor(initialState),
       _states = states,
       _navigate = navigate;

  final Stream<AuthState> _states;
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
    AuthNavigationDestination.locked => const LocalUnlockRoute(),
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
