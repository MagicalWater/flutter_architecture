import 'package:freezed_annotation/freezed_annotation.dart';

part 'resend_otp_request_dto.freezed.dart';
part 'resend_otp_request_dto.g.dart';

/// Request for a full replacement OTP challenge.
@Freezed(toStringOverride: false)
abstract class ResendOtpRequestDto with _$ResendOtpRequestDto {
  const factory ResendOtpRequestDto({required String challengeId}) =
      _ResendOtpRequestDto;

  factory ResendOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpRequestDtoFromJson(json);
}
