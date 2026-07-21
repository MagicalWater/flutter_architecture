import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/entities/otp_challenge.dart';

extension OtpChallengeDtoMapper on OtpChallengeDto {
  OtpChallenge toDomain() => OtpChallenge(
    challengeId: challengeId,
    expiresAt: expiresAt,
    maskedDestination: maskedDestination,
    resendAvailableAt: resendAvailableAt,
    attemptsRemaining: attemptsRemaining,
  );
}
