import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late MockAuthApi api;

  setUp(() {
    now = DateTime.utc(2026, 7, 21, 10);
    api = MockAuthApi(clock: () => now, responseDelay: Duration.zero);
  });

  test('normal account authenticates directly', () async {
    final result = await api.login(
      const LoginRequestDto(account: 'demo', password: 'password'),
    );

    expect(result, isA<AuthenticatedLoginResponseDto>());
  });

  test('OTP account receives deterministic challenge', () async {
    final challenge = await _loginForChallenge(api);

    expect(challenge.challengeId, 'mock-otp-1');
    expect(challenge.attemptsRemaining, 3);
    expect(challenge.expiresAt, now.add(const Duration(minutes: 5)));
  });

  test('correct code authenticates and consumes challenge', () async {
    final challenge = await _loginForChallenge(api);

    final authenticated = await api.verifyOtp(
      VerifyOtpRequestDto(
        challengeId: challenge.challengeId,
        code: MockAuthApi.demoOtpCode,
      ),
    );

    expect(authenticated.userId, 'user-otp-001');
    await expectLater(
      api.verifyOtp(
        VerifyOtpRequestDto(
          challengeId: challenge.challengeId,
          code: MockAuthApi.demoOtpCode,
        ),
      ),
      _throwsBackendCode('otp_challenge_invalidated'),
    );
  });

  test('invalid code decrements attempts and exhaustion invalidates', () async {
    final challenge = await _loginForChallenge(api);

    await expectLater(
      api.verifyOtp(
        VerifyOtpRequestDto(challengeId: challenge.challengeId, code: '000000'),
      ),
      _throwsBackendCode('otp_invalid_code', attemptsRemaining: 2),
    );
    await expectLater(
      api.verifyOtp(
        VerifyOtpRequestDto(challengeId: challenge.challengeId, code: '000000'),
      ),
      _throwsBackendCode('otp_invalid_code', attemptsRemaining: 1),
    );
    await expectLater(
      api.verifyOtp(
        VerifyOtpRequestDto(challengeId: challenge.challengeId, code: '000000'),
      ),
      _throwsBackendCode('otp_too_many_attempts', attemptsRemaining: 0),
    );
  });

  test('expired challenge cannot be verified', () async {
    final challenge = await _loginForChallenge(api);
    now = challenge.expiresAt;

    await expectLater(
      api.verifyOtp(
        VerifyOtpRequestDto(
          challengeId: challenge.challengeId,
          code: MockAuthApi.demoOtpCode,
        ),
      ),
      _throwsBackendCode('otp_challenge_expired'),
    );
  });

  test(
    'resend enforces cooldown then replaces and invalidates predecessor',
    () async {
      final original = await _loginForChallenge(api);

      await expectLater(
        api.resendOtp(ResendOtpRequestDto(challengeId: original.challengeId)),
        throwsA(
          isA<ApiEndpointException>().having(
            (error) => error.backendMetadata['retryAt'],
            'retryAt',
            original.resendAvailableAt.toIso8601String(),
          ),
        ),
      );

      now = original.resendAvailableAt;
      final replacement = await api.resendOtp(
        ResendOtpRequestDto(challengeId: original.challengeId),
      );

      expect(replacement.challengeId, isNot(original.challengeId));
      await expectLater(
        api.verifyOtp(
          VerifyOtpRequestDto(
            challengeId: original.challengeId,
            code: MockAuthApi.demoOtpCode,
          ),
        ),
        _throwsBackendCode('otp_challenge_invalidated'),
      );
      expect(
        await api.verifyOtp(
          VerifyOtpRequestDto(
            challengeId: replacement.challengeId,
            code: MockAuthApi.demoOtpCode,
          ),
        ),
        isA<AuthenticatedResponseDto>(),
      );
    },
  );
}

Future<OtpChallengeDto> _loginForChallenge(MockAuthApi api) async {
  final result = await api.login(
    const LoginRequestDto(
      account: MockAuthApi.otpAccount,
      password: 'password',
    ),
  );
  return result.maybeWhen(
    otpChallenge: (challenge) => challenge,
    orElse: () => throw StateError('Expected OTP challenge.'),
  );
}

Matcher _throwsBackendCode(String code, {int? attemptsRemaining}) {
  var matcher = isA<ApiEndpointException>().having(
    (error) => error.backendCode,
    'backend code',
    code,
  );
  if (attemptsRemaining != null) {
    matcher = matcher.having(
      (error) => error.backendMetadata['attemptsRemaining'],
      'attempts remaining',
      attemptsRemaining,
    );
  }
  return throwsA(matcher);
}
