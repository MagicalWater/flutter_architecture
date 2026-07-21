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
      _sessionManager.clear();
      await _unlockCoordinator.retry();
      return true;
    }
    return false;
  }
}
