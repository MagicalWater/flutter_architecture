import 'package:api_client/api_client.dart';
import 'package:auth/src/domain/failures/otp_failure_details.dart';
import 'package:core/core.dart';

/// 負責把登入／OTP request 送給 Auth API，並把後端錯誤整理成 Auth 能理解的結果。
///
/// 這裡不直接依賴 Dio；上層只需要知道「登入成功、需要 OTP、或是哪一類 Auth failure」。
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

  /// 把已知 OTP backend code 轉成明確的 Auth failure；不認識的 code 不猜語意。
  ///
  /// 未知 code 會保留在原本的 transport exception 裡往上拋，因此新增 backend code 時
  /// 不會被靜默吃掉，只是不會在 Client 尚未理解前硬轉成錯誤的 OTP 狀態。
  Never _rethrowAuthEndpointFailure(
    Object error,
    StackTrace stackTrace, {
    required String operation,
  }) {
    if (error is ApiEndpointException) {
      // 只有 Client 已明確理解的 OTP code 才轉成 Auth failure。未知 code 不做猜測，
      // 直接保留原本 backendCode 往上拋，避免把新後端狀態誤分類。
      final data = error.backendMetadata;
      final backendCode = error.backendCode;
      if (backendCode != null) {
        late final OtpFailureDetails? details;
        try {
          details = _otpFailureDetails(backendCode, data);
        } on FormatException catch (metadataError, metadataStackTrace) {
          // 已知 OTP code 的 metadata 如果連格式都不對，代表 Client 無法安全判斷
          // 下一步；這時應視為 protocol error，而不是讓 UI 繼續照一般 OTP failure 操作。
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

  /// 只解析 Client 已明確定義語意的 OTP backend code。
  ///
  /// 未知 code 回傳 null，讓 caller 保留原始 backendCode；未來後端新增 code 時不會
  /// 被錯誤映射成現有 [OtpFailureKind]。
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
