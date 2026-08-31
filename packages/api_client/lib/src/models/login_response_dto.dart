import 'package:api_client/src/models/authenticated_response_dto.dart';
import 'package:api_client/src/models/otp_challenge_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

/// Password login 的 typed response。
@Freezed(toStringOverride: false, unionKey: 'resultType')
sealed class LoginResponseDto with _$LoginResponseDto {
  @FreezedUnionValue('authenticated')
  const factory LoginResponseDto.authenticated({
    @JsonKey(
      fromJson: AuthenticatedResponseDto.fromJson,
      toJson: _authenticatedToJson,
    )
    required AuthenticatedResponseDto authenticated,
  }) = AuthenticatedLoginResponseDto;

  @FreezedUnionValue('otpChallenge')
  const factory LoginResponseDto.otpChallenge({
    @JsonKey(fromJson: OtpChallengeDto.fromJson, toJson: _challengeToJson)
    required OtpChallengeDto challenge,
  }) = OtpChallengeLoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}

Map<String, dynamic> _authenticatedToJson(AuthenticatedResponseDto value) =>
    value.toJson();

Map<String, dynamic> _challengeToJson(OtpChallengeDto value) => value.toJson();
