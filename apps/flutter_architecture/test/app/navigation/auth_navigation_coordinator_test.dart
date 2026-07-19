import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/navigation/auth_navigation_coordinator.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('start先訂閱state再觸發restore，authenticated時導向Profile', () async {
    final states = StreamController<AuthState>();
    addTearDown(states.close);
    final destinations = <AuthNavigationDestination>[];
    late AuthNavigationCoordinator coordinator;

    coordinator = AuthNavigationCoordinator(
      initialState: AuthState.initial(),
      states: states.stream,
      restoreSession: () {
        states.add(
          const AuthState(
            isLoading: false,
            user: AuthUser(id: 'user-1', name: 'User'),
            failure: null,
            failureOperation: null,
          ),
        );
      },
      navigate: destinations.add,
    );
    addTearDown(coordinator.dispose);

    coordinator.start();
    await Future<void>.delayed(Duration.zero);

    expect(destinations, <AuthNavigationDestination>[
      AuthNavigationDestination.profile,
    ]);
  });

  test('authenticated轉為unauthenticated時導向Login', () async {
    final states = StreamController<AuthState>();
    addTearDown(states.close);
    final destinations = <AuthNavigationDestination>[];
    final coordinator = AuthNavigationCoordinator(
      initialState: const AuthState(
        isLoading: false,
        user: AuthUser(id: 'user-1', name: 'User'),
        failure: null,
        failureOperation: null,
      ),
      states: states.stream,
      restoreSession: () {},
      navigate: destinations.add,
    );
    addTearDown(coordinator.dispose);

    coordinator.start();
    destinations.clear();
    states.add(AuthState.initial());
    await Future<void>.delayed(Duration.zero);

    expect(destinations, <AuthNavigationDestination>[
      AuthNavigationDestination.login,
    ]);
  });

  test('相同authentication狀態不重複導航', () async {
    final states = StreamController<AuthState>();
    addTearDown(states.close);
    final destinations = <AuthNavigationDestination>[];
    final coordinator = AuthNavigationCoordinator(
      initialState: AuthState.initial(),
      states: states.stream,
      restoreSession: () {},
      navigate: destinations.add,
    );
    addTearDown(coordinator.dispose);

    coordinator.start();
    states
      ..add(AuthState.initial())
      ..add(
        const AuthState(
          isLoading: true,
          user: null,
          failure: null,
          failureOperation: null,
        ),
      );
    await Future<void>.delayed(Duration.zero);

    expect(destinations, isEmpty);
  });

  test('initial authenticated會在start時reconcile到Profile', () {
    final destinations = <AuthNavigationDestination>[];
    final coordinator = AuthNavigationCoordinator(
      initialState: const AuthState(
        isLoading: false,
        user: AuthUser(id: 'user-1', name: 'User'),
        failure: null,
        failureOperation: null,
      ),
      states: const Stream<AuthState>.empty(),
      restoreSession: () {},
      navigate: destinations.add,
    );
    addTearDown(coordinator.dispose);

    coordinator.start();

    expect(destinations, <AuthNavigationDestination>[
      AuthNavigationDestination.profile,
    ]);
  });

  test('dispose後已排程state不再觸發navigation', () async {
    final states = StreamController<AuthState>();
    addTearDown(states.close);
    final destinations = <AuthNavigationDestination>[];
    final coordinator = AuthNavigationCoordinator(
      initialState: AuthState.initial(),
      states: states.stream,
      restoreSession: () {},
      navigate: destinations.add,
    );

    coordinator.start();
    await coordinator.dispose();
    states.add(
      const AuthState(
        isLoading: false,
        user: AuthUser(id: 'user-1', name: 'User'),
        failure: null,
        failureOperation: null,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(destinations, isEmpty);
  });

  test('App-owned destination明確映射到Shell child route', () {
    final profile = routeForAuthDestination(
      AuthNavigationDestination.profile,
    );
    final login = routeForAuthDestination(AuthNavigationDestination.login);

    expect(profile.routeName, ShellRoute.name);
    expect(profile.initialChildren!.single.routeName, ProfileRoute.name);
    expect(login.routeName, ShellRoute.name);
    expect(login.initialChildren!.single.routeName, LoginRoute.name);
  });
}
