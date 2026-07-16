import 'package:api_client/src/auth_refresh/auth_refresher.dart';
import 'package:api_client/src/dio/auth_token_provider.dart';
import 'package:api_client/src/dio/request_extras.dart';
import 'package:dio/dio.dart';

/// 處理 authenticated request 的單次 401 refresh 與 replay。
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor(
    this._dio,
    this._tokenProvider,
    this._authRefresher,
  );

  final Dio _dio;
  final AuthTokenProvider _tokenProvider;
  final AuthRefresher _authRefresher;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final failedToken = _eligibleFailedToken(err);
    if (failedToken == null) {
      handler.next(err);
      return;
    }

    final requestGeneration =
        request.extra[RequestExtras.authSessionGeneration];
    final requestUserId = request.extra[RequestExtras.authSessionUserId];
    final current = _tokenProvider.getCurrentSession();

    if (current == null ||
        requestGeneration != current.generation ||
        requestUserId != current.userId) {
      handler.next(err);
      return;
    }

    if (current.accessToken != failedToken) {
      await _replayWithCurrentSession(request, current, handler, err);
      return;
    }

    late final AuthRefreshResult refreshResult;
    try {
      refreshResult = await _authRefresher.refresh(
        failedAccessToken: failedToken,
      );
    } catch (_) {
      handler.next(err);
      return;
    }

    if (refreshResult is! AuthRefreshSuccess) {
      handler.next(err);
      return;
    }

    final refreshed = _tokenProvider.getCurrentSession();
    if (refreshed == null ||
        refreshed.generation != requestGeneration ||
        refreshed.userId != requestUserId ||
        refreshed.accessToken == failedToken) {
      handler.next(err);
      return;
    }

    await _replayWithCurrentSession(request, refreshed, handler, err);
  }

  String? _eligibleFailedToken(DioException error) {
    final request = error.requestOptions;
    if (!_isReplaySafe(request)) {
      return null;
    }
    final retryValue = request.extra[RequestExtras.authRetryCount];
    final retryCount = retryValue is int ? retryValue : null;
    if (error.response?.statusCode != 401 ||
        request.extra[RequestExtras.requiresAuth] != true ||
        request.extra[RequestExtras.skipAuthRefresh] == true ||
        (retryValue != null && retryCount == null) ||
        (retryCount ?? 0) > 0) {
      return null;
    }

    final authorization = request.headers['Authorization'];
    if (authorization is! String || !authorization.startsWith('Bearer ')) {
      return null;
    }
    final token = authorization.substring('Bearer '.length);
    return token.isEmpty ? null : token;
  }

  bool _isReplaySafe(RequestOptions request) {
    if (request.extra[RequestExtras.allowAuthReplay] != true) {
      return false;
    }
    // Multipart and stream bodies may already be consumed by the first send.
    return request.data is! FormData && request.data is! Stream;
  }

  Future<void> _replayWithCurrentSession(
    RequestOptions request,
    AuthSessionSnapshot session,
    ErrorInterceptorHandler handler,
    DioException originalError,
  ) async {
    final current = _tokenProvider.getCurrentSession();
    if (current == null ||
        current.generation != session.generation ||
        current.userId != session.userId ||
        current.accessToken != session.accessToken) {
      handler.next(originalError);
      return;
    }

    final replay = request.copyWith(
      headers: <String, dynamic>{
        ...request.headers,
        'Authorization': 'Bearer ${session.accessToken}',
      },
      extra: <String, dynamic>{
        ...request.extra,
        RequestExtras.authRetryCount: 1,
        RequestExtras.preserveAuthSnapshot: true,
        RequestExtras.authSessionGeneration: session.generation,
        RequestExtras.authSessionUserId: session.userId,
      },
    );

    try {
      handler.resolve(await _dio.fetch<dynamic>(replay));
    } on DioException catch (replayError) {
      handler.next(replayError);
    } catch (_) {
      handler.next(originalError);
    }
  }
}
