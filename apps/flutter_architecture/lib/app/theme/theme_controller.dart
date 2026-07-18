import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';

final class ThemeController extends ChangeNotifier {
  ThemeController({
    required this.registry,
    required ThemePreferenceStore store,
    required ThemePreference initialPreference,
    Object? restoreDiagnostic,
  }) : _store = store,
       _preference = initialPreference,
       _diagnostic = restoreDiagnostic;

  final DsThemeRegistry registry;
  final ThemePreferenceStore _store;

  ThemePreference _preference;
  Object? _diagnostic;
  Future<void> _writeTail = Future<void>.value();
  int _revision = 0;

  ThemePreference get preference => _preference;
  Object? get diagnostic => _diagnostic;
  DsThemeDefinition get definition => registry.resolve(_preference.themeId);

  void selectTheme(DsThemeId themeId) {
    _setPreference(_preference.copyWith(themeId: registry.resolve(themeId).id));
  }

  void selectMode(AppThemeMode mode) {
    _setPreference(_preference.copyWith(mode: mode));
  }

  Future<void> waitForPendingWrites() => _writeTail;

  void clearDiagnostic() {
    if (_diagnostic == null) return;
    _diagnostic = null;
    notifyListeners();
  }

  void _setPreference(ThemePreference next) {
    if (next == _preference) return;
    _preference = next;
    _diagnostic = null;
    final revision = ++_revision;
    notifyListeners();

    final snapshot = next;
    _writeTail = _writeTail
        .catchError((Object _) {})
        .then((_) => _store.save(snapshot))
        .then((_) {
          if (revision != _revision || _diagnostic == null) return;
          _diagnostic = null;
          notifyListeners();
        })
        .catchError((Object error) {
          if (revision != _revision) return;
          _diagnostic = error;
          notifyListeners();
        });
  }
}

final class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    required ThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    if (scope == null) {
      throw FlutterError(
        'ThemeControllerScope.of() was called without a '
        'ThemeControllerScope ancestor.',
      );
    }
    return scope.notifier!;
  }
}
