import 'dart:collection';

import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 從 [ErrorReport] 取出可以安全送到 provider 的簡短文字欄位。
///
/// 不包含 error message、stack trace、request body 等可能含敏感資訊的內容。
final class ErrorReportMetadata {
  ErrorReportMetadata._(Map<String, String> values)
    : values = UnmodifiableMapView<String, String>(values);

  factory ErrorReportMetadata.fromReport(ErrorReport report) {
    return ErrorReportMetadata._(<String, String>{
      'severity': report.severity.name,
      'source': report.context.source.name,
      'operation': report.context.operation.name,
      'error_type': report.error.runtimeType.toString(),
    });
  }

  final Map<String, String> values;

  @override
  String toString() => 'ErrorReportMetadata(keys: ${values.keys.join(',')})';
}

/// 封裝 App error-reporting policy，負責 degraded rate limit 與 reporter failure isolation。
final class ErrorReportingRouter implements ErrorReporter {
  ErrorReportingRouter({
    required ErrorReporter delegate,
    int degradedBurstLimit = 5,
  }) : _delegate = delegate,
       _degradedBurstLimit = degradedBurstLimit;

  final ErrorReporter _delegate;
  final int _degradedBurstLimit;
  final Map<_DegradedRateLimitKey, int> _degradedCounts =
      <_DegradedRateLimitKey, int>{};
  bool _isReporting = false;

  @override
  void report(ErrorReport report) {
    if (_isReporting || !_shouldForward(report)) {
      return;
    }

    _isReporting = true;
    try {
      _delegate.report(report);
    } on Object {
      // Reporting是best effort；provider或adapter failure不得改變App flow。
    } finally {
      _isReporting = false;
    }
  }

  bool _shouldForward(ErrorReport report) {
    if (report.severity != ErrorSeverity.degraded) {
      return true;
    }

    final key = _DegradedRateLimitKey(
      source: report.context.source,
      operation: report.context.operation,
    );
    final count = _degradedCounts[key] ?? 0;
    if (count >= _degradedBurstLimit) {
      return false;
    }
    _degradedCounts[key] = count + 1;
    return true;
  }
}

final class _DegradedRateLimitKey {
  const _DegradedRateLimitKey({required this.source, required this.operation});

  final ErrorReportSource source;
  final ErrorReportOperation operation;

  @override
  bool operator ==(Object other) {
    return other is _DegradedRateLimitKey &&
        other.source == source &&
        other.operation == operation;
  }

  @override
  int get hashCode => Object.hash(source, operation);
}
