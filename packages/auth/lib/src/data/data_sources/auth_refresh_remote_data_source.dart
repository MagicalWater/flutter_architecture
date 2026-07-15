import 'package:api_client/api_client.dart';
import 'package:auth/src/data/exceptions/invalid_refresh_credential_exception.dart';
import 'package:auth/src/data/exceptions/temporary_refresh_exception.dart';
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
        throw const TemporaryRefreshException();
      }
      return response;
    } on DioException catch (error, stackTrace) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        Error.throwWithStackTrace(
          InvalidRefreshCredentialException(cause: error),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(
        TemporaryRefreshException(cause: error),
        stackTrace,
      );
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        TemporaryRefreshException(cause: error),
        stackTrace,
      );
    } on TypeError catch (error, stackTrace) {
      Error.throwWithStackTrace(
        TemporaryRefreshException(cause: error),
        stackTrace,
      );
    }
  }
}
