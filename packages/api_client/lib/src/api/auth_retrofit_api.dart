import 'package:api_client/src/models/login_request_dto.dart';
import 'package:api_client/src/models/login_response_dto.dart';
import 'package:api_client/src/models/authenticated_response_dto.dart';
import 'package:api_client/src/models/otp_challenge_dto.dart';
import 'package:api_client/src/models/resend_otp_request_dto.dart';
import 'package:api_client/src/models/verify_otp_request_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_retrofit_api.g.dart';

/// Auth HTTP API boundary。
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<LoginResponseDto> login(@Body() LoginRequestDto request);

  @POST('/auth/otp/verify')
  Future<AuthenticatedResponseDto> verifyOtp(
    @Body() VerifyOtpRequestDto request,
  );

  @POST('/auth/otp/resend')
  Future<OtpChallengeDto> resendOtp(@Body() ResendOtpRequestDto request);
}
