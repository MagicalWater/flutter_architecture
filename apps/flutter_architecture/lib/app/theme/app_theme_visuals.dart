import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/gen/assets.gen.dart';

/// App-owned、會隨 Theme Identity / Brightness 切換的 bounded visual contract。
///
/// FlutterGen 只提供 bundle accessor；此 owner 才負責 semantic selection。
final class AppThemeVisuals {
  const AppThemeVisuals({required this.referenceVisual});

  final AssetGenImage referenceVisual;
}

AppThemeVisuals resolveAppThemeVisuals({
  required DsThemeRegistry registry,
  required DsThemeId themeId,
  required Brightness brightness,
}) {
  final resolvedThemeId = registry.resolve(themeId).id.value;

  return switch ((resolvedThemeId, brightness)) {
    ('default', Brightness.light) => AppThemeVisuals(
      referenceVisual: Assets.themeReference.defaultLight,
    ),
    ('default', Brightness.dark) => AppThemeVisuals(
      referenceVisual: Assets.themeReference.defaultDark,
    ),
    ('ocean', Brightness.light) => AppThemeVisuals(
      referenceVisual: Assets.themeReference.oceanLight,
    ),
    ('ocean', Brightness.dark) => AppThemeVisuals(
      referenceVisual: Assets.themeReference.oceanDark,
    ),
    _ => throw StateError(
      'Theme "$resolvedThemeId" 已註冊，但缺少 App-owned visual mapping。',
    ),
  };
}
