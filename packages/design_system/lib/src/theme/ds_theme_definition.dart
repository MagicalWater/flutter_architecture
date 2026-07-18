import 'package:design_system/src/theme/ds_theme_id.dart';
import 'package:design_system/src/theme/ds_theme_metadata.dart';
import 'package:flutter/material.dart';

/// 一套 Theme Identity 的 Light / Dark ThemeData contract。
abstract interface class DsThemeDefinition {
  DsThemeId get id;

  DsThemeMetadata get metadata;

  ThemeData createLightTheme();

  ThemeData createDarkTheme();
}
