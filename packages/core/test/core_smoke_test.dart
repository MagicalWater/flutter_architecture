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

  test('AppException mapper 會使用 domain fallback 並保留診斷資訊', () {
    final cause = StateError('network failed');
    final failure = mapAppExceptionToFailure(
      AppException(
        message: 'API request failed',
        code: '503',
        cause: cause,
      ),
      fallbackMessage: '登入失敗',
    );

    expect(failure.message, '登入失敗');
    expect(failure.code, '503');
    expect(failure.cause, same(cause));
  });
}
