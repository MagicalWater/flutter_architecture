import 'dart:io';

import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refresher production shape remains single and nonnullable', () {
    final source = File(
      'lib/src/refresh/auth_session_refresher.dart',
    ).readAsStringSync();

    expect(source, contains('AuthSessionRefresher('));
    expect(source, isNot(contains('factory AuthSessionRefresher')));
    expect(source, isNot(contains('_SecureLifecycleAuthSessionRefresher')));
    expect(source, isNot(contains('AuthLifecycleDiagnosticSink?')));
  });

  test('secure refresh persists rotated pair before runtime token', () async {
    final operations = <String>[];
    final store = _Store(operations);
    final session = _Session(operations)
      ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
    operations.clear();
    final refresher = _refresher(store, session, _Api());

    final result = await refresher.refresh(failedAccessToken: 'old-access');

    expect(result, isA<AuthRefreshSuccess>());
    expect(operations, <String>[
      'secure.read',
      'user.read',
      'secure.write',
      'session.update',
    ]);
    expect(store.tokens?.accessToken, 'new-access');
  });

  test(
    'expected passive cleanup failure expires session then reports outside lock',
    () async {
      final operations = <String>[];
      final store = _Store(
        operations,
        secureClearError: const AppException(
          kind: AppExceptionKind.localStorage,
          message: 'secure clear failed',
        ),
      );
      final session = _Session(operations)
        ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
      operations.clear();
      final coordinator = _TrackingCoordinator();
      final sink = _Sink(() {
        expect(coordinator.isHeld, isFalse);
        expect(session.currentSession, isNull);
      });
      final refresher = _refresher(
        store,
        session,
        _Api(statusCode: 401),
        coordinator: coordinator,
        sink: sink,
      );

      final result = await refresher.refresh(failedAccessToken: 'old-access');

      expect(result, isA<AuthRefreshSessionExpired>());
      expect(
        operations,
        containsAllInOrder(<String>[
          'secure.clear',
          'legacy.clear',
          'user.clear',
          'session.clear',
        ]),
      );
      expect(sink.diagnostics, hasLength(1));
    },
  );

  test(
    'unknown passive cleanup failure expires session and preserves identity',
    () async {
      final unknown = StateError('cleanup bug');
      final operations = <String>[];
      final store = _Store(operations, secureClearError: unknown);
      final session = _Session(operations)
        ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
      operations.clear();
      final refresher = _refresher(store, session, _Api(statusCode: 401));

      await expectLater(
        refresher.refresh(failedAccessToken: 'old-access'),
        throwsA(same(unknown)),
      );

      expect(session.currentSession, isNull);
      expect(
        operations,
        containsAllInOrder(<String>[
          'secure.clear',
          'legacy.clear',
          'user.clear',
          'session.clear',
        ]),
      );
    },
  );

  test(
    'mixed passive cleanup reports expected once then throws unknown outside lock',
    () async {
      final unknown = StateError('user cleanup bug');
      final operations = <String>[];
      final store = _Store(
        operations,
        secureClearError: const AppException(
          kind: AppExceptionKind.localStorage,
          message: 'secure cleanup failed',
        ),
        userClearError: unknown,
      );
      final session = _Session(operations)
        ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
      operations.clear();
      final coordinator = _TrackingCoordinator();
      final sink = _Sink(() {
        expect(coordinator.isHeld, isFalse);
        expect(session.currentSession, isNull);
      });
      final refresher = _refresher(
        store,
        session,
        _Api(statusCode: 401),
        coordinator: coordinator,
        sink: sink,
      );

      await expectLater(
        refresher.refresh(failedAccessToken: 'old-access'),
        throwsA(same(unknown)),
      );

      expect(sink.diagnostics, hasLength(1));
      expect(
        sink.diagnostics.single.operation,
        AuthLifecycleDiagnosticOperation.secureCleanup,
      );
    },
  );

  test('secure identity mismatch skips remote and expires session', () async {
    final operations = <String>[];
    final store = _Store(operations)
      ..user = const AuthUser(id: 'other-user', name: 'Other');
    final session = _Session(operations)
      ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
    operations.clear();
    final api = _Api();
    final refresher = _refresher(store, session, api);

    final result = await refresher.refresh(failedAccessToken: 'old-access');

    expect(result, isA<AuthRefreshSessionExpired>());
    expect(api.callCount, 0);
    expect(session.currentSession, isNull);
  });

  test(
    'expected secure rotation failure expires session and reports cleanup',
    () async {
      final operations = <String>[];
      final store = _Store(
        operations,
        writeError: const AppException(
          kind: AppExceptionKind.localStorage,
          message: 'secure write failed',
        ),
        secureClearError: const AppException(
          kind: AppExceptionKind.localStorage,
          message: 'secure clear failed',
        ),
      );
      final session = _Session(operations)
        ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
      operations.clear();
      final sink = _Sink();
      final refresher = _refresher(store, session, _Api(), sink: sink);

      final result = await refresher.refresh(failedAccessToken: 'old-access');

      expect(result, isA<AuthRefreshLocalStateFailure>());
      expect(session.currentSession, isNull);
      expect(sink.diagnostics, hasLength(1));
    },
  );

  test('old secure refresh 401 cannot clear newer session state', () async {
    final operations = <String>[];
    final store = _Store(operations);
    final session = _Session(operations)
      ..setAuthenticated(accessToken: 'old-access', userId: 'user-1');
    operations.clear();
    final api = _ControlledApi();
    final refresher = _refresher(store, session, api);

    final refresh = refresher.refresh(failedAccessToken: 'old-access');
    await api.started;
    session.clear();
    session.setAuthenticated(accessToken: 'new-access', userId: 'user-2');
    store.tokens = const StoredAuthTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      userId: 'user-2',
    );
    store.user = const AuthUser(id: 'user-2', name: 'New User');
    operations.clear();
    api.completeUnauthorized();

    expect(await refresh, isA<AuthRefreshSessionChanged>());
    expect(session.currentSession?.userId, 'user-2');
    expect(store.tokens?.userId, 'user-2');
    expect(operations.where((value) => value.endsWith('.clear')), isEmpty);
  });
}

AuthSessionRefresher _refresher(
  _Store store,
  SessionManager session,
  AuthRefreshEndpoint api, {
  AuthStateMutationCoordinator? coordinator,
  AuthLifecycleDiagnosticSink? sink,
}) {
  return AuthSessionRefresher(
    AuthRefreshRemoteDataSource(api),
    store,
    store,
    store,
    session,
    coordinator ?? AuthStateMutationCoordinator(),
    sink ?? _Sink(),
  );
}

final class _Api implements AuthRefreshEndpoint {
  _Api({this.statusCode});
  final int? statusCode;
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
    return const RefreshTokenResponseDto(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }
}

final class _ControlledApi implements AuthRefreshEndpoint {
  final Completer<void> _started = Completer<void>();
  final Completer<RefreshTokenResponseDto> _response =
      Completer<RefreshTokenResponseDto>();

  Future<void> get started => _started.future;

  @override
  Future<RefreshTokenResponseDto> refresh(RefreshTokenRequestDto request) {
    _started.complete();
    return _response.future;
  }

  void completeUnauthorized() {
    _response.completeError(_endpointFailure(statusCode: 401));
  }
}

ApiEndpointException _endpointFailure({required int statusCode}) {
  return ApiEndpointException(
    transportException: AppException(
      kind: AppExceptionKind.transport,
      message: 'API request failed',
      transportKind: TransportExceptionKind.response,
      httpStatus: statusCode,
      diagnosticCode: 'test_auth_refresh_endpoint_failure',
      stackTrace: StackTrace.current,
    ),
  );
}

final class _Store
    implements AuthCredentialStore, AuthLegacyCredentialStore, AuthUserStore {
  _Store(
    this.operations, {
    this.secureClearError,
    this.userClearError,
    this.writeError,
  });
  final List<String> operations;
  final Object? secureClearError;
  final Object? userClearError;
  final Object? writeError;
  StoredAuthTokens? tokens = const StoredAuthTokens(
    accessToken: 'old-access',
    refreshToken: 'refresh-token',
    userId: 'user-1',
  );
  AuthUser? user = const AuthUser(id: 'user-1', name: 'User');

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    operations.add('secure.read');
    final value = tokens;
    return value == null
        ? const AuthCredentialReadAbsent()
        : AuthCredentialReadPresent(value);
  }

  @override
  Future<void> writeCredential(StoredAuthTokens value) async {
    operations.add('secure.write');
    final error = writeError;
    if (error != null) throw error;
    tokens = value;
  }

  @override
  Future<void> clearCredential() async {
    operations.add('secure.clear');
    final error = secureClearError;
    if (error != null) throw error;
    tokens = null;
  }

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async =>
      const AuthCredentialReadAbsent();

  @override
  Future<void> clearLegacyCredential() async {
    operations.add('legacy.clear');
  }

  @override
  Future<AuthUser?> readUser() async {
    operations.add('user.read');
    return user;
  }

  @override
  Future<void> writeUser(AuthUser value) async => user = value;

  @override
  Future<void> clearUser() async {
    operations.add('user.clear');
    final error = userClearError;
    if (error != null) throw error;
    user = null;
  }
}

final class _Session extends SessionManager {
  _Session(this.operations);
  final List<String> operations;

  @override
  void updateAccessToken(String accessToken) {
    operations.add('session.update');
    super.updateAccessToken(accessToken);
  }

  @override
  void clear() {
    operations.add('session.clear');
    super.clear();
  }
}

final class _TrackingCoordinator extends AuthStateMutationCoordinator {
  bool isHeld = false;

  @override
  Future<T> runExclusive<T>(Future<T> Function() action) {
    return super.runExclusive(() async {
      isHeld = true;
      try {
        return await action();
      } finally {
        isHeld = false;
      }
    });
  }
}

final class _Sink implements AuthLifecycleDiagnosticSink {
  _Sink([this.onReport]);
  final void Function()? onReport;
  final List<AuthLifecycleDiagnostic> diagnostics = <AuthLifecycleDiagnostic>[];

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {
    onReport?.call();
    this.diagnostics.addAll(diagnostics);
  }
}
