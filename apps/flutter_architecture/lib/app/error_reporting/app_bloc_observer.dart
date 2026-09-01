import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 將未被Bloc自身轉為typed UI state的錯誤送往App reporting boundary。
///
/// 不讀取Bloc state、event或runtime內容，避免敏感資料進入report context。
final class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._reporter, this._deduplicator);

  final ErrorReporter _reporter;
  final ErrorReportDeduplicator _deduplicator;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    try {
      _reporter.report(
        ErrorReport(
          error: error,
          stackTrace: stackTrace,
          severity: ErrorSeverity.unexpected,
          context: const ErrorReportContext(
            operation: ErrorReportOperation.blocUnhandledError,
          ),
        ),
      );
      _deduplicator.markReported(error, stackTrace);
    } on Object {
      // Reporting不得改變Bloc原有error propagation。
    }

    super.onError(bloc, error, stackTrace);
  }
}
