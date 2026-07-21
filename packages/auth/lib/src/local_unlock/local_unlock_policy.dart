import 'package:auth/src/local_unlock/local_unlock_preference.dart';
import 'package:auth/src/local_user_presence/local_user_presence_verifier.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:core/core.dart';

enum LocalUnlockPolicyResult {
  enabled,
  disabled,
  notAuthenticated,
  unavailable,
  rejected,
  storageFailure,
  superseded,
}

final class LocalUnlockPolicy {
  const LocalUnlockPolicy(
    this._sessionManager,
    this._mutationCoordinator,
    this._verifier,
    this._store,
  );

  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  final LocalUserPresenceVerifier _verifier;
  final LocalUnlockPreferenceStore _store;

  Future<LocalUnlockPolicyResult> enable({required String reason}) async {
    if (!_sessionManager.isAuthenticated) {
      return LocalUnlockPolicyResult.notAuthenticated;
    }
    final operation = _mutationCoordinator.beginLifecycleOperation();
    final capability = await _verifier.checkCapability();
    if (capability is! LocalUserPresenceAvailable) {
      return LocalUnlockPolicyResult.unavailable;
    }
    final verification = await _verifier.verify(reason: reason);
    if (verification is! LocalUserPresenceVerified) {
      return LocalUnlockPolicyResult.rejected;
    }
    if (!operation.isCurrent || !_sessionManager.isAuthenticated) {
      return LocalUnlockPolicyResult.superseded;
    }
    try {
      await _mutationCoordinator.runExclusive(() async {
        operation.throwIfSuperseded();
        if (!_sessionManager.isAuthenticated) {
          throw const AuthLifecycleOperationSuperseded();
        }
        await _store.write(LocalUnlockPreference.enabled);
      });
    } on AuthLifecycleOperationSuperseded {
      return LocalUnlockPolicyResult.superseded;
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return LocalUnlockPolicyResult.storageFailure;
    }
    return LocalUnlockPolicyResult.enabled;
  }

  Future<LocalUnlockPolicyResult> disable() async {
    await _store.write(LocalUnlockPreference.disabled);
    return LocalUnlockPolicyResult.disabled;
  }
}
