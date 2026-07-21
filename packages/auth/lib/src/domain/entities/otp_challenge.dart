/// Server-issued OTP challenge metadata.
final class OtpChallenge {
  OtpChallenge({
    required String challengeId,
    required DateTime expiresAt,
    required String maskedDestination,
    required DateTime resendAvailableAt,
    this.attemptsRemaining,
  }) : challengeId = _requireNonBlank(challengeId, 'challengeId'),
       expiresAt = _requireUtc(expiresAt, 'expiresAt'),
       maskedDestination = _requireNonBlank(
         maskedDestination,
         'maskedDestination',
       ),
       resendAvailableAt = _requireUtc(resendAvailableAt, 'resendAvailableAt') {
    final attempts = attemptsRemaining;
    if (attempts != null && attempts < 0) {
      throw ArgumentError.value(
        attempts,
        'attemptsRemaining',
        'must not be negative',
      );
    }
  }

  final String challengeId;
  final DateTime expiresAt;
  final String maskedDestination;
  final DateTime resendAvailableAt;
  final int? attemptsRemaining;

  static String _requireNonBlank(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not be blank');
    }
    return value;
  }

  static DateTime _requireUtc(DateTime value, String name) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, name, 'must be UTC');
    }
    return value;
  }

  @override
  String toString() => 'OtpChallenge()';
}
