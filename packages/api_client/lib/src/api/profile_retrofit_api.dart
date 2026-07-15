import 'package:api_client/src/dio/request_extras.dart';
import 'package:api_client/src/models/profile_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_retrofit_api.g.dart';

/// Profile HTTP API boundary。
@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String? baseUrl}) = _ProfileApi;

  @GET('/profile')
  @Extra(<String, Object>{RequestExtras.requiresAuth: true})
  Future<ProfileResponseDto> getProfile();
}
