import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/observability/observability_runtime_config.dart';

/// 只在明確開啟 acceptance mode 時，送出一筆受控的測試 error。
///
/// 用來驗證 staging 的 remote collection、release metadata 與 symbolication pipeline；
/// 一般 App 執行不會觸發，production 也不允許開啟。
final class ObservabilityAcceptanceEvent {
  const ObservabilityAcceptanceEvent._();

  static void emit({
    required ErrorReporter reporter,
    required ObservabilityRuntimeConfig config,
  }) {
    if (!config.emitAcceptanceEvent) return;

    reporter.report(
      ErrorReport(
        error: StateError('controlled-observability-acceptance-event'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.unexpected,
        context: const ErrorReportContext(
          operation: ErrorReportOperation.observabilityAcceptance,
        ),
      ),
    );
  }
}
