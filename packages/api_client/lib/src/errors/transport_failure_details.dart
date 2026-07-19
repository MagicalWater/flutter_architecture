import 'package:dio/dio.dart';
import 'package:core/core.dart';

/// 可安全帶入診斷資訊的 transport failure 摘要。
///
/// 不包含 request body、headers、cookies 或 token，避免敏感資料進入一般 log。
class TransportFailureDetails {
  const TransportFailureDetails({
    required this.method,
    required this.path,
    required this.type,
    this.statusCode,
  });

  factory TransportFailureDetails.fromDioException(DioException error) {
    return TransportFailureDetails(
      method: error.requestOptions.method,
      path: error.requestOptions.uri.path,
      type: mapDioExceptionType(error.type),
      statusCode: error.response?.statusCode,
    );
  }

  final String method;
  final String path;
  final TransportExceptionKind type;
  final int? statusCode;

  @override
  String toString() {
    return 'TransportFailureDetails('
        'method: $method, path: $path, type: $type, statusCode: $statusCode)';
  }
}

TransportExceptionKind mapDioExceptionType(DioExceptionType type) {
  return switch (type) {
    DioExceptionType.connectionTimeout =>
      TransportExceptionKind.connectionTimeout,
    DioExceptionType.sendTimeout => TransportExceptionKind.sendTimeout,
    DioExceptionType.receiveTimeout => TransportExceptionKind.receiveTimeout,
    DioExceptionType.connectionError => TransportExceptionKind.connection,
    DioExceptionType.badCertificate => TransportExceptionKind.badCertificate,
    DioExceptionType.cancel => TransportExceptionKind.cancelled,
    DioExceptionType.badResponse => TransportExceptionKind.response,
    DioExceptionType.unknown => TransportExceptionKind.unknown,
  };
}
