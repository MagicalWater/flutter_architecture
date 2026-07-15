import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
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
  _FakeAuthRepository(this._sessionManager);

  final SessionManager _sessionManager;
  AuthUser? _cachedUser;

  @override
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  }) async {
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
        user: user,
      ),
    );
  }

  @override
  Future<Result<void>> logout() async {
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
