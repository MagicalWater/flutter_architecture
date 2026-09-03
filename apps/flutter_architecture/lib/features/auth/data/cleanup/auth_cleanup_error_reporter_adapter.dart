import 'package:auth/auth_infrastructure.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 把 Auth package 的 cleanup 錯誤轉成 App [ErrorReporter] 看得懂的格式。
///
/// 這裡只做 operation 對應與 error reporting；即使 reporter 自己失敗，也不能改變
/// Auth cleanup／migration 原本成功或失敗的判定。
final class AuthCleanupErrorReporterAdapter
    implements AuthCleanupDiagnosticSink {
  const AuthCleanupErrorReporterAdapter(this._reporter);

  final ErrorReporter _reporter;

  @override
  void reportAll(Iterable<AuthCleanupDiagnostic> diagnostics) {
    for (final diagnostic in diagnostics) {
      try {
        _reporter.report(
          ErrorReport(
            error: diagnostic.error,
            stackTrace: diagnostic.stackTrace,
            severity: ErrorSeverity.degraded,
            context: ErrorReportContext(
              operation: _mapOperation(diagnostic.operation),
            ),
          ),
        );
      } on Object {
        // 記錄失敗不能影響 cleanup 結果，也不能阻止後續 diagnostics 繼續回報。
      }
    }
  }

  ErrorReportOperation _mapOperation(AuthCleanupOperation operation) {
    return switch (operation) {
      AuthCleanupOperation.migrationLegacyCleanup =>
        ErrorReportOperation.authMigrationLegacyCleanup,
      AuthCleanupOperation.secureCleanup =>
        ErrorReportOperation.authSecureCleanup,
      AuthCleanupOperation.legacyCleanup =>
        ErrorReportOperation.authLegacyCleanup,
      AuthCleanupOperation.userCleanup => ErrorReportOperation.authUserCleanup,
      AuthCleanupOperation.localUnlockPreferenceCleanup =>
        ErrorReportOperation.authLocalUnlockPreferenceCleanup,
    };
  }
}
