import 'dart:io';

enum PresentationResponsibility {
  pageOrView,
  component,
  layout,
  surface,
}

List<String> findPageOrViewRenderInfrastructureViolations(Directory libRoot) {
  final violations = <String>[];
  for (final entity in libRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = entity.readAsStringSync();
    if (pageOrViewOwnsRenderInfrastructure(source)) {
      violations.add(entity.path.replaceAll('\\', '/'));
    }
  }
  return violations;
}

bool pageOrViewOwnsRenderInfrastructure(String source) {
  final declaresPageOrView = RegExp(
    r'class\s+\w+(?:Page|View)\b',
  ).hasMatch(source);
  final declaresRenderInfrastructure =
      source.contains('MultiChildRenderObjectWidget') ||
      RegExp(r'extends\s+Render\w+').hasMatch(source) ||
      source.contains('createRenderObject(') ||
      source.contains('updateRenderObject(');
  return declaresPageOrView && declaresRenderInfrastructure;
}

bool usesPartAcrossDeclaredResponsibilities({
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

bool requiresOneClassPerFile(String source) => false;

bool requiresBlocForLocalUiState(String source) => false;

bool launcherAndSurfaceCanHaveDifferentOwners({
  required String launcherSource,
  required String surfaceSource,
}) {
  return launcherSource.contains('showDialog') &&
      surfaceSource.contains('Dialog');
}
