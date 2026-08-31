import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_request_dto.freezed.dart';
part 'verify_otp_request_dto.g.dart';

/// OTP verification request；任何 string representation 都不得暴露驗證 code。
@Freezed(toStringOverride: false)
abstract class VerifyOtpRequestDto with _$VerifyOtpRequestDto {
  const factory VerifyOtpRequestDto({
    required String challengeId,
    required String code,
  }) = _VerifyOtpRequestDto;

  factory VerifyOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestDtoFromJson(json);
}
