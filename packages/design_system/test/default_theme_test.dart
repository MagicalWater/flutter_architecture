import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultThemeDefinition', () {
    final definition = DefaultThemeDefinition();

    test('提供穩定 default ID 與 metadata', () {
      expect(definition.id, DsThemeId('default'));
      expect(definition.metadata.id, definition.id);
      expect(definition.metadata.displayName, 'Default');
    });

    test('建立 Material 3 Light / Dark ThemeData', () {
      final light = definition.createLightTheme();
      final dark = definition.createDarkTheme();

      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.colorScheme.primary, isNot(dark.colorScheme.primary));
      expect(light.colorScheme.surface, isNot(dark.colorScheme.surface));
    });

    test('提供完整 Typography hierarchy', () {
      final lightText = definition.createLightTheme().textTheme;
      final darkText = definition.createDarkTheme().textTheme;

      for (final textTheme in <TextTheme>[lightText, darkText]) {
        expect(textTheme.displayLarge?.fontSize, 57);
        expect(textTheme.displayLarge?.fontWeight, FontWeight.w400);
        expect(textTheme.headlineLarge?.fontSize, 32);
        expect(textTheme.headlineLarge?.fontWeight, FontWeight.w500);
        expect(textTheme.titleLarge?.fontSize, 22);
        expect(textTheme.titleLarge?.fontWeight, FontWeight.w600);
        expect(textTheme.titleMedium?.fontSize, 16);
        expect(textTheme.titleMedium?.fontWeight, FontWeight.w600);
        expect(textTheme.bodyLarge?.fontSize, 16);
        expect(textTheme.labelLarge?.fontSize, 14);
        expect(textTheme.labelLarge?.fontWeight, FontWeight.w600);
        expect(
          textTheme.headlineLarge!.fontSize!,
          greaterThan(textTheme.titleLarge!.fontSize!),
        );
      }
    });

    test('設定核心 Material component themes', () {
      for (final theme in <ThemeData>[
        definition.createLightTheme(),
        definition.createDarkTheme(),
      ]) {
        expect(theme.appBarTheme.centerTitle, isFalse);
        expect(theme.navigationBarTheme.height, 72);
        expect(
          theme.navigationBarTheme.indicatorColor,
          theme.colorScheme.secondaryContainer,
        );
        expect(theme.inputDecorationTheme.filled, isTrue);

        final focusedBorder =
            theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
        expect(focusedBorder.borderSide.color, theme.colorScheme.primary);
        expect(focusedBorder.borderSide.width, 2);

        final filledStyle = theme.filledButtonTheme.style!;
        expect(
          filledStyle.minimumSize!.resolve(<WidgetState>{}),
          const Size(64, 48),
        );
        expect(
          (filledStyle.shape!.resolve(<WidgetState>{})!
                  as RoundedRectangleBorder)
              .borderRadius,
          BorderRadius.circular(DsRadius.md),
        );

        final outlinedStyle = theme.outlinedButtonTheme.style!;
        expect(
          outlinedStyle.minimumSize!.resolve(<WidgetState>{}),
          const Size(64, 48),
        );

        final textStyle = theme.textButtonTheme.style!;
        expect(
          textStyle.minimumSize!.resolve(<WidgetState>{}),
          const Size(48, 48),
        );

        expect(theme.cardTheme.elevation, DsElevation.low);
        expect(
          (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(DsRadius.lg),
        );
        expect(theme.dividerTheme.space, 1);
        expect(theme.dividerTheme.thickness, 1);
        expect(theme.progressIndicatorTheme.color, theme.colorScheme.primary);
        expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
        expect(
          (theme.snackBarTheme.shape! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(DsRadius.md),
        );
      }
    });

    test('掛載 Light / Dark semantic colors', () {
      final light = definition.createLightTheme().extension<DsSemanticColors>();
      final dark = definition.createDarkTheme().extension<DsSemanticColors>();

      expect(light, isNotNull);
      expect(dark, isNotNull);
      expect(light!.success, isNot(light.successContainer));
      expect(light.onSuccessContainer, isNot(light.successContainer));
      expect(light.warning, isNot(light.info));
      expect(dark!.successContainer, isNot(light.successContainer));
      expect(dark.warningContainer, isNot(light.warningContainer));
      expect(dark.infoContainer, isNot(light.infoContainer));

      for (final colors in <DsSemanticColors>[light, dark]) {
        expect(
          _contrastRatio(colors.success, colors.onSuccess),
          greaterThan(4.5),
        );
        expect(
          _contrastRatio(colors.successContainer, colors.onSuccessContainer),
          greaterThan(4.5),
        );
        expect(
          _contrastRatio(colors.warning, colors.onWarning),
          greaterThan(4.5),
        );
        expect(
          _contrastRatio(colors.warningContainer, colors.onWarningContainer),
          greaterThan(4.5),
        );
        expect(_contrastRatio(colors.info, colors.onInfo), greaterThan(4.5));
        expect(
          _contrastRatio(colors.infoContainer, colors.onInfoContainer),
          greaterThan(4.5),
        );
      }
    });
  });

  group('DsSemanticColors', () {
    const colors = DsSemanticColors(
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

    test('copyWith 只替換指定欄位', () {
      const replacement = Color(0xFF123456);
      final copied = colors.copyWith(success: replacement);

      expect(copied.success, replacement);
      expect(copied.warning, colors.warning);
      expect(copied.infoContainer, colors.infoContainer);
    });

    test('lerp 正確處理端點與中間值', () {
      final target = colors.copyWith(
        success: const Color(0xFFFFFFFF),
        warning: const Color(0xFF000000),
      );

      expect(colors.lerp(target, 0), colors);
      expect(colors.lerp(target, 1), target);
      expect(colors.lerp(target, 0.5).success, isNot(colors.success));
    });
  });
}

double _contrastRatio(Color background, Color foreground) {
  final backgroundLuminance = background.computeLuminance();
  final foregroundLuminance = foreground.computeLuminance();
  final brighter = backgroundLuminance > foregroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  final darker = backgroundLuminance > foregroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;

  return (brighter + 0.05) / (darker + 0.05);
}
