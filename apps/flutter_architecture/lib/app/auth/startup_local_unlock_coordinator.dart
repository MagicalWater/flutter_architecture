import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter/foundation.dart';

/// App 冷啟動時，本機解鎖流程目前走到哪一步。
enum StartupLocalUnlockState {
  /// 尚未開始處理。
  idle,

  /// 正在讀取「是否啟用本機解鎖」的設定。
  checkingPreference,

  /// 已確認需要本機驗證，畫面應顯示鎖定狀態。
  locked,

  /// 正在等待 Face ID／指紋驗證結果。
  prompting,

  /// 本機驗證已通過，正在還原登入 Session。
  restoring,

  /// 使用者取消或沒有通過本機驗證。
  rejected,

  /// 裝置目前沒有可用的本機驗證能力。
  unavailable,

  /// 驗證流程本身發生系統或 plugin 錯誤。
  operationalFailure,

  /// 這次啟動流程已被較新的登入／登出操作取代，不應再套用結果。
  superseded,

  /// 使用者放棄本機解鎖，改回 Server 登入流程。
  serverLoginRequested,
}

/// App 冷啟動時決定「先做本機解鎖，還是直接還原登入 Session」。
///
/// 如果使用者開啟本機解鎖，必須先通過 Face ID／指紋，才會執行 Session restore；
/// 不能先把 Session 還原成已登入，再補做生物辨識。
final class StartupLocalUnlockCoordinator extends ChangeNotifier {
  StartupLocalUnlockCoordinator({
    required LocalUnlockPreferenceStore preferenceStore,
    required LocalUserPresenceVerifier verifier,
    required SessionManager sessionManager,
    required AuthStateMutationCoordinator mutationCoordinator,
    required FutureOr<void> Function() restoreSession,
  }) : _preferenceStore = preferenceStore,
       _verifier = verifier,
       _sessionManager = sessionManager,
       _mutationCoordinator = mutationCoordinator,
       _restoreSession = restoreSession;

  final LocalUnlockPreferenceStore _preferenceStore;
  final LocalUserPresenceVerifier _verifier;
  final SessionManager _sessionManager;
  final AuthStateMutationCoordinator _mutationCoordinator;
  final FutureOr<void> Function() _restoreSession;

  StartupLocalUnlockState _state = StartupLocalUnlockState.idle;
  Object? _failure;
  StackTrace? _failureStackTrace;
  Future<void>? _inFlight;

  StartupLocalUnlockState get state => _state;
  bool get requiresUnlockSurface => switch (_state) {
    StartupLocalUnlockState.locked ||
    StartupLocalUnlockState.prompting ||
    StartupLocalUnlockState.rejected ||
    StartupLocalUnlockState.unavailable ||
    StartupLocalUnlockState.operationalFailure => true,
    _ => false,
  };
  Object? get failure => _failure;
  StackTrace? get failureStackTrace => _failureStackTrace;

  Future<void> start() => _run();

  Future<void> retry() => _run();

  Future<void> useServerLogin() async {
    // 使用者改選 server login 是新的 lifecycle intent；先使任何仍在進行的
    // 這代表使用者已改選新的登入流程；先讓仍在執行的 unlock／restore 過期，
    // 再清掉目前 runtime Session，避免舊流程稍後又把登入狀態寫回來。
    _mutationCoordinator.beginMutationLease();
    _sessionManager.clear();
    try {
      await _preferenceStore.writeEnabled(false);
    } catch (error, stackTrace) {
      _recordFailure(error, stackTrace);
      return;
    }
    _setState(StartupLocalUnlockState.serverLoginRequested);
  }

  Future<void> _run() {
    final existing = _inFlight;
    if (existing != null) return existing;

    // Cold-start / retry 只允許一條 unlock pipeline，避免重複 biometric prompt
    // 或兩個 restore flow 競爭同一 Session lifecycle。
    final future = _runInternal();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }

  Future<void> _runInternal() async {
    final operation = _mutationCoordinator.beginMutationLease();
    _failure = null;
    _failureStackTrace = null;
    _setState(StartupLocalUnlockState.checkingPreference);

    late final bool enabled;
    try {
      enabled = await _preferenceStore.readEnabled();
    } catch (error, stackTrace) {
      _recordFailure(error, stackTrace);
      return;
    }
    if (!operation.isCurrent) {
      _setState(StartupLocalUnlockState.superseded);
      return;
    }

    if (!enabled) {
      await _restore(operation);
      return;
    }

    // Enabled preference 採 fail closed：user-presence 尚未通過前，
    // SessionManager 必須維持 unauthenticated，不能先 restore 再補驗證。
    _sessionManager.clear();
    await _verifyThenRestore(operation);
  }

  Future<void> _verifyThenRestore(AuthMutationLease operation) async {
    _setState(StartupLocalUnlockState.locked);

    try {
      final capability = await _verifier.checkCapability();
      if (!operation.isCurrent) {
        _setState(StartupLocalUnlockState.superseded);
        return;
      }
      if (!capability.isAvailable) {
        _setState(StartupLocalUnlockState.unavailable);
        return;
      }

      _setState(StartupLocalUnlockState.prompting);
      final verification = await _verifier.verify(
        reason: 'Unlock saved session',
      );
      if (!operation.isCurrent) {
        _setState(StartupLocalUnlockState.superseded);
        return;
      }
      if (!verification.isVerified) {
        _setState(StartupLocalUnlockState.rejected);
        return;
      }

      await _restore(operation);
    } catch (error, stackTrace) {
      _recordFailure(error, stackTrace);
    }
  }

  Future<void> _restore(AuthMutationLease operation) async {
    if (!operation.isCurrent) {
      _setState(StartupLocalUnlockState.superseded);
      return;
    }
    _setState(StartupLocalUnlockState.restoring);
    await Future<void>.sync(_restoreSession);
  }

  void _recordFailure(Object error, StackTrace stackTrace) {
    _failure = error;
    _failureStackTrace = stackTrace;
    _setState(StartupLocalUnlockState.operationalFailure);
  }

  void _setState(StartupLocalUnlockState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }
}
