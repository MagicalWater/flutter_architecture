import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Double Login 反向完成時只允許最新 Login commit', () async {
    final sessionManager = SessionManager();
    final local = _FakeAuthLocalStore();
    final api = _ControlledAuthApi();
    final repository = _repository(
      AuthRemoteDataSource(api),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final loginA = repository.login(account: 'account-a', password: 'password');
    final loginB = repository.login(account: 'account-b', password: 'password');

    api.completeLogin(
      'account-b',
      const LoginResponseDto(
        accessToken: 'access-b',
        refreshToken: 'refresh-b',
        userId: 'user-b',
        userName: 'User B',
      ),
    );
    final resultB = await loginB;

    api.completeLogin(
      'account-a',
      const LoginResponseDto(
        accessToken: 'access-a',
        refreshToken: 'refresh-a',
        userId: 'user-a',
        userName: 'User A',
      ),
    );

    await expectLater(loginA, throwsA(isA<AuthLifecycleOperationSuperseded>()));
    expect(resultB, isA<Success<AuthResult>>());
    expect(local.tokens?.accessToken, 'access-b');
    expect(local.user?.id, 'user-b');
    expect(sessionManager.currentSession?.userId, 'user-b');
  });

  test('Logout 會使尚未完成的舊 Login 失效', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'old-token', userId: 'old-user');
    final local = _FakeAuthLocalStore()
      ..tokens = const StoredAuthTokens(
        accessToken: 'old-token',
        refreshToken: 'old-refresh',
      )
      ..user = const AuthUser(id: 'old-user', name: 'Old User');
    final api = _ControlledAuthApi();
    final repository = _repository(
      AuthRemoteDataSource(api),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final login = repository.login(account: 'account-a', password: 'password');
    final logoutResult = await repository.logout();

    api.completeLogin(
      'account-a',
      const LoginResponseDto(
        accessToken: 'access-a',
        refreshToken: 'refresh-a',
        userId: 'user-a',
        userName: 'User A',
      ),
    );

    await expectLater(login, throwsA(isA<AuthLifecycleOperationSuperseded>()));
    expect(logoutResult, isA<Success<void>>());
    expect(local.tokens, isNull);
    expect(local.user, isNull);
    expect(sessionManager.currentSession, isNull);
  });

  test('Logout cleanup 一旦開始會完成，但不會清除較新 Login 的 Session', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'old-token', userId: 'old-user');
    final local = _BlockingLogoutAuthLocalStore()
      ..tokens = const StoredAuthTokens(
        accessToken: 'old-token',
        refreshToken: 'old-refresh',
      )
      ..user = const AuthUser(id: 'old-user', name: 'Old User');
    final api = _ControlledAuthApi();
    final mutationCoordinator = AuthStateMutationCoordinator();
    final repository = _repository(
      AuthRemoteDataSource(api),
      local,
      sessionManager,
      mutationCoordinator,
    );

    final logout = repository.logout();
    await local.clearUserStarted;

    final login = repository.login(account: 'account-b', password: 'password');
    api.completeLogin(
      'account-b',
      const LoginResponseDto(
        accessToken: 'access-b',
        refreshToken: 'refresh-b',
        userId: 'user-b',
        userName: 'User B',
      ),
    );

    local.releaseClearUser();

    await expectLater(logout, throwsA(isA<AuthLifecycleOperationSuperseded>()));
    final loginResult = await login;

    expect(loginResult, isA<Success<AuthResult>>());
    expect(local.clearUserCalls, 1);
    expect(local.clearTokensCalls, 1);
    expect(local.tokens?.accessToken, 'access-b');
    expect(local.user?.id, 'user-b');
    expect(sessionManager.currentSession?.userId, 'user-b');
  });

  test('Login 保存 User 失敗時會補償清除本地狀態與 runtime Session', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'old-token', userId: 'old-user');
    final local = _FakeAuthLocalStore(failSaveUser: true);
    final repository = _repository(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.login(
      account: 'demo',
      password: 'password',
    );

    expect(result, isA<FailureResult<AuthResult>>());
    expect(local.clearTokensCalls, 1);
    expect(local.clearLegacyCredentialCalls, 1);
    expect(local.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Restore 遇到損壞 Token Pair 時會清除本地狀態並視為未登入', () async {
    final sessionManager = SessionManager();
    final local = _FakeAuthLocalStore(corruptedTokens: true);
    final repository = _repository(
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

  test('Restore 遇到legacy token缺少userId時會清除本地狀態', () async {
    final sessionManager = SessionManager();
    final local = _FakeAuthLocalStore()
      ..tokens = const StoredAuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      )
      ..user = const AuthUser(id: 'user-001', name: 'User');
    final repository = _repository(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect(local.tokens, isNull);
    expect(local.user, isNull);
    expect(sessionManager.currentSession, isNull);
  });

  test('Restore 遇到token與user identity不一致時會清除本地狀態', () async {
    final sessionManager = SessionManager();
    final local = _FakeAuthLocalStore()
      ..tokens = const StoredAuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'user-token',
      )
      ..user = const AuthUser(id: 'user-row', name: 'User');
    final repository = _repository(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect(local.tokens, isNull);
    expect(local.user, isNull);
    expect(sessionManager.currentSession, isNull);
  });

  test('Restore token與user identity一致時建立相同user Session', () async {
    final sessionManager = SessionManager();
    final local = _FakeAuthLocalStore()
      ..tokens = const StoredAuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'user-001',
      )
      ..user = const AuthUser(id: 'user-001', name: 'User');
    final repository = _repository(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect(sessionManager.currentSession?.userId, 'user-001');
  });

  test(
    'Restore 遇到已知 local storage failure 時保留 runtime Session 並回傳 Failure',
    () async {
      final sessionManager = SessionManager()
        ..setAuthenticated(
          accessToken: 'runtime-token',
          userId: 'runtime-user',
        );
      final local = _FakeAuthLocalStore(failReadTokens: true);
      final repository = _repository(
        AuthRemoteDataSource(MockAuthApi()),
        local,
        sessionManager,
        AuthStateMutationCoordinator(),
      );

      final result = await repository.restoreSession();

      expect(result, isA<FailureResult<AuthUser?>>());
      expect(local.clearTokensCalls, 0);
      expect(local.clearUserCalls, 0);
      expect(sessionManager.currentSession?.accessToken, 'runtime-token');
    },
  );

  test('Restore 遇到 unexpected AppException kind 時保留原始 exception', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'runtime-token', userId: 'runtime-user');
    final unexpected = AppException(
      kind: AppExceptionKind.protocol,
      message: 'unexpected restore protocol failure',
      stackTrace: StackTrace.current,
    );
    final local = _FakeAuthLocalStore(readTokensError: unexpected);
    final repository = _repository(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    await expectLater(repository.restoreSession(), throwsA(same(unexpected)));

    expect(local.clearTokensCalls, 0);
    expect(local.clearUserCalls, 0);
    expect(sessionManager.currentSession?.accessToken, 'runtime-token');
  });

  test('Logout 第一個 cleanup 失敗時仍執行第二個並清除 runtime Session', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'token', userId: 'user-001');
    final local = _FakeAuthLocalStore(failClearUser: true);
    final repository = _repository(
      AuthRemoteDataSource(MockAuthApi()),
      local,
      sessionManager,
      AuthStateMutationCoordinator(),
    );

    final result = await repository.logout();

    expect(result, isA<FailureResult<void>>());
    expect(local.clearUserCalls, 1);
    expect(local.clearTokensCalls, 1);
    expect(local.clearLegacyCredentialCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Login persistence 發生未知錯誤時仍補償清除並保留原始錯誤', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'old-token', userId: 'old-user');
    final local = _FakeAuthLocalStore(failSaveUserWithUnknownError: true);
    final repository = _repository(
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
    final repository = _repository(
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

  test(
    'Logout 遇到 unexpected AppException kind 時仍清除 runtime Session 並重新拋出',
    () async {
      final sessionManager = SessionManager()
        ..setAuthenticated(accessToken: 'token', userId: 'user-001');
      final unexpected = AppException(
        kind: AppExceptionKind.protocol,
        message: 'unexpected logout failure',
        stackTrace: StackTrace.current,
      );
      final local = _FakeAuthLocalStore(clearUserError: unexpected);
      final repository = _repository(
        AuthRemoteDataSource(MockAuthApi()),
        local,
        sessionManager,
        AuthStateMutationCoordinator(),
      );

      await expectLater(repository.logout(), throwsA(same(unexpected)));

      expect(local.clearUserCalls, 1);
      expect(local.clearTokensCalls, 1);
      expect(sessionManager.currentSession, isNull);
    },
  );

  test(
    'Logout 同時發生 expected 與 unknown cleanup error 時優先保留 unknown error',
    () async {
      final sessionManager = SessionManager()
        ..setAuthenticated(accessToken: 'token', userId: 'user-001');
      final local = _FakeAuthLocalStore(
        failClearUser: true,
        clearTokensError: StateError('clear tokens unknown failure'),
      );
      final repository = _repository(
        AuthRemoteDataSource(MockAuthApi()),
        local,
        sessionManager,
        AuthStateMutationCoordinator(),
      );

      await expectLater(repository.logout(), throwsA(isA<StateError>()));

      expect(local.clearUserCalls, 1);
      expect(local.clearTokensCalls, 1);
      expect(sessionManager.currentSession, isNull);
    },
  );

  test(
    'Logout 同時發生 expected 與 protocol cleanup error 時優先保留 protocol error',
    () async {
      final sessionManager = SessionManager()
        ..setAuthenticated(accessToken: 'token', userId: 'user-001');
      final protocolError = AppException(
        kind: AppExceptionKind.protocol,
        message: 'clear tokens protocol failure',
        stackTrace: StackTrace.current,
      );
      final local = _FakeAuthLocalStore(
        failClearUser: true,
        clearTokensError: protocolError,
      );
      final repository = _repository(
        AuthRemoteDataSource(MockAuthApi()),
        local,
        sessionManager,
        AuthStateMutationCoordinator(),
      );

      await expectLater(repository.logout(), throwsA(same(protocolError)));

      expect(local.clearUserCalls, 1);
      expect(local.clearTokensCalls, 1);
      expect(sessionManager.currentSession, isNull);
    },
  );
}

AuthRepositoryImpl _repository(
  AuthRemoteDataSource remoteDataSource,
  _FakeAuthLocalStore local,
  SessionManager sessionManager,
  AuthStateMutationCoordinator mutationCoordinator,
) {
  return AuthRepositoryImpl(
    remoteDataSource,
    local,
    local,
    local,
    sessionManager,
    mutationCoordinator,
  );
}

class _ControlledAuthApi implements AuthApi {
  final Map<String, Completer<LoginResponseDto>> _requests = {};

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) {
    final completer = Completer<LoginResponseDto>();
    _requests[request.account] = completer;
    return completer.future;
  }

  void completeLogin(String account, LoginResponseDto response) {
    final completer = _requests[account];
    if (completer == null) {
      throw StateError('No pending login for $account');
    }
    completer.complete(response);
  }
}

class _FakeAuthLocalStore
    implements AuthCredentialStore, AuthLegacyCredentialStore, AuthUserStore {
  _FakeAuthLocalStore({
    this.failSaveUser = false,
    this.failClearUser = false,
    this.failSaveUserWithUnknownError = false,
    this.failClearUserWithUnknownError = false,
    this.corruptedTokens = false,
    this.failReadTokens = false,
    this.readTokensError,
    this.clearUserError,
    this.clearTokensError,
  });

  final bool failSaveUser;
  final bool failClearUser;
  final bool failSaveUserWithUnknownError;
  final bool failClearUserWithUnknownError;
  final bool corruptedTokens;
  final bool failReadTokens;
  final Object? readTokensError;
  final Object? clearUserError;
  final Object? clearTokensError;

  int clearTokensCalls = 0;
  int clearLegacyCredentialCalls = 0;
  int clearUserCalls = 0;

  StoredAuthTokens? tokens;
  AuthUser? user;

  @override
  Future<void> writeCredential(StoredAuthTokens value) async {
    tokens = value;
  }

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    final error = readTokensError;
    if (error != null) {
      throw error;
    }
    if (failReadTokens) {
      throw const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'read tokens failed',
      );
    }
    if (corruptedTokens) {
      return const AuthCredentialReadCorrupted();
    }
    final value = tokens;
    if (value == null) return const AuthCredentialReadAbsent();
    return AuthCredentialReadPresent(value);
  }

  @override
  Future<void> clearCredential() async {
    clearTokensCalls += 1;
    final error = clearTokensError;
    if (error != null) {
      throw error;
    }
    tokens = null;
  }

  @override
  Future<void> writeUser(AuthUser value) async {
    if (failSaveUserWithUnknownError) {
      throw StateError('save user unknown failure');
    }
    if (failSaveUser) {
      throw const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'save user failed',
      );
    }
    user = value;
  }

  @override
  Future<AuthUser?> readUser() async => user;

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    return const AuthCredentialReadAbsent();
  }

  @override
  Future<void> clearLegacyCredential() async {
    clearLegacyCredentialCalls += 1;
  }

  @override
  Future<void> clearUser() async {
    clearUserCalls += 1;
    final error = clearUserError;
    if (error != null) {
      throw error;
    }
    if (failClearUserWithUnknownError) {
      throw StateError('clear user unknown failure');
    }
    if (failClearUser) {
      throw const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'clear user failed',
      );
    }
    user = null;
  }
}

class _BlockingLogoutAuthLocalStore extends _FakeAuthLocalStore {
  final Completer<void> _clearUserStarted = Completer<void>();
  final Completer<void> _clearUserRelease = Completer<void>();

  Future<void> get clearUserStarted => _clearUserStarted.future;

  void releaseClearUser() => _clearUserRelease.complete();

  @override
  Future<void> clearUser() async {
    if (!_clearUserStarted.isCompleted) _clearUserStarted.complete();
    await _clearUserRelease.future;
    await super.clearUser();
  }
}
