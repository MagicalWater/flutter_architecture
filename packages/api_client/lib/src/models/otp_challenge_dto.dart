import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_challenge_dto.freezed.dart';
part 'otp_challenge_dto.g.dart';

/// Server-issued OTP challenge metadata；內容可安全提供給 client presentation。
@Freezed(toStringOverride: false)
abstract class OtpChallengeDto with _$OtpChallengeDto {
  const factory OtpChallengeDto({
    required String challengeId,
    required DateTime expiresAt,
    required String maskedDestination,
    required DateTime resendAvailableAt,
    int? attemptsRemaining,
  }) = _OtpChallengeDto;

  factory OtpChallengeDto.fromJson(Map<String, dynamic> json) =>
      _$OtpChallengeDtoFromJson(json);
}
