/// Domain／Presentation 能理解的失敗大分類。
enum FailureKind {
  /// 網路目前不可用、連線失敗或傳輸逾時。
  network,

  /// 後端服務失敗或一般非認證類服務錯誤。
  service,

  /// 登入、Session 或權限狀態失效。
  authentication,

  /// 本機資料讀寫、偏好或快取狀態有問題。
  localState,

  /// Client 與 Server 的資料格式或協定不符合預期。
  protocol,
}

/// 已從底層 Exception 整理過、可以交給 Bloc／UI 判斷的失敗資訊。
///
/// Dio、SQLite 等 implementation error 不應直接跑到畫面；Data 層會把它們轉成
/// [Failure]，Presentation 再依 [kind]／code 映射成目前語系的使用者文案。
class Failure {
  const Failure({
    this.kind = FailureKind.service,
    required this.message,
    this.httpStatus,
    this.backendCode,
    this.providerCode,
    this.diagnosticCode,
    this.cause,
    this.stackTrace,
  });

  final FailureKind kind;

  /// 診斷與 fallback 訊息，不保證可直接作為 localized UI 文案。
  final String message;

  final int? httpStatus;
  final String? backendCode;

  /// 從底層 SDK／plugin 保留下來的 machine-readable code；沒有 provider code 時為 null。
  ///
  /// 只供 diagnostics 使用；Presentation 不應依這個欄位決定文案或流程。
  final String? providerCode;
  final String? diagnosticCode;

  /// 原始錯誤，通常只用於除錯。
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'Failure('
        'kind: $kind, '
        'httpStatus: $httpStatus, '
        'backendCode: $backendCode, '
        'providerCode: $providerCode, '
        'diagnosticCode: $diagnosticCode, '
        'message: $message)';
  }
}
