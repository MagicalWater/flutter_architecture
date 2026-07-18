import 'package:flutter/material.dart';

/// Design System package internal raw palette。
///
/// 此檔案不由 package entrypoint export；Feature 必須使用 semantic roles。
abstract final class DsRawPalette {
  static const Color defaultSeed = Color(0xFF3F51B5);
  static const Color oceanSeed = Color(0xFF006A6A);
  static const Color neutralSeed = Color(0xFF5F6368);
}
