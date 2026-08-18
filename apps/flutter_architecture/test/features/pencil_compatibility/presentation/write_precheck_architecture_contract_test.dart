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
        if (_isGenericUiSpecCatchAll(source)) {
          violations.add('$normalizedPath mixes UI design ownership domains');
        }
      }

      final pageSource = File(
        'lib/features/pencil_compatibility/presentation/pages/'
        'write_precheck_view.dart',
      ).readAsStringSync();
      final pageOwnershipSource =
          Directory('lib/features/pencil_compatibility/presentation/pages')
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))
              .map((file) => file.readAsStringSync())
              .join('\n');
      final projectedCanvasSource = File(
        'lib/features/pencil_compatibility/presentation/widgets/'
        'write_precheck/write_precheck_content.dart',
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
      if (_pageOwnsRenderOrProjectionInfrastructure(pageOwnershipSource)) {
        violations.add(
          'presentation/pages owns custom render/projection infrastructure',
        );
      }
      if (_pageOwnsBoundedSectionImplementations(pageOwnershipSource)) {
        violations.add(
          'presentation/pages owns bounded write-precheck section implementations',
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

  test('page owner rejects custom render and projection infrastructure', () {
    const pageSource = '''
class ScreenView extends StatelessWidget {
  Widget build(BuildContext context) => Content();
}
class _ProjectedStack extends MultiChildRenderObjectWidget {}
class _RenderProjectedStack extends RenderStack {}
''';
    const layoutSource = '''
class ProjectedStack extends MultiChildRenderObjectWidget {}
class RenderProjectedStack extends RenderStack {}
''';

    expect(_pageOwnsRenderOrProjectionInfrastructure(pageSource), isTrue);
    expect(_pageOwnsRenderOrProjectionInfrastructure(layoutSource), isTrue);
  });

  test(
    'generic UI spec catch-all is rejected without banning local constants',
    () {
      const catchAll = '''
abstract final class FeatureVisualSpec {
  static const Size canonicalSize = Size(360, 640);
  static const Color background = Color(0xFF000000);
  static const String fontFamily = 'Example';
  static const double cardRadius = 17;
  static const LinearGradient heroGradient = LinearGradient(colors: []);
  static const String heroAssetPath = 'assets/hero.png';
}
''';
      const componentLocal = '''
class HeroCard extends StatelessWidget {
  static const double _radius = 17;
}
''';

      expect(_isGenericUiSpecCatchAll(catchAll), isTrue);
      expect(_isGenericUiSpecCatchAll(componentLocal), isFalse);
    },
  );

  test('page orchestration does not own bounded section implementations', () {
    const orchestrationOnly = '''
class WritePrecheckView extends StatelessWidget {
  Widget build(BuildContext context) => WritePrecheckContent();
}
''';
    const sectionDump = '''
class WritePrecheckView extends StatelessWidget {}
class _CanonicalDataRow extends StatelessWidget {}
class _CanonicalRecordTile extends StatelessWidget {}
class _CanonicalSecondaryAction extends StatelessWidget {}
''';

    expect(_pageOwnsBoundedSectionImplementations(orchestrationOnly), isFalse);
    expect(_pageOwnsBoundedSectionImplementations(sectionDump), isTrue);
  });
}

bool _pageOwnsRenderOrProjectionInfrastructure(String source) {
  return source.contains('MultiChildRenderObjectWidget') ||
      source.contains('RenderStack') ||
      source.contains('createRenderObject(') ||
      source.contains('updateRenderObject(');
}

bool _pageOwnsBoundedSectionImplementations(String source) {
  const boundedSectionOwners = <String>[
    'class _CanonicalBackground',
    'class _CanonicalAmbientGlows',
    'class _CanonicalStep',
    'class _CanonicalDataRow',
    'class _CanonicalRecordTile',
    'class _CanonicalSecondaryAction',
    'class _ShieldAuthority',
    'class _Orbit',
    'class _ActiveStepGlow',
    'class _RadialGlow',
  ];
  return boundedSectionOwners.any(source.contains);
}

bool _isGenericUiSpecCatchAll(String source) {
  final looksLikeGenericSpec = RegExp(
    r'class\s+\w*(?:VisualSpec|VisualTokens|UiSpec|StyleConfig)\b',
  ).hasMatch(source);
  if (!looksLikeGenericSpec) return false;

  final ownershipDomains = <bool>[
    source.contains('canonicalSize') ||
        source.contains('canonicalDevicePixelRatio'),
    source.contains('Color('),
    source.contains('fontFamily') || source.contains('TextStyle'),
    source.contains('Radius') ||
        source.contains('radius') ||
        source.contains('Width') ||
        source.contains('Height'),
    source.contains('Gradient'),
    source.contains('AssetPath') || source.contains('assetPath'),
  ].where((matched) => matched).length;

  return ownershipDomains >= 3;
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
