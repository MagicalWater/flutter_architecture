import 'package:api_client/api_client.dart';

/// Auth 遠端資料來源。
///
/// ## 所屬 Layer
///
/// Data Layer。
///
/// ## 責任
///
/// 負責呼叫 AuthApiClient，不處理 UI，也不處理業務規則。
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authApiClient);

  final AuthApiClient _authApiClient;

  Future<LoginResponse> login({
    required String account,
    required String password,
  }) {
    return _authApiClient.login(
      account: account,
      password: password,
    );
  }
}
