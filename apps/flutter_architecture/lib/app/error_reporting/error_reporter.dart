import 'package:flutter_architecture/app/error_reporting/error_report.dart';

/// App 需要統一記錄的錯誤都透過這個介面送出。
///
/// Feature 與 package 不需要知道 Firebase Crashlytics 或其他 provider；App 啟動時再決定
/// 實際要接哪個 reporter。
abstract interface class ErrorReporter {
  void report(ErrorReport report);
}

/// 明確丟棄所有 error report；用在未啟用 provider 或測試情境。
final class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  void report(ErrorReport report) {}
}
