import 'package:api_client/src/dio/auth_token_provider.dart';
import 'package:api_client/src/dio/request_extras.dart';
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
    final requiresAuth = options.extra[RequestExtras.requiresAuth] == true;

    if (!requiresAuth) {
      handler.next(options);
      return;
    }

    if (options.extra[RequestExtras.preserveAuthSnapshot] == true) {
      final replayGeneration =
          options.extra[RequestExtras.authSessionGeneration];
      final replayUserId = options.extra[RequestExtras.authSessionUserId];
      final current = _tokenProvider.getCurrentSession();
      if (current == null ||
          replayGeneration != current.generation ||
          replayUserId != current.userId ||
          options.headers['Authorization'] !=
              'Bearer ${current.accessToken}') {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Auth session changed before request replay.',
          ),
        );
        return;
      }
      handler.next(options);
      return;
    }

    final session = _tokenProvider.getCurrentSession();
    final token = session?.accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[RequestExtras.authSessionGeneration] = session!.generation;
      options.extra[RequestExtras.authSessionUserId] = session.userId;
    }

    handler.next(options);
  }
}
