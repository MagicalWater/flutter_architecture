import 'package:api_client/src/models/refresh_token_request_dto.dart';
import 'package:api_client/src/models/refresh_token_response_dto.dart';
import 'package:api_client/src/dio/request_extras.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_refresh_retrofit_api.g.dart';

@RestApi()
abstract class AuthRefreshApi {
  factory AuthRefreshApi(Dio dio, {String? baseUrl}) = _AuthRefreshApi;

  @POST('/auth/refresh')
  @Extra(<String, Object>{RequestExtras.skipAuthRefresh: true})
  Future<RefreshTokenResponseDto> refresh(
    @Body() RefreshTokenRequestDto request,
  );
}
