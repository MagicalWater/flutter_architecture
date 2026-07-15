import 'package:api_client/src/models/login_request_dto.dart';
import 'package:api_client/src/models/login_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_retrofit_api.g.dart';

/// Auth HTTP API boundary。
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<LoginResponseDto> login(@Body() LoginRequestDto request);
}
