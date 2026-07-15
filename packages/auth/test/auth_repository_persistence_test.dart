import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:auth/src/data/data_sources/auth_local_store.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Login 保存 User 失敗時會補償清除本地狀態與 runtime Session', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'old-token', userId: 'old-user');
    final local = _FakeAuthLocalStore(failSaveUser: true);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.login(account: 'demo', password: 'password');

    expect(result, isA<FailureResult<AuthResult>>());
    expect(local.clearTokensCalls, 1);
    expect(local.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Restore 遇到損壞 Token Pair 時會清除本地狀態並視為未登入', () async {
    final sessionManager = SessionManager();
    final local = _FakeAuthLocalStore(corruptedTokens: true);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect(local.clearTokensCalls, 1);
    expect(local.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Logout 第一個 cleanup 失敗時仍執行第二個並清除 runtime Session', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'token', userId: 'user-001');
    final local = _FakeAuthLocalStore(failClearUser: true);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.logout();

    expect(result, isA<FailureResult<void>>());
    expect(local.clearUserCalls, 1);
    expect(local.clearTokensCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Login persistence 發生未知錯誤時仍補償清除並保留原始錯誤', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'old-token', userId: 'old-user');
    final local = _FakeAuthLocalStore(failSaveUserWithUnknownError: true);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    await expectLater(
      repository.login(account: 'demo', password: 'password'),
      throwsA(isA<StateError>()),
    );

    expect(local.clearTokensCalls, 1);
    expect(local.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Logout 第一個 cleanup 發生未知錯誤時仍執行第二個並保留原始錯誤', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'token', userId: 'user-001');
    final local = _FakeAuthLocalStore(failClearUserWithUnknownError: true);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    await expectLater(repository.logout(), throwsA(isA<StateError>()));

    expect(local.clearUserCalls, 1);
    expect(local.clearTokensCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });
}

class _FakeAuthLocalStore implements AuthLocalStore {
  _FakeAuthLocalStore({
    this.failSaveUser = false,
    this.failClearUser = false,
    this.failSaveUserWithUnknownError = false,
    this.failClearUserWithUnknownError = false,
    this.corruptedTokens = false,
  });

  final bool failSaveUser;
  final bool failClearUser;
  final bool failSaveUserWithUnknownError;
  final bool failClearUserWithUnknownError;
  final bool corruptedTokens;

  int clearTokensCalls = 0;
  int clearUserCalls = 0;

  StoredAuthTokens? tokens;
  AuthUserModel? user;

  @override
  Future<void> saveTokens(StoredAuthTokens value) async {
    tokens = value;
  }

  @override
  Future<StoredAuthTokens?> readTokens() async {
    if (corruptedTokens) {
      throw const CorruptedAuthTokensException();
    }
    return tokens;
  }

  @override
  Future<void> clearTokens() async {
    clearTokensCalls += 1;
    tokens = null;
  }

  @override
  Future<void> saveUser(AuthUserModel value) async {
    if (failSaveUserWithUnknownError) {
      throw StateError('save user unknown failure');
    }
    if (failSaveUser) {
      throw const AppException(message: 'save user failed');
    }
    user = value;
  }

  @override
  Future<AuthUserModel?> readUser() async => user;

  @override
  Future<void> clearUser() async {
    clearUserCalls += 1;
    if (failClearUserWithUnknownError) {
      throw StateError('clear user unknown failure');
    }
    if (failClearUser) {
      throw const AppException(message: 'clear user failed');
    }
    user = null;
  }
}
