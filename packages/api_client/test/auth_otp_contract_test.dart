import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

void main() {
  group('LoginResponseDto', () {
    test('serializes and parses authenticated variant', () {
      const response = LoginResponseDto.authenticated(
        authenticated: AuthenticatedResponseDto(
          accessToken: 'access-secret',
          refreshToken: 'refresh-secret',
          userId: 'user-1',
          userName: 'Water',
        ),
      );

      final json = response.toJson();

      expect(json['resultType'], 'authenticated');
      expect(LoginResponseDto.fromJson(json), response);
    });

    test('serializes and parses otpChallenge variant', () {
      final response = LoginResponseDto.otpChallenge(
        challenge: OtpChallengeDto(
          challengeId: 'challenge-secret',
          expiresAt: DateTime.utc(2026, 7, 21, 10),
          maskedDestination: '+886 9** *** 123',
          resendAvailableAt: DateTime.utc(2026, 7, 21, 9, 55),
          attemptsRemaining: 3,
        ),
      );

      final json = response.toJson();

      expect(json['resultType'], 'otpChallenge');
      expect(LoginResponseDto.fromJson(json), response);
    });

    test('rejects unknown discriminator', () {
      expect(
        () => LoginResponseDto.fromJson(<String, dynamic>{
          'resultType': 'unknown',
        }),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });

  test('verify request serializes required identity and code', () {
    const request = VerifyOtpRequestDto(
      challengeId: 'challenge-secret',
      code: '123456',
    );

    expect(request.toJson(), <String, dynamic>{
      'challengeId': 'challenge-secret',
      'code': '123456',
    });
  });

  test('resend request and replacement challenge serialize', () {
    const request = ResendOtpRequestDto(challengeId: 'challenge-old');
    final replacement = OtpChallengeDto(
      challengeId: 'challenge-new',
      expiresAt: DateTime.utc(2026, 7, 21, 10),
      maskedDestination: 'w***@example.com',
      resendAvailableAt: DateTime.utc(2026, 7, 21, 9, 55),
    );

    expect(request.toJson(), <String, dynamic>{'challengeId': 'challenge-old'});
    expect(OtpChallengeDto.fromJson(replacement.toJson()), replacement);
  });

  test('sensitive model toString does not expose fields', () {
    const authenticated = AuthenticatedResponseDto(
      accessToken: 'access-secret',
      refreshToken: 'refresh-secret',
      userId: 'user-1',
      userName: 'Water',
    );
    const verify = VerifyOtpRequestDto(
      challengeId: 'challenge-secret',
      code: '123456',
    );

    expect(authenticated.toString(), isNot(contains('access-secret')));
    expect(authenticated.toString(), isNot(contains('refresh-secret')));
    expect(verify.toString(), isNot(contains('challenge-secret')));
    expect(verify.toString(), isNot(contains('123456')));
  });
}
