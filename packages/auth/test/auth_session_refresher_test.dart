import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Refresh 成功會保存 rotated Token Pair 並更新 runtime token', () async {
    final sessionManager = _authenticatedSession();
    final generation = sessionManager.currentSession!.generation;
    final localStore = _FakeRefreshLocalStore();
    final api = _FakeAuthRefreshApi();
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSuccess>());
    expect(api.callCount, 1);
    expect(localStore.tokens?.accessToken, 'new-access-token');
    expect(localStore.tokens?.refreshToken, 'new-refresh-token');
    expect(sessionManager.currentSession?.accessToken, 'new-access-token');
    expect(sessionManager.currentSession?.generation, generation);
  });

  test('多個並行 refresh 只會呼叫一次 endpoint', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final responseCompleter = Completer<RefreshTokenResponseDto>();
    final api = _FakeAuthRefreshApi(completer: responseCompleter);
    final refresher = _createRefresher(api, localStore, sessionManager);

    final operations = List.generate(
      10,
      (_) => refresher.refresh(failedAccessToken: 'access-token'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(api.callCount, 1);

    responseCompleter.complete(_FakeAuthRefreshApi.successResponse);
    final results = await Future.wait(operations);

    expect(results, everyElement(isA<AuthRefreshSuccess>()));
    expect(api.callCount, 1);
  });

  test(
    'Invalid refresh credential 會清除 auth state 並回傳 sessionExpired',
    () async {
      final sessionManager = _authenticatedSession();
      final localStore = _FakeRefreshLocalStore();
      final api = _FakeAuthRefreshApi(statusCode: 401);
      final refresher = _createRefresher(api, localStore, sessionManager);

      final result = await refresher.refresh(failedAccessToken: 'access-token');

      expect(result, isA<AuthRefreshSessionExpired>());
      expect(localStore.clearTokensCalls, 1);
      expect(localStore.clearUserCalls, 1);
      expect(sessionManager.currentSession, isNull);
    },
  );

  test('缺少 refresh token 時會清除 auth state 並回傳 sessionExpired', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore()..tokens = null;
    final api = _FakeAuthRefreshApi();
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(api.callCount, 0);
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Corrupted credential不呼叫remote並清除三個store', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(corruptedCredential: true);
    final api = _FakeAuthRefreshApi();
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(api.callCount, 0);
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearLegacyCredentialCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Token userId與runtime Session不一致時不呼叫remote並清除auth state', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore()
      ..tokens = const StoredAuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'other-user',
      );
    final api = _FakeAuthRefreshApi();
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(api.callCount, 0);
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Server 5xx 會保留 Session 並回傳 temporarilyUnavailable', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final api = _FakeAuthRefreshApi(statusCode: 503);
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshTemporarilyUnavailable>());
    expect(localStore.clearTokensCalls, 0);
    expect(localStore.clearUserCalls, 0);
    expect(sessionManager.currentSession?.accessToken, 'access-token');
  });

  test('Refresh 期間 Session identity 改變時丟棄舊 response', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final responseCompleter = Completer<RefreshTokenResponseDto>();
    final api = _FakeAuthRefreshApi(completer: responseCompleter);
    final refresher = _createRefresher(api, localStore, sessionManager);

    final operation = refresher.refresh(failedAccessToken: 'access-token');
    await Future<void>.delayed(Duration.zero);
    sessionManager.clear();
    sessionManager.setAuthenticated(
      accessToken: 'other-account-token',
      userId: 'other-user',
    );
    responseCompleter.complete(_FakeAuthRefreshApi.successResponse);

    final result = await operation;

    expect(result, isA<AuthRefreshSessionChanged>());
    expect(localStore.saveTokensCalls, 0);
    expect(sessionManager.currentSession?.accessToken, 'other-account-token');
    expect(sessionManager.currentSession?.userId, 'other-user');
  });

  test('保存 rotated Token Pair 失敗時清除 Session 並回傳 localStateFailure', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(failSaveTokens: true);
    final api = _FakeAuthRefreshApi();
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshLocalStateFailure>());
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('新 Session 不會加入舊 Session 的 in-flight refresh', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final firstResponse = Completer<RefreshTokenResponseDto>();
    final secondResponse = Completer<RefreshTokenResponseDto>();
    final api = _SequencedAuthRefreshApi([firstResponse, secondResponse]);
    final refresher = _createRefresher(api, localStore, sessionManager);

    final first = refresher.refresh(failedAccessToken: 'access-token');
    await Future<void>.delayed(Duration.zero);

    sessionManager.clear();
    sessionManager.setAuthenticated(
      accessToken: 'account-b-token',
      userId: 'user-002',
    );
    localStore.tokens = const StoredAuthTokens(
      accessToken: 'account-b-token',
      refreshToken: 'account-b-refresh-token',
      userId: 'user-002',
    );
    localStore.user = const AuthUser(id: 'user-002', name: 'User B');
    final second = refresher.refresh(failedAccessToken: 'account-b-token');

    firstResponse.complete(_FakeAuthRefreshApi.successResponse);
    await Future<void>.delayed(Duration.zero);
    expect(api.callCount, 2);

    secondResponse.complete(
      const RefreshTokenResponseDto(
        accessToken: 'account-b-new-token',
        refreshToken: 'account-b-new-refresh-token',
      ),
    );

    expect(await first, isA<AuthRefreshSessionChanged>());
    expect(await second, isA<AuthRefreshSuccess>());
    expect(sessionManager.currentSession?.accessToken, 'account-b-new-token');
  });

  test('Refresh Token Pair 寫入期間的新登入會在同一 mutation lock 後覆蓋舊結果', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(blockSaveTokens: true);
    final coordinator = AuthStateMutationCoordinator();
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(),
      localStore,
      sessionManager,
      coordinator: coordinator,
    );

    final refresh = refresher.refresh(failedAccessToken: 'access-token');
    await localStore.saveStarted.future;

    final loginMutation = coordinator.runExclusive(() async {
      await localStore.writeCredential(
        const StoredAuthTokens(
          accessToken: 'account-b-token',
          refreshToken: 'account-b-refresh-token',
          userId: 'user-002',
        ),
      );
      sessionManager.setAuthenticated(
        accessToken: 'account-b-token',
        userId: 'user-002',
      );
    });

    localStore.allowSave.complete();
    expect(await refresh, isA<AuthRefreshSuccess>());
    await loginMutation;

    expect(localStore.tokens?.accessToken, 'account-b-token');
    expect(localStore.tokens?.refreshToken, 'account-b-refresh-token');
    expect(sessionManager.currentSession?.userId, 'user-002');
  });

  test('Malformed 200 response 不會清除 Session', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(
        response: const RefreshTokenResponseDto(
          accessToken: '',
          refreshToken: '',
        ),
      ),
      localStore,
      sessionManager,
    );

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshTemporarilyUnavailable>());
    expect(localStore.clearTokensCalls, 0);
    expect(sessionManager.currentSession, isNotNull);
  });

  test('舊 Session refresh 返回 401 時不會清除新 Session', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final responseCompleter = Completer<RefreshTokenResponseDto>();
    final api = _FakeAuthRefreshApi(completer: responseCompleter);
    final refresher = _createRefresher(api, localStore, sessionManager);

    final operation = refresher.refresh(failedAccessToken: 'access-token');
    await Future<void>.delayed(Duration.zero);

    sessionManager.clear();
    sessionManager.setAuthenticated(
      accessToken: 'account-b-token',
      userId: 'user-002',
    );
    localStore.tokens = const StoredAuthTokens(
      accessToken: 'account-b-token',
      refreshToken: 'account-b-refresh-token',
      userId: 'user-002',
    );
    responseCompleter.completeError(
      _endpointFailure(statusCode: 401),
    );

    final result = await operation;

    expect(result, isA<AuthRefreshSessionChanged>());
    expect(localStore.clearTokensCalls, 0);
    expect(localStore.clearUserCalls, 0);
    expect(localStore.tokens?.accessToken, 'account-b-token');
    expect(sessionManager.currentSession?.userId, 'user-002');
    expect(sessionManager.currentSession?.accessToken, 'account-b-token');
  });
}

SessionManager _authenticatedSession() {
  return SessionManager()
    ..setAuthenticated(accessToken: 'access-token', userId: 'user-001');
}

AuthSessionRefresher _createRefresher(
  AuthRefreshEndpoint api,
  _FakeRefreshLocalStore localStore,
  SessionManager sessionManager, {
  AuthStateMutationCoordinator? coordinator,
}) {
  return AuthSessionRefresher(
    AuthRefreshRemoteDataSource(api),
    localStore,
    localStore,
    localStore,
    sessionManager,
    coordinator ?? AuthStateMutationCoordinator(),
    const _NoopLifecycleDiagnosticSink(),
  );
}

final class _NoopLifecycleDiagnosticSink
    implements AuthLifecycleDiagnosticSink {
  const _NoopLifecycleDiagnosticSink();

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {}
}

class _FakeAuthRefreshApi implements AuthRefreshEndpoint {
  _FakeAuthRefreshApi({
    this.statusCode,
    this.completer,
    this.response,
  });

  static const successResponse = RefreshTokenResponseDto(
    accessToken: 'new-access-token',
    refreshToken: 'new-refresh-token',
  );

  final int? statusCode;
  final Completer<RefreshTokenResponseDto>? completer;
  final RefreshTokenResponseDto? response;
  int callCount = 0;

  @override
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) async {
    callCount += 1;
    final code = statusCode;
    if (code != null) {
      throw _endpointFailure(statusCode: code);
    }
    return completer?.future ?? response ?? successResponse;
  }
}

class _SequencedAuthRefreshApi implements AuthRefreshEndpoint {
  _SequencedAuthRefreshApi(this.responses);

  final List<Completer<RefreshTokenResponseDto>> responses;
  int callCount = 0;

  @override
  Future<RefreshTokenResponseDto> refresh(RefreshTokenRequestDto request) {
    final response = responses[callCount];
    callCount += 1;
    return response.future;
  }
}

ApiEndpointException _endpointFailure({
  int? statusCode,
  TransportExceptionKind transportKind = TransportExceptionKind.response,
}) {
  return ApiEndpointException(
    transportException: AppException(
      kind: AppExceptionKind.transport,
      message: 'API request failed',
      transportKind: transportKind,
      httpStatus: statusCode,
      diagnosticCode: 'test_auth_refresh_endpoint_failure',
      stackTrace: StackTrace.current,
    ),
  );
}

class _FakeRefreshLocalStore
    implements AuthCredentialStore, AuthLegacyCredentialStore, AuthUserStore {
  _FakeRefreshLocalStore({
    this.failSaveTokens = false,
    this.blockSaveTokens = false,
    this.corruptedCredential = false,
  });

  final bool failSaveTokens;
  final bool blockSaveTokens;
  final bool corruptedCredential;
  int saveTokensCalls = 0;
  int clearTokensCalls = 0;
  int clearLegacyCredentialCalls = 0;
  int clearUserCalls = 0;
  final Completer<void> saveStarted = Completer<void>();
  final Completer<void> allowSave = Completer<void>();

  StoredAuthTokens? tokens = const StoredAuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    userId: 'user-001',
  );
  AuthUser? user = const AuthUser(id: 'user-001', name: 'User');

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    if (corruptedCredential) {
      return const AuthCredentialReadCorrupted();
    }
    final value = tokens;
    if (value == null) return const AuthCredentialReadAbsent();
    return AuthCredentialReadPresent(value);
  }

  @override
  Future<void> writeCredential(StoredAuthTokens value) async {
    saveTokensCalls += 1;
    if (blockSaveTokens && saveTokensCalls == 1) {
      saveStarted.complete();
      await allowSave.future;
    }
    if (failSaveTokens) {
      throw const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'save tokens failed',
      );
    }
    tokens = value;
  }

  @override
  Future<void> clearCredential() async {
    clearTokensCalls += 1;
    tokens = null;
  }

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    return const AuthCredentialReadAbsent();
  }

  @override
  Future<void> clearLegacyCredential() async {
    clearLegacyCredentialCalls += 1;
  }

  @override
  Future<AuthUser?> readUser() async => user;

  @override
  Future<void> writeUser(AuthUser user) async {
    this.user = user;
  }

  @override
  Future<void> clearUser() async {
    clearUserCalls += 1;
    user = null;
  }
}
