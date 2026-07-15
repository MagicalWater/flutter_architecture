import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:api_client/src/errors/transport_failure_details.dart';

/// 將 api_client 內部的 transport exception 轉為共用 AppException。
///
/// 非 DioException 代表不是已知的 HTTP transport failure，保留原始 stack trace
/// 重新拋出，避免把程式錯誤誤判為網路錯誤。
Never rethrowMappedTransportException(
  Object error,
  StackTrace stackTrace,
) {
  if (error is DioException) {
    Error.throwWithStackTrace(
      AppException(
        message: 'API request failed',
        code: error.response?.statusCode?.toString(),
        cause: TransportFailureDetails.fromDioException(error),
      ),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(error, stackTrace);
}
