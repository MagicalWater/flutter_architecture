import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter/foundation.dart';

enum StartupLocalUnlockState {
  idle,
  checkingPreference,
  locked,
  prompting,
  restoring,
  rejected,
  unavailable,
  operationalFailure,
  superseded,
  serverLoginRequested,
}

/// App-owned cold-start local unlock gate，負責本機解鎖啟動閘門。
///
/// 此 coordinator 是 startup restore 的唯一入口。當 preference enabled 時，
/// 必須先完成 local user-presence verification，才允許 dispatch repository restore。
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
    // unlock / restore operation supersede，再清除 runtime authenticated authority。
    _mutationCoordinator.beginLifecycleOperation();
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
    final operation = _mutationCoordinator.beginLifecycleOperation();
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

  Future<void> _verifyThenRestore(AuthLifecycleOperation operation) async {
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

  Future<void> _restore(AuthLifecycleOperation operation) async {
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
