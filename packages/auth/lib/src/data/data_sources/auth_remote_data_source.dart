import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/failures/otp_failure_details.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Auth 遠端資料來源。
///
/// ## 所屬 Layer
///
/// Data Layer。
///
/// ## 責任
///
/// 負責建立 request DTO、呼叫 AuthApi abstraction，
/// 並將 transport exception 映射為共用 AppException。
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authApi);

  final AuthApi _authApi;

  Future<LoginResponseDto> login({
    required String account,
    required String password,
  }) async {
    try {
      return await _authApi.login(
        LoginRequestDto(account: account, password: password),
      );
    } catch (error, stackTrace) {
      rethrowMappedTransportException(error, stackTrace);
    }
  }

  Future<AuthenticatedResponseDto> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    try {
      return await _authApi.verifyOtp(
        VerifyOtpRequestDto(challengeId: challengeId, code: code),
      );
    } catch (error, stackTrace) {
      _rethrowAuthEndpointFailure(error, stackTrace, operation: 'verify');
    }
  }

  Future<OtpChallengeDto> resendOtp({required String challengeId}) async {
    try {
      return await _authApi.resendOtp(
        ResendOtpRequestDto(challengeId: challengeId),
      );
    } catch (error, stackTrace) {
      _rethrowAuthEndpointFailure(error, stackTrace, operation: 'resend');
    }
  }

  Never _rethrowAuthEndpointFailure(
    Object error,
    StackTrace stackTrace, {
    required String operation,
  }) {
    if (error is DioException && error.response?.data is Map) {
      final data = Map<String, dynamic>.from(error.response!.data! as Map);
      final backendCode = data['code'];
      if (backendCode is String) {
        late final OtpFailureDetails? details;
        try {
          details = _otpFailureDetails(backendCode, data);
        } on FormatException catch (metadataError, metadataStackTrace) {
          final exception = AppException(
            kind: AppExceptionKind.protocol,
            message: 'Invalid OTP failure metadata',
            diagnosticCode: 'auth_otp_failure_metadata_invalid',
            cause: metadataError,
            stackTrace: metadataStackTrace,
          );
          Error.throwWithStackTrace(exception, metadataStackTrace);
        }
        if (details != null) {
          final exception = AppException(
            kind: AppExceptionKind.session,
            message: 'OTP $operation failed',
            httpStatus: error.response?.statusCode,
            backendCode: backendCode,
            diagnosticCode: 'auth_otp_$operation',
            cause: details,
            stackTrace: stackTrace,
          );
          Error.throwWithStackTrace(exception, stackTrace);
        }
      }
    }
    rethrowMappedTransportException(error, stackTrace);
  }

  OtpFailureDetails? _otpFailureDetails(
    String backendCode,
    Map<String, dynamic> data,
  ) {
    return switch (backendCode) {
      'otp_invalid_code' => OtpFailureDetails(
        kind: OtpFailureKind.invalidCode,
        attemptsRemaining: _optionalNonNegativeInt(data['attemptsRemaining']),
      ),
      'otp_challenge_expired' => const OtpFailureDetails(
        kind: OtpFailureKind.challengeExpired,
      ),
      'otp_too_many_attempts' => OtpFailureDetails(
        kind: OtpFailureKind.tooManyAttempts,
        attemptsRemaining: _optionalNonNegativeInt(data['attemptsRemaining']),
      ),
      'otp_resend_cooldown' => OtpFailureDetails(
        kind: OtpFailureKind.resendCooldown,
        retryAt: _requiredUtcTimestamp(data['retryAt']),
      ),
      'otp_challenge_invalidated' => const OtpFailureDetails(
        kind: OtpFailureKind.challengeInvalidated,
      ),
      _ => null,
    };
  }

  int? _optionalNonNegativeInt(Object? value) {
    if (value == null) return null;
    if (value is! int || value < 0) {
      throw const FormatException('Invalid OTP attempts metadata');
    }
    return value;
  }

  DateTime _requiredUtcTimestamp(Object? value) {
    if (value is! String) {
      throw const FormatException('Missing OTP retry timestamp');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw const FormatException('Invalid OTP retry timestamp');
    }
    return parsed;
  }
}
