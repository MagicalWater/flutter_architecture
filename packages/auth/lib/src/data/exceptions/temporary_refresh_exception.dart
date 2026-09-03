import 'package:core/core.dart';

/// Refresh 服務目前暫時不能完成，但 credential 本身沒有被判定失效。
///
/// 例如後端暫時不可用；上層可以保留 Session，之後再重試。
class TemporaryRefreshException extends AppException {
  const TemporaryRefreshException({super.cause, super.stackTrace})
      : super(
          kind: AppExceptionKind.backend,
          message: 'Refresh service 暫時無法使用',
        );
}
