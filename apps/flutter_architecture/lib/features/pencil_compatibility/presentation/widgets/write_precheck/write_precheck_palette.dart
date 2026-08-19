import 'package:flutter/material.dart';

/// Accepted Write Precheck proof在bounded components間共用的窄責任色票。
///
/// 此色票刻意維持feature-local：它不是template-wide Theme Identity；沒有獨立
/// semantic/shared-owner evidence前，不得promotion至Design System。
abstract final class WritePrecheckPalette {
  static const Color background = Color(0xFF020B14);
  static const Color text = Color(0xFFEAF2F8);
  static const Color muted = Color(0xFFB8C4CF);
  static const Color dim = Color(0xFF7F94A7);
  static const Color goldAccent = Color(0xFFF5B941);
  static const Color blueAccent = Color(0xFF3DAEFF);
  static const Color cyanAccent = Color(0xFF74D8FF);
  static const Color subtleOutline = Color(0xFF244056);
}
