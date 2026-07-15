import 'package:api_client/api_client.dart';

/// Auth 遠端資料來源。
///
/// ## 所屬 Layer
///
/// Data Layer。
///
/// ## 責任
///
/// 負責建立 request DTO、呼叫 AuthApi abstraction，
/// 並將 transport exception 映射為共用 AppException。
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authApi);

  final AuthApi _authApi;

  Future<LoginResponseDto> login({
    required String account,
    required String password,
  }) async {
    try {
      return await _authApi.login(
        LoginRequestDto(
          account: account,
          password: password,
        ),
      );
    } catch (error, stackTrace) {
      rethrowMappedTransportException(error, stackTrace);
    }
  }
}
