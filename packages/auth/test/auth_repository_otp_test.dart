import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'challenge login performs zero persistence and session writes',
    () async {
      final stores = _Stores();
      final session = SessionManager();
      final repository = _repository(
        _ImmediateAuthApi(
          loginResponse: LoginResponseDto.otpChallenge(
            challenge: OtpChallengeDto(
              challengeId: 'challenge-1',
              expiresAt: DateTime.utc(2026, 7, 21, 10, 5),
              maskedDestination: 'o***@example.com',
              resendAvailableAt: DateTime.utc(2026, 7, 21, 10, 0, 30),
            ),
          ),
        ),
        stores,
        session,
      );

      final result = await repository.login(account: 'otp', password: 'secret');

      expect(result, isA<Success<AuthLoginResult>>());
      expect(stores.operations, isEmpty);
      expect(session.currentSession, isNull);
    },
  );

  test('verify success commits secure then user then session', () async {
    final stores = _Stores();
    final session = _TrackingSessionManager(stores.operations);
    final repository = _repository(_ImmediateAuthApi(), stores, session);

    final result = await repository.verifyOtp(
      challengeId: 'challenge-1',
      code: '123456',
    );

    expect(result, isA<Success<AuthAuthenticatedResult>>());
    expect(stores.operations, ['secure.write', 'user.write', 'session.set']);
    expect(session.currentSession?.userId, 'otp-user');
  });

  test(
    'newer login supersedes delayed verify before credential commit',
    () async {
      final api = _ControlledAuthApi();
      final stores = _Stores();
      final session = SessionManager();
      final repository = _repository(api, stores, session);

      final verify = repository.verifyOtp(
        challengeId: 'challenge-1',
        code: '123456',
      );
      await api.verifyStarted.future;
      final login = repository.login(account: 'newer', password: 'secret');
      api.completeLogin();
      expect(await login, isA<Success<AuthLoginResult>>());

      api.completeVerify();
      await expectLater(
        verify,
        throwsA(isA<AuthLifecycleOperationSuperseded>()),
      );
      expect(session.currentSession?.userId, 'new-user');
      expect(stores.tokens?.userId, 'new-user');
    },
  );

  test(
    'newer resend supersedes delayed verify before credential commit',
    () async {
      final api = _ControlledAuthApi();
      final stores = _Stores();
      final session = SessionManager();
      final repository = _repository(api, stores, session);

      final verify = repository.verifyOtp(
        challengeId: 'challenge-1',
        code: '123456',
      );
      await api.verifyStarted.future;
      final resend = repository.resendOtp(challengeId: 'challenge-1');
      expect(await resend, isA<Success<OtpChallenge>>());

      api.completeVerify();
      await expectLater(
        verify,
        throwsA(isA<AuthLifecycleOperationSuperseded>()),
      );
      expect(stores.operations, isEmpty);
      expect(session.currentSession, isNull);
    },
  );

  test(
    'newer logout supersedes delayed verify before credential commit',
    () async {
      final api = _ControlledAuthApi();
      final stores = _Stores();
      final session = SessionManager();
      final repository = _repository(api, stores, session);

      final verify = repository.verifyOtp(
        challengeId: 'challenge-1',
        code: '123456',
      );
      await api.verifyStarted.future;
      expect(await repository.logout(), isA<Success<void>>());
      stores.operations.clear();

      api.completeVerify();
      await expectLater(
        verify,
        throwsA(isA<AuthLifecycleOperationSuperseded>()),
      );
      expect(stores.operations, isEmpty);
      expect(session.currentSession, isNull);
    },
  );

  test('resend returns replacement without persistence side effects', () async {
    final stores = _Stores();
    final session = SessionManager();
    final repository = _repository(_ImmediateAuthApi(), stores, session);

    final result = await repository.resendOtp(challengeId: 'challenge-1');

    expect(result, isA<Success<OtpChallenge>>());
    expect(stores.operations, isEmpty);
    expect(session.currentSession, isNull);
  });
}

AuthRepositoryImpl _repository(
  AuthApi api,
  _Stores stores,
  SessionManager session,
) => AuthRepositoryImpl(
  AuthRemoteDataSource(api),
  stores,
  stores,
  stores,
  session,
  AuthStateMutationCoordinator(),
  AuthCredentialMigrationCoordinator(stores, stores, stores),
  const _NoopSink(),
);

class _ImmediateAuthApi implements AuthApi {
  _ImmediateAuthApi({this.loginResponse});

  final LoginResponseDto? loginResponse;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async =>
      loginResponse ??
      const LoginResponseDto.authenticated(
        authenticated: AuthenticatedResponseDto(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
          userId: 'new-user',
          userName: 'New User',
        ),
      );

  @override
  Future<AuthenticatedResponseDto> verifyOtp(
    VerifyOtpRequestDto request,
  ) async => const AuthenticatedResponseDto(
    accessToken: 'otp-access',
    refreshToken: 'otp-refresh',
    userId: 'otp-user',
    userName: 'OTP User',
  );

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) async =>
      OtpChallengeDto(
        challengeId: 'challenge-2',
        expiresAt: DateTime.utc(2026, 7, 21, 10, 10),
        maskedDestination: 'o***@example.com',
        resendAvailableAt: DateTime.utc(2026, 7, 21, 10, 5, 30),
      );
}

final class _ControlledAuthApi extends _ImmediateAuthApi {
  final verifyStarted = Completer<void>();
  final _verify = Completer<AuthenticatedResponseDto>();
  final _login = Completer<LoginResponseDto>();

  @override
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request) {
    if (!verifyStarted.isCompleted) verifyStarted.complete();
    return _verify.future;
  }

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) => _login.future;

  void completeVerify() => _verify.complete(
    const AuthenticatedResponseDto(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      userId: 'old-user',
      userName: 'Old User',
    ),
  );

  void completeLogin() => _login.complete(
    const LoginResponseDto.authenticated(
      authenticated: AuthenticatedResponseDto(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        userId: 'new-user',
        userName: 'New User',
      ),
    ),
  );
}

class _Stores
    implements AuthCredentialStore, AuthLegacyCredentialStore, AuthUserStore {
  final operations = <String>[];
  StoredAuthTokens? tokens;
  AuthUser? user;

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {
    operations.add('secure.write');
    this.tokens = tokens;
  }

  @override
  Future<void> writeUser(AuthUser user) async {
    operations.add('user.write');
    this.user = user;
  }

  @override
  Future<AuthCredentialReadResult> readCredential() async =>
      const AuthCredentialReadAbsent();

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async =>
      const AuthCredentialReadAbsent();

  @override
  Future<AuthUser?> readUser() async => user;

  @override
  Future<void> clearCredential() async {
    operations.add('secure.clear');
    tokens = null;
  }

  @override
  Future<void> clearLegacyCredential() async => operations.add('legacy.clear');

  @override
  Future<void> clearUser() async {
    operations.add('user.clear');
    user = null;
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
}

final class _NoopSink implements AuthLifecycleDiagnosticSink {
  const _NoopSink();
  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {}
}
