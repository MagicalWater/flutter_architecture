import 'package:core/core.dart';

class InvalidRefreshCredentialException extends AppException {
  const InvalidRefreshCredentialException({super.cause, super.stackTrace})
      : super(
          kind: AppExceptionKind.session,
          message: 'Refresh credential 無效',
        );
}
