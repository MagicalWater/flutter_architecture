import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_typography.dart';

TextStyle writePrecheckTextStyle({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = WritePrecheckPalette.text,
  double? lineHeight,
  double? letterSpacing,
  double? rasterWeight,
}) => TextStyle(
  fontFamily: WritePrecheckTypography.fontFamily,
  fontFamilyFallback: WritePrecheckTypography.fontFamilyFallback,
  fontSize: size,
  fontWeight: _pencilRasterWeight(weight),
  fontVariations: rasterWeight == null
      ? null
      : <ui.FontVariation>[ui.FontVariation('wght', rasterWeight)],
  height: lineHeight,
  letterSpacing: letterSpacing,
  color: color,
);

FontWeight _pencilRasterWeight(FontWeight weight) {
  if (weight.value <= FontWeight.w200.value) {
    return weight;
  }
  if (weight.value >= FontWeight.w700.value) {
    return FontWeight.w600;
  }
  if (weight.value >= FontWeight.w500.value) {
    return FontWeight.w400;
  }
  return FontWeight.w300;
}
