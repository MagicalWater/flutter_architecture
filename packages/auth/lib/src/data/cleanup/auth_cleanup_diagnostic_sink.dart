import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';

/// 把 Auth cleanup 收集到的錯誤交給 App 統一記錄。
///
/// Auth package 不直接依賴 Crashlytics 或 App 的 `ErrorReporter`；實際怎麼記錄由 App 實作。
/// 記錄失敗也不能反過來改變 cleanup／migration 原本的結果。
abstract interface class AuthCleanupDiagnosticSink {
  /// 一次回報這次 cleanup 收集到的所有診斷；其中一筆記錄失敗也不能中斷後面的資料。
  void reportAll(Iterable<AuthCleanupDiagnostic> diagnostics);
}
