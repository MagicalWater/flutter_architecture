import 'package:auth/auth.dart';
import 'package:flutter_architecture/features/auth/data/local_user_presence/local_auth_user_presence_verifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  group('LocalAuthUserPresenceVerifier', () {
    test('reports no hardware without opening authentication UI', () async {
      final gateway = _FakeLocalAuthGateway(isDeviceSupported: false);
      final verifier = LocalAuthUserPresenceVerifier(gateway);

      expect(
        await verifier.checkCapability(),
        const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.noHardware,
        ),
      );
      expect(gateway.authenticateCalls, 0);
    });

    test('reports not enrolled when no biometric is available', () async {
      final verifier = LocalAuthUserPresenceVerifier(
        _FakeLocalAuthGateway(availableBiometrics: const <BiometricType>[]),
      );

      expect(
        await verifier.checkCapability(),
        const LocalUserPresenceCapability.unavailable(
          LocalUserPresenceUnavailableReason.notEnrolled,
        ),
      );
    });

    test(
      'requires biometric-only authentication with no background retry',
      () async {
        final gateway = _FakeLocalAuthGateway(authenticationResult: true);
        final verifier = LocalAuthUserPresenceVerifier(gateway);

        expect(
          await verifier.verify(reason: 'Unlock saved session'),
          const LocalUserPresenceVerification.verified(),
        );
        expect(gateway.lastBiometricOnly, isTrue);
        expect(gateway.lastPersistAcrossBackgrounding, isFalse);
        expect(gateway.lastReason, 'Unlock saved session');
      },
    );

    test('maps a false authentication result to not verified', () async {
      final verifier = LocalAuthUserPresenceVerifier(
        _FakeLocalAuthGateway(authenticationResult: false),
      );

      expect(
        await verifier.verify(reason: 'Unlock'),
        const LocalUserPresenceVerification.rejected(
          LocalUserPresenceRejectionReason.notVerified,
        ),
      );
    });

    test('maps user cancellation to a typed rejected result', () async {
      final verifier = LocalAuthUserPresenceVerifier(
        _FakeLocalAuthGateway(
          authenticationError: const LocalAuthException(
            code: LocalAuthExceptionCode.userCanceled,
          ),
        ),
      );

      expect(
        await verifier.verify(reason: 'Unlock'),
        const LocalUserPresenceVerification.rejected(
          LocalUserPresenceRejectionReason.cancelled,
        ),
      );
    });

    test('maps temporary and permanent lockout separately', () async {
      final temporary = LocalAuthUserPresenceVerifier(
        _FakeLocalAuthGateway(
          authenticationError: const LocalAuthException(
            code: LocalAuthExceptionCode.temporaryLockout,
          ),
        ),
      );
      final permanent = LocalAuthUserPresenceVerifier(
        _FakeLocalAuthGateway(
          authenticationError: const LocalAuthException(
            code: LocalAuthExceptionCode.biometricLockout,
          ),
        ),
      );

      expect(
        await temporary.verify(reason: 'Unlock'),
        const LocalUserPresenceVerification.rejected(
          LocalUserPresenceRejectionReason.temporaryLockout,
        ),
      );
      expect(
        await permanent.verify(reason: 'Unlock'),
        const LocalUserPresenceVerification.rejected(
          LocalUserPresenceRejectionReason.permanentLockout,
        ),
      );
    });

    test(
      'wraps unknown plugin failures without exposing descriptions',
      () async {
        final verifier = LocalAuthUserPresenceVerifier(
          _FakeLocalAuthGateway(
            authenticationError: const LocalAuthException(
              code: LocalAuthExceptionCode.unknownError,
              description: 'raw platform prompt detail',
            ),
          ),
        );

        await expectLater(
          verifier.verify(reason: 'Unlock'),
          throwsA(
            isA<LocalUserPresenceOperationalException>()
                .having(
                  (error) => error.operation,
                  'operation',
                  LocalUserPresenceOperation.verify,
                )
                .having(
                  (error) => error.toString(),
                  'safe toString',
                  isNot(contains('raw platform prompt detail')),
                ),
          ),
        );
      },
    );
  });
}

final class _FakeLocalAuthGateway implements LocalAuthGateway {
  _FakeLocalAuthGateway({
    this.isDeviceSupported = true,
    this.availableBiometrics = const <BiometricType>[BiometricType.strong],
    this.authenticationResult = false,
    this.authenticationError,
  });

  final bool isDeviceSupported;
  final List<BiometricType> availableBiometrics;
  final bool authenticationResult;
  final Object? authenticationError;

  int authenticateCalls = 0;
  bool? lastBiometricOnly;
  bool? lastPersistAcrossBackgrounding;
  String? lastReason;

  @override
  Future<bool> deviceSupported() async => isDeviceSupported;

  @override
  Future<bool> biometricsAvailable() async => true;

  @override
  Future<List<BiometricType>> enrolledBiometrics() async => availableBiometrics;

  @override
  Future<bool> authenticate({
    required String reason,
    required bool biometricOnly,
    required bool persistAcrossBackgrounding,
  }) async {
    authenticateCalls += 1;
    lastReason = reason;
    lastBiometricOnly = biometricOnly;
    lastPersistAcrossBackgrounding = persistAcrossBackgrounding;
    final error = authenticationError;
    if (error != null) throw error;
    return authenticationResult;
  }
}
