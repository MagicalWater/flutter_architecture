/// Data Layer 或 Infrastructure Layer 使用的例外型別。
///
/// ## 所屬位置
///
/// 這個型別可以被 Data Layer 使用，最後通常會被轉換成 [Failure]。
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException(code: $code, message: $message, cause: $cause)';
}
