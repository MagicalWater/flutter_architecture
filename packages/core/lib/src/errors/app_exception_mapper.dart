import 'package:core/src/errors/app_exception.dart';
import 'package:core/src/errors/failure.dart';

/// 將 Data / Infrastructure Layer 的 [AppException] 轉為 Domain 可理解的 Failure。
///
/// [fallbackMessage] 是不依賴 locale 的診斷 fallback；
/// Presentation 不應直接顯示它，而應依 code / operation 映射 localized copy。
/// exception 原始 message 留在 cause chain 供 log 與除錯使用。
Failure mapAppExceptionToFailure(
  AppException exception, {
  required String fallbackMessage,
}) {
  return Failure(
    message: fallbackMessage,
    code: exception.code,
    cause: exception.cause ?? exception,
  );
}
