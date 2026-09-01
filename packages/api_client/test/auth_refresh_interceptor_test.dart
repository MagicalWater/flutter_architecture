import 'dart:async';
import 'dart:typed_data';

import 'package:api_client/api_client_infrastructure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('10 個並行 401 共用一次 refresh，並各自以新 token replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refreshGate = Completer<void>();
    final refresher = _FakeRefresher(() async {
      await refreshGate.future;
      provider.current = _session('new-token');
      return AuthRefreshResult.success;
    });
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    final requests = List.generate(
      10,
      (index) => dio.get<dynamic>(
        '/resource-$index',
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
    );
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 10)).then((_) {
        refreshGate.complete();
      }),
    );
    final responses = await Future.wait(requests);

    expect(responses.map((response) => response.statusCode), everyElement(200));
    expect(refresher.callCount, 1);
    expect(adapter.oldTokenCalls, 10);
    expect(adapter.newTokenCalls, 10);
  });

  test('Logout 後重新登入時，舊 request 不會使用新 Session token replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refreshGate = Completer<void>();
    final refreshStarted = Completer<void>();
    final refresher = _FakeRefresher(() async {
      refreshStarted.complete();
      await refreshGate.future;
      return AuthRefreshResult.sessionChanged;
    });
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    final request = dio.get<dynamic>(
      '/profile',
      options: Options(
        extra: {
          RequestExtras.requiresAuth: true,
          RequestExtras.allowAuthReplay: true,
        },
      ),
    );
    await refreshStarted.future;

    provider.current = null;
    provider.current = const AuthSessionSnapshot(
      accessToken: 'account-b-token',
      userId: 'user-002',
      generation: 3,
    );
    refreshGate.complete();

    await expectLater(request, throwsA(isA<DioException>()));
    expect(refresher.callCount, 1);
    expect(adapter.oldTokenCalls, 1);
    expect(adapter.accountBTokenCalls, 0);
    expect(adapter.totalCalls, 1);
  });

  test('failed token 已過期時直接以 current token replay，不再次 refresh', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
    late final _AuthAdapter adapter;
    adapter = _AuthAdapter(
      onOldToken: () => provider.current = _session('new-token'),
    );
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    final response = await dio.get<dynamic>(
      '/profile',
      options: Options(
        extra: {
          RequestExtras.requiresAuth: true,
          RequestExtras.allowAuthReplay: true,
        },
      ),
    );

    expect(response.statusCode, 200);
    expect(refresher.callCount, 0);
    expect(adapter.newTokenCalls, 1);
  });

  test('request Session identity 已改變時不 refresh、不 replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
    final adapter = _AuthAdapter(
      onOldToken: () {
        provider.current = const AuthSessionSnapshot(
          accessToken: 'account-b-token',
          userId: 'user-002',
          generation: 2,
        );
      },
    );
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refresher.callCount, 0);
    expect(adapter.totalCalls, 1);
  });

  test('replay 再次 401 時不會進入第二次 refresh', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async {
      provider.current = _session('new-token');
      return AuthRefreshResult.success;
    });
    final adapter = _AuthAdapter(alwaysUnauthorized: true);
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refresher.callCount, 1);
    expect(adapter.totalCalls, 2);
  });

  test('Replay 進入 onRequest 前切換帳號時取消 replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async {
      provider.current = _session('new-token');
      return AuthRefreshResult.success;
    });
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra[RequestExtras.authRetryCount] == 1) {
            provider.current = const AuthSessionSnapshot(
              accessToken: 'account-b-token',
              userId: 'user-002',
              generation: 2,
            );
          }
          handler.next(options);
        },
      ),
    );

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );

    expect(adapter.newTokenCalls, 0);
    expect(adapter.accountBTokenCalls, 0);
    expect(adapter.totalCalls, 1);
  });

  for (final testCase in <({String name, Map<String, dynamic> extra})>[
    (name: 'requiresAuth 不是 true', extra: const {}),
    (
      name: 'skipAuthRefresh 为 true',
      extra: const {
        RequestExtras.requiresAuth: true,
        RequestExtras.allowAuthReplay: true,
        RequestExtras.skipAuthRefresh: true,
      },
    ),
    (
      name: 'allowAuthReplay 不是 true',
      extra: const {RequestExtras.requiresAuth: true},
    ),
    (
      name: 'authRetryCount 大于 0',
      extra: const {
        RequestExtras.requiresAuth: true,
        RequestExtras.allowAuthReplay: true,
        RequestExtras.authRetryCount: 1,
      },
    ),
    (
      name: 'authRetryCount 类型错误',
      extra: const {
        RequestExtras.requiresAuth: true,
        RequestExtras.allowAuthReplay: true,
        RequestExtras.authRetryCount: '1',
      },
    ),
  ]) {
    test('${testCase.name} 时不 refresh、不 replay', () async {
      final provider = _MutableTokenProvider(_session('old-token'));
      final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
      final adapter = _AuthAdapter();
      final dio = AppDioFactory().createMain(
        baseUrl: 'https://example.test',
        tokenProvider: provider,
        authRefresher: refresher,
      )..httpClientAdapter = adapter;

      await expectLater(
        dio.get<dynamic>('/profile', options: Options(extra: testCase.extra)),
        throwsA(isA<DioException>()),
      );

      expect(refresher.callCount, 0);
      expect(adapter.totalCalls, 1);
    });
  }

  for (final result in <AuthRefreshResult>[
    AuthRefreshResult.sessionExpired,
    AuthRefreshResult.temporarilyUnavailable,
    AuthRefreshResult.sessionChanged,
    AuthRefreshResult.localStateFailure,
  ]) {
    test('${result.name} 时保留原始 401，不 replay', () async {
      final provider = _MutableTokenProvider(_session('old-token'));
      final refresher = _FakeRefresher(() async => result);
      final adapter = _AuthAdapter();
      final dio = AppDioFactory().createMain(
        baseUrl: 'https://example.test',
        tokenProvider: provider,
        authRefresher: refresher,
      )..httpClientAdapter = adapter;

      await expectLater(
        dio.get<dynamic>(
          '/profile',
          options: Options(
            extra: {
              RequestExtras.requiresAuth: true,
              RequestExtras.allowAuthReplay: true,
            },
          ),
        ),
        throwsA(isA<DioException>()),
      );

      expect(refresher.callCount, 1);
      expect(adapter.totalCalls, 1);
    });
  }

  test('refresh implementation 拋出 unexpected error 時保留原始錯誤', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final error = StateError('refresh implementation failed');
    final refresher = _FakeRefresher(() async => throw error);
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
      throwsA(
        isA<DioException>()
            .having((value) => value.type, 'type', DioExceptionType.unknown)
            .having((value) => value.error, 'original error', same(error))
            .having((value) => value.stackTrace, 'stack trace', isNotNull),
      ),
    );

    expect(refresher.callCount, 1);
    expect(adapter.totalCalls, 1);
  });

  test('replay 發生 unexpected error 時不會退回原始 401', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final replayError = StateError('replay interceptor failed');
    final refresher = _FakeRefresher(() async {
      provider.current = _session('new-token');
      return AuthRefreshResult.success;
    });
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra[RequestExtras.authRetryCount] == 1) {
            throw replayError;
          }
          handler.next(options);
        },
      ),
    );

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
      throwsA(
        isA<DioException>()
            .having((value) => value.type, 'type', DioExceptionType.unknown)
            .having((value) => value.error, 'original error', same(replayError))
            .having((value) => value.stackTrace, 'stack trace', isNotNull),
      ),
    );

    expect(refresher.callCount, 1);
    expect(adapter.totalCalls, 1);
  });

  test('authenticated request 未實際帶 token 時不 refresh、不 replay', () async {
    final provider = _MutableTokenProvider(null);
    final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(extra: {RequestExtras.requiresAuth: true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refresher.callCount, 0);
    expect(adapter.totalCalls, 1);
  });

  test('authenticated request 的非 401 錯誤不 refresh、不 replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
    final adapter = _AuthAdapter(oldTokenStatusCode: 500);
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(extra: {RequestExtras.requiresAuth: true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refresher.callCount, 0);
    expect(adapter.totalCalls, 1);
  });

  test('未明確允許 auth replay 時不 refresh、不 replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>(
        '/profile',
        options: Options(extra: {RequestExtras.requiresAuth: true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refresher.callCount, 0);
    expect(adapter.totalCalls, 1);
  });

  test('FormData request 即使明確允許 replay 也不會自動重送', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async => AuthRefreshResult.success);
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.post<dynamic>(
        '/upload',
        data: FormData.fromMap({'file': 'payload'}),
        options: Options(
          extra: {
            RequestExtras.requiresAuth: true,
            RequestExtras.allowAuthReplay: true,
          },
        ),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refresher.callCount, 0);
    expect(adapter.totalCalls, 1);
  });

  test('JSON body、query、headers 與 Idempotency-Key 會完整保留並 replay', () async {
    final provider = _MutableTokenProvider(_session('old-token'));
    final refresher = _FakeRefresher(() async {
      provider.current = _session('new-token');
      return AuthRefreshResult.success;
    });
    final adapter = _AuthAdapter();
    final dio = AppDioFactory().createMain(
      baseUrl: 'https://example.test',
      tokenProvider: provider,
      authRefresher: refresher,
    )..httpClientAdapter = adapter;

    final response = await dio.post<dynamic>(
      '/orders',
      data: <String, dynamic>{'symbol': '2330', 'quantity': 1},
      queryParameters: <String, dynamic>{'market': 'TW'},
      options: Options(
        headers: const <String, dynamic>{
          'X-Request-Source': 'app',
          'Idempotency-Key': 'order-001',
        },
        extra: const <String, dynamic>{
          RequestExtras.requiresAuth: true,
          RequestExtras.allowAuthReplay: true,
        },
      ),
    );

    expect(response.statusCode, 200);
    expect(adapter.requests, hasLength(2));
    final original = adapter.requests.first;
    final replay = adapter.requests.last;
    expect(replay.method, original.method);
    expect(replay.path, original.path);
    expect(replay.queryParameters, original.queryParameters);
    expect(replay.data, original.data);
    expect(replay.headers['X-Request-Source'], 'app');
    expect(replay.headers['Idempotency-Key'], 'order-001');
    expect(replay.extra[RequestExtras.authRetryCount], 1);
    expect(replay.headers['Authorization'], 'Bearer new-token');
  });
}

AuthSessionSnapshot _session(String token) =>
    AuthSessionSnapshot(accessToken: token, userId: 'user-001', generation: 1);

class _MutableTokenProvider implements AuthTokenProvider {
  _MutableTokenProvider(this.current);

  AuthSessionSnapshot? current;

  @override
  AuthSessionSnapshot? getCurrentSession() => current;
}

class _FakeRefresher implements AuthRefresher {
  _FakeRefresher(this.action);

  final Future<AuthRefreshResult> Function() action;
  int callCount = 0;
  Future<AuthRefreshResult>? _inFlight;

  @override
  Future<AuthRefreshResult> refresh({required String failedAccessToken}) {
    final existing = _inFlight;
    if (existing != null) return existing;
    callCount += 1;
    final operation = action();
    _inFlight = operation;
    operation.then<void>(
      (_) => _clearInFlight(operation),
      onError: (Object error, StackTrace stackTrace) =>
          _clearInFlight(operation),
    );
    return operation;
  }

  void _clearInFlight(Future<AuthRefreshResult> operation) {
    if (identical(_inFlight, operation)) {
      _inFlight = null;
    }
  }
}

class _AuthAdapter implements HttpClientAdapter {
  _AuthAdapter({
    this.onOldToken,
    this.alwaysUnauthorized = false,
    this.oldTokenStatusCode = 401,
  });

  final void Function()? onOldToken;
  final bool alwaysUnauthorized;
  final int oldTokenStatusCode;
  int totalCalls = 0;
  int oldTokenCalls = 0;
  int newTokenCalls = 0;
  int accountBTokenCalls = 0;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    totalCalls += 1;
    requests.add(options);
    final authorization = options.headers['Authorization'];
    if (authorization == 'Bearer old-token') {
      oldTokenCalls += 1;
      onOldToken?.call();
      return ResponseBody.fromString('{}', oldTokenStatusCode);
    }
    if (authorization == 'Bearer new-token') {
      newTokenCalls += 1;
      return ResponseBody.fromString(
        '{}',
        alwaysUnauthorized ? 401 : 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (authorization == 'Bearer account-b-token') {
      accountBTokenCalls += 1;
      return ResponseBody.fromString('{}', 200);
    }
    return ResponseBody.fromString('{}', 401);
  }

  @override
  void close({bool force = false}) {}
}
