import 'package:design_system/src/palette/ds_raw_palette.dart';
import 'package:design_system/src/theme/ds_material_theme_factory.dart';
import 'package:design_system/src/theme/ds_semantic_colors.dart';
import 'package:design_system/src/theme/ds_theme_definition.dart';
import 'package:design_system/src/theme/ds_theme_id.dart';
import 'package:design_system/src/theme/ds_theme_metadata.dart';
import 'package:design_system/src/tokens/ds_radius.dart';
import 'package:flutter/material.dart';

/// Design System 的 production Default Theme。
final class DefaultThemeDefinition implements DsThemeDefinition {
  DefaultThemeDefinition()
    : id = DsThemeId('default'),
      metadata = DsThemeMetadata(
        id: DsThemeId('default'),
        displayName: 'Default',
      );

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
        seedColor: DsRawPalette.defaultSeed,
        semanticColors: brightness == Brightness.dark
            ? _darkSemanticColors
            : _lightSemanticColors,
        componentRadius: DsRadius.md,
        cardRadius: DsRadius.lg,
        titleLargeWeight: FontWeight.w600,
      );

  static const _lightSemanticColors = DsSemanticColors(
    success: Color(0xFF006C4C),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFF89F8C7),
    onSuccessContainer: Color(0xFF002116),
    warning: Color(0xFF7A5900),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFDEA3),
    onWarningContainer: Color(0xFF261900),
    info: Color(0xFF0061A4),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFD1E4FF),
    onInfoContainer: Color(0xFF001D36),
  );

  static const _darkSemanticColors = DsSemanticColors(
    success: Color(0xFF6CDBAC),
    onSuccess: Color(0xFF003829),
    successContainer: Color(0xFF00513A),
    onSuccessContainer: Color(0xFF89F8C7),
    warning: Color(0xFFF9BD24),
    onWarning: Color(0xFF402D00),
    warningContainer: Color(0xFF5C4300),
    onWarningContainer: Color(0xFFFFDEA3),
    info: Color(0xFF9ECAFF),
    onInfo: Color(0xFF003258),
    infoContainer: Color(0xFF00497D),
    onInfoContainer: Color(0xFFD1E4FF),
  );
}
