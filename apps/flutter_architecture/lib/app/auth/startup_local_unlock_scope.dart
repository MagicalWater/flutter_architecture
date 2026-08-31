import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/auth/startup_local_unlock_coordinator.dart';

/// 將 root-owned startup unlock lifecycle 以 widget tree 傳給 auth presentation。
///
/// Coordinator 仍由 ArchitectureApp 建立與 dispose；此 scope 只負責 dependency
/// delivery，避免 route/page 依賴 widget initState 期間的動態 service-locator 註冊。
final class StartupLocalUnlockCoordinatorScope
    extends InheritedNotifier<StartupLocalUnlockCoordinator> {
  const StartupLocalUnlockCoordinatorScope({
    required StartupLocalUnlockCoordinator coordinator,
    required super.child,
    super.key,
  }) : super(notifier: coordinator);

  static StartupLocalUnlockCoordinator of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<
          StartupLocalUnlockCoordinatorScope
        >();
    assert(scope != null, 'StartupLocalUnlockCoordinatorScope is missing.');
    return scope!.notifier!;
  }
}
