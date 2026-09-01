/// 本機使用者存在驗證能力。
///
/// 此 contract 不代表 Server authentication，也不暴露任何 platform plugin
/// type、biometric type 或原始 platform error code。
abstract interface class LocalUserPresenceVerifier {
  Future<LocalUserPresenceCapability> checkCapability();

  Future<LocalUserPresenceVerification> verify({required String reason});
}

/// 標示 operational failure 發生在 capability check 或實際 verification 階段。
enum LocalUserPresenceOperation { capabilityCheck, verify }

/// 包裝 local user-presence 執行期間的 operational / platform failure。
///
/// 這類錯誤不代表使用者「驗證未通過」，而是 capability check 或 verify 本身
/// 無法正常完成。`toString()` 刻意不輸出原始 cause，避免 platform detail 或敏感
/// 診斷資訊意外進入 production log。
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

/// 描述在真正發出驗證前，裝置目前是否具備可用的 local user-presence 能力。
///
/// 這個結果只回答「現在能不能驗」，不代表某一次驗證是否成功。
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

/// 描述 capability check 階段無法進行 local user-presence verification 的原因。
enum LocalUserPresenceUnavailableReason {
  noHardware,
  notEnrolled,
  temporarilyUnavailable,
}

/// 描述實際執行 local user-presence verification 後的結果。
///
/// `verified` 才代表這一次成功取得 user-presence authority；`rejected` 則表示
/// 驗證有被執行但沒有取得該 authority，與 operational exception 是不同類型失敗。
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

/// 描述某次 verification 沒有取得 verified authority 的原因。
enum LocalUserPresenceRejectionReason {
  notVerified,
  cancelled,
  notEnrolled,
  noHardware,
  temporaryLockout,
  permanentLockout,
  temporarilyUnavailable,
}
