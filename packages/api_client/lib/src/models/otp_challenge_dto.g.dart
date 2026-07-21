// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_challenge_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpChallengeDto _$OtpChallengeDtoFromJson(Map<String, dynamic> json) =>
    _OtpChallengeDto(
      challengeId: json['challengeId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      maskedDestination: json['maskedDestination'] as String,
      resendAvailableAt: DateTime.parse(json['resendAvailableAt'] as String),
      attemptsRemaining: (json['attemptsRemaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OtpChallengeDtoToJson(_OtpChallengeDto instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'maskedDestination': instance.maskedDestination,
      'resendAvailableAt': instance.resendAvailableAt.toIso8601String(),
      'attemptsRemaining': instance.attemptsRemaining,
    };
