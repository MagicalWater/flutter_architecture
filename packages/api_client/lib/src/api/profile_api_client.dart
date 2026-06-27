import 'package:api_client/src/models/profile_response.dart';
import 'package:dio/dio.dart';

/// Profile API client。
///
/// ## 為什麼這裡注入 Dio？
///
/// 這個 class 位於 api_client package，屬於 Network boundary。
///
/// Dio 細節被限制在這個 package 裡，不會污染 Domain Layer 或 Presentation Layer。
class ProfileApiClient {
  const ProfileApiClient(this._dio);

  final Dio _dio;

  Future<ProfileResponse> getProfile() async {
    // MVP 使用 mock 資料。
    // 真正串 API 時，這裡會改成：
    // final response = await _dio.get('/profile', options: Options(extra: {'requiresAuth': true}));
    // AuthHeaderInterceptor 會自動替 requiresAuth 的 request 加上 Authorization header。
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return const ProfileResponse(
      id: 'user-001',
      name: 'Water Magical',
    );
  }

  /// 示範真實 Dio request 應該如何標記需要登入。
  ///
  /// MVP 目前使用 mock response；若未來切換成真實 API，
  /// 可以沿用這個 authenticated request 寫法。
  Future<Response<dynamic>> authenticatedRequestExample() {
    return _dio.get<dynamic>(
      '/profile',
      options: Options(
        extra: <String, Object?>{
          'requiresAuth': true,
        },
      ),
    );
  }
}
