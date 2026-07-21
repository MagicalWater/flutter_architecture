import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('disabled preference restores without opening prompt', () async {
    final verifier = _Verifier();
    var restores = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: _Store(LocalUnlockPreference.disabled),
      verifier: verifier,
      sessionManager: SessionManager(),
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () => restores += 1,
    );

    await coordinator.start();

    expect(restores, 1);
    expect(verifier.verifyCalls, 0);
    expect(coordinator.state, StartupLocalUnlockState.restoring);
  });

  test('enabled preference verifies before restore', () async {
    final verifier = _Verifier();
    var restores = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: _Store(LocalUnlockPreference.enabled),
      verifier: verifier,
      sessionManager: SessionManager(),
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () => restores += 1,
    );

    await coordinator.start();

    expect(verifier.verifyCalls, 1);
    expect(restores, 1);
    expect(coordinator.state, StartupLocalUnlockState.restoring);
  });

  test('cancel remains locked and does not restore', () async {
    final verifier = _Verifier(
      verification: const LocalUserPresenceVerification.rejected(
        LocalUserPresenceRejectionReason.cancelled,
      ),
    );
    var restores = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: _Store(LocalUnlockPreference.enabled),
      verifier: verifier,
      sessionManager: SessionManager(),
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () => restores += 1,
    );

    await coordinator.start();

    expect(restores, 0);
    expect(coordinator.state, StartupLocalUnlockState.rejected);
  });

  test('concurrent retries share one prompt', () async {
    final prompt = Completer<LocalUserPresenceVerification>();
    final verifier = _Verifier(pendingVerification: prompt.future);
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'token', userId: 'user-1');
    var restores = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: _Store(LocalUnlockPreference.enabled),
      verifier: verifier,
      sessionManager: sessionManager,
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () => restores += 1,
    );

    final first = coordinator.start();
    final second = coordinator.retry();
    await Future<void>.delayed(Duration.zero);

    expect(verifier.verifyCalls, 1);
    expect(sessionManager.currentSession, isNull);
    prompt.complete(const LocalUserPresenceVerification.verified());
    await Future.wait(<Future<void>>[first, second]);

    expect(restores, 1);
  });

  test(
    'new auth lifecycle intent invalidates delayed prompt completion',
    () async {
      final prompt = Completer<LocalUserPresenceVerification>();
      final verifier = _Verifier(pendingVerification: prompt.future);
      final mutationCoordinator = AuthStateMutationCoordinator();
      var restores = 0;
      final coordinator = StartupLocalUnlockCoordinator(
        preferenceStore: _Store(LocalUnlockPreference.enabled),
        verifier: verifier,
        sessionManager: SessionManager(),
        mutationCoordinator: mutationCoordinator,
        restoreSession: () => restores += 1,
      );

      final start = coordinator.start();
      await Future<void>.delayed(Duration.zero);
      mutationCoordinator.beginLifecycleOperation();
      prompt.complete(const LocalUserPresenceVerification.verified());
      await start;

      expect(restores, 0);
      expect(coordinator.state, StartupLocalUnlockState.superseded);
    },
  );

  test('corrupted preference fails closed', () async {
    var restores = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: _Store.corrupted(),
      verifier: _Verifier(),
      sessionManager: SessionManager(),
      mutationCoordinator: AuthStateMutationCoordinator(),
      restoreSession: () => restores += 1,
    );

    await coordinator.start();

    expect(restores, 0);
    expect(coordinator.state, StartupLocalUnlockState.preferenceCorrupted);
  });

  test('new auth intent during preference read prevents restore', () async {
    final read = Completer<LocalUnlockPreferenceReadResult>();
    final mutationCoordinator = AuthStateMutationCoordinator();
    var restores = 0;
    final coordinator = StartupLocalUnlockCoordinator(
      preferenceStore: _PendingStore(read.future),
      verifier: _Verifier(),
      sessionManager: SessionManager(),
      mutationCoordinator: mutationCoordinator,
      restoreSession: () => restores += 1,
    );

    final start = coordinator.start();
    mutationCoordinator.beginLifecycleOperation();
    read.complete(
      const LocalUnlockPreferenceReadResult.present(
        LocalUnlockPreference.disabled,
      ),
    );
    await start;

    expect(restores, 0);
    expect(coordinator.state, StartupLocalUnlockState.superseded);
  });
}

final class _Store implements LocalUnlockPreferenceStore {
  _Store(LocalUnlockPreference preference)
    : _result = LocalUnlockPreferenceReadResult.present(preference);

  _Store.corrupted()
    : _result = const LocalUnlockPreferenceReadResult.corrupted();

  final LocalUnlockPreferenceReadResult _result;

  @override
  Future<LocalUnlockPreferenceReadResult> read() async => _result;

  @override
  Future<void> write(LocalUnlockPreference preference) async {}

  @override
  Future<void> clear() async {}
}

final class _Verifier implements LocalUserPresenceVerifier {
  _Verifier({
    this.verification = const LocalUserPresenceVerification.verified(),
    this.pendingVerification,
  });

  final LocalUserPresenceVerification verification;
  final Future<LocalUserPresenceVerification>? pendingVerification;
  int verifyCalls = 0;

  @override
  Future<LocalUserPresenceCapability> checkCapability() async =>
      const LocalUserPresenceCapability.available();

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) {
    verifyCalls += 1;
    return pendingVerification ?? Future.value(verification);
  }
}

final class _PendingStore implements LocalUnlockPreferenceStore {
  const _PendingStore(this.result);

  final Future<LocalUnlockPreferenceReadResult> result;

  @override
  Future<LocalUnlockPreferenceReadResult> read() => result;

  @override
  Future<void> write(LocalUnlockPreference preference) async {}

  @override
  Future<void> clear() async {}
}
