import 'package:flutter/material.dart';

/// App 擁有的 UI design-space baseline。
///
/// Product repository 採用 template 後，應把 [designSize] 換成主要 UI 設計來源的
/// canonical logical design-space size；此值不屬於 Design System token。
abstract final class AppUiDesign {
  static const Size designSize = Size(390, 844);
}
