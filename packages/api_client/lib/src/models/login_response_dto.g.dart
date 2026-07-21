// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticatedLoginResponseDto _$AuthenticatedLoginResponseDtoFromJson(
  Map<String, dynamic> json,
) => AuthenticatedLoginResponseDto(
  authenticated: AuthenticatedResponseDto.fromJson(
    json['authenticated'] as Map<String, dynamic>,
  ),
  $type: json['resultType'] as String?,
);

Map<String, dynamic> _$AuthenticatedLoginResponseDtoToJson(
  AuthenticatedLoginResponseDto instance,
) => <String, dynamic>{
  'authenticated': _authenticatedToJson(instance.authenticated),
  'resultType': instance.$type,
};

OtpChallengeLoginResponseDto _$OtpChallengeLoginResponseDtoFromJson(
  Map<String, dynamic> json,
) => OtpChallengeLoginResponseDto(
  challenge: OtpChallengeDto.fromJson(
    json['challenge'] as Map<String, dynamic>,
  ),
  $type: json['resultType'] as String?,
);

Map<String, dynamic> _$OtpChallengeLoginResponseDtoToJson(
  OtpChallengeLoginResponseDto instance,
) => <String, dynamic>{
  'challenge': _challengeToJson(instance.challenge),
  'resultType': instance.$type,
};
