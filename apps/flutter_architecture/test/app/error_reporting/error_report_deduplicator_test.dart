import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/app/error_reporting/app_bloc_observer.dart';
import 'package:flutter_architecture/app/error_reporting/app_uncaught_error_handler.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bloc已上報的同identity error不會再由Platform重複上報', () async {
    final reporter = _RecordingReporter();
    final deduplicator = ErrorReportDeduplicator();
    final observer = AppBlocObserver(reporter, deduplicator);
    final platformHandler = AppUncaughtErrorHandler(reporter, deduplicator);
    final bloc = _TestCubit();
    addTearDown(bloc.close);
    final error = StateError('bloc failed');
    final stackTrace = StackTrace.current;

    observer.onError(bloc, error, stackTrace);
    final handled = platformHandler.handlePlatformError(error, stackTrace);

    expect(handled, isTrue);
    expect(reporter.reports, hasLength(1));
    expect(
      reporter.reports.single.context.operation,
      ErrorReportOperation.blocUnhandledError,
    );
  });

  test('相同error但不同stack仍視為獨立Platform failure', () async {
    final reporter = _RecordingReporter();
    final deduplicator = ErrorReportDeduplicator();
    final observer = AppBlocObserver(reporter, deduplicator);
    final platformHandler = AppUncaughtErrorHandler(reporter, deduplicator);
    final bloc = _TestCubit();
    addTearDown(bloc.close);
    final error = StateError('reused error');
    final blocStack = StackTrace.current;
    final platformStack = StackTrace.current;

    observer.onError(bloc, error, blocStack);
    platformHandler.handlePlatformError(error, platformStack);

    expect(reporter.reports, hasLength(2));
    expect(reporter.reports.last.severity, ErrorSeverity.fatal);
  });

  test('不同identity的Platform error仍會以fatal上報', () {
    final reporter = _RecordingReporter();
    final deduplicator = ErrorReportDeduplicator();
    final observer = AppBlocObserver(reporter, deduplicator);
    final platformHandler = AppUncaughtErrorHandler(reporter, deduplicator);
    final bloc = _TestCubit();
    addTearDown(bloc.close);

    observer.onError(bloc, StateError('bloc failed'), StackTrace.current);
    platformHandler.handlePlatformError(
      StateError('platform failed'),
      StackTrace.current,
    );

    expect(reporter.reports, hasLength(2));
    expect(reporter.reports.last.severity, ErrorSeverity.fatal);
    expect(
      reporter.reports.last.context.operation,
      ErrorReportOperation.platformUncaughtAsync,
    );
  });

  test('Bloc identity標記只存活於目前event-loop turn', () async {
    final reporter = _RecordingReporter();
    final deduplicator = ErrorReportDeduplicator();
    final observer = AppBlocObserver(reporter, deduplicator);
    final platformHandler = AppUncaughtErrorHandler(reporter, deduplicator);
    final bloc = _TestCubit();
    addTearDown(bloc.close);
    final error = StateError('reused error');

    observer.onError(bloc, error, StackTrace.current);
    await Future<void>.delayed(Duration.zero);
    platformHandler.handlePlatformError(error, StackTrace.current);

    expect(reporter.reports, hasLength(2));
    expect(reporter.reports.last.severity, ErrorSeverity.fatal);
  });

  test('較舊cleanup不會清除同key較新的mark', () async {
    final cleanups = <void Function()>[];
    final deduplicator = ErrorReportDeduplicator(scheduleCleanup: cleanups.add);
    final error = StateError('reused error');
    final stackTrace = StackTrace.current;

    deduplicator.markReported(error, stackTrace);
    deduplicator.markReported(error, stackTrace);
    expect(cleanups, hasLength(2));

    cleanups.first();

    expect(deduplicator.consumeReported(error, stackTrace), isTrue);

    cleanups.last();
    expect(deduplicator.consumeReported(error, stackTrace), isFalse);
  });
}

final class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);
}

final class _RecordingReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) {
    reports.add(report);
  }
}
