import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Presentation responsibility architecture contract', () {
    test('stable repository authority is discoverable from fresh admission', () {
      final repositoryRoot = Directory.current.parent.parent;
      final adr = File(
        '${repositoryRoot.path}/docs/adr/'
        'adr-032-presentation-component-responsibility-state-ownership.md',
      );
      final agentPolicy = File('${repositoryRoot.path}/AGENTS.md').readAsStringSync();

      expect(
        adr.existsSync(),
        isTrue,
        reason: 'Milestone 43 requires a stable ADR-032 authority',
      );
      expect(
        agentPolicy,
        contains('ADR-032'),
        reason: 'fresh admission must route to the stable Presentation authority',
      );
    });

    test('Page or View orchestration cannot own custom render infrastructure', () {
      const mixedOwner = '''
class CheckoutPage extends StatelessWidget {
  Widget build(BuildContext context) => CheckoutContent();
}
class _CheckoutRenderStack extends MultiChildRenderObjectWidget {}
class _RenderCheckoutStack extends RenderStack {}
''';

      expect(_pageOrViewOwnsRenderInfrastructure(mixedOwner), isTrue);
    });

    test('handwritten part cannot masquerade as a separate responsibility owner', () {
      const ownerSource = '''
part '../layout/projected_layout.dart';
class CheckoutContent extends StatelessWidget {}
''';
      const partSource = '''
part of '../widgets/checkout_content.dart';
class ProjectedLayout extends MultiChildRenderObjectWidget {}
''';

      expect(
        _usesPartAcrossDeclaredResponsibilities(
          ownerSource: ownerSource,
          ownerRole: PresentationResponsibility.component,
          partSource: partSource,
          partRole: PresentationResponsibility.layout,
        ),
        isTrue,
      );
    });

    test('cohesive private helpers may remain in one handwritten source file', () {
      const source = '''
class ProfileSummary extends StatelessWidget {}
class _Avatar extends StatelessWidget {}
class _DisplayName extends StatelessWidget {}
''';

      expect(_requiresOneClassPerFile(source), isFalse);
    });

    test('local ephemeral UI state does not require Cubit or Bloc', () {
      const localStateSource = '''
class ExpandableHint extends StatefulWidget {}
class _ExpandableHintState extends State<ExpandableHint> {
  bool expanded = false;
  void toggle() => setState(() => expanded = !expanded);
}
''';

      expect(_requiresBlocForLocalUiState(localStateSource), isFalse);
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
        _launcherAndSurfaceCanHaveDifferentOwners(
          launcherSource: shellSource,
          surfaceSource: surfaceSource,
        ),
        isTrue,
      );
    });
  });
}

enum PresentationResponsibility {
  pageOrView,
  component,
  layout,
  surface,
}

bool _pageOrViewOwnsRenderInfrastructure(String source) {
  final declaresPageOrView = RegExp(
    r'class\s+\w+(?:Page|View)\b',
  ).hasMatch(source);
  final declaresRenderInfrastructure =
      source.contains('MultiChildRenderObjectWidget') ||
      source.contains('RenderObject') ||
      source.contains('RenderStack') ||
      source.contains('createRenderObject(') ||
      source.contains('updateRenderObject(');
  return declaresPageOrView && declaresRenderInfrastructure;
}

bool _usesPartAcrossDeclaredResponsibilities({
  required String ownerSource,
  required PresentationResponsibility ownerRole,
  required String partSource,
  required PresentationResponsibility partRole,
}) {
  final handwrittenLibraryLink =
      RegExp(r'''^\s*part\s+['"]''', multiLine: true).hasMatch(ownerSource) &&
      RegExp(r'''^\s*part\s+of\s+['"]''', multiLine: true).hasMatch(partSource);
  return handwrittenLibraryLink && ownerRole != partRole;
}

bool _requiresOneClassPerFile(String source) => false;

bool _requiresBlocForLocalUiState(String source) => false;

bool _launcherAndSurfaceCanHaveDifferentOwners({
  required String launcherSource,
  required String surfaceSource,
}) {
  return launcherSource.contains('showDialog') &&
      surfaceSource.contains('Dialog');
}
