import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SessionManager sessionManager;
  late AuthStateMutationCoordinator coordinator;
  late _OtpRepository repository;
  late AuthBloc bloc;

  setUp(() {
    sessionManager = SessionManager();
    coordinator = AuthStateMutationCoordinator();
    repository = _OtpRepository(sessionManager);
    bloc = AuthBloc(repository, sessionManager, coordinator);
  });

  tearDown(() async {
    await bloc.close();
    await sessionManager.dispose();
  });

  test('Delayed Verify cannot overwrite newer Resend challenge', () async {
    repository.blockVerify = true;
    bloc.add(const AuthEvent.loginRequested(account: 'otp', password: 'pw'));
    await _waitForStatus(bloc, AuthPresentationStatus.otpRequired);

    bloc.add(const AuthEvent.otpVerifyRequested(code: '123456'));
    await repository.verifyStarted.future;
    bloc.add(const AuthEvent.otpResendRequested());
    await _waitForChallenge(bloc, 'challenge-2');
    repository.completeVerify();
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.status, AuthPresentationStatus.otpRequired);
    expect(bloc.state.otpChallenge?.challengeId, 'challenge-2');
    expect(bloc.state.user, isNull);
  });

  test('Second Verify owns final presentation state', () async {
    repository.blockFirstVerify = true;
    bloc.add(const AuthEvent.loginRequested(account: 'otp', password: 'pw'));
    await _waitForStatus(bloc, AuthPresentationStatus.otpRequired);

    bloc.add(const AuthEvent.otpVerifyRequested(code: '111111'));
    await repository.firstVerifyStarted.future;
    bloc.add(const AuthEvent.otpVerifyRequested(code: '222222'));
    await _waitForStatus(bloc, AuthPresentationStatus.authenticated);
    repository.completeFirstVerify();
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.user?.id, 'user-2');
  });

  test('Second Resend owns replacement challenge', () async {
    repository.blockFirstResend = true;
    bloc.add(const AuthEvent.loginRequested(account: 'otp', password: 'pw'));
    await _waitForStatus(bloc, AuthPresentationStatus.otpRequired);

    bloc.add(const AuthEvent.otpResendRequested());
    await repository.firstResendStarted.future;
    bloc.add(const AuthEvent.otpResendRequested());
    await _waitForChallenge(bloc, 'challenge-3');
    repository.completeFirstResend();
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.otpChallenge?.challengeId, 'challenge-3');
  });

  test('New Login replaces active account challenge', () async {
    bloc.add(const AuthEvent.loginRequested(account: 'otp', password: 'pw'));
    await _waitForStatus(bloc, AuthPresentationStatus.otpRequired);

    bloc.add(const AuthEvent.loginRequested(account: 'other', password: 'pw'));
    await _waitForChallenge(bloc, 'challenge-other');

    expect(bloc.state.status, AuthPresentationStatus.otpRequired);
  });

  test(
    'Authoritative null to null clear invalidates active OTP state',
    () async {
      bloc.add(const AuthEvent.loginRequested(account: 'otp', password: 'pw'));
      await _waitForStatus(bloc, AuthPresentationStatus.otpRequired);
      expect(sessionManager.currentSession, isNull);

      sessionManager.clear();
      await _waitForStatus(bloc, AuthPresentationStatus.unauthenticated);

      expect(bloc.state.otpChallenge, isNull);
      expect(bloc.state.user, isNull);
    },
  );
}

Future<void> _waitForStatus(
  AuthBloc bloc,
  AuthPresentationStatus status,
) async {
  if (bloc.state.status == status) return;
  await bloc.stream.firstWhere((state) => state.status == status);
}

Future<void> _waitForChallenge(AuthBloc bloc, String challengeId) async {
  if (bloc.state.otpChallenge?.challengeId == challengeId) return;
  await bloc.stream.firstWhere(
    (state) => state.otpChallenge?.challengeId == challengeId,
  );
}

final class _OtpRepository implements AuthRepository {
  _OtpRepository(this._sessionManager);

  final SessionManager _sessionManager;
  bool blockVerify = false;
  bool blockFirstVerify = false;
  bool blockFirstResend = false;
  Failure? verifyFailure;
  int _verifyCalls = 0;
  int _resendCalls = 0;
  final Completer<void> verifyStarted = Completer<void>();
  final Completer<void> _verifyGate = Completer<void>();
  final Completer<void> firstVerifyStarted = Completer<void>();
  final Completer<void> _firstVerifyGate = Completer<void>();
  final Completer<void> firstResendStarted = Completer<void>();
  final Completer<void> _firstResendGate = Completer<void>();

  OtpChallenge get _challenge1 => OtpChallenge(
    challengeId: 'challenge-1',
    maskedDestination: '***123',
    expiresAt: DateTime.utc(2030),
    resendAvailableAt: DateTime.utc(2029),
  );

  OtpChallenge get _challenge2 => OtpChallenge(
    challengeId: 'challenge-2',
    maskedDestination: '***123',
    expiresAt: DateTime.utc(2030),
    resendAvailableAt: DateTime.utc(2029),
  );

  OtpChallenge get _challenge3 => OtpChallenge(
    challengeId: 'challenge-3',
    maskedDestination: '***123',
    expiresAt: DateTime.utc(2030),
    resendAvailableAt: DateTime.utc(2029),
  );

  OtpChallenge get _otherChallenge => OtpChallenge(
    challengeId: 'challenge-other',
    maskedDestination: '***999',
    expiresAt: DateTime.utc(2030),
    resendAvailableAt: DateTime.utc(2029),
  );

  void completeVerify() {
    if (!_verifyGate.isCompleted) _verifyGate.complete();
  }

  void completeFirstVerify() {
    if (!_firstVerifyGate.isCompleted) _firstVerifyGate.complete();
  }

  void completeFirstResend() {
    if (!_firstResendGate.isCompleted) _firstResendGate.complete();
  }

  @override
  Future<Result<AuthLoginResult>> login({
    required String account,
    required String password,
  }) async => SuccessResult(
    AuthLoginResult.otpChallenge(
      account == 'other' ? _otherChallenge : _challenge1,
    ),
  );

  @override
  Future<Result<AuthAuthenticatedResult>> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    _verifyCalls += 1;
    final call = _verifyCalls;
    if (!verifyStarted.isCompleted) verifyStarted.complete();
    if (blockFirstVerify && call == 1) {
      if (!firstVerifyStarted.isCompleted) firstVerifyStarted.complete();
      await _firstVerifyGate.future;
    }
    if (blockVerify) await _verifyGate.future;
    final failure = verifyFailure;
    if (failure != null) return FailureResult(failure);
    final result = AuthAuthenticatedResult(
      accessToken: 'access',
      refreshToken: 'refresh',
      user: AuthUser(id: 'user-$call', name: 'User'),
    );
    return SuccessResult(result);
  }

  @override
  Future<Result<OtpChallenge>> resendOtp({required String challengeId}) async {
    _resendCalls += 1;
    final call = _resendCalls;
    if (blockFirstResend && call == 1) {
      if (!firstResendStarted.isCompleted) firstResendStarted.complete();
      await _firstResendGate.future;
    }
    return SuccessResult(call == 1 ? _challenge2 : _challenge3);
  }

  @override
  Future<Result<void>> logout() async {
    _sessionManager.clear();
    return const SuccessResult(null);
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async => const SuccessResult(null);
}
