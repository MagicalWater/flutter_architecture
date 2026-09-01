import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/failures/otp_failure_details.dart';
import 'package:core/core.dart';

/// Auth 遠端資料來源。
///
/// ## 所屬 Layer
///
/// Data Layer。
///
/// ## 責任
///
/// 負責建立 request DTO、呼叫transport-neutral AuthEndpoint，
/// 並將endpoint failure映射為Auth-owned AppException。
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authEndpoint);

  final AuthEndpoint _authEndpoint;

  Future<LoginResponseDto> login({
    required String account,
    required String password,
  }) async {
    try {
      return await _authEndpoint.login(
        LoginRequestDto(account: account, password: password),
      );
    } on ApiEndpointException catch (error, stackTrace) {
      Error.throwWithStackTrace(error.transportException, stackTrace);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<AuthenticatedResponseDto> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    try {
      return await _authEndpoint.verifyOtp(
        VerifyOtpRequestDto(challengeId: challengeId, code: code),
      );
    } catch (error, stackTrace) {
      _rethrowAuthEndpointFailure(error, stackTrace, operation: 'verify');
    }
  }

  Future<OtpChallengeDto> resendOtp({required String challengeId}) async {
    try {
      return await _authEndpoint.resendOtp(
        ResendOtpRequestDto(challengeId: challengeId),
      );
    } catch (error, stackTrace) {
      _rethrowAuthEndpointFailure(error, stackTrace, operation: 'resend');
    }
  }

  /// 將 transport endpoint failure 轉成 Auth 認得的 OTP session/protocol failure。
  /// 未 allowlist 的 backend error 保留原 transport identity，不自行猜測語意。
  Never _rethrowAuthEndpointFailure(
    Object error,
    StackTrace stackTrace, {
    required String operation,
  }) {
    if (error is ApiEndpointException) {
      // 只有 Auth 明確認識且 metadata contract 已驗證的 OTP backend code，才升格
      // 成 Auth-owned session failure；未知 backend failure 保留 transport identity。
      final data = error.backendMetadata;
      final backendCode = error.backendCode;
      if (backendCode != null) {
        late final OtpFailureDetails? details;
        try {
          details = _otpFailureDetails(backendCode, data);
        } on FormatException catch (metadataError, metadataStackTrace) {
          // 已 allowlist 的 metadata 若型別/格式仍不符合 Auth contract，代表 server
          // protocol 已破壞，不能退化成一般 OTP 錯誤讓 UI 繼續操作。
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
            httpStatus: error.httpStatus,
            backendCode: backendCode,
            diagnosticCode: 'auth_otp_$operation',
            cause: details,
            stackTrace: stackTrace,
          );
          Error.throwWithStackTrace(exception, stackTrace);
        }
      }
      Error.throwWithStackTrace(error.transportException, stackTrace);
    }
    Error.throwWithStackTrace(error, stackTrace);
  }

  /// 只解析 Auth 明確認識的 OTP backend code；未知 code 回傳 null，交由上層保留
  /// transport failure，而不是錯誤升格成 domain failure。
  OtpFailureDetails? _otpFailureDetails(
    String backendCode,
    Map<String, Object?> data,
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
