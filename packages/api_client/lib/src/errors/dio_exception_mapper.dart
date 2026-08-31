import 'package:api_client/src/errors/api_endpoint_exception.dart';
import 'package:api_client/src/errors/transport_failure_details.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';

AppException mapDioException(
  DioException error,
  StackTrace stackTrace, {
  String? backendCode,
}) {
  final details = TransportFailureDetails.fromDioException(error);
  return AppException(
    kind: AppExceptionKind.transport,
    message: 'API request failed',
    transportKind: details.type,
    httpStatus: details.statusCode,
    backendCode: backendCode,
    cause: details,
    stackTrace: stackTrace,
  );
}

ApiEndpointException mapDioEndpointException(
  DioException error,
  StackTrace stackTrace, {
  Set<String> safeMetadataKeys = const <String>{},
}) {
  final payload = _stringKeyedMap(error.response?.data);
  final rawBackendCode = payload.remove('code');
  final backendCode = rawBackendCode is String ? rawBackendCode : null;
  final backendMetadata = <String, Object?>{
    for (final key in safeMetadataKeys)
      if (payload.containsKey(key)) key: payload[key],
  };

  return ApiEndpointException(
    transportException: mapDioException(
      error,
      stackTrace,
      backendCode: backendCode,
    ),
    backendCode: backendCode,
    backendMetadata: backendMetadata,
  );
}

Map<String, Object?> _stringKeyedMap(Object? value) {
  if (value is! Map) return <String, Object?>{};

  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is String) {
      result[key] = entry.value;
    }
  }
  return result;
}
