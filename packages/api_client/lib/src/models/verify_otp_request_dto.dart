import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_request_dto.freezed.dart';
part 'verify_otp_request_dto.g.dart';

/// OTP verification request. Its string representation must never expose code.
@Freezed(toStringOverride: false)
abstract class VerifyOtpRequestDto with _$VerifyOtpRequestDto {
  const factory VerifyOtpRequestDto({
    required String challengeId,
    required String code,
  }) = _VerifyOtpRequestDto;

  factory VerifyOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestDtoFromJson(json);
}
