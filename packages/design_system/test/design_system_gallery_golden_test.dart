import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/load_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('Design System gallery remains visually stable', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DefaultThemeDefinition().createLightTheme(),
        home: const _GalleryFixture(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(_GalleryFixture),
      matchesGoldenFile('goldens/design_system_gallery.png'),
    );
  });
}

final class _GalleryFixture extends StatelessWidget {
  const _GalleryFixture();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(DsSpace.lg),
        children: <Widget>[
          const DsStatusBanner(
            tone: DsStatusTone.info,
            title: 'Cached data',
            message: 'Last updated: 2026-07-18 06:00 UTC',
          ),
          const SizedBox(height: DsSpace.md),
          const DsStatusBanner(
            tone: DsStatusTone.warning,
            title: 'Background update failed',
            message: 'Existing content remains available.',
          ),
          const SizedBox(height: DsSpace.lg),
          const SizedBox(
            height: 340,
            child: DsEmptyState(
              title: 'No catalog items',
              message: 'Try another search or pull to refresh.',
              primaryAction: DsPageStateAction(
                label: 'Refresh',
                onPressed: _noop,
              ),
            ),
          ),
          const SizedBox(height: DsSpace.lg),
          const FilledButton(
            onPressed: null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.hourglass_top_outlined),
                SizedBox(width: DsSpace.xs),
                Text('Loading more'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}
