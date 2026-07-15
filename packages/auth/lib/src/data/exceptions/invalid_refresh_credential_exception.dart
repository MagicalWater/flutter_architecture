import 'package:core/core.dart';

class InvalidRefreshCredentialException extends AppException {
  const InvalidRefreshCredentialException({super.cause})
      : super(message: 'Refresh credential 無效');
}
