import 'package:flutter/foundation.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

typedef ErrorReportLogSink = void Function(String message);

/// Development用的安全console adapter。
///
/// 不呼叫 `error.toString()`，只輸出error runtime type與typed safe context。
/// Sink自身失敗時也不向外拋出，避免reporting造成recursive error。
final class DebugErrorReporter implements ErrorReporter {
  DebugErrorReporter({ErrorReportLogSink? sink}) : _sink = sink ?? debugPrint;

  final ErrorReportLogSink _sink;

  @override
  void report(ErrorReport report) {
    try {
      _sink(
        'ErrorReport('
        'errorType: ${report.error.runtimeType}, '
        'severity: ${report.severity.name}, '
        'source: ${report.context.source.name}, '
        'operation: ${report.context.operation.name})',
      );
    } on Object {
      // Reporting必須是best effort，不得改變原始App error flow。
    }
  }
}
