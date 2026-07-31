import 'package:core/core.dart';

/// 跨package使用的transport-neutral endpoint failure envelope。
///
/// 不保存Dio Response、RequestOptions、headers或raw transport object。
class ApiEndpointException implements Exception {
  ApiEndpointException({
    required this.transportException,
    this.backendCode,
    Map<String, Object?> backendMetadata = const <String, Object?>{},
  }) : backendMetadata = Map<String, Object?>.unmodifiable(backendMetadata);

  final AppException transportException;
  final String? backendCode;
  final Map<String, Object?> backendMetadata;

  int? get httpStatus => transportException.httpStatus;

  @override
  String toString() {
    return 'ApiEndpointException('
        'httpStatus: $httpStatus, '
        'backendCode: $backendCode, '
        'transportKind: ${transportException.transportKind})';
  }
}
