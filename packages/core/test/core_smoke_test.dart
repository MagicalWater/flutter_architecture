import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  test('Result.when 可以正確處理 Success', () {
    const result = Success<int>(1);

    final value = result.when(
      success: (data) => data,
      failure: (_) => -1,
    );

    expect(value, 1);
  });
}
