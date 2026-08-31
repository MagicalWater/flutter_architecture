import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transport cancellation cannot be downgraded into Failure', () {
    final stackTrace = StackTrace.current;
    final exception = AppException(
      kind: AppExceptionKind.transport,
      transportKind: TransportExceptionKind.cancelled,
      message: 'cancelled',
      stackTrace: stackTrace,
    );

    try {
      mapAppExceptionToFailure(exception, fallbackMessage: 'fallback');
      fail('Cancellation must not return Failure.');
    } catch (error, caughtStackTrace) {
      expect(error, same(exception));
      expect(caughtStackTrace.toString(), stackTrace.toString());
    }
  });
}
