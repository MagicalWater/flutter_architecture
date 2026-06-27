import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
    test('SessionManager 被其他 feature 清空時，AuthBloc 會同步清除 user', () async {
      final tokenStorage = _MemoryTokenStorage();
      final sessionManager = SessionManager(tokenStorage);
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

      await sessionManager.logout();

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
  const _FakeAuthRepository(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  }) async {
    const user = AuthUser(
      id: 'user-1',
      name: 'Demo User',
    );

    await _sessionManager.login(
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
    await _sessionManager.logout();
    return const Success(null);
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    return const Success(null);
  }
}

class _MemoryTokenStorage implements TokenStorage {
  String? _accessToken;

  @override
  Future<void> clearAccessToken() async {
    _accessToken = null;
  }

  @override
  Future<String?> readAccessToken() async {
    return _accessToken;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }
}
