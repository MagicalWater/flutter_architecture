import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';

typedef MonotonicNow = Duration Function();

/// App 從背景回到前景時，決定是否要重新要求 Face ID／指紋解鎖。
///
/// 如果離開 App 超過 [gracePeriod] 且本機解鎖仍啟用，會先清掉目前 runtime Session，
/// 再重新走完整 unlock 流程；驗證完成前不能繼續沿用離開前的已登入狀態。
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
    try {
      final enabled = await _preferenceStore.readEnabled();
      if (!enabled) return false;

      // 離開 App 太久後必須重新驗證；先清 Session，再重新解鎖，避免驗證期間仍可
      // 使用離開前的登入狀態。
      _sessionManager.clear();
      await _unlockCoordinator.retry();
      return true;
    } catch (_) {
      // 如果連設定都讀不到，就不能冒險保留已登入 Session；清掉後交給 startup
      // coordinator 顯示同一套失敗／重試流程。
      _sessionManager.clear();
      await _unlockCoordinator.retry();
      return true;
    }
  }
}
