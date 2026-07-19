import 'package:api_client/api_client.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';

class AuthRefreshRemoteDataSource {
  const AuthRefreshRemoteDataSource(this._api);

  final AuthRefreshApi _api;

  Future<RefreshTokenResponseDto> refresh(String refreshToken) async {
    try {
      final response = await _api.refresh(
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
    } on DioException catch (error, stackTrace) {
      final transport = mapDioException(error, stackTrace);
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
