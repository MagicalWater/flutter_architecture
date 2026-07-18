import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/shell/presentation/pages/shell_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShellScaffold wires themed chrome and callbacks', (
    tester,
  ) async {
    var appearanceCount = 0;
    var protectedCount = 0;
    int? selectedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: OceanThemeDefinition().createDarkTheme(),
        home: ShellScaffold(
          selectedIndex: 1,
          onDestinationSelected: (value) => selectedIndex = value,
          onOpenAppearance: () => appearanceCount += 1,
          onOpenProtected: () => protectedCount += 1,
          child: const Text('Shell body'),
        ),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    await tester.tap(find.byTooltip('Appearance'));
    await tester.tap(find.byTooltip('Protected Page'));
    await tester.tap(find.text('Profile'));

    expect(appearanceCount, 1);
    expect(protectedCount, 1);
    expect(selectedIndex, 2);
  });

  for (final themeCase in _themeCases) {
    testWidgets('ShellScaffold renders under ${themeCase.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeCase.theme,
          home: ShellScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onOpenAppearance: () {},
            onOpenProtected: () {},
            child: const Text('Shell body'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Shell body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

final _themeCases = <({String name, ThemeData theme})>[
  (name: 'Default Light', theme: DefaultThemeDefinition().createLightTheme()),
  (name: 'Default Dark', theme: DefaultThemeDefinition().createDarkTheme()),
  (name: 'Ocean Light', theme: OceanThemeDefinition().createLightTheme()),
  (name: 'Ocean Dark', theme: OceanThemeDefinition().createDarkTheme()),
];
