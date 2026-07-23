import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/observability/observability_acceptance_event.dart';
import 'package:flutter_architecture/app/observability/observability_runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enabled staging config emits one handled non-fatal event', () {
    final reporter = RecordingErrorReporter();
    final config = ObservabilityRuntimeConfig.resolve(
      environment: AppEnvironment.staging,
      remoteCollectionRequested: true,
      acceptanceEventRequested: true,
    );

    ObservabilityAcceptanceEvent.emit(reporter: reporter, config: config);

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.severity, ErrorSeverity.unexpected);
    expect(
      reporter.reports.single.context.operation,
      ErrorReportOperation.observabilityAcceptance,
    );
  });

  test('disabled config emits nothing', () {
    final reporter = RecordingErrorReporter();
    final config = ObservabilityRuntimeConfig.resolve(
      environment: AppEnvironment.staging,
      remoteCollectionRequested: false,
      acceptanceEventRequested: false,
    );

    ObservabilityAcceptanceEvent.emit(reporter: reporter, config: config);

    expect(reporter.reports, isEmpty);
  });
}

final class RecordingErrorReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) => reports.add(report);
}
