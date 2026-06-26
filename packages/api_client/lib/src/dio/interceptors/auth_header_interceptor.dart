import 'package:api_client/src/dio/auth_token_provider.dart';
import 'package:dio/dio.dart';

/// 自動替需要登入的 API 加上 Authorization header。
///
/// ## Runtime Flow
///
/// ```txt
/// RepositoryImpl
///   ↓
/// RemoteDataSource
///   ↓
/// ApiClient
///   ↓
/// Dio request
///   ↓
/// AuthHeaderInterceptor  ← 目前所在位置
///   ↓
/// Authorization: Bearer token
/// ```
///
/// 這樣 Repository / UseCase / Bloc 都不需要知道 header 怎麼加。
class AuthHeaderInterceptor extends Interceptor {
  AuthHeaderInterceptor(this._tokenProvider);

  final AuthTokenProvider _tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] == true;

    if (!requiresAuth) {
      handler.next(options);
      return;
    }

    final token = await _tokenProvider.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
