import 'package:flutter/material.dart';

/// Accepted Pencil authority中由此feature擁有的最小視覺契約。
abstract final class PencilCompatibilityVisualSpec {
  static const Size canonicalSize = Size(941, 1672);
  static const double canonicalDevicePixelRatio = 1;

  static const Color background = Color(0xFF020B14);
  static const Color cyan = Color(0xFF3DAEFF);
  static const Color gold = Color(0xFFF5B941);
}
