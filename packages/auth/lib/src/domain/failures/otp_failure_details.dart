enum OtpFailureKind {
  invalidCode,
  challengeExpired,
  tooManyAttempts,
  resendCooldown,
  challengeInvalidated,
  protocolViolation,
}

/// Safe typed transition metadata for OTP failures.
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
