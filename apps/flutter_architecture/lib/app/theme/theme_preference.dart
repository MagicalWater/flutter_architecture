import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get materialMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  String get storageValue => name;
}

final class ThemePreference {
  const ThemePreference({required this.themeId, required this.mode});

  factory ThemePreference.defaults(DsThemeRegistry registry) {
    return ThemePreference(
      themeId: registry.defaultThemeId,
      mode: AppThemeMode.system,
    );
  }

  final DsThemeId themeId;
  final AppThemeMode mode;

  ThemePreference copyWith({DsThemeId? themeId, AppThemeMode? mode}) {
    return ThemePreference(
      themeId: themeId ?? this.themeId,
      mode: mode ?? this.mode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemePreference &&
        other.themeId == themeId &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(themeId, mode);
}
