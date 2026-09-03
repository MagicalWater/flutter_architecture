/// 提供 App「確認目前拿手機的人是不是本人」的能力。
///
/// 這只處理裝置上的 Face ID／指紋等本機驗證，不代表 Server 登入，也不把
/// platform plugin 的型別或錯誤碼往上層暴露。
abstract interface class LocalUserPresenceVerifier {
  Future<LocalUserPresenceCapability> checkCapability();

  Future<LocalUserPresenceVerification> verify({required String reason});
}

/// 標記本機身分驗證是在哪個步驟發生系統性錯誤。
enum LocalUserPresenceOperation {
  /// 檢查裝置是否具備可用的 Face ID／指紋能力時出錯。
  capabilityCheck,

  /// 實際跳出驗證並要求使用者確認身分時出錯。
  verify,
}

/// 表示本機身分驗證「流程本身沒辦法正常執行」。
///
/// 這和「使用者驗證失敗或取消」不同；例如 plugin 異常、平台呼叫失敗才會走這裡。
/// 如果錯誤來自具名 provider code，[providerCode] 會保留它的名稱，讓未知／新增 code
/// 不會只剩一般 operational failure 而失去診斷線索。
/// `toString()` 不輸出原始 [cause]，避免平台細節或敏感資訊直接進入 production log。
final class LocalUserPresenceOperationalException implements Exception {
  const LocalUserPresenceOperationalException({
    required this.operation,
    required this.cause,
    required this.stackTrace,
    this.providerCode,
  });

  final LocalUserPresenceOperation operation;

  /// Provider 回傳的 machine-readable 錯誤代碼名稱；一般非 provider 例外時為 null。
  ///
  /// 這裡只保存字串，不把 plugin enum 暴露到 Auth package 對外 API。未來 provider 新增
  /// code 時也能保留診斷資訊，而不用先擴充 Domain taxonomy 才看得到實際來源。
  /// 這個值只供 diagnostics 使用，不應拿來決定 UI 文案或業務流程。
  final String? providerCode;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'LocalUserPresenceOperationalException('
        'operation: $operation, '
        'providerCode: $providerCode)';
  }
}

/// 描述裝置目前能不能執行 Face ID／指紋驗證。
///
/// 這只回答「現在能不能驗」，不代表某一次驗證有沒有通過。
final class LocalUserPresenceCapability {
  const LocalUserPresenceCapability.available() : unavailableReason = null;

  const LocalUserPresenceCapability.unavailable(
    LocalUserPresenceUnavailableReason reason,
  ) : unavailableReason = reason;

  final LocalUserPresenceUnavailableReason? unavailableReason;

  bool get isAvailable => unavailableReason == null;

  @override
  bool operator ==(Object other) =>
      other is LocalUserPresenceCapability &&
      other.unavailableReason == unavailableReason;

  @override
  int get hashCode => unavailableReason.hashCode;
}

/// 裝置目前不能進行本機身分驗證的原因。
enum LocalUserPresenceUnavailableReason {
  /// 裝置沒有可用的生物辨識硬體。
  noHardware,

  /// 有硬體，但使用者尚未設定 Face ID／指紋或裝置憑證。
  notEnrolled,

  /// 功能暫時不能使用，例如系統 UI 或感測器暫時忙碌。
  temporarilyUnavailable,
}

/// 描述這一次 Face ID／指紋驗證最後有沒有通過。
///
/// [verified] 代表確認成功；[rejected] 代表驗證有正常執行，但使用者沒有通過。
/// 如果連驗證流程都無法執行，則會拋出 [LocalUserPresenceOperationalException]。
final class LocalUserPresenceVerification {
  const LocalUserPresenceVerification.verified() : rejectionReason = null;

  const LocalUserPresenceVerification.rejected(
    LocalUserPresenceRejectionReason reason,
  ) : rejectionReason = reason;

  final LocalUserPresenceRejectionReason? rejectionReason;

  bool get isVerified => rejectionReason == null;

  @override
  bool operator ==(Object other) =>
      other is LocalUserPresenceVerification &&
      other.rejectionReason == rejectionReason;

  @override
  int get hashCode => rejectionReason.hashCode;
}

/// 這一次本機身分驗證沒有通過的原因。
enum LocalUserPresenceRejectionReason {
  /// 驗證完成，但沒有確認成功。
  notVerified,

  /// 使用者取消、系統取消或流程逾時。
  cancelled,

  /// 使用者尚未設定 Face ID／指紋或裝置憑證。
  notEnrolled,

  /// 裝置沒有可用的生物辨識硬體。
  noHardware,

  /// 失敗次數過多，系統暫時鎖定驗證。
  temporaryLockout,

  /// 生物辨識已被系統長時間鎖定，需要其他方式解除。
  permanentLockout,

  /// 驗證功能暫時不可用，但之後可以再試。
  temporarilyUnavailable,
}
