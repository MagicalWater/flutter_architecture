import 'package:api_client/src/models/login_response.dart';

/// Auth API client。
///
/// ## MVP 說明
///
/// 第一階段使用 mock 資料，不打真正後端。
///
/// 但方法命名與回傳型別會盡量模擬真實 API，
/// 讓未來替換成真正 Dio request 時不需要大改上層架構。
class AuthApiClient {
  const AuthApiClient();

  Future<LoginResponse> login({
    required String account,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const LoginResponse(
      accessToken: 'mock-access-token',
      userId: 'user-001',
      userName: 'Water Magical',
    );
  }
}
