import 'package:freezed_annotation/freezed_annotation.dart';

part 'resend_otp_request_dto.freezed.dart';
part 'resend_otp_request_dto.g.dart';

/// 要求 server 建立完整 replacement OTP challenge 的 request。
@Freezed(toStringOverride: false)
abstract class ResendOtpRequestDto with _$ResendOtpRequestDto {
  const factory ResendOtpRequestDto({required String challengeId}) =
      _ResendOtpRequestDto;

  factory ResendOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpRequestDtoFromJson(json);
}
