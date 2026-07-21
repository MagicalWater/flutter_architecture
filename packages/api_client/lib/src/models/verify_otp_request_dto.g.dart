// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyOtpRequestDto _$VerifyOtpRequestDtoFromJson(Map<String, dynamic> json) =>
    _VerifyOtpRequestDto(
      challengeId: json['challengeId'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestDtoToJson(
  _VerifyOtpRequestDto instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'code': instance.code,
};
