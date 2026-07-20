enum ErrorSeverity { degraded, unexpected, fatal }

enum ErrorReportSource {
  bootstrap,
  flutterFramework,
  platform,
  bloc,
  preference,
  catalogCache,
  authMigration,
}

enum ErrorReportOperation {
  bootstrapInitialize,
  flutterFrameworkError,
  platformUncaughtAsync,
  blocUnhandledError,
  preferenceRestore,
  preferenceWrite,
  catalogCacheRead,
  catalogCacheWrite,
  catalogCacheCleanup,
  authMigrationLegacyCleanup,
}

/// 可安全送往 reporting adapter 的封閉 context。
///
/// 不接受任意 Map 或 String operation，避免 request body、token、query、state、
/// event 或其他敏感內容被無意加入。
final class ErrorReportContext {
  const ErrorReportContext({required this.source, required this.operation});

  final ErrorReportSource source;
  final ErrorReportOperation operation;

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
