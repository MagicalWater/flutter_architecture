import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioAuthEndpoint', () {
    test('maps Dio bad response to transport-neutral endpoint exception', () async {
      final endpoint = DioAuthEndpoint(
        _ThrowingAuthApi(
          _badResponse(
            path: '/auth/otp/verify',
            statusCode: 400,
            data: const <String, Object?>{
              'code': 'otp_invalid_code',
              'attemptsRemaining': 2,
              'submittedCode': '123456',
            },
          ),
        ),
      );

      final error = await _captureEndpointException(
        () => endpoint.verifyOtp(
          const VerifyOtpRequestDto(
            challengeId: 'challenge',
            code: '123456',
          ),
        ),
      );

      expect(error.httpStatus, 400);
      expect(error.backendCode, 'otp_invalid_code');
      expect(error.backendMetadata['attemptsRemaining'], 2);
      expect(error.transportException.kind, AppExceptionKind.transport);
      expect(error.transportException.transportKind, TransportExceptionKind.response);
      expect(
        () => error.backendMetadata['new'] = 'value',
        throwsUnsupportedError,
      );
      expect(error.toString(), isNot(contains('123456')));
      expect(error.toString(), isNot(contains('attemptsRemaining')));
      expect(error.toString(), isNot(contains('submittedCode')));
    });

    test('maps connection error without response metadata', () async {
      final endpoint = DioAuthEndpoint(
        _ThrowingAuthApi(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      final error = await _captureEndpointException(
        () => endpoint.login(
          const LoginRequestDto(account: 'user', password: 'password'),
        ),
      );

      expect(error.httpStatus, isNull);
      expect(error.backendCode, isNull);
      expect(error.backendMetadata, isEmpty);
      expect(
        error.transportException.transportKind,
        TransportExceptionKind.connection,
      );
    });

    test('preserves unknown error identity', () async {
      final original = StateError('bug');
      final endpoint = DioAuthEndpoint(_ThrowingAuthApi(original));

      await expectLater(
        endpoint.login(
          const LoginRequestDto(account: 'user', password: 'password'),
        ),
        throwsA(same(original)),
      );
    });
  });

  test('DioAuthRefreshEndpoint uses the same neutral failure contract', () async {
    final endpoint = DioAuthRefreshEndpoint(
      _ThrowingAuthRefreshApi(
        _badResponse(
          path: '/auth/refresh',
          statusCode: 401,
          data: const <String, Object?>{'code': 'refresh_invalid'},
        ),
      ),
    );

    final error = await _captureEndpointException(
      () => endpoint.refresh(
        const RefreshTokenRequestDto(refreshToken: 'refresh-token'),
      ),
    );

    expect(error.httpStatus, 401);
    expect(error.backendCode, 'refresh_invalid');
    expect(error.transportException.kind, AppExceptionKind.transport);
  });
}

Future<ApiEndpointException> _captureEndpointException(
  Future<Object?> Function() operation,
) async {
  try {
    await operation();
    fail('Expected ApiEndpointException');
  } on ApiEndpointException catch (error) {
    return error;
  }
}

DioException _badResponse({
  required String path,
  required int statusCode,
  required Map<String, Object?> data,
}) {
  final options = RequestOptions(path: path);
  return DioException.badResponse(
    statusCode: statusCode,
    requestOptions: options,
    response: Response<Map<String, Object?>>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

final class _ThrowingAuthApi implements AuthApi {
  _ThrowingAuthApi(this.error);

  final Object error;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async => throw error;

  @override
  Future<AuthenticatedResponseDto> verifyOtp(
    VerifyOtpRequestDto request,
  ) async => throw error;

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) async =>
      throw error;
}

final class _ThrowingAuthRefreshApi implements AuthRefreshApi {
  _ThrowingAuthRefreshApi(this.error);

  final Object error;

  @override
  Future<RefreshTokenResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) async => throw error;
}
