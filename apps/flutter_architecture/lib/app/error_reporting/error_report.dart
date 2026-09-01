enum ErrorSeverity { degraded, unexpected, fatal }

enum ErrorReportSource {
  bootstrap,
  flutterFramework,
  platform,
  bloc,
  preference,
  catalogCache,
  authLifecycle,
}

enum ErrorReportOperation {
  bootstrapInitialize,
  observabilityAcceptance,
  flutterFrameworkError,
  platformUncaughtAsync,
  blocUnhandledError,
  preferenceRestore,
  preferenceWrite,
  catalogCacheRead,
  catalogCacheWrite,
  catalogCacheCleanup,
  authMigrationLegacyCleanup,
  authSecureCleanup,
  authLegacyCleanup,
  authUserCleanup,
  authLocalUnlockPreferenceCleanup,
}

/// 可安全送往 reporting adapter 的封閉 context。
///
/// 不接受任意 Map 或 String operation，避免 request body、token、query、state、
/// event 或其他敏感內容被無意加入。
final class ErrorReportContext {
  const ErrorReportContext({required this.operation});

  final ErrorReportOperation operation;

  /// Operation 是 reporting context 的唯一 authority；source 由 operation 推導，
  /// 避免 caller 手動傳入互相矛盾的 source / operation 組合。
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

/// Reporter boundary 的 immutable input。
///
/// [toString] 不展開 error 或 stack trace；adapter若要存取原始資料必須明確使用
/// typed 欄位。
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
