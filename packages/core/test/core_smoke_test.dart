import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Result.when 可以正確處理 Success', () {
    const result = Success<int>(1);

    final value = result.when(
      success: (data) => data,
      failure: (_) => -1,
    );

    expect(value, 1);
  });

  test('Result.when 的 failure channel 只傳遞 Failure', () {
    const failure = Failure(message: 'diagnostic');
    const result = FailureResult<int>(failure);

    final captured = result.when<Failure?>(
      success: (_) => null,
      failure: (value) => value,
    );

    expect(captured, same(failure));
  });

  test('AppException mapper 會使用 domain fallback 並保留診斷資訊', () {
    final cause = StateError('network failed');
    final failure = mapAppExceptionToFailure(
      AppException(
        kind: AppExceptionKind.transport,
        message: 'API request failed',
        transportKind: TransportExceptionKind.response,
        httpStatus: 503,
        cause: cause,
        stackTrace: StackTrace.current,
      ),
      fallbackMessage: '登入失敗',
    );

    expect(failure.message, '登入失敗');
    expect(failure.kind, FailureKind.service);
    expect(failure.httpStatus, 503);
    expect(failure.cause, same(cause));
    expect(failure.stackTrace, isNotNull);
  });

  test('AppException 與 Failure toString 不展開 cause', () {
    final sensitiveCause = StateError('token=secret');
    final exception = AppException(
      kind: AppExceptionKind.localStorage,
      message: 'storage failed',
      cause: sensitiveCause,
    );
    final failure = Failure(
      kind: FailureKind.localState,
      message: 'storage failed',
      cause: sensitiveCause,
    );

    expect(exception.toString(), isNot(contains('token=secret')));
    expect(failure.toString(), isNot(contains('token=secret')));
  });
}
