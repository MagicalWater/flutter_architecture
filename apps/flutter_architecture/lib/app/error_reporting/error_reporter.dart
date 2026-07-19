import 'package:flutter_architecture/app/error_reporting/error_report.dart';

/// App-owned reporting boundary。
///
/// Feature與package不依賴任何Crashlytics implementation；實際adapter由App
/// Composition Root組裝。
abstract interface class ErrorReporter {
  void report(ErrorReport report);
}

final class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  void report(ErrorReport report) {}
}
