import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'secure login persists credential then user before session commit',
    () async {
      final operations = <String>[];
      final secure = _CredentialStore(operations);
      final legacy = _LegacyStore(operations);
      final userStore = _UserStore(operations);
      final session = _TrackingSessionManager(operations);
      final repository = _repository(secure, legacy, userStore, session);

      final result = await repository.login(
        account: 'demo',
        password: 'password',
      );

      expect(result, isA<Success<AuthLoginResult>>());
      expect(operations, <String>['secure.write', 'user.write', 'session.set']);
      expect(legacy.writeCalls, 0);
    },
  );

  test(
    'user write failure compensates all stores and does not create session',
    () async {
      final expected = const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'user write failed',
      );
      final operations = <String>[];
      final secure = _CredentialStore(operations);
      final legacy = _LegacyStore(operations);
      final userStore = _UserStore(operations, writeError: expected);
      final session = _TrackingSessionManager(operations);
      final repository = _repository(secure, legacy, userStore, session);

      final result = await repository.login(
        account: 'demo',
        password: 'password',
      );

      expect(result, isA<FailureResult<AuthLoginResult>>());
      expect(operations, <String>[
        'secure.write',
        'user.write',
        'secure.clear',
        'legacy.clear',
        'user.clear',
        'session.clear',
      ]);
      expect(session.currentSession, isNull);
    },
  );

  test(
    'unknown compensation error outranks original persistence failure',
    () async {
      final original = const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'user write failed',
      );
      final unknown = StateError('secure cleanup bug');
      final repository = _repository(
        _CredentialStore(<String>[], clearError: unknown),
        _LegacyStore(<String>[]),
        _UserStore(<String>[], writeError: original),
        _TrackingSessionManager(<String>[]),
      );

      await expectLater(
        repository.login(account: 'demo', password: 'password'),
        throwsA(same(unknown)),
      );
    },
  );

  test(
    'original unknown persistence error outranks expected cleanup failure',
    () async {
      final original = StateError('user write bug');
      final expectedCleanup = const AppException(
        kind: AppExceptionKind.localStorage,
        message: 'secure cleanup failed',
      );
      final repository = _repository(
        _CredentialStore(<String>[], clearError: expectedCleanup),
        _LegacyStore(<String>[]),
        _UserStore(<String>[], writeError: original),
        _TrackingSessionManager(<String>[]),
      );

      await expectLater(
        repository.login(account: 'demo', password: 'password'),
        throwsA(same(original)),
      );
    },
  );

  test('superseded compensation preserves existing runtime session', () async {
    final operations = <String>[];
    final secure = _CredentialStore(operations);
    final legacy = _LegacyStore(operations);
    final userStore = _BlockingUserStore(operations);
    final session = _TrackingSessionManager(operations)
      ..setAuthenticated(accessToken: 'existing', userId: 'existing-user');
    operations.clear();
    final mutationCoordinator = AuthStateMutationCoordinator();
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      secure,
      legacy,
      userStore,
      session,
      mutationCoordinator,
      AuthCredentialMigrationCoordinator(secure, legacy, userStore),
      const _NoopSink(),
    );

    final login = repository.login(account: 'demo', password: 'password');
    await userStore.writeStarted;
    mutationCoordinator.beginLifecycleOperation();
    userStore.releaseWrite();

    await expectLater(login, throwsA(isA<AuthLifecycleOperationSuperseded>()));
    expect(session.currentSession?.userId, 'existing-user');
    expect(
      operations,
      containsAll(<String>['secure.clear', 'legacy.clear', 'user.clear']),
    );
    expect(operations, isNot(contains('session.clear')));
  });

  test('older secure login cannot clear newer committed state', () async {
    final operations = <String>[];
    final secure = _CredentialStore(operations);
    final legacy = _LegacyStore(operations);
    final userStore = _UserStore(operations);
    final session = _TrackingSessionManager(operations);
    final api = _ControlledAuthApi();
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(api),
      secure,
      legacy,
      userStore,
      session,
      AuthStateMutationCoordinator(),
      AuthCredentialMigrationCoordinator(secure, legacy, userStore),
      const _NoopSink(),
    );

    final older = repository.login(account: 'older', password: 'password');
    final newer = repository.login(account: 'newer', password: 'password');
    api.complete(
      'newer',
      const LoginResponseDto.authenticated(
        authenticated: AuthenticatedResponseDto(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
          userId: 'new-user',
          userName: 'New User',
        ),
      ),
    );
    expect(await newer, isA<Success<AuthLoginResult>>());
    api.complete(
      'older',
      const LoginResponseDto.authenticated(
        authenticated: AuthenticatedResponseDto(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
          userId: 'old-user',
          userName: 'Old User',
        ),
      ),
    );

    await expectLater(older, throwsA(isA<AuthLifecycleOperationSuperseded>()));
    expect(session.currentSession?.userId, 'new-user');
    expect(operations.where((value) => value.endsWith('.clear')), isEmpty);
  });
}

AuthRepositoryImpl _repository(
  AuthCredentialStore secure,
  AuthLegacyCredentialStore legacy,
  AuthUserStore userStore,
  SessionManager session,
) {
  return AuthRepositoryImpl(
    AuthRemoteDataSource(MockAuthApi()),
    secure,
    legacy,
    userStore,
    session,
    AuthStateMutationCoordinator(),
    AuthCredentialMigrationCoordinator(secure, legacy, userStore),
    const _NoopSink(),
  );
}

final class _CredentialStore implements AuthCredentialStore {
  _CredentialStore(this.operations, {this.clearError});
  final List<String> operations;
  final Object? clearError;

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {
    operations.add('secure.write');
  }

  @override
  Future<AuthCredentialReadResult> readCredential() async =>
      const AuthCredentialReadAbsent();

  @override
  Future<void> clearCredential() async {
    operations.add('secure.clear');
    final error = clearError;
    if (error != null) throw error;
  }
}

final class _LegacyStore implements AuthLegacyCredentialStore {
  _LegacyStore(this.operations);
  final List<String> operations;
  int writeCalls = 0;

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async =>
      const AuthCredentialReadAbsent();

  @override
  Future<void> clearLegacyCredential() async {
    operations.add('legacy.clear');
  }
}

final class _UserStore implements AuthUserStore {
  _UserStore(this.operations, {this.writeError});
  final List<String> operations;
  final Object? writeError;

  @override
  Future<void> writeUser(AuthUser user) async {
    operations.add('user.write');
    final error = writeError;
    if (error != null) throw error;
  }

  @override
  Future<AuthUser?> readUser() async => null;

  @override
  Future<void> clearUser() async {
    operations.add('user.clear');
  }
}

final class _BlockingUserStore extends _UserStore {
  _BlockingUserStore(super.operations);

  final Completer<void> _writeStarted = Completer<void>();
  final Completer<void> _writeRelease = Completer<void>();

  Future<void> get writeStarted => _writeStarted.future;

  void releaseWrite() => _writeRelease.complete();

  @override
  Future<void> writeUser(AuthUser user) async {
    operations.add('user.write');
    if (!_writeStarted.isCompleted) _writeStarted.complete();
    await _writeRelease.future;
  }
}

final class _TrackingSessionManager extends SessionManager {
  _TrackingSessionManager(this.operations);
  final List<String> operations;

  @override
  void setAuthenticated({required String accessToken, required String userId}) {
    operations.add('session.set');
    super.setAuthenticated(accessToken: accessToken, userId: userId);
  }

  @override
  void clear() {
    operations.add('session.clear');
    super.clear();
  }
}

final class _NoopSink implements AuthLifecycleDiagnosticSink {
  const _NoopSink();

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {}
}

final class _ControlledAuthApi implements AuthEndpoint {
  final Map<String, Completer<LoginResponseDto>> _requests =
      <String, Completer<LoginResponseDto>>{};

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) {
    return (_requests[request.account] = Completer<LoginResponseDto>()).future;
  }

  @override
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request) =>
      throw UnimplementedError();

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) =>
      throw UnimplementedError();

  void complete(String account, LoginResponseDto response) {
    _requests[account]!.complete(response);
  }
}
