import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalUserPresenceVerifier contract', () {
    test('capability result exposes only auth-owned availability identity', () {
      const available = LocalUserPresenceCapability.available();
      const unavailable = LocalUserPresenceCapability.unavailable(
        LocalUserPresenceUnavailableReason.notEnrolled,
      );

      expect(available, isA<LocalUserPresenceAvailable>());
      expect(unavailable, isA<LocalUserPresenceUnavailable>());
      expect(
        (unavailable as LocalUserPresenceUnavailable).reason,
        LocalUserPresenceUnavailableReason.notEnrolled,
      );
    });

    test('verification result distinguishes safe terminal outcomes', () {
      const verified = LocalUserPresenceVerification.verified();
      const rejected = LocalUserPresenceVerification.rejected(
        LocalUserPresenceRejectionReason.permanentLockout,
      );

      expect(verified, isA<LocalUserPresenceVerified>());
      expect(rejected, isA<LocalUserPresenceRejected>());
      expect(
        (rejected as LocalUserPresenceRejected).reason,
        LocalUserPresenceRejectionReason.permanentLockout,
      );
    });

    test('contract can be implemented without plugin dependencies', () async {
      const verifier = _FakeVerifier();

      expect(
        await verifier.checkCapability(),
        const LocalUserPresenceCapability.available(),
      );
      expect(
        await verifier.verify(reason: 'Unlock saved session'),
        const LocalUserPresenceVerification.verified(),
      );
    });
  });
}

final class _FakeVerifier implements LocalUserPresenceVerifier {
  const _FakeVerifier();

  @override
  Future<LocalUserPresenceCapability> checkCapability() async {
    return const LocalUserPresenceCapability.available();
  }

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) async {
    return const LocalUserPresenceVerification.verified();
  }
}
