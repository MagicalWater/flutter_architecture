import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/app/error_reporting/app_bloc_observer.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bloc error以unexpected與固定safe context上報', () async {
    final reporter = _RecordingReporter();
    final observer = AppBlocObserver(reporter, ErrorReportDeduplicator());
    final bloc = _TestCubit();
    final error = StateError('bloc failed');
    final stackTrace = StackTrace.current;
    addTearDown(bloc.close);

    observer.onError(bloc, error, stackTrace);

    expect(reporter.reports, hasLength(1));
    final report = reporter.reports.single;
    expect(report.error, same(error));
    expect(report.stackTrace, same(stackTrace));
    expect(report.severity, ErrorSeverity.unexpected);
    expect(report.context.source, ErrorReportSource.bloc);
    expect(report.context.operation, ErrorReportOperation.blocUnhandledError);
  });

  test('Reporter失敗不會從BlocObserver向外拋出', () async {
    final observer = AppBlocObserver(
      _ThrowingReporter(),
      ErrorReportDeduplicator(),
    );
    final bloc = _TestCubit();
    addTearDown(bloc.close);

    expect(
      () =>
          observer.onError(bloc, StateError('bloc failed'), StackTrace.current),
      returnsNormally,
    );
  });

  test('Bloc global observer會接收Cubit error且只上報一次', () async {
    final previousObserver = Bloc.observer;
    final reporter = _RecordingReporter();
    Bloc.observer = AppBlocObserver(reporter, ErrorReportDeduplicator());
    addTearDown(() => Bloc.observer = previousObserver);
    final bloc = _TestCubit();
    addTearDown(bloc.close);
    final error = StateError('bloc failed');
    final stackTrace = StackTrace.current;

    bloc.emitError(error, stackTrace);

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.error, same(error));
    expect(reporter.reports.single.stackTrace, same(stackTrace));
  });
}

final class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);

  void emitError(Object error, StackTrace stackTrace) {
    addError(error, stackTrace);
  }
}

final class _RecordingReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) {
    reports.add(report);
  }
}

final class _ThrowingReporter implements ErrorReporter {
  @override
  void report(ErrorReport report) {
    throw StateError('reporter failed');
  }
}
