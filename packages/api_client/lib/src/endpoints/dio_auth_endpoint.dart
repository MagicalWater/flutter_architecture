import 'package:api_client/src/api/auth_retrofit_api.dart';
import 'package:api_client/src/endpoints/auth_endpoint.dart';
import 'package:api_client/src/errors/dio_exception_mapper.dart';
import 'package:api_client/src/models/authenticated_response_dto.dart';
import 'package:api_client/src/models/login_request_dto.dart';
import 'package:api_client/src/models/login_response_dto.dart';
import 'package:api_client/src/models/otp_challenge_dto.dart';
import 'package:api_client/src/models/resend_otp_request_dto.dart';
import 'package:api_client/src/models/verify_otp_request_dto.dart';
import 'package:dio/dio.dart';

/// 將Retrofit Auth API適配為transport-neutral endpoint。
class DioAuthEndpoint implements AuthEndpoint {
  const DioAuthEndpoint(this._api);

  final AuthApi _api;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) =>
      _execute(() => _api.login(request));

  @override
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request) =>
      _execute(() => _api.verifyOtp(request));

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) =>
      _execute(() => _api.resendOtp(request));

  Future<T> _execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        mapDioEndpointException(error, stackTrace),
        stackTrace,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
