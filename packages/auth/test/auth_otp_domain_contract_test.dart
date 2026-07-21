import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final expiresAt = DateTime.utc(2026, 7, 21, 10, 5);
  final resendAt = DateTime.utc(2026, 7, 21, 10, 0, 30);

  test('challenge rejects blank identity and non-UTC timestamps', () {
    expect(
      () => OtpChallenge(
        challengeId: ' ',
        expiresAt: expiresAt,
        maskedDestination: 'o***@example.com',
        resendAvailableAt: resendAt,
      ),
      throwsArgumentError,
    );
    expect(
      () => OtpChallenge(
        challengeId: 'challenge-1',
        expiresAt: DateTime(2026, 7, 21),
        maskedDestination: 'o***@example.com',
        resendAvailableAt: resendAt,
      ),
      throwsArgumentError,
    );
  });

  test('login union is exhaustive without exposing sensitive values', () {
    final challenge = OtpChallenge(
      challengeId: 'secret-challenge',
      expiresAt: expiresAt,
      maskedDestination: 'o***@example.com',
      resendAvailableAt: resendAt,
      attemptsRemaining: 3,
    );
    final result = AuthLoginResult.otpChallenge(challenge);

    expect(
      result.when(
        authenticated: (_) => 'authenticated',
        otpChallenge: (_) => 'challenge',
      ),
      'challenge',
    );
    expect(result.toString(), isNot(contains('secret-challenge')));
  });
}
