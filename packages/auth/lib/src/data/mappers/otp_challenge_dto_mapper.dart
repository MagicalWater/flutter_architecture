import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/entities/otp_challenge.dart';

/// 將 API client 的 OTP DTO 轉成 Auth domain 使用的 [OtpChallenge]。
extension OtpChallengeDtoMapper on OtpChallengeDto {
  OtpChallenge toDomain() => OtpChallenge(
    challengeId: challengeId,
    expiresAt: expiresAt,
    maskedDestination: maskedDestination,
    resendAvailableAt: resendAvailableAt,
    attemptsRemaining: attemptsRemaining,
  );
}
