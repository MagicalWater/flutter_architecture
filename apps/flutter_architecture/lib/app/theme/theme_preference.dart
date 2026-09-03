import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 使用者希望 App 採用哪一種亮暗模式。
enum AppThemeMode {
  /// 跟隨作業系統亮暗模式。
  system,

  /// 永遠使用亮色模式。
  light,

  /// 永遠使用暗色模式。
  dark,
}

extension AppThemeModeX on AppThemeMode {
  ThemeMode get materialMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  String get storageValue => name;
}

/// 使用者目前選擇的 Theme Identity 與亮暗模式。
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
