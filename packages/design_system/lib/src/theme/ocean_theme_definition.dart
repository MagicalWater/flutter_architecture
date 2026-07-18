import 'package:design_system/src/palette/ds_raw_palette.dart';
import 'package:design_system/src/theme/ds_material_theme_factory.dart';
import 'package:design_system/src/theme/ds_semantic_colors.dart';
import 'package:design_system/src/theme/ds_theme_definition.dart';
import 'package:design_system/src/theme/ds_theme_id.dart';
import 'package:design_system/src/theme/ds_theme_metadata.dart';
import 'package:design_system/src/tokens/ds_radius.dart';
import 'package:flutter/material.dart';

/// 用來驗證多 Theme Identity contract 的 production Ocean Theme。
final class OceanThemeDefinition implements DsThemeDefinition {
  OceanThemeDefinition()
    : id = DsThemeId('ocean'),
      metadata = DsThemeMetadata(id: DsThemeId('ocean'), displayName: 'Ocean');

  @override
  final DsThemeId id;

  @override
  final DsThemeMetadata metadata;

  @override
  ThemeData createDarkTheme() => _createTheme(Brightness.dark);

  @override
  ThemeData createLightTheme() => _createTheme(Brightness.light);

  ThemeData _createTheme(Brightness brightness) =>
      DsMaterialThemeFactory.create(
        brightness: brightness,
        seedColor: DsRawPalette.oceanSeed,
        semanticColors: brightness == Brightness.dark
            ? _darkSemanticColors
            : _lightSemanticColors,
        componentRadius: DsRadius.sm,
        cardRadius: DsRadius.md,
        titleLargeWeight: FontWeight.w700,
      );

  static const _lightSemanticColors = DsSemanticColors(
    success: Color(0xFF006C4C),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFF89F8C7),
    onSuccessContainer: Color(0xFF002116),
    warning: Color(0xFF725C00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFE16A),
    onWarningContainer: Color(0xFF221B00),
    info: Color(0xFF005B5B),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFF7FF8F8),
    onInfoContainer: Color(0xFF002020),
  );

  static const _darkSemanticColors = DsSemanticColors(
    success: Color(0xFF6CDBAC),
    onSuccess: Color(0xFF003829),
    successContainer: Color(0xFF00513A),
    onSuccessContainer: Color(0xFF89F8C7),
    warning: Color(0xFFE8C447),
    onWarning: Color(0xFF3B2F00),
    warningContainer: Color(0xFF564500),
    onWarningContainer: Color(0xFFFFE16A),
    info: Color(0xFF5DDBDB),
    onInfo: Color(0xFF003737),
    infoContainer: Color(0xFF004F4F),
    onInfoContainer: Color(0xFF7FF8F8),
  );
}
