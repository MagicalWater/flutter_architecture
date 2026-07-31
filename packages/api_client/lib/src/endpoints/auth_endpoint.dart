import 'package:api_client/src/models/authenticated_response_dto.dart';
import 'package:api_client/src/models/login_request_dto.dart';
import 'package:api_client/src/models/login_response_dto.dart';
import 'package:api_client/src/models/otp_challenge_dto.dart';
import 'package:api_client/src/models/resend_otp_request_dto.dart';
import 'package:api_client/src/models/verify_otp_request_dto.dart';

/// Auth consumer-facing endpoint boundary。
///
/// Consumer不應知道底層是Retrofit、Dio或Mock implementation。
abstract interface class AuthEndpoint {
  Future<LoginResponseDto> login(LoginRequestDto request);

  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request);

  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request);
}
