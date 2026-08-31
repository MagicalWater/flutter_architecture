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
    // 這不是單純抽 Bearer token；null 代表 request 不符合 refresh / replay
    // admission contract。回傳值則是實際造成這次 401 的 failed access token。
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
      // 舊 request 不得跨 logout / relogin / account replacement boundary
      // 借用目前 Session 的 token refresh 或 replay。
      handler.next(err);
      return;
    }

    if (current.accessToken != failedToken) {
      // generation / user 相同但 token 已不同，通常代表另一個並發 401 已先
      // 完成 refresh；refresh requirement 已被滿足，直接用 current token replay。
      await _replayWithCurrentSession(request, current, handler, err);
      return;
    }

    late final AuthRefreshResult refreshResult;
    try {
      refreshResult = await _authRefresher.refresh(
        failedAccessToken: failedToken,
      );
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: request,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace,
        ),
      );
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
      // Refresh await 期間 Session 可能已被取代。只有原 lifecycle identity 仍
      // 擁有結果且 token 確實 rotation 後，才允許 replay。
      handler.next(err);
      return;
    }

    await _replayWithCurrentSession(request, refreshed, handler, err);
  }

  String? _eligibleFailedToken(DioException error) {
    final request = error.requestOptions;
    // Replay safety 是 refresh admission 的一部分；即使是合法 authenticated
    // 401，也不能自動重送已消耗 body、stream 或 progress-sensitive request。
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
    // Multipart / request stream bodies may already be consumed by the first
    // send. Streaming responses usually belong to download/progress flows that
    // must define their own retry strategy.
    return request.data is! FormData &&
        request.data is! Stream &&
        request.responseType != ResponseType.stream &&
        request.onSendProgress == null &&
        request.onReceiveProgress == null;
  }

  Future<void> _replayWithCurrentSession(
    RequestOptions request,
    AuthSessionSnapshot session,
    ErrorInterceptorHandler handler,
    DioException originalError,
  ) async {
    final current = _tokenProvider.getCurrentSession();
    // Replay 真正送出前再次驗 ownership，封住 refresh decision 與 fetch 之間
    // 的 Session replacement race。
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
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: replay,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
