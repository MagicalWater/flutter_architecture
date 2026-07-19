import 'package:core/core.dart';

class TemporaryRefreshException extends AppException {
  const TemporaryRefreshException({super.cause, super.stackTrace})
      : super(
          kind: AppExceptionKind.backend,
          message: 'Refresh service 暫時無法使用',
        );
}
