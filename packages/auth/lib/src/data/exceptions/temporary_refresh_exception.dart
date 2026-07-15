import 'package:core/core.dart';

class TemporaryRefreshException extends AppException {
  const TemporaryRefreshException({super.cause})
      : super(message: 'Refresh service 暫時無法使用');
}
