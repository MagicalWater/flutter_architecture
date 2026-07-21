/// 本機使用者存在驗證能力。
///
/// 此 contract 不代表 Server authentication，也不暴露任何 platform plugin
/// type、biometric type 或原始 platform error code。
abstract interface class LocalUserPresenceVerifier {
  Future<LocalUserPresenceCapability> checkCapability();

  Future<LocalUserPresenceVerification> verify({required String reason});
}

enum LocalUserPresenceOperation { capabilityCheck, verify }

final class LocalUserPresenceOperationalException implements Exception {
  const LocalUserPresenceOperationalException({
    required this.operation,
    required this.cause,
    required this.stackTrace,
  });

  final LocalUserPresenceOperation operation;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'LocalUserPresenceOperationalException(operation: $operation)';
  }
}

sealed class LocalUserPresenceCapability {
  const LocalUserPresenceCapability();

  const factory LocalUserPresenceCapability.available() =
      LocalUserPresenceAvailable;

  const factory LocalUserPresenceCapability.unavailable(
    LocalUserPresenceUnavailableReason reason,
  ) = LocalUserPresenceUnavailable;
}

final class LocalUserPresenceAvailable extends LocalUserPresenceCapability {
  const LocalUserPresenceAvailable();

  @override
  bool operator ==(Object other) => other is LocalUserPresenceAvailable;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class LocalUserPresenceUnavailable extends LocalUserPresenceCapability {
  const LocalUserPresenceUnavailable(this.reason);

  final LocalUserPresenceUnavailableReason reason;

  @override
  bool operator ==(Object other) =>
      other is LocalUserPresenceUnavailable && other.reason == reason;

  @override
  int get hashCode => Object.hash(LocalUserPresenceUnavailable, reason);
}

enum LocalUserPresenceUnavailableReason {
  noHardware,
  notEnrolled,
  temporarilyUnavailable,
}

sealed class LocalUserPresenceVerification {
  const LocalUserPresenceVerification();

  const factory LocalUserPresenceVerification.verified() =
      LocalUserPresenceVerified;

  const factory LocalUserPresenceVerification.rejected(
    LocalUserPresenceRejectionReason reason,
  ) = LocalUserPresenceRejected;
}

final class LocalUserPresenceVerified extends LocalUserPresenceVerification {
  const LocalUserPresenceVerified();

  @override
  bool operator ==(Object other) => other is LocalUserPresenceVerified;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class LocalUserPresenceRejected extends LocalUserPresenceVerification {
  const LocalUserPresenceRejected(this.reason);

  final LocalUserPresenceRejectionReason reason;

  @override
  bool operator ==(Object other) =>
      other is LocalUserPresenceRejected && other.reason == reason;

  @override
  int get hashCode => Object.hash(LocalUserPresenceRejected, reason);
}

enum LocalUserPresenceRejectionReason {
  notVerified,
  cancelled,
  notEnrolled,
  noHardware,
  temporaryLockout,
  permanentLockout,
  temporarilyUnavailable,
}
