import 'package:core/core.dart';

/// Refresh token 已確定無效，這個 Session 不能再繼續刷新。
///
/// 上層收到後應把它當成 Session 已失效，而不是一般暫時性網路錯誤重試。
class InvalidRefreshCredentialException extends AppException {
  const InvalidRefreshCredentialException({super.cause, super.stackTrace})
      : super(
          kind: AppExceptionKind.session,
          message: 'Refresh credential 無效',
        );
}
