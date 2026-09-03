/// 這筆錯誤對 App 造成多嚴重的影響。
enum ErrorSeverity {
  /// 部分功能失敗，但 App 仍可繼續使用，例如偏好設定或快取寫入失敗。
  degraded,

  /// 發生不在預期流程內的錯誤，通常需要追查，但不代表 App 一定要立即停止。
  unexpected,

  /// App 已無法安全繼續目前流程，例如啟動失敗或未捕獲的致命 platform error。
  fatal,
}

/// 錯誤大致來自 App 的哪一類功能。
///
/// Caller 不直接指定 source；實際值會由 [ErrorReportOperation] 自動推導，
/// 避免「操作內容」和「來源分類」彼此對不上。
enum ErrorReportSource {
  /// App 啟動與初始化流程。
  bootstrap,

  /// Flutter framework 回報的未處理錯誤。
  flutterFramework,

  /// Dart / platform 層未捕獲的非同步錯誤。
  platform,

  /// Bloc 處理事件或狀態時出現的未處理錯誤。
  bloc,

  /// 語系、Theme 等使用者偏好的讀寫。
  preference,

  /// Catalog cache 的讀取、寫入或清理。
  catalogCache,

  /// Auth migration、credential、user state 或 local unlock 的 lifecycle 清理。
  authLifecycle,
}

/// 發生錯誤時，App 當下正在執行的具體動作。
///
/// 相較於 [ErrorReportSource] 的大分類，operation 用來區分同一功能內到底是哪一步失敗，
/// 方便 log / Crashlytics 一眼看出問題發生在哪個動作。
enum ErrorReportOperation {
  /// 初始化 App 必要服務與依賴時失敗。
  bootstrapInitialize,

  /// 受控的 observability 驗收錯誤，用來確認遠端收集與 symbolication 是否正常。
  observabilityAcceptance,

  /// Flutter framework 捕獲到未處理錯誤。
  flutterFrameworkError,

  /// PlatformDispatcher 捕獲到未處理的非同步錯誤。
  platformUncaughtAsync,

  /// Bloc 執行過程出現未處理錯誤。
  blocUnhandledError,

  /// App 啟動時還原使用者偏好失敗。
  preferenceRestore,

  /// 寫入使用者偏好失敗。
  preferenceWrite,

  /// 讀取 Catalog cache 失敗。
  catalogCacheRead,

  /// 寫入 Catalog cache 失敗。
  catalogCacheWrite,

  /// 清除 Catalog cache 失敗。
  catalogCacheCleanup,

  /// Auth migration 完成後清除舊版 credential 失敗。
  authMigrationLegacyCleanup,

  /// 清除目前使用中的 secure credential 失敗。
  authSecureCleanup,

  /// 一般 Auth cleanup 清除 legacy credential 失敗。
  authLegacyCleanup,

  /// 清除持久化 Auth user state 失敗。
  authUserCleanup,

  /// 清除 local unlock 持久化偏好失敗。
  authLocalUnlockPreferenceCleanup,
}

/// 錯誤回報時使用的固定分類資訊。
///
/// 只允許預先定義的 operation，不接受任意 Map 或字串，避免 request body、token、
/// query、state、event 等敏感內容不小心被塞進錯誤回報。
final class ErrorReportContext {
  const ErrorReportContext({required this.operation});

  final ErrorReportOperation operation;

  /// Source 直接由 operation 推導，避免 caller 傳出彼此矛盾的分類。
  ErrorReportSource get source => switch (operation) {
    ErrorReportOperation.bootstrapInitialize ||
    ErrorReportOperation.observabilityAcceptance => ErrorReportSource.bootstrap,
    ErrorReportOperation.flutterFrameworkError =>
      ErrorReportSource.flutterFramework,
    ErrorReportOperation.platformUncaughtAsync => ErrorReportSource.platform,
    ErrorReportOperation.blocUnhandledError => ErrorReportSource.bloc,
    ErrorReportOperation.preferenceRestore ||
    ErrorReportOperation.preferenceWrite => ErrorReportSource.preference,
    ErrorReportOperation.catalogCacheRead ||
    ErrorReportOperation.catalogCacheWrite ||
    ErrorReportOperation.catalogCacheCleanup => ErrorReportSource.catalogCache,
    ErrorReportOperation.authMigrationLegacyCleanup ||
    ErrorReportOperation.authSecureCleanup ||
    ErrorReportOperation.authLegacyCleanup ||
    ErrorReportOperation.authUserCleanup ||
    ErrorReportOperation.authLocalUnlockPreferenceCleanup =>
      ErrorReportSource.authLifecycle,
  };

  @override
  String toString() {
    return 'ErrorReportContext(source: $source, operation: $operation)';
  }
}

/// 一筆準備送給 error reporter 的完整錯誤資料。
///
/// [toString] 不印出 error 內容或 stack trace，避免除錯輸出意外帶出敏感資料；
/// reporter 若需要原始錯誤，必須明確讀取對應欄位。
final class ErrorReport {
  const ErrorReport({
    required this.error,
    required this.stackTrace,
    required this.severity,
    required this.context,
  });

  final Object error;
  final StackTrace stackTrace;
  final ErrorSeverity severity;
  final ErrorReportContext context;

  @override
  String toString() {
    return 'ErrorReport('
        'errorType: ${error.runtimeType}, '
        'severity: $severity, '
        'source: ${context.source}, '
        'operation: ${context.operation})';
  }
}
