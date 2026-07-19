import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:api_client/src/errors/transport_failure_details.dart';

/// 將 api_client 內部的 transport exception 轉為共用 AppException。
///
/// 非 DioException 代表不是已知的 HTTP transport failure，保留原始 stack trace
/// 重新拋出，避免把程式錯誤誤判為網路錯誤。
AppException mapDioException(
  DioException error,
  StackTrace stackTrace,
) {
  final details = TransportFailureDetails.fromDioException(error);
  return AppException(
    kind: AppExceptionKind.transport,
    message: 'API request failed',
    transportKind: details.type,
    httpStatus: details.statusCode,
    cause: details,
    stackTrace: stackTrace,
  );
}

Never rethrowMappedTransportException(
  Object error,
  StackTrace stackTrace,
) {
  if (error is DioException) {
    Error.throwWithStackTrace(
      mapDioException(error, stackTrace),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(error, stackTrace);
}
