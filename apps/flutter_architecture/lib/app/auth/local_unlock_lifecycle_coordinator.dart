import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';

typedef MonotonicNow = Duration Function();

final class LocalUnlockLifecycleCoordinator {
  LocalUnlockLifecycleCoordinator({
    required StartupLocalUnlockCoordinator unlockCoordinator,
    required LocalUnlockPreferenceStore preferenceStore,
    required SessionManager sessionManager,
    required MonotonicNow now,
    this.gracePeriod = const Duration(minutes: 5),
  }) : _unlockCoordinator = unlockCoordinator,
       _preferenceStore = preferenceStore,
       _sessionManager = sessionManager,
       _now = now;

  final StartupLocalUnlockCoordinator _unlockCoordinator;
  final LocalUnlockPreferenceStore _preferenceStore;
  final SessionManager _sessionManager;
  final MonotonicNow _now;
  final Duration gracePeriod;
  Duration? _backgroundedAt;

  void onBackgrounded() {
    // Native biometric prompt 可能伴隨 lifecycle bounce；prompting 期間不重新
    // 起算背景時間，避免同一次驗證回前景後立即觸發第二次 unlock。
    if (_unlockCoordinator.state == StartupLocalUnlockState.prompting) return;
    _backgroundedAt = _now();
  }

  Future<bool> onResumed() async {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null ||
        _unlockCoordinator.state == StartupLocalUnlockState.prompting ||
        _now() - backgroundedAt <= gracePeriod) {
      return false;
    }
    final preference = await _preferenceStore.read();
    if (preference case LocalUnlockPreferenceReadPresent(
      preference: LocalUnlockPreference.enabled,
    )) {
      // Grace period 已過且 local unlock 仍啟用時先撤銷 runtime Session authority，
      // 再重新走完整 unlock gate；不能讓舊 Session 在驗證期間繼續可用。
      _sessionManager.clear();
      await _unlockCoordinator.retry();
      return true;
    }
    return false;
  }
}
