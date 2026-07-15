import 'package:core/core.dart';

/// 表示本地 Token Pair payload 已損壞，應清除並視為未登入。
class CorruptedAuthTokensException extends AppException {
  const CorruptedAuthTokensException({super.cause})
      : super(message: '本地 token pair 已損壞');
}
