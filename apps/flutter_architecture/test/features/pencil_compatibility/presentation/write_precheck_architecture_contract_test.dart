import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Pencil compatibility feature remains presentation-only and anti-raster',
    () {
      final featureRoot = Directory('lib/features/pencil_compatibility');
      expect(featureRoot.existsSync(), isTrue);

      final dartFiles = featureRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList(growable: false);
      expect(dartFiles, isNotEmpty);

      final violations = <String>[];
      for (final file in dartFiles) {
        final normalizedPath = file.path.replaceAll('\\', '/');
        final source = file.readAsStringSync();

        if (normalizedPath.contains('/domain/') ||
            normalizedPath.contains('/data/')) {
          violations.add('$normalizedPath introduces a forbidden layer');
        }
        for (final forbidden in <String>[
          'Bloc',
          'Repository',
          'UseCase',
          'getIt',
          'injectable',
        ]) {
          if (source.contains(forbidden)) {
            violations.add('$normalizedPath contains $forbidden');
          }
        }
        if (source.contains('Image.asset(') || source.contains('Image.file(')) {
          violations.add('$normalizedPath embeds a raster image');
        }
      }

      final pageSource = File(
        'lib/features/pencil_compatibility/presentation/pages/'
        'write_precheck_view.dart',
      ).readAsStringSync();
      final projectedCanvasSource = File(
        'lib/features/pencil_compatibility/presentation/pages/'
        'write_precheck_projected_canvas.dart',
      ).readAsStringSync();
      if (pageSource.contains('FittedBox(')) {
        violations.add('WritePrecheckView uses fixed-canvas FittedBox scaling');
      }
      if (pageSource.contains('Transform.scale(')) {
        violations.add('WritePrecheckView uses top-level Transform.scale');
      }
      if (_usesWholeScreenCanonicalCoordinateProjection(
        projectedCanvasSource,
      )) {
        violations.add(
          'WritePrecheckProjectedCanvas reconstructs page flow from canonical '
          'coordinates and a shared whole-screen scale',
        );
      }
      if (!projectedCanvasSource.contains('Column(') ||
          !projectedCanvasSource.contains('_flowRegion(')) {
        violations.add(
          'WritePrecheckProjectedCanvas does not expose constraint-owned '
          'page flow',
        );
      }
      for (final forbidden in <String>[
        'static const double designHeight = 1672',
        'top: 1277',
        'top: 1455',
        'top: 1536',
        'top: 1606',
      ]) {
        if (projectedCanvasSource.contains(forbidden)) {
          violations.add(
            'WritePrecheckProjectedCanvas retains page-coordinate owner '
            '$forbidden',
          );
        }
      }
      if (pageSource.contains('constraints.maxWidth >= 900') ||
          (pageSource.contains('WritePrecheckCanonicalCanvas') &&
              pageSource.contains('PrecheckSectionCard'))) {
        violations.add(
          'WritePrecheckView selects parallel whole-screen renderers by width',
        );
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );

  test(
    'bounded local overlay is not classified as whole-screen projection',
    () {
      const source = '''
Widget build(BuildContext context) => Column(
  children: [
    Header(),
    SizedBox(height: 24),
    SizedBox(
      height: 220,
      child: Stack(children: [Positioned(right: 12, top: 8, child: Badge())]),
    ),
    Details(),
  ],
);
''';

      expect(_usesWholeScreenCanonicalCoordinateProjection(source), isFalse);
    },
  );

  test('single renderer with scaled page coordinates is rejected', () {
    const source = '''
static const double designWidth = 941;
static const double designHeight = 1672;
double get scale => availableWidth / designWidth;
class _ProjectedScreen extends StatelessWidget {
  Widget build(BuildContext context) => SizedBox(
    width: projection.px(designWidth),
    height: projection.px(designHeight),
    child: _ProjectedStack(children: [
      Positioned(left: 37, top: 232, width: 853, height: 254, child: Hero()),
      Positioned(left: 36, top: 1277, width: 855, height: 171, child: Guidance()),
    ]),
  );
}
class _RenderProjectedStack extends RenderStack {
  void performLayout() {
    final data = child.parentData! as StackParentData;
    data
      ..left = _scaled(data.left)
      ..top = _scaled(data.top);
  }
  double? _scaled(double? value) => value == null ? null : value * scale;
}
''';

    expect(_usesWholeScreenCanonicalCoordinateProjection(source), isTrue);
  });
}

bool _usesWholeScreenCanonicalCoordinateProjection(String source) {
  final ownsPageDesignHeight =
      source.contains('designHeight = 1672') ||
      source.contains('designHeight=1672');
  final ownsSharedScale =
      source.contains('availableWidth / designWidth') ||
      source.contains('availableWidth/designWidth');
  final hasScreenRootProjectedStack =
      source.contains('class _ProjectedScreen') &&
      source.contains('_ProjectedStack(');
  final scalesPositionedParentData =
      source.contains('StackParentData') &&
      source.contains('..left = _scaled(data.left)') &&
      source.contains('..top = _scaled(data.top)');

  return ownsPageDesignHeight &&
      ownsSharedScale &&
      hasScreenRootProjectedStack &&
      scalesPositionedParentData;
}
