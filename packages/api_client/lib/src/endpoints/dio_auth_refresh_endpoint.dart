import 'package:api_client/src/api/auth_refresh_retrofit_api.dart';
import 'package:api_client/src/endpoints/auth_refresh_endpoint.dart';
import 'package:api_client/src/errors/dio_exception_mapper.dart';
import 'package:api_client/src/models/refresh_token_request_dto.dart';
import 'package:api_client/src/models/refresh_token_response_dto.dart';
import 'package:dio/dio.dart';

/// 將Retrofit Refresh API適配為transport-neutral endpoint。
class DioAuthRefreshEndpoint implements AuthRefreshEndpoint {
  const DioAuthRefreshEndpoint(this._api);

  final AuthRefreshApi _api;

  @override
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) async {
    try {
      return await _api.refresh(request);
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
