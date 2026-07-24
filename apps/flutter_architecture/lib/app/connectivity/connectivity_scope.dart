import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_controller.dart';

/// 將App-owned connectivity authority提供給presentation。
final class ConnectivityScope extends InheritedWidget {
  const ConnectivityScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final ConnectivityController controller;

  static ConnectivityController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ConnectivityScope>();
    assert(scope != null, 'ConnectivityScope not found');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(ConnectivityScope oldWidget) =>
      !identical(controller, oldWidget.controller);
}
