import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
    test('Login 成功後進入 authenticated state', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      final mutationCoordinator = AuthStateMutationCoordinator();
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(account: 'demo', password: 'password'),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          predicate<AuthState>((state) => state.isLoading),
          predicate<AuthState>(
            (state) =>
                !state.isLoading &&
                state.isAuthenticated &&
                state.user?.name == 'Demo User' &&
                state.failure == null &&
                state.failureOperation == null,
          ),
        ]),
      );
    });

    test('Login 失敗時保持未登入並顯示錯誤', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(
        sessionManager,
        loginResult: const FailureResult<AuthLoginResult>(
          Failure(message: 'login failed'),
        ),
      );
      final mutationCoordinator = AuthStateMutationCoordinator();
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(account: 'demo', password: 'wrong'),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          predicate<AuthState>((state) => state.isLoading),
          predicate<AuthState>(
            (state) =>
                !state.isLoading &&
                !state.isAuthenticated &&
                state.failure?.message == 'login failed' &&
                state.failureOperation == AuthFailureOperation.login,
          ),
        ]),
      );
    });

    test('Login unknown error 保留 framework error flow，不降級為 Failure', () async {
      final sessionManager = SessionManager();
      final unknownError = StateError('login unknown');
      final repository = _FakeAuthRepository(
        sessionManager,
        loginError: unknownError,
      );
      late AuthBloc bloc;
      final mutationCoordinator = AuthStateMutationCoordinator();
      final errors = <Object>[];
      final errorCaptured = Completer<void>();

      await runZonedGuarded(
        () async {
          bloc = AuthBloc(
            LoginUseCase(repository),
            RestoreSessionUseCase(repository),
            LogoutUseCase(repository),
            sessionManager,
            mutationCoordinator,
          );
          bloc.add(
            const AuthEvent.loginRequested(
              account: 'demo',
              password: 'password',
            ),
          );
          await errorCaptured.future.timeout(const Duration(seconds: 1));
        },
        (error, stackTrace) {
          errors.add(error);
          if (!errorCaptured.isCompleted) errorCaptured.complete();
        },
      );

      expect(errors, contains(same(unknownError)));
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.failure, isNull);
      expect(bloc.state.failureOperation, isNull);

      await bloc.close();
      await sessionManager.dispose();
    });

    test('Logout 成功後清除 authenticated user', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      final mutationCoordinator = AuthStateMutationCoordinator();
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(account: 'demo', password: 'password'),
      );
      await bloc.stream.firstWhere((state) => state.isAuthenticated);

      bloc.add(const AuthEvent.logoutRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          predicate<AuthState>(
            (state) => state.isLoading && state.isAuthenticated,
          ),
          predicate<AuthState>(
            (state) => !state.isLoading && !state.isAuthenticated,
          ),
        ]),
      );
    });

    test('Logout 失敗時保留 authenticated user 並顯示錯誤', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(
        sessionManager,
        logoutResult: const FailureResult<void>(
          Failure(message: 'logout failed'),
        ),
      );
      final mutationCoordinator = AuthStateMutationCoordinator();
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(account: 'demo', password: 'password'),
      );
      await bloc.stream.firstWhere((state) => state.isAuthenticated);

      bloc.add(const AuthEvent.logoutRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          predicate<AuthState>(
            (state) => state.isLoading && state.isAuthenticated,
          ),
          predicate<AuthState>(
            (state) =>
                !state.isLoading &&
                state.isAuthenticated &&
                state.user?.name == 'Demo User' &&
                state.failure?.message == 'logout failed' &&
                state.failureOperation == AuthFailureOperation.logout,
          ),
        ]),
      );
    });

    test('App 啟動時可以 restore 已存在的 session', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      await repository.login(account: 'demo', password: 'password');
      final mutationCoordinator = AuthStateMutationCoordinator();
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(const AuthEvent.started());

      await expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          predicate<AuthState>((state) => state.isLoading),
          predicate<AuthState>(
            (state) =>
                !state.isLoading &&
                state.isAuthenticated &&
                state.user?.name == 'Demo User',
          ),
        ]),
      );
    });

    test('Double Login 反向完成時不會讓舊結果覆蓋最新 UI state', () async {
      final sessionManager = SessionManager();
      final mutationCoordinator = AuthStateMutationCoordinator();
      final repository = _ControlledAuthRepository(
        sessionManager,
        mutationCoordinator,
      );
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);

      bloc.add(
        const AuthEvent.loginRequested(account: 'user-a', password: 'password'),
      );
      await repository.loginStarted('user-a');

      bloc.add(
        const AuthEvent.loginRequested(account: 'user-b', password: 'password'),
      );
      await repository.loginStarted('user-b');

      repository.completeLogin('user-b');
      await bloc.stream.firstWhere((state) => state.user?.id == 'user-b');

      repository.completeLogin('user-a');
      await repository.loginFinished('user-a');
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.user?.id, 'user-b');
      expect(states.where((state) => state.user?.id == 'user-a'), isEmpty);
    });

    test('Logout 完成後舊 Login 不會重新建立 authenticated UI state', () async {
      final sessionManager = SessionManager();
      final mutationCoordinator = AuthStateMutationCoordinator();
      final repository = _ControlledAuthRepository(
        sessionManager,
        mutationCoordinator,
      );
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);

      bloc.add(
        const AuthEvent.loginRequested(account: 'user-a', password: 'password'),
      );
      await repository.loginStarted('user-a');

      bloc.add(const AuthEvent.logoutRequested());
      await repository.logoutFinished;
      await bloc.stream.firstWhere(
        (state) => !state.isLoading && !state.isAuthenticated,
      );

      repository.completeLogin('user-a');
      await repository.loginFinished('user-a');
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isAuthenticated, isFalse);
      expect(states.where((state) => state.user?.id == 'user-a'), isEmpty);
    });

    test('較新 Login 接管 Restore loading 與最終 UI state', () async {
      final sessionManager = SessionManager();
      final mutationCoordinator = AuthStateMutationCoordinator();
      final repository = _ControlledAuthRepository(
        sessionManager,
        mutationCoordinator,
      );
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(const AuthEvent.started());
      await repository.restoreStarted;

      bloc.add(
        const AuthEvent.loginRequested(account: 'user-b', password: 'password'),
      );
      await repository.loginStarted('user-b');

      repository.completeRestore();
      await repository.restoreFinished;
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.user, isNull);

      repository.completeLogin('user-b');
      await bloc.stream.firstWhere((state) => state.user?.id == 'user-b');

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.user?.id, 'user-b');
    });

    test('外部 Session clear 會使尚未完成的舊 Login 失效', () async {
      final sessionManager = SessionManager();
      final mutationCoordinator = AuthStateMutationCoordinator();
      final repository = _ControlledAuthRepository(
        sessionManager,
        mutationCoordinator,
      );
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(account: 'user-a', password: 'password'),
      );
      await repository.loginStarted('user-a');
      expect(bloc.state.isLoading, isTrue);

      sessionManager.clear();
      await bloc.stream.firstWhere(
        (state) => !state.isLoading && !state.isAuthenticated,
      );

      repository.completeLogin('user-a');
      await repository.loginFinished('user-a');
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isAuthenticated, isFalse);
      expect(sessionManager.currentSession, isNull);
    });

    test('SessionManager 被其他 feature 清空時，AuthBloc 會同步清除 user', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      final mutationCoordinator = AuthStateMutationCoordinator();
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
        mutationCoordinator,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(account: 'demo', password: 'password'),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          predicate<AuthState>((state) => state.isLoading),
          predicate<AuthState>(
            (state) =>
                !state.isLoading &&
                state.isAuthenticated &&
                state.user?.name == 'Demo User',
          ),
        ]),
      );

      sessionManager.clear();

      await expectLater(
        bloc.stream,
        emits(
          predicate<AuthState>(
            (state) => !state.isLoading && !state.isAuthenticated,
          ),
        ),
      );
    });
  });
}

class _ControlledAuthRepository implements AuthRepository {
  _ControlledAuthRepository(this._sessionManager, this._mutationCoordinator);

  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  final Map<String, Completer<void>> _loginCompletions = {};
  final Map<String, Completer<void>> _loginStarted = {};
  final Map<String, Completer<void>> _loginFinished = {};
  final Completer<void> _restoreCompletion = Completer<void>();
  final Completer<void> _restoreStarted = Completer<void>();
  final Completer<void> _restoreFinished = Completer<void>();
  final Completer<void> _logoutFinished = Completer<void>();

  Future<void> loginStarted(String account) =>
      (_loginStarted[account] ??= Completer<void>()).future;

  Future<void> loginFinished(String account) =>
      (_loginFinished[account] ??= Completer<void>()).future;

  void completeLogin(String account) {
    (_loginCompletions[account] ??= Completer<void>()).complete();
  }

  Future<void> get restoreStarted => _restoreStarted.future;
  Future<void> get restoreFinished => _restoreFinished.future;
  Future<void> get logoutFinished => _logoutFinished.future;

  void completeRestore() => _restoreCompletion.complete();

  @override
  Future<Result<AuthLoginResult>> login({
    required String account,
    required String password,
  }) async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    final started = _loginStarted[account] ??= Completer<void>();
    if (!started.isCompleted) started.complete();

    try {
      await (_loginCompletions[account] ??= Completer<void>()).future;
      operation.throwIfSuperseded();

      final user = AuthUser(id: account, name: account);
      _sessionManager.setAuthenticated(
        accessToken: 'access-$account',
        userId: account,
      );
      return Success(
        AuthLoginResult.authenticated(
          AuthResult(
            accessToken: 'access-$account',
            refreshToken: 'refresh-$account',
            user: user,
          ),
        ),
      );
    } finally {
      final finished = _loginFinished[account] ??= Completer<void>();
      if (!finished.isCompleted) finished.complete();
    }
  }

  @override
  Future<Result<void>> logout() async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    operation.throwIfSuperseded();
    _sessionManager.clear();
    if (!_logoutFinished.isCompleted) _logoutFinished.complete();
    return const Success(null);
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    final operation = _mutationCoordinator.beginLifecycleOperation();
    if (!_restoreStarted.isCompleted) _restoreStarted.complete();

    try {
      await _restoreCompletion.future;
      operation.throwIfSuperseded();
      const user = AuthUser(id: 'restored-user', name: 'Restored User');
      _sessionManager.setAuthenticated(
        accessToken: 'restored-token',
        userId: user.id,
      );
      return const Success(user);
    } finally {
      if (!_restoreFinished.isCompleted) _restoreFinished.complete();
    }
  }

  @override
  Future<Result<AuthAuthenticatedResult>> verifyOtp({
    required String challengeId,
    required String code,
  }) => throw UnimplementedError();

  @override
  Future<Result<OtpChallenge>> resendOtp({required String challengeId}) =>
      throw UnimplementedError();
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(
    this._sessionManager, {
    this.loginResult,
    this.logoutResult,
    this.loginError,
  });

  final SessionManager _sessionManager;
  final Result<AuthLoginResult>? loginResult;
  final Result<void>? logoutResult;
  final Object? loginError;
  AuthUser? _cachedUser;

  @override
  Future<Result<AuthLoginResult>> login({
    required String account,
    required String password,
  }) async {
    final configuredError = loginError;
    if (configuredError != null) {
      throw configuredError;
    }

    final configuredResult = loginResult;
    if (configuredResult != null) {
      return configuredResult;
    }

    const user = AuthUser(id: 'user-1', name: 'Demo User');
    _cachedUser = user;

    _sessionManager.setAuthenticated(
      accessToken: 'access-token',
      userId: user.id,
    );

    return const Success(
      AuthLoginResult.authenticated(
        AuthResult(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          user: user,
        ),
      ),
    );
  }

  @override
  Future<Result<void>> logout() async {
    final configuredResult = logoutResult;
    if (configuredResult != null) {
      return configuredResult;
    }

    _cachedUser = null;
    _sessionManager.clear();
    return const Success(null);
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    final user = _cachedUser;

    if (user == null) {
      _sessionManager.clear();
      return const Success(null);
    }

    _sessionManager.setAuthenticated(
      accessToken: 'access-token',
      userId: user.id,
    );
    return Success(user);
  }

  @override
  Future<Result<AuthAuthenticatedResult>> verifyOtp({
    required String challengeId,
    required String code,
  }) => throw UnimplementedError();

  @override
  Future<Result<OtpChallenge>> resendOtp({required String challengeId}) =>
      throw UnimplementedError();
}
