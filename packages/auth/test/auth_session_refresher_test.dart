import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
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

  test('Invalid refresh credential 會清除 auth state 並回傳 sessionExpired', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final api = _FakeAuthRefreshApi(statusCode: 401);
    final refresher = _createRefresher(api, localStore, sessionManager);

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Invalidation 的 clearTokens 失敗時仍嘗試 clearUser 並清除 Session', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(failClearTokens: true);
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(statusCode: 401),
      localStore,
      sessionManager,
    );

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('Invalidation 的 clearUser 失敗時仍清除 Session', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(failClearUser: true);
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(statusCode: 401),
      localStore,
      sessionManager,
    );

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

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

  for (final type in <DioExceptionType>[
    DioExceptionType.connectionTimeout,
    DioExceptionType.connectionError,
  ]) {
    test('$type 會保留 Session 並回傳 temporarilyUnavailable', () async {
      final sessionManager = _authenticatedSession();
      final localStore = _FakeRefreshLocalStore();
      final refresher = _createRefresher(
        _FakeAuthRefreshApi(errorType: type),
        localStore,
        sessionManager,
      );

      final result = await refresher.refresh(failedAccessToken: 'access-token');

      expect(result, isA<AuthRefreshTemporarilyUnavailable>());
      expect(localStore.clearTokensCalls, 0);
      expect(localStore.clearUserCalls, 0);
      expect(sessionManager.currentSession?.accessToken, 'access-token');
    });
  }

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

  test('讀取 Token Pair 發生未知錯誤時清除 Session 並回傳 localStateFailure', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(failReadTokensUnknown: true);
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(),
      localStore,
      sessionManager,
    );

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshLocalStateFailure>());
    expect(localStore.clearTokensCalls, 1);
    expect(localStore.clearUserCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test('保存 Token Pair 發生未知錯誤時清除 Session 並回傳 localStateFailure', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore(failSaveTokensUnknown: true);
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(),
      localStore,
      sessionManager,
    );

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
    );
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
      await localStore.saveTokens(
        const StoredAuthTokens(
          accessToken: 'account-b-token',
          refreshToken: 'account-b-refresh-token',
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

  test('HTTP 400 不會清除 Session', () async {
    final sessionManager = _authenticatedSession();
    final localStore = _FakeRefreshLocalStore();
    final refresher = _createRefresher(
      _FakeAuthRefreshApi(statusCode: 400),
      localStore,
      sessionManager,
    );

    final result = await refresher.refresh(failedAccessToken: 'access-token');

    expect(result, isA<AuthRefreshTemporarilyUnavailable>());
    expect(localStore.clearTokensCalls, 0);
    expect(sessionManager.currentSession, isNotNull);
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
    );
    responseCompleter.completeError(
      DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: Response<void>(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
        ),
      ),
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
  AuthRefreshApi api,
  AuthRefreshLocalStore localStore,
  SessionManager sessionManager, {
  AuthStateMutationCoordinator? coordinator,
}) {
  return AuthSessionRefresher(
    AuthRefreshRemoteDataSource(api),
    localStore,
    sessionManager,
    coordinator ?? AuthStateMutationCoordinator(),
  );
}

class _FakeAuthRefreshApi implements AuthRefreshApi {
  _FakeAuthRefreshApi({
    this.statusCode,
    this.completer,
    this.response,
    this.errorType,
  });

  static const successResponse = RefreshTokenResponseDto(
    accessToken: 'new-access-token',
    refreshToken: 'new-refresh-token',
  );

  final int? statusCode;
  final Completer<RefreshTokenResponseDto>? completer;
  final RefreshTokenResponseDto? response;
  final DioExceptionType? errorType;
  int callCount = 0;

  @override
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) async {
    callCount += 1;
    final type = errorType;
    if (type != null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        type: type,
      );
    }
    final code = statusCode;
    if (code != null) {
      final options = RequestOptions(path: '/auth/refresh');
      throw DioException(
        requestOptions: options,
        response: Response<void>(requestOptions: options, statusCode: code),
      );
    }
    return completer?.future ?? response ?? successResponse;
  }
}

class _SequencedAuthRefreshApi implements AuthRefreshApi {
  _SequencedAuthRefreshApi(this.responses);

  final List<Completer<RefreshTokenResponseDto>> responses;
  int callCount = 0;

  @override
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) {
    final response = responses[callCount];
    callCount += 1;
    return response.future;
  }
}

class _FakeRefreshLocalStore implements AuthRefreshLocalStore {
  _FakeRefreshLocalStore({
    this.failSaveTokens = false,
    this.failReadTokensUnknown = false,
    this.failSaveTokensUnknown = false,
    this.blockSaveTokens = false,
    this.failClearTokens = false,
    this.failClearUser = false,
  });

  final bool failSaveTokens;
  final bool failReadTokensUnknown;
  final bool failSaveTokensUnknown;
  final bool blockSaveTokens;
  final bool failClearTokens;
  final bool failClearUser;
  int saveTokensCalls = 0;
  int clearTokensCalls = 0;
  int clearUserCalls = 0;
  final Completer<void> saveStarted = Completer<void>();
  final Completer<void> allowSave = Completer<void>();

  StoredAuthTokens? tokens = const StoredAuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );

  @override
  Future<StoredAuthTokens?> readTokens() async {
    if (failReadTokensUnknown) {
      throw StateError('read tokens failed');
    }
    return tokens;
  }

  @override
  Future<void> saveTokens(StoredAuthTokens value) async {
    saveTokensCalls += 1;
    if (blockSaveTokens && saveTokensCalls == 1) {
      saveStarted.complete();
      await allowSave.future;
    }
    if (failSaveTokens) {
      throw const AppException(message: 'save tokens failed');
    }
    if (failSaveTokensUnknown) {
      throw StateError('save tokens failed');
    }
    tokens = value;
  }

  @override
  Future<void> clearTokens() async {
    clearTokensCalls += 1;
    if (failClearTokens) {
      throw StateError('clear tokens failed');
    }
    tokens = null;
  }

  @override
  Future<void> clearUser() async {
    clearUserCalls += 1;
    if (failClearUser) {
      throw StateError('clear user failed');
    }
  }
}
