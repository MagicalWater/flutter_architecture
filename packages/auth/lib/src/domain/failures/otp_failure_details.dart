/// OTP 驗證失敗的原因。
enum OtpFailureKind {
  /// 驗證碼不正確，但 challenge 仍可繼續嘗試。
  invalidCode,

  /// 這組 OTP challenge 已超過有效時間。
  challengeExpired,

  /// 錯誤次數已達上限，不能再繼續驗證。
  tooManyAttempts,

  /// 還在重新發送冷卻時間內，暫時不能再發 OTP。
  resendCooldown,

  /// 這組 challenge 已被新的流程或後端狀態作廢。
  challengeInvalidated,

  /// 後端回傳內容不符合既定 OTP 協定，Client 無法安全判斷下一步。
  protocolViolation,
}

/// OTP 失敗後，畫面決定下一步需要的補充資料。
///
/// 例如還能嘗試幾次或何時可以重新發送；不讓 Presentation 自己解析後端 raw payload。
final class OtpFailureDetails {
  const OtpFailureDetails({
    required this.kind,
    this.attemptsRemaining,
    this.retryAt,
  });

  final OtpFailureKind kind;
  final int? attemptsRemaining;
  final DateTime? retryAt;

  @override
  String toString() => 'OtpFailureDetails(kind: $kind)';
}
