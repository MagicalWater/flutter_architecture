import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OceanThemeDefinition', () {
    final ocean = OceanThemeDefinition();
    final defaultTheme = DefaultThemeDefinition();

    test('提供穩定 ocean ID 與 metadata', () {
      expect(ocean.id, DsThemeId('ocean'));
      expect(ocean.metadata.id, ocean.id);
      expect(ocean.metadata.displayName, 'Ocean');
    });

    test('建立可辨識的 Material 3 Light / Dark ThemeData', () {
      final oceanLight = ocean.createLightTheme();
      final oceanDark = ocean.createDarkTheme();
      final defaultLight = defaultTheme.createLightTheme();
      final defaultDark = defaultTheme.createDarkTheme();

      expect(oceanLight.useMaterial3, isTrue);
      expect(oceanDark.useMaterial3, isTrue);
      expect(oceanLight.brightness, Brightness.light);
      expect(oceanDark.brightness, Brightness.dark);
      expect(
        oceanLight.colorScheme.primary,
        isNot(defaultLight.colorScheme.primary),
      );
      expect(
        oceanDark.colorScheme.primary,
        isNot(defaultDark.colorScheme.primary),
      );
    });

    test('不只替換 seed color，並提供 Typography 與 radius 差異', () {
      final oceanLight = ocean.createLightTheme();
      final defaultLight = defaultTheme.createLightTheme();

      expect(oceanLight.textTheme.titleLarge?.fontWeight, FontWeight.w700);
      expect(defaultLight.textTheme.titleLarge?.fontWeight, FontWeight.w600);

      final oceanCard = oceanLight.cardTheme.shape! as RoundedRectangleBorder;
      final defaultCard =
          defaultLight.cardTheme.shape! as RoundedRectangleBorder;
      expect(oceanCard.borderRadius, BorderRadius.circular(DsRadius.md));
      expect(defaultCard.borderRadius, BorderRadius.circular(DsRadius.lg));
    });

    test('提供獨立且具可讀性的 semantic colors', () {
      final cases =
          <({DsSemanticColors ocean, DsSemanticColors defaultColors})>[
            (
              ocean: ocean.createLightTheme().extension<DsSemanticColors>()!,
              defaultColors: defaultTheme
                  .createLightTheme()
                  .extension<DsSemanticColors>()!,
            ),
            (
              ocean: ocean.createDarkTheme().extension<DsSemanticColors>()!,
              defaultColors: defaultTheme
                  .createDarkTheme()
                  .extension<DsSemanticColors>()!,
            ),
          ];

      for (final testCase in cases) {
        final colors = testCase.ocean;
        expect(colors.info, isNot(testCase.defaultColors.info));
        expect(
          colors.infoContainer,
          isNot(testCase.defaultColors.infoContainer),
        );
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

  test('Registry 可解析兩套 Theme 的四種 Light / Dark 組合', () {
    final defaultTheme = DefaultThemeDefinition();
    final ocean = OceanThemeDefinition();
    final registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[defaultTheme, ocean],
      defaultThemeId: defaultTheme.id,
    );

    expect(registry.resolve(defaultTheme.id), same(defaultTheme));
    expect(registry.resolve(ocean.id), same(ocean));

    final combinations = <ThemeData>[
      registry.resolve(defaultTheme.id).createLightTheme(),
      registry.resolve(defaultTheme.id).createDarkTheme(),
      registry.resolve(ocean.id).createLightTheme(),
      registry.resolve(ocean.id).createDarkTheme(),
    ];

    expect(combinations.map((theme) => theme.brightness), <Brightness>[
      Brightness.light,
      Brightness.dark,
      Brightness.light,
      Brightness.dark,
    ]);
    expect(
      combinations.every(
        (theme) => theme.extension<DsSemanticColors>() != null,
      ),
      isTrue,
    );
    expect(
      combinations[0].colorScheme.primary,
      isNot(combinations[2].colorScheme.primary),
    );
    expect(
      combinations[1].colorScheme.primary,
      isNot(combinations[3].colorScheme.primary),
    );
  });
}

double _contrastRatio(Color background, Color foreground) {
  final first = background.computeLuminance();
  final second = foreground.computeLuminance();
  final brighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (brighter + 0.05) / (darker + 0.05);
}
