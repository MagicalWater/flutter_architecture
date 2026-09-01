import 'package:api_client/api_client.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
import 'package:core/core.dart';

/// 將 refresh endpoint 的 transport/protocol failure 收斂成 Auth domain 可判斷的失敗類型。
class AuthRefreshRemoteDataSource {
  const AuthRefreshRemoteDataSource(this._endpoint);

  final AuthRefreshEndpoint _endpoint;

  Future<RefreshTokenResponseDto> refresh(String refreshToken) async {
    try {
      final response = await _endpoint.refresh(
        RefreshTokenRequestDto(refreshToken: refreshToken),
      );
      if (response.accessToken.isEmpty || response.refreshToken.isEmpty) {
        final stackTrace = StackTrace.current;
        Error.throwWithStackTrace(
          TemporaryRefreshException(
            cause: AppException(
              kind: AppExceptionKind.protocol,
              message: 'Malformed refresh response',
              diagnosticCode: 'malformed_refresh_response',
              stackTrace: stackTrace,
            ),
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
      return response;
    } on ApiEndpointException catch (error, stackTrace) {
      final transport = error.transportException;
      // 只有 401 / 403 能證明 refresh credential 已不可再使用；timeout、429、5xx
      // 等 transport/backend failure 都必須保留 Session，交由 temporary path 處理。
      if (transport.httpStatus == 401 || transport.httpStatus == 403) {
        Error.throwWithStackTrace(
          InvalidRefreshCredentialException(
            cause: transport,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(
        TemporaryRefreshException(
          cause: transport,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        TemporaryRefreshException(
          cause: AppException(
            kind: AppExceptionKind.protocol,
            message: 'Malformed refresh response',
            diagnosticCode: 'malformed_refresh_response',
            cause: error,
            stackTrace: stackTrace,
          ),
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}
