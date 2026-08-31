import 'package:api_client/src/errors/dio_exception_mapper.dart';
import 'package:api_client/src/errors/transport_failure_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('endpoint metadata only exposes explicitly allowlisted fields', () {
    final request = RequestOptions(path: '/auth/otp/verify');
    final error = DioException(
      requestOptions: request,
      response: Response<Object?>(
        requestOptions: request,
        statusCode: 429,
        data: <String, Object?>{
          'code': 'otp_too_many_attempts',
          'attemptsRemaining': 1,
          'accessToken': 'must-not-cross-boundary',
          'message': 'raw backend payload',
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final mapped = mapDioEndpointException(
      error,
      StackTrace.current,
      safeMetadataKeys: const <String>{'attemptsRemaining'},
    );

    expect(mapped.backendCode, 'otp_too_many_attempts');
    expect(mapped.backendMetadata, const <String, Object?>{'attemptsRemaining': 1});
  });

  test('transport diagnostic does not retain runtime request path', () {
    final request = RequestOptions(path: '/users/private-user-id/profile');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.connectionError,
    );

    final details = TransportFailureDetails.fromDioException(error);

    expect(details.toString(), isNot(contains('private-user-id')));
    expect(details.toString(), contains('method: GET'));
  });
}
