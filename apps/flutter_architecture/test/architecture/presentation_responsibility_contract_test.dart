import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/presentation_architecture_policy.dart';

void main() {
  group('Presentation responsibility architecture contract', () {
    test(
      'stable repository authority is discoverable from fresh admission',
      () {
        final repositoryRoot = Directory.current.parent.parent;
        final adr = File(
          '${repositoryRoot.path}/docs/adr/'
          'adr-032-presentation-component-responsibility-state-ownership.md',
        );
        final agentPolicy = File(
          '${repositoryRoot.path}/AGENTS.md',
        ).readAsStringSync();

        expect(
          adr.existsSync(),
          isTrue,
          reason: 'Milestone 43 requires a stable ADR-032 authority',
        );
        expect(
          agentPolicy,
          contains('ADR-032'),
          reason:
              'fresh admission must route to the stable Presentation authority',
        );
      },
    );

    test(
      'Page or View orchestration cannot own custom render infrastructure',
      () {
        const mixedOwner = '''
class CheckoutPage extends StatelessWidget {
  Widget build(BuildContext context) => CheckoutContent();
}
class _CheckoutRenderStack extends MultiChildRenderObjectWidget {}
class _RenderCheckoutStack extends RenderStack {}
''';

        expect(pageOrViewOwnsRenderInfrastructure(mixedOwner), isTrue);
      },
    );

    test(
      'repository Page and View owners do not own render infrastructure',
      () {
        final violations = findPageOrViewRenderInfrastructureViolations(
          Directory('lib'),
        );

        expect(violations, isEmpty, reason: violations.join('\n'));
      },
    );

    test(
      'handwritten part cannot masquerade as a separate responsibility owner',
      () {
        const ownerSource = '''
part '../layout/projected_layout.dart';
class CheckoutContent extends StatelessWidget {}
''';
        const partSource = '''
part of '../widgets/checkout_content.dart';
class ProjectedLayout extends MultiChildRenderObjectWidget {}
''';

        expect(
          usesPartAcrossDeclaredResponsibilities(
            ownerSource: ownerSource,
            ownerRole: PresentationResponsibility.component,
            partSource: partSource,
            partRole: PresentationResponsibility.layout,
          ),
          isTrue,
        );
      },
    );

    test(
      'cohesive private helpers may remain in one handwritten source file',
      () {
        const source = '''
class ProfileSummary extends StatelessWidget {}
class _Avatar extends StatelessWidget {}
class _DisplayName extends StatelessWidget {}
''';

        expect(requiresOneClassPerFile(source), isFalse);
      },
    );

    test('local ephemeral UI state does not require Cubit or Bloc', () {
      const localStateSource = '''
class ExpandableHint extends StatefulWidget {}
class _ExpandableHintState extends State<ExpandableHint> {
  bool expanded = false;
  void toggle() => setState(() => expanded = !expanded);
}
''';

      expect(requiresBlocForLocalUiState(localStateSource), isFalse);
    });

    test('surface launcher may differ from surface implementation owner', () {
      const shellSource = '''
void openAppearance(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const AppearanceSelectorDialog(),
  );
}
''';
      const surfaceSource = '''
class AppearanceSelectorDialog extends StatelessWidget {}
''';

      expect(
        launcherAndSurfaceCanHaveDifferentOwners(
          launcherSource: shellSource,
          surfaceSource: surfaceSource,
        ),
        isTrue,
      );
    });

    test('normal content owner cannot expose canonical left/top placement', () {
      const source = '''
class SummaryDataRow extends StatelessWidget {
  const SummaryDataRow({
    required this.left,
    required this.top,
    required this.label,
    required this.value,
  });
  final double left;
  final double top;
  final String label;
  final String value;

  Widget build(BuildContext context) => Positioned(
    left: left,
    top: top,
    child: Row(children: [Text(label), Text(value)]),
  );
}
''';

      expect(
        findNormalContentCoordinatePlacementViolations(
          source: source,
          normalContentOwners: const <String>{'SummaryDataRow'},
        ),
        isNotEmpty,
      );
    });

    test('relationship-owned normal data row remains legal', () {
      const source = '''
class SummaryDataRow extends StatelessWidget {
  const SummaryDataRow({required this.label, required this.value});
  final String label;
  final String value;

  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      Expanded(child: Text(label)),
      Align(alignment: Alignment.centerRight, child: Text(value)),
    ]),
  );
}
''';

      expect(
        findNormalContentCoordinatePlacementViolations(
          source: source,
          normalContentOwners: const <String>{'SummaryDataRow'},
        ),
        isEmpty,
      );
    });

    test('bounded decorative overlay remains legal', () {
      const source = '''
class HeroArtwork extends StatelessWidget {
  Widget build(BuildContext context) => Stack(children: [
    Content(),
    Positioned(right: 12, top: 8, child: Badge()),
    Positioned.fill(child: IgnorePointer(child: Glow())),
  ]);
}
''';

      expect(
        findNormalContentCoordinatePlacementViolations(source: source),
        isEmpty,
      );
    });
  });
}
