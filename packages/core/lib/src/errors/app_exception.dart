enum AppExceptionKind {
  transport,
  backend,
  localStorage,
  dataCorruption,
  protocol,
  session,
}

enum TransportExceptionKind {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  connection,
  badCertificate,
  cancelled,
  response,
  unknown,
}

/// Data Layer 或 Infrastructure Layer 使用的例外型別。
///
/// ## 所屬位置
///
/// 這個型別可以被 Data Layer 使用，最後通常會被轉換成 [Failure]。
class AppException implements Exception {
  const AppException({
    this.kind = AppExceptionKind.backend,
    required this.message,
    this.transportKind,
    this.httpStatus,
    this.backendCode,
    String? diagnosticCode,
    String? code,
    this.cause,
    this.stackTrace,
  }) : diagnosticCode = diagnosticCode ?? code;

  final AppExceptionKind kind;
  final String message;
  final TransportExceptionKind? transportKind;
  final int? httpStatus;
  final String? backendCode;
  final String? diagnosticCode;
  final Object? cause;
  final StackTrace? stackTrace;

  /// 舊程式的相容讀取入口；新程式應使用明確 typed 欄位。
  String? get code =>
      backendCode ?? httpStatus?.toString() ?? diagnosticCode;

  @override
  String toString() {
    return 'AppException('
        'kind: $kind, '
        'transportKind: $transportKind, '
        'httpStatus: $httpStatus, '
        'backendCode: $backendCode, '
        'diagnosticCode: $diagnosticCode, '
        'message: $message)';
  }
}
