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
  if (exception.kind == AppExceptionKind.transport &&
      exception.transportKind == TransportExceptionKind.cancelled) {
    // Cancellation 是 control flow，不得被 generic mapper 降級成普通 Failure；
    // 保留原始 exception identity 與 stack，交回擁有 operation 語意的 boundary。
    Error.throwWithStackTrace(
      exception,
      exception.stackTrace ?? StackTrace.current,
    );
  }

  return Failure(
    kind: _mapFailureKind(exception),
    message: fallbackMessage,
    httpStatus: exception.httpStatus,
    backendCode: exception.backendCode,
    diagnosticCode: exception.diagnosticCode,
    cause: exception.cause ?? exception,
    stackTrace: exception.stackTrace,
  );
}

FailureKind _mapFailureKind(AppException exception) {
  return switch (exception.kind) {
    AppExceptionKind.transport => switch (exception.transportKind) {
        TransportExceptionKind.connectionTimeout ||
        TransportExceptionKind.sendTimeout ||
        TransportExceptionKind.receiveTimeout ||
        TransportExceptionKind.connection ||
        TransportExceptionKind.badCertificate ||
        TransportExceptionKind.unknown => FailureKind.network,
        TransportExceptionKind.response ||
        TransportExceptionKind.cancelled ||
        null => FailureKind.service,
      },
    AppExceptionKind.backend => FailureKind.service,
    AppExceptionKind.localStorage || AppExceptionKind.dataCorruption =>
      FailureKind.localState,
    AppExceptionKind.protocol => FailureKind.protocol,
    AppExceptionKind.session => FailureKind.authentication,
  };
}
