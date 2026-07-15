import 'package:dio/dio.dart';

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
      path: error.requestOptions.path,
      type: error.type.name,
      statusCode: error.response?.statusCode,
    );
  }

  final String method;
  final String path;
  final String type;
  final int? statusCode;

  @override
  String toString() {
    return 'TransportFailureDetails('
        'method: $method, path: $path, type: $type, statusCode: $statusCode)';
  }
}
