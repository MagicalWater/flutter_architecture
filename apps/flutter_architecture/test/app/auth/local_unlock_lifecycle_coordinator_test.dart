import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/auth/local_unlock_lifecycle_coordinator.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resume within grace period does not prompt', () async {
    var now = Duration.zero;
    final verifier = _Verifier();
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'token', userId: 'user-1');
    final unlock = StartupLocalUnlockCoordinator(
      preferenceStore: _Store(),
      verifier: verifier,
      sessionManager: sessionManager,
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () {},
    );
    final lifecycle = LocalUnlockLifecycleCoordinator(
      unlockCoordinator: unlock,
      preferenceStore: _Store(),
      sessionManager: sessionManager,
      now: () => now,
    );

    lifecycle.onBackgrounded();
    now = const Duration(minutes: 4);

    expect(await lifecycle.onResumed(), isFalse);
    expect(verifier.verifyCalls, 0);
    expect(sessionManager.currentSession, isNotNull);
  });

  test('resume after grace clears session and requires unlock', () async {
    var now = Duration.zero;
    final verifier = _Verifier();
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'token', userId: 'user-1');
    final unlock = StartupLocalUnlockCoordinator(
      preferenceStore: _Store(),
      verifier: verifier,
      sessionManager: sessionManager,
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () {},
    );
    final lifecycle = LocalUnlockLifecycleCoordinator(
      unlockCoordinator: unlock,
      preferenceStore: _Store(),
      sessionManager: sessionManager,
      now: () => now,
    );

    lifecycle.onBackgrounded();
    now = const Duration(minutes: 6);

    expect(await lifecycle.onResumed(), isTrue);
    expect(verifier.verifyCalls, 1);
    expect(sessionManager.currentSession, isNull);
  });

  test(
    'prompt-owned lifecycle bounce does not create another prompt',
    () async {
      final verifier = _Verifier();
      final sessionManager = SessionManager();
      final unlock = StartupLocalUnlockCoordinator(
        preferenceStore: _Store(),
        verifier: verifier,
        sessionManager: sessionManager,
        mutationCoordinator: AuthStateMutationCoordinator(),
        restoreSession: () {},
      );
      await unlock.start();
      final lifecycle = LocalUnlockLifecycleCoordinator(
        unlockCoordinator: unlock,
        preferenceStore: _Store(),
        sessionManager: sessionManager,
        now: () => const Duration(minutes: 10),
      );

      lifecycle.onBackgrounded();
      await lifecycle.onResumed();

      expect(verifier.verifyCalls, 1);
    },
  );
}

final class _Store implements LocalUnlockPreferenceStore {
  @override
  Future<LocalUnlockPreferenceReadResult> read() async =>
      const LocalUnlockPreferenceReadResult.present(
        LocalUnlockPreference.enabled,
      );

  @override
  Future<void> write(LocalUnlockPreference preference) async {}

  @override
  Future<void> clear() async {}
}

final class _Verifier implements LocalUserPresenceVerifier {
  int verifyCalls = 0;

  @override
  Future<LocalUserPresenceCapability> checkCapability() async =>
      const LocalUserPresenceCapability.available();

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) async {
    verifyCalls += 1;
    return const LocalUserPresenceVerification.verified();
  }
}
