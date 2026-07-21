import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invalid code preserves typed attempts metadata', () async {
    final source = AuthRemoteDataSource(
      _FailingAuthApi(code: 'otp_invalid_code', data: {'attemptsRemaining': 2}),
    );

    final result = source.verifyOtp(challengeId: 'challenge', code: '000000');
    await expectLater(
      result,
      throwsA(
        isA<AppException>()
            .having((value) => value.backendCode, 'code', 'otp_invalid_code')
            .having(
              (value) => (value.cause as OtpFailureDetails).attemptsRemaining,
              'attempts',
              2,
            ),
      ),
    );
  });

  test('invalid code may intentionally omit attempts metadata', () async {
    final source = AuthRemoteDataSource(
      _FailingAuthApi(code: 'otp_invalid_code', data: const {}),
    );

    await expectLater(
      source.verifyOtp(challengeId: 'challenge', code: '000000'),
      throwsA(
        isA<AppException>().having(
          (value) => (value.cause as OtpFailureDetails).attemptsRemaining,
          'attempts',
          isNull,
        ),
      ),
    );
  });

  for (final entry in <String, OtpFailureKind>{
    'otp_challenge_expired': OtpFailureKind.challengeExpired,
    'otp_too_many_attempts': OtpFailureKind.tooManyAttempts,
    'otp_challenge_invalidated': OtpFailureKind.challengeInvalidated,
  }.entries) {
    test('${entry.key} maps to typed OTP failure identity', () async {
      final source = AuthRemoteDataSource(
        _FailingAuthApi(code: entry.key, data: const {}),
      );

      await expectLater(
        source.verifyOtp(challengeId: 'challenge', code: '000000'),
        throwsA(
          isA<AppException>().having(
            (value) => (value.cause as OtpFailureDetails).kind,
            'kind',
            entry.value,
          ),
        ),
      );
    });
  }

  test('cooldown preserves authoritative retryAt', () async {
    final source = AuthRemoteDataSource(
      _FailingAuthApi(
        code: 'otp_resend_cooldown',
        data: {'retryAt': '2026-07-21T10:00:30.000Z'},
      ),
    );

    await expectLater(
      source.resendOtp(challengeId: 'challenge'),
      throwsA(
        isA<AppException>().having(
          (value) => (value.cause as OtpFailureDetails).retryAt,
          'retryAt',
          DateTime.utc(2026, 7, 21, 10, 0, 30),
        ),
      ),
    );
  });

  test('malformed cooldown metadata is a protocol violation', () async {
    final source = AuthRemoteDataSource(
      _FailingAuthApi(
        code: 'otp_resend_cooldown',
        data: const {'retryAt': 'not-a-timestamp'},
      ),
    );

    await expectLater(
      source.resendOtp(challengeId: 'challenge'),
      throwsA(
        isA<AppException>()
            .having((value) => value.kind, 'kind', AppExceptionKind.protocol)
            .having(
              (value) => value.diagnosticCode,
              'diagnostic',
              'auth_otp_failure_metadata_invalid',
            ),
      ),
    );
  });

  test('unknown errors preserve identity', () async {
    final error = StateError('bug');
    final source = AuthRemoteDataSource(_ThrowingAuthApi(error));
    await expectLater(
      source.verifyOtp(challengeId: 'challenge', code: '123456'),
      throwsA(same(error)),
    );
  });
}

final class _FailingAuthApi extends _BaseAuthApi {
  _FailingAuthApi({required this.code, required this.data});
  final String code;
  final Map<String, dynamic> data;

  Never _failure(String path) {
    final options = RequestOptions(path: path);
    throw DioException.badResponse(
      statusCode: 400,
      requestOptions: options,
      response: Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 400,
        data: {'code': code, ...data},
      ),
    );
  }

  @override
  Future<AuthenticatedResponseDto> verifyOtp(
    VerifyOtpRequestDto request,
  ) async => _failure('/auth/otp/verify');

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) async =>
      _failure('/auth/otp/resend');
}

final class _ThrowingAuthApi extends _BaseAuthApi {
  _ThrowingAuthApi(this.error);
  final Object error;

  @override
  Future<AuthenticatedResponseDto> verifyOtp(
    VerifyOtpRequestDto request,
  ) async => throw error;
}

abstract class _BaseAuthApi implements AuthApi {
  @override
  Future<LoginResponseDto> login(LoginRequestDto request) =>
      throw UnimplementedError();

  @override
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request) =>
      throw UnimplementedError();

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) =>
      throw UnimplementedError();
}
