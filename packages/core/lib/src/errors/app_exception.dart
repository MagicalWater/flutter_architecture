/// App 內部例外的大分類，讓上層知道問題大致發生在哪一種基礎能力。
enum AppExceptionKind {
  /// 網路連線或 HTTP 傳輸階段失敗。
  transport,

  /// 後端有回應，但服務端回報失敗。
  backend,

  /// 本機資料庫、SharedPreferences、Secure Storage 等讀寫失敗。
  localStorage,

  /// 已保存的資料內容不合法、損壞或無法解析。
  dataCorruption,

  /// Client 與 Server 的資料格式或協定不符合預期。
  protocol,

  /// 登入 Session 或 credential 狀態已失效。
  session,
}

/// 網路傳輸失敗的更細分類，主要用來保留 Dio／HTTP 層的失敗原因。
enum TransportExceptionKind {
  /// 建立連線超時。
  connectionTimeout,

  /// 上傳 request 資料超時。
  sendTimeout,

  /// 等待 response 資料超時。
  receiveTimeout,

  /// 無法建立或維持網路連線。
  connection,

  /// TLS／憑證驗證失敗。
  badCertificate,

  /// Request 被主動取消。
  cancelled,

  /// Server 有回應，但 HTTP response 本身代表失敗。
  response,

  /// 無法歸類到上述原因的傳輸錯誤。
  unknown,
}

/// Data／Infrastructure 層用來保留「實際發生了什麼」的錯誤。
///
/// 它可以保留 HTTP status、後端 code、原始 cause 等診斷資訊；進入 Domain／UI 前
/// 通常會再整理成 [Failure]，避免畫面直接依賴底層 implementation error。
class AppException implements Exception {
  const AppException({
    this.kind = AppExceptionKind.backend,
    required this.message,
    this.transportKind,
    this.httpStatus,
    this.backendCode,
    this.providerCode,
    this.diagnosticCode,
    this.cause,
    this.stackTrace,
  });

  final AppExceptionKind kind;
  final String message;
  final TransportExceptionKind? transportKind;
  final int? httpStatus;
  final String? backendCode;

  /// 底層 SDK／plugin 回傳的 machine-readable code，例如 `PlatformException.code`。
  ///
  /// 只保存字串，不把 provider-specific enum／type 暴露到 Core API。未來 provider
  /// 新增 code 時，也能保留診斷線索，而不用先修改 Core taxonomy。
  /// 此欄位只供 diagnostics 使用，不應成為 Domain／Presentation 的分支依據。
  final String? providerCode;
  final String? diagnosticCode;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'AppException('
        'kind: $kind, '
        'transportKind: $transportKind, '
        'httpStatus: $httpStatus, '
        'backendCode: $backendCode, '
        'providerCode: $providerCode, '
        'diagnosticCode: $diagnosticCode, '
        'message: $message)';
  }
}
