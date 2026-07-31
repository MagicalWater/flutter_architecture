import 'package:api_client/api_client.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
import 'package:core/core.dart';

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
