import 'dart:io';

enum PresentationResponsibility { pageOrView, component, layout, surface }

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

List<String> findNormalContentCoordinatePlacementViolations({
  required String source,
  Set<String> normalContentOwners = const <String>{},
  Set<String> normalContentHelpers = const <String>{},
}) {
  final violations = <String>[];

  for (final owner in normalContentOwners) {
    final body = _classBody(source, owner);
    if (body == null) continue;
    final exposesCoordinateApi =
        RegExp(r'\bfinal\s+double\s+(?:left|top)\s*;').hasMatch(body) ||
        RegExp(r'\brequired\s+this\.(?:left|top)\b').hasMatch(body);
    final positionsNormalContent =
        body.contains('Positioned(') &&
        (body.contains('Text(') ||
            body.contains('ProjectedIcon(') ||
            body.contains('Semantics('));
    if (exposesCoordinateApi && positionsNormalContent) {
      violations.add('$owner exposes canonical left/top for normal content');
    }
  }

  for (final helper in normalContentHelpers) {
    final declarations = RegExp(
      '(?:Positioned|Widget)\\s+${RegExp.escape(helper)}\\s*\\(',
    ).allMatches(source).toList(growable: false);
    if (declarations.isEmpty) continue;
    final helperStart = declarations.last.start;
    final helperSliceEnd = (helperStart + 1600).clamp(0, source.length);
    final helperSlice = source.substring(helperStart, helperSliceEnd);
    final acceptsCoordinate = RegExp(
      r'\brequired\s+double\s+(?:left|top)\b',
    ).hasMatch(helperSlice);
    final returnsPositioned = RegExp(
      r'=>\s*Positioned\s*\(',
    ).hasMatch(helperSlice);
    if (acceptsCoordinate && returnsPositioned) {
      violations.add(
        '$helper positions normal content with canonical coordinates',
      );
    }
  }

  return violations;
}

String? _classBody(String source, String className) {
  final declaration = RegExp(
    'class\\s+${RegExp.escape(className)}\\b',
  ).firstMatch(source);
  if (declaration == null) return null;
  final start = source.indexOf('{', declaration.end);
  if (start == -1) return null;

  var depth = 0;
  for (var index = start; index < source.length; index++) {
    final character = source[index];
    if (character == '{') {
      depth++;
    } else if (character == '}') {
      depth--;
      if (depth == 0) {
        return source.substring(start + 1, index);
      }
    }
  }
  return null;
}
