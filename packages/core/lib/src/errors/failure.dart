/// Domain 層可以理解的失敗型別。
///
/// ## 為什麼不用 Exception？
///
/// Exception 通常代表外部實作錯誤，例如 Dio、SQLite、檔案系統。
///
/// Failure 則是整理後，準備交給 UseCase、Bloc、UI 使用的失敗資訊。
class Failure {
  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  /// 給 UI 或 log 使用的人類可讀訊息。
  final String message;

  /// 可選錯誤代碼，例如 API error code。
  final String? code;

  /// 原始錯誤，通常只用於除錯。
  final Object? cause;

  @override
  String toString() => 'Failure(code: $code, message: $message, cause: $cause)';
}
