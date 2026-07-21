import 'package:api_client/src/api/auth_retrofit_api.dart';
import 'package:api_client/src/models/authenticated_response_dto.dart';
import 'package:api_client/src/models/login_request_dto.dart';
import 'package:api_client/src/models/login_response_dto.dart';
import 'package:api_client/src/models/otp_challenge_dto.dart';
import 'package:api_client/src/models/resend_otp_request_dto.dart';
import 'package:api_client/src/models/verify_otp_request_dto.dart';

/// Auth API 的 Mock implementation。
class MockAuthApi implements AuthApi {
  const MockAuthApi();

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const LoginResponseDto.authenticated(
      authenticated: AuthenticatedResponseDto(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        userId: 'user-001',
        userName: 'Water Magical',
      ),
    );
  }

  @override
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request) =>
      throw UnimplementedError('Stateful OTP Mock is implemented in Task 2.');

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) =>
      throw UnimplementedError('Stateful OTP Mock is implemented in Task 2.');
}
