enum FailureKind {
  network,
  service,
  authentication,
  localState,
  protocol,
}

/// Domain 層可以理解的失敗型別。
///
/// ## 為什麼不用 Exception？
///
/// Exception 通常代表外部實作錯誤，例如 Dio、SQLite、檔案系統。
///
/// Failure 則是整理後，準備交給 UseCase 與 Bloc 使用的失敗資訊。
/// Presentation 應依穩定 code / kind 映射成目前 locale 的 UI 文案。
class Failure {
  const Failure({
    this.kind = FailureKind.service,
    required this.message,
    this.httpStatus,
    this.backendCode,
    String? diagnosticCode,
    String? code,
    this.cause,
    this.stackTrace,
  }) : diagnosticCode = diagnosticCode ?? code;

  final FailureKind kind;

  /// 診斷與 fallback 訊息，不保證可直接作為 localized UI 文案。
  final String message;

  final int? httpStatus;
  final String? backendCode;
  final String? diagnosticCode;

  /// 原始錯誤，通常只用於除錯。
  final Object? cause;
  final StackTrace? stackTrace;

  /// 舊程式的相容讀取入口；新程式應使用明確 typed 欄位。
  String? get code =>
      backendCode ?? httpStatus?.toString() ?? diagnosticCode;

  @override
  String toString() {
    return 'Failure('
        'kind: $kind, '
        'httpStatus: $httpStatus, '
        'backendCode: $backendCode, '
        'diagnosticCode: $diagnosticCode, '
        'message: $message)';
  }
}
