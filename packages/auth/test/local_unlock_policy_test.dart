import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preference codec round-trips enabled and disabled', () {
    const codec = LocalUnlockPreferenceCodec();

    for (final preference in LocalUnlockPreference.values) {
      expect(codec.decode(codec.encode(preference)), preference);
    }
  });

  test('preference codec rejects malformed and future payloads', () {
    const codec = LocalUnlockPreferenceCodec();

    expect(
      () => codec.decode('{"version":2,"enabled":true}'),
      throwsFormatException,
    );
    expect(
      () => codec.decode('{"version":1,"enabled":"true"}'),
      throwsFormatException,
    );
  });

  test(
    'enable requires authenticated session and successful verification',
    () async {
      final sessionManager = SessionManager();
      final store = _MemoryLocalUnlockPreferenceStore();
      final verifier = _FakeVerifier();
      final policy = LocalUnlockPolicy(
        sessionManager,
        AuthStateMutationCoordinator(),
        verifier,
        store,
      );

      expect(
        await policy.enable(reason: 'Enable local unlock'),
        LocalUnlockPolicyResult.notAuthenticated,
      );

      sessionManager.setAuthenticated(accessToken: 'access', userId: 'user');
      expect(
        await policy.enable(reason: 'Enable local unlock'),
        LocalUnlockPolicyResult.enabled,
      );
      expect(store.preference, LocalUnlockPreference.enabled);
    },
  );

  test(
    'new auth intent supersedes delayed enable before persistence',
    () async {
      final sessionManager = SessionManager()
        ..setAuthenticated(accessToken: 'access', userId: 'user');
      final mutationCoordinator = AuthStateMutationCoordinator();
      final store = _MemoryLocalUnlockPreferenceStore();
      final verifier = _FakeVerifier(blockVerification: true);
      final policy = LocalUnlockPolicy(
        sessionManager,
        mutationCoordinator,
        verifier,
        store,
      );

      final enable = policy.enable(reason: 'Enable local unlock');
      await verifier.started.future;
      mutationCoordinator.beginLifecycleOperation();
      verifier.completeVerification();

      expect(await enable, LocalUnlockPolicyResult.superseded);
      expect(store.preference, LocalUnlockPreference.disabled);
    },
  );

  test('disable only changes preference and preserves session', () async {
    final sessionManager = SessionManager()
      ..setAuthenticated(accessToken: 'access', userId: 'user');
    final store = _MemoryLocalUnlockPreferenceStore(
      LocalUnlockPreference.enabled,
    );
    final policy = LocalUnlockPolicy(
      sessionManager,
      AuthStateMutationCoordinator(),
      _FakeVerifier(),
      store,
    );

    expect(await policy.disable(), LocalUnlockPolicyResult.disabled);
    expect(store.preference, LocalUnlockPreference.disabled);
    expect(sessionManager.isAuthenticated, isTrue);
  });

  test(
    'enable write failure returns typed storage failure and stays disabled',
    () async {
      final sessionManager = SessionManager()
        ..setAuthenticated(accessToken: 'access', userId: 'user');
      final store = _MemoryLocalUnlockPreferenceStore()..failWrites = true;
      final policy = LocalUnlockPolicy(
        sessionManager,
        AuthStateMutationCoordinator(),
        _FakeVerifier(),
        store,
      );

      expect(
        await policy.enable(reason: 'Enable local unlock'),
        LocalUnlockPolicyResult.storageFailure,
      );
      expect(store.preference, LocalUnlockPreference.disabled);
    },
  );
}

final class _MemoryLocalUnlockPreferenceStore
    implements LocalUnlockPreferenceStore {
  _MemoryLocalUnlockPreferenceStore([
    this.preference = LocalUnlockPreference.disabled,
  ]);

  LocalUnlockPreference preference;
  bool failWrites = false;

  @override
  Future<LocalUnlockPreferenceReadResult> read() async =>
      LocalUnlockPreferenceReadResult.present(preference);

  @override
  Future<void> write(LocalUnlockPreference preference) async {
    if (failWrites) {
      throw AppException(
        kind: AppExceptionKind.localStorage,
        message: 'write failed',
      );
    }
    this.preference = preference;
  }

  @override
  Future<void> clear() async {
    preference = LocalUnlockPreference.disabled;
  }
}

final class _FakeVerifier implements LocalUserPresenceVerifier {
  _FakeVerifier({this.blockVerification = false});

  final bool blockVerification;
  final Completer<void> started = Completer<void>();
  final Completer<void> _release = Completer<void>();

  void completeVerification() => _release.complete();

  @override
  Future<LocalUserPresenceCapability> checkCapability() async =>
      const LocalUserPresenceCapability.available();

  @override
  Future<LocalUserPresenceVerification> verify({required String reason}) async {
    if (!started.isCompleted) started.complete();
    if (blockVerification) await _release.future;
    return const LocalUserPresenceVerification.verified();
  }
}
