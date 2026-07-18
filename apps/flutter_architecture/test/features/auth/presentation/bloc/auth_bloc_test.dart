import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
    test('Login 成功後進入 authenticated state', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(
          account: 'demo',
          password: 'password',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
            predicate<AuthState>((state) => state.isLoading),
            predicate<AuthState>(
              (state) =>
                  !state.isLoading &&
                  state.isAuthenticated &&
                  state.user?.name == 'Demo User' &&
                  state.failure == null &&
                  state.failureOperation == null,
            ),
          ],
        ),
      );
    });

    test('Login 失敗時保持未登入並顯示錯誤', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(
        sessionManager,
        loginResult: const FailureResult<AuthResult>('login failed'),
      );
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(
          account: 'demo',
          password: 'wrong',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
            predicate<AuthState>((state) => state.isLoading),
            predicate<AuthState>(
              (state) =>
                  !state.isLoading &&
                  !state.isAuthenticated &&
                  state.failure?.message == 'login failed' &&
                  state.failureOperation == AuthFailureOperation.login,
            ),
          ],
        ),
      );
    });

    test('Logout 成功後清除 authenticated user', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(
          account: 'demo',
          password: 'password',
        ),
      );
      await bloc.stream.firstWhere((state) => state.isAuthenticated);

      bloc.add(const AuthEvent.logoutRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
            predicate<AuthState>(
              (state) => state.isLoading && state.isAuthenticated,
            ),
            predicate<AuthState>(
              (state) => !state.isLoading && !state.isAuthenticated,
            ),
          ],
        ),
      );
    });

    test('Logout 失敗時保留 authenticated user 並顯示錯誤', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(
        sessionManager,
        logoutResult: const FailureResult<void>('logout failed'),
      );
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(
          account: 'demo',
          password: 'password',
        ),
      );
      await bloc.stream.firstWhere((state) => state.isAuthenticated);

      bloc.add(const AuthEvent.logoutRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
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
          ],
        ),
      );
    });

    test('App 啟動時可以 restore 已存在的 session', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      await repository.login(account: 'demo', password: 'password');
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(const AuthEvent.started());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
            predicate<AuthState>((state) => state.isLoading),
            predicate<AuthState>(
              (state) =>
                  !state.isLoading &&
                  state.isAuthenticated &&
                  state.user?.name == 'Demo User',
            ),
          ],
        ),
      );
    });

    test('SessionManager 被其他 feature 清空時，AuthBloc 會同步清除 user', () async {
      final sessionManager = SessionManager();
      final repository = _FakeAuthRepository(sessionManager);
      final bloc = AuthBloc(
        LoginUseCase(repository),
        RestoreSessionUseCase(repository),
        LogoutUseCase(repository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(
        const AuthEvent.loginRequested(
          account: 'demo',
          password: 'password',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
            predicate<AuthState>((state) => state.isLoading),
            predicate<AuthState>(
              (state) =>
                  !state.isLoading &&
                  state.isAuthenticated &&
                  state.user?.name == 'Demo User',
            ),
          ],
        ),
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

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(
    this._sessionManager, {
    this.loginResult,
    this.logoutResult,
  });

  final SessionManager _sessionManager;
  final Result<AuthResult>? loginResult;
  final Result<void>? logoutResult;
  AuthUser? _cachedUser;

  @override
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  }) async {
    final configuredResult = loginResult;
    if (configuredResult != null) {
      return configuredResult;
    }

    const user = AuthUser(
      id: 'user-1',
      name: 'Demo User',
    );
    _cachedUser = user;

    _sessionManager.setAuthenticated(
      accessToken: 'access-token',
      userId: user.id,
    );

    return const Success(
      AuthResult(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        user: user,
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
}
