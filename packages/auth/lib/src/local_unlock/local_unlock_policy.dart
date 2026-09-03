import 'package:auth/src/local_unlock/local_unlock_preference.dart';
import 'package:auth/src/local_user_presence/local_user_presence_verifier.dart';
import 'package:auth/src/session/auth_state_mutation_coordinator.dart';
import 'package:auth/src/session/session_manager.dart';
import 'package:core/core.dart';

/// 處理「開啟／關閉下次啟動時的 Face ID／指紋解鎖」。
///
/// 開啟前會先確認目前真的已登入、裝置可驗證、使用者也通過驗證；等待驗證期間如果
/// Session 已被登出或替換，就不會把舊操作留下的設定寫進 storage。
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

  Future<bool> enable({required String reason}) async {
    if (!_sessionManager.isAuthenticated) {
      return false;
    }
    final operation = _mutationCoordinator.beginMutationLease();
    // 啟用 local unlock 是對目前 authenticated Session 的能力變更。Biometric
    // prompt 期間 Session 可能被 logout / replace，因此 commit 前必須重驗 lease。
    final capability = await _verifier.checkCapability();
    if (!capability.isAvailable) {
      return false;
    }
    final verification = await _verifier.verify(reason: reason);
    if (!verification.isVerified) {
      return false;
    }
    if (!operation.isCurrent || !_sessionManager.isAuthenticated) {
      return false;
    }
    try {
      await _mutationCoordinator.runExclusive(() async {
        // Preference 只能在仍擁有同一 Auth lifecycle intent 時寫入；否則可能把
        // 已登出的帳號重新留下「下次啟動需 local unlock」的 stale policy。
        operation.throwIfSuperseded();
        if (!_sessionManager.isAuthenticated) {
          throw const AuthMutationSuperseded();
        }
        await _store.writeEnabled(true);
      });
    } on AuthMutationSuperseded {
      return false;
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return false;
    }
    return true;
  }

  Future<bool> disable() async {
    try {
      await _store.writeEnabled(false);
      return true;
    } on AppException catch (error, stackTrace) {
      if (error.kind != AppExceptionKind.localStorage) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return false;
    }
  }
}
