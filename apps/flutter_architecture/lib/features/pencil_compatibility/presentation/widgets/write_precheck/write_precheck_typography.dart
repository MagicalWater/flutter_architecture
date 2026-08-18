/// Accepted Write Precheck proof的窄責任typography authority。
///
/// Noto Sans TC不是current template-global typography identity，因此維持
/// feature-local ownership。
abstract final class WritePrecheckTypography {
  static const String fontFamily = 'Noto Sans TC';
  static const List<String> fontFamilyFallback = <String>[
    'Microsoft JhengHei',
    'PingFang TC',
    'Roboto',
  ];
}
