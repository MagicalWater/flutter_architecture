import 'package:auth/auth.dart';
import 'package:local_auth/local_auth.dart';

/// 把 `local_auth` plugin 的呼叫集中在一個小介面，避免其他 Auth code 直接依賴 plugin API。
abstract interface class LocalAuthGateway {
  Future<bool> deviceSupported();

  Future<bool> biometricsAvailable();

  Future<List<BiometricType>> enrolledBiometrics();

  Future<bool> authenticate({
    required String reason,
    required bool biometricOnly,
    required bool persistAcrossBackgrounding,
  });
}

/// 直接呼叫 `local_auth` plugin 的實作。
final class PluginLocalAuthGateway implements LocalAuthGateway {
  PluginLocalAuthGateway(this._authentication);

  final LocalAuthentication _authentication;

  @override
  Future<bool> deviceSupported() => _authentication.isDeviceSupported();

  @override
  Future<bool> biometricsAvailable() => _authentication.canCheckBiometrics;

  @override
  Future<List<BiometricType>> enrolledBiometrics() {
    return _authentication.getAvailableBiometrics();
  }

  @override
  Future<bool> authenticate({
    required String reason,
    required bool biometricOnly,
    required bool persistAcrossBackgrounding,
  }) {
    return _authentication.authenticate(
      localizedReason: reason,
      biometricOnly: biometricOnly,
      sensitiveTransaction: true,
      persistAcrossBackgrounding: persistAcrossBackgrounding,
    );
  }
}

/// 把 iOS／Android 的 Face ID／指紋結果轉成 Auth package 看得懂的統一結果。
///
/// 已知的取消、未設定、鎖定等狀況會轉成明確結果；真正無法辨識的 plugin／platform
/// 錯誤才會拋出 [LocalUserPresenceOperationalException]。
final class LocalAuthUserPresenceVerifier implements LocalUserPresenceVerifier {
  const LocalAuthUserPresenceVerifier(this._gateway);

  final LocalAuthGateway _gateway;

  @override
  Future<LocalUserPresenceCapability> checkCapability() async {
    try {
      // 先確認裝置支援，再確認目前能不能檢查生物辨識，最後才看有沒有已註冊的
      // Face ID／指紋。這三種失敗在 UI 上代表不同狀態，不能全部壓成同一個 unavailable。
      if (!await _gateway.deviceSupported()) {
        return const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.noHardware,
        );
      }
      if (!await _gateway.biometricsAvailable()) {
        return const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.noHardware,
        );
      }
      if ((await _gateway.enrolledBiometrics()).isEmpty) {
        return const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.notEnrolled,
        );
      }
      return const LocalUserPresenceCapability.available();
    } on LocalAuthException catch (error, stackTrace) {
      final mapped = _mapCapabilityException(error.code);
      if (mapped != null) return mapped;
      throw LocalUserPresenceOperationalException(
        operation: LocalUserPresenceOperation.capabilityCheck,
        providerCode: error.code.name,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      throw LocalUserPresenceOperationalException(
        operation: LocalUserPresenceOperation.capabilityCheck,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) async {
    try {
      // plugin 回傳 false 代表驗證流程正常完成，但這次沒有確認成功；只有 exception 才代表
      // 取消、鎖定、裝置狀態或系統／plugin 本身無法正常完成。
      final verified = await _gateway.authenticate(
        reason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
      return verified
          ? const LocalUserPresenceVerification.verified()
          : const LocalUserPresenceVerification.rejected(
              LocalUserPresenceRejectionReason.notVerified,
            );
    } on LocalAuthException catch (error, stackTrace) {
      final mapped = _mapVerificationException(error.code);
      if (mapped != null) return mapped;
      throw LocalUserPresenceOperationalException(
        operation: LocalUserPresenceOperation.verify,
        providerCode: error.code.name,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      throw LocalUserPresenceOperationalException(
        operation: LocalUserPresenceOperation.verify,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  LocalUserPresenceCapability? _mapCapabilityException(
    LocalAuthExceptionCode code,
  ) {
    // 只把可以安全解讀成「目前裝置能力狀態」的 provider code 轉成 Domain result。
    // deviceError、unknownError 與未來新增的 code 都不能猜分類，會留給 caller 當
    // operational failure 處理，並透過 providerCode 保留原始代碼名稱。
    return switch (code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.noHardware,
        ),
      LocalAuthExceptionCode.noBiometricsEnrolled ||
      LocalAuthExceptionCode.noCredentialsSet =>
        const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.notEnrolled,
        ),
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
      LocalAuthExceptionCode.uiUnavailable ||
      LocalAuthExceptionCode.authInProgress =>
        const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.temporarilyUnavailable,
        ),
      _ => null,
    };
  }

  LocalUserPresenceVerification? _mapVerificationException(
    LocalAuthExceptionCode code,
  ) {
    // 只把明確代表「這次驗證沒有通過」的 provider code 轉成 rejection reason。
    // 其他 code 代表系統／plugin 層問題或未來未知情況，不能硬塞成 cancelled/unknown；
    // fallback 會拋 operational exception，並保留 providerCode 供診斷。
    final reason = switch (code) {
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled ||
      LocalAuthExceptionCode.timeout ||
      LocalAuthExceptionCode.userRequestedFallback =>
        LocalUserPresenceRejectionReason.cancelled,
      LocalAuthExceptionCode.noBiometricsEnrolled ||
      LocalAuthExceptionCode.noCredentialsSet =>
        LocalUserPresenceRejectionReason.notEnrolled,
      LocalAuthExceptionCode.noBiometricHardware =>
        LocalUserPresenceRejectionReason.noHardware,
      LocalAuthExceptionCode.temporaryLockout =>
        LocalUserPresenceRejectionReason.temporaryLockout,
      LocalAuthExceptionCode.biometricLockout =>
        LocalUserPresenceRejectionReason.permanentLockout,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
      LocalAuthExceptionCode.uiUnavailable ||
      LocalAuthExceptionCode.authInProgress =>
        LocalUserPresenceRejectionReason.temporarilyUnavailable,
      _ => null,
    };
    return reason == null
        ? null
        : LocalUserPresenceVerification.rejected(reason);
  }
}
