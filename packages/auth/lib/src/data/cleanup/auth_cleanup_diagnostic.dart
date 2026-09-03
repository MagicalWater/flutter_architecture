/// 標記 Auth 清理失敗時，當時正在清哪一份資料。
///
/// Cleanup 會把 secure credential、舊 credential、使用者資料等都盡量清完，不會第一個
/// store 失敗就停；因此需要記住「是哪一步失敗」，最後才能決定要拋哪個錯誤、記錄哪一筆診斷。
enum AuthCleanupOperation {
  /// Credential 已成功搬到 secure storage 後，清掉舊版 credential。
  ///
  /// 這和一般 logout／reset 的 [legacyCleanup] 不同；這裡只代表 migration 完成後的收尾。
  migrationLegacyCleanup,

  /// 清除目前正式使用的 secure credential。
  secureCleanup,

  /// 在一般 logout／reset cleanup 中清除舊版 credential。
  legacyCleanup,

  /// 清除本機保存的登入使用者資料。
  userCleanup,

  /// 清除「下次啟動要先做 Face ID／指紋解鎖」的設定。
  localUnlockPreferenceCleanup,
}

/// 保存某一個 cleanup 步驟失敗時的原始 error 與 stack trace。
///
/// 這份資料先被收集起來，讓其他 cleanup 繼續執行；全部做完後再統一決定哪個錯誤需要拋出。
final class AuthCleanupDiagnostic {
  const AuthCleanupDiagnostic({
    required this.operation,
    required this.error,
    required this.stackTrace,
  });

  final AuthCleanupOperation operation;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'AuthCleanupDiagnostic('
        'operation: $operation, '
        'errorType: ${error.runtimeType})';
  }
}
