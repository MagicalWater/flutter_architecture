import 'package:api_client/src/api/auth_retrofit_api.dart';
import 'package:api_client/src/models/authenticated_response_dto.dart';
import 'package:api_client/src/models/login_request_dto.dart';
import 'package:api_client/src/models/login_response_dto.dart';
import 'package:api_client/src/models/otp_challenge_dto.dart';
import 'package:api_client/src/models/resend_otp_request_dto.dart';
import 'package:api_client/src/models/verify_otp_request_dto.dart';
import 'package:dio/dio.dart';

typedef MockAuthClock = DateTime Function();

/// Auth-specific deterministic Mock with an in-memory OTP challenge registry.
class MockAuthApi implements AuthApi {
  MockAuthApi({
    MockAuthClock? clock,
    this.responseDelay = const Duration(milliseconds: 600),
    this.challengeTtl = const Duration(minutes: 5),
    this.resendCooldown = const Duration(seconds: 30),
    this.maximumAttempts = 3,
  }) : assert(!responseDelay.isNegative),
       assert(challengeTtl > Duration.zero),
       assert(!resendCooldown.isNegative),
       assert(maximumAttempts > 0),
       _clock = clock ?? _utcNow;

  static const otpAccount = 'otp@example.com';
  static const demoOtpCode = '123456';

  final MockAuthClock _clock;
  final Duration responseDelay;
  final Duration challengeTtl;
  final Duration resendCooldown;
  final int maximumAttempts;

  final Map<String, _MockOtpChallenge> _challenges =
      <String, _MockOtpChallenge>{};
  int _challengeSequence = 0;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    await _delay();

    if (request.account != otpAccount) {
      return LoginResponseDto.authenticated(
        authenticated: _authenticatedFor(request.account),
      );
    }

    final challenge = _issueChallenge(account: request.account);
    return LoginResponseDto.otpChallenge(challenge: challenge.toDto());
  }

  @override
  Future<AuthenticatedResponseDto> verifyOtp(
    VerifyOtpRequestDto request,
  ) async {
    await _delay();
    final challenge = _activeChallenge(request.challengeId);
    final now = _clock().toUtc();

    if (!now.isBefore(challenge.expiresAt)) {
      challenge.isActive = false;
      throw _backendFailure(
        path: '/auth/otp/verify',
        statusCode: 410,
        code: 'otp_challenge_expired',
      );
    }

    if (request.code != demoOtpCode) {
      challenge.attemptsRemaining -= 1;
      if (challenge.attemptsRemaining <= 0) {
        challenge.isActive = false;
        throw _backendFailure(
          path: '/auth/otp/verify',
          statusCode: 429,
          code: 'otp_too_many_attempts',
          data: const <String, dynamic>{'attemptsRemaining': 0},
        );
      }
      throw _backendFailure(
        path: '/auth/otp/verify',
        statusCode: 401,
        code: 'otp_invalid_code',
        data: <String, dynamic>{
          'attemptsRemaining': challenge.attemptsRemaining,
        },
      );
    }

    challenge.isActive = false;
    return _authenticatedFor(challenge.account);
  }

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) async {
    await _delay();
    final challenge = _activeChallenge(request.challengeId);
    final now = _clock().toUtc();

    if (!now.isBefore(challenge.expiresAt)) {
      challenge.isActive = false;
      throw _backendFailure(
        path: '/auth/otp/resend',
        statusCode: 410,
        code: 'otp_challenge_expired',
      );
    }
    if (now.isBefore(challenge.resendAvailableAt)) {
      throw _backendFailure(
        path: '/auth/otp/resend',
        statusCode: 429,
        code: 'otp_resend_cooldown',
        data: <String, dynamic>{
          'retryAt': challenge.resendAvailableAt.toIso8601String(),
        },
      );
    }

    challenge.isActive = false;
    return _issueChallenge(account: challenge.account).toDto();
  }

  _MockOtpChallenge _issueChallenge({required String account}) {
    final now = _clock().toUtc();
    final challenge = _MockOtpChallenge(
      id: 'mock-otp-${++_challengeSequence}',
      account: account,
      expiresAt: now.add(challengeTtl),
      resendAvailableAt: now.add(resendCooldown),
      attemptsRemaining: maximumAttempts,
    );
    _challenges[challenge.id] = challenge;
    return challenge;
  }

  _MockOtpChallenge _activeChallenge(String id) {
    final challenge = _challenges[id];
    if (challenge == null || !challenge.isActive) {
      throw _backendFailure(
        path: '/auth/otp',
        statusCode: 409,
        code: 'otp_challenge_invalidated',
      );
    }
    return challenge;
  }

  AuthenticatedResponseDto _authenticatedFor(String account) =>
      AuthenticatedResponseDto(
        accessToken: account == otpAccount
            ? 'mock-otp-access-token'
            : 'mock-access-token',
        refreshToken: account == otpAccount
            ? 'mock-otp-refresh-token'
            : 'mock-refresh-token',
        userId: account == otpAccount ? 'user-otp-001' : 'user-001',
        userName: account == otpAccount ? 'OTP User' : 'Water Magical',
      );

  DioException _backendFailure({
    required String path,
    required int statusCode,
    required String code,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    final request = RequestOptions(path: path);
    return DioException.badResponse(
      statusCode: statusCode,
      requestOptions: request,
      response: Response<Map<String, dynamic>>(
        requestOptions: request,
        statusCode: statusCode,
        data: <String, dynamic>{'code': code, ...data},
      ),
    );
  }

  Future<void> _delay() => Future<void>.delayed(responseDelay);

  static DateTime _utcNow() => DateTime.now().toUtc();
}

class _MockOtpChallenge {
  _MockOtpChallenge({
    required this.id,
    required this.account,
    required this.expiresAt,
    required this.resendAvailableAt,
    required this.attemptsRemaining,
  });

  final String id;
  final String account;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;
  int attemptsRemaining;
  bool isActive = true;

  OtpChallengeDto toDto() => OtpChallengeDto(
    challengeId: id,
    expiresAt: expiresAt,
    maskedDestination: 'o***@example.com',
    resendAvailableAt: resendAvailableAt,
    attemptsRemaining: attemptsRemaining,
  );
}
