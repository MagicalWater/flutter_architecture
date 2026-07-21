import 'package:auth/auth.dart';
import 'package:local_auth/local_auth.dart';

/// App-owned local_auth gateway，隔離plugin API並讓adapter可測試。
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

final class LocalAuthUserPresenceVerifier implements LocalUserPresenceVerifier {
  const LocalAuthUserPresenceVerifier(this._gateway);

  final LocalAuthGateway _gateway;

  @override
  Future<LocalUserPresenceCapability> checkCapability() async {
    try {
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
