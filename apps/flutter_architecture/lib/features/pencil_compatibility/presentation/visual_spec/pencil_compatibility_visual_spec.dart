import 'package:flutter/material.dart';

/// Accepted Pencil authority中由此feature擁有的最小視覺契約。
abstract final class PencilCompatibilityVisualSpec {
  static const Size canonicalSize = Size(941, 1672);
  static const double canonicalDevicePixelRatio = 1;

  static const Color background = Color(0xFF020B14);
  static const Color backgroundDeep = Color(0xFF01070D);
  static const Color surface = Color(0xFF071522);
  static const Color surfaceRaised = Color(0xFF0B1B2B);
  static const Color border = Color(0xFF536B7E);
  static const Color borderSoft = Color(0xFF244056);
  static const Color text = Color(0xFFEAF2F8);
  static const Color muted = Color(0xFFB8C4CF);
  static const Color dim = Color(0xFF7F94A7);
  static const Color cyan = Color(0xFF3DAEFF);
  static const Color cyanBright = Color(0xFF74D8FF);
  static const Color cyanDeep = Color(0xFF0A4A82);
  static const Color gold = Color(0xFFF5B941);
  static const Color goldSoft = Color(0xFF9A6A25);

  static const String fontFamily = 'Noto Sans TC';
  static const List<String> fontFamilyFallback = <String>[
    'Microsoft JhengHei',
    'PingFang TC',
    'Roboto',
  ];

  static const double maxContentWidth = 853;
  static const double cardRadius = 24;
  static const double recordRadius = 14;
  static const double buttonRadius = 18;
  static const double pillRadius = 21;
  static const double guidanceRadius = 9;

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[backgroundDeep, background, Color(0xFF03111D)],
    stops: <double>[0, 0.46, 1],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[surfaceRaised, surface],
  );

  static TextStyle textStyle({
    required double size,
    Color color = text,
    FontWeight weight = FontWeight.w400,
    double height = 1.35,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  );
}
