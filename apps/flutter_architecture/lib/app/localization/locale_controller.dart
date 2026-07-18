import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';

final class LocaleController extends ChangeNotifier {
  LocaleController({
    required LocalePreferenceStore store,
    required AppLocalePreference initialPreference,
    Object? restoreDiagnostic,
  }) : _store = store,
       _preference = initialPreference,
       _diagnostic = restoreDiagnostic;

  final LocalePreferenceStore _store;

  AppLocalePreference _preference;
  Object? _diagnostic;
  Future<void> _writeTail = Future<void>.value();
  int _revision = 0;

  AppLocalePreference get preference => _preference;
  Locale? get locale => _preference.materialLocale;
  Object? get diagnostic => _diagnostic;

  void select(AppLocalePreference preference) {
    if (preference == _preference) return;
    _preference = preference;
    _diagnostic = null;
    final revision = ++_revision;
    notifyListeners();

    final snapshot = preference;
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

  Future<void> waitForPendingWrites() => _writeTail;

  void clearDiagnostic() {
    if (_diagnostic == null) return;
    _diagnostic = null;
    notifyListeners();
  }
}

final class LocaleControllerScope extends InheritedNotifier<LocaleController> {
  const LocaleControllerScope({
    required LocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    if (scope == null) {
      throw FlutterError(
        'LocaleControllerScope.of() was called without a '
        'LocaleControllerScope ancestor.',
      );
    }
    return scope.notifier!;
  }
}
