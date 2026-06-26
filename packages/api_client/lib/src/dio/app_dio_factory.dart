import 'package:api_client/src/dio/auth_token_provider.dart';
import 'package:api_client/src/dio/interceptors/auth_header_interceptor.dart';
import 'package:dio/dio.dart';

/// 建立 App 使用的 Dio。
///
/// ## 為什麼集中建立 Dio？
///
/// API client 不應該各自 new Dio。
///
/// 集中建立可以統一：
///
/// - baseUrl
/// - timeout
/// - interceptor
/// - log
/// - auth header
class AppDioFactory {
  const AppDioFactory();

  Dio create({required AuthTokenProvider tokenProvider}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://mock.local',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(AuthHeaderInterceptor(tokenProvider));

    return dio;
  }
}
