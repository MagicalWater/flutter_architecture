import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

Future<void> loadPencilCompatibilityTestFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) {
    throw StateError(
      'FLUTTER_ROOT is required for Pencil compatibility golden tests.',
    );
  }

  final materialFontRoot = Directory(
    '$flutterRoot${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts',
  );
  final materialFonts = await _filesByName(materialFontRoot);

  await _loadFont(
    family: 'Roboto',
    file: _requiredFont(materialFonts, 'roboto-regular.ttf', materialFontRoot),
  );
  await _loadFont(
    family: 'MaterialIcons',
    file: _requiredFont(
      materialFonts,
      'materialicons-regular.otf',
      materialFontRoot,
    ),
  );

  if (Platform.isWindows) {
    final windowsDirectory = Platform.environment['WINDIR'];
    if (windowsDirectory == null || windowsDirectory.isEmpty) {
      throw StateError('WINDIR is required for the Windows canonical golden.');
    }
    final notoFile = File(
      '$windowsDirectory${Platform.pathSeparator}Fonts'
      '${Platform.pathSeparator}NotoSansTC-VF.ttf',
    );
    if (!notoFile.existsSync()) {
      throw StateError(
        'Required Windows authority font is missing: ${notoFile.path}',
      );
    }
    await _loadFont(family: 'Noto Sans TC', file: notoFile);
  }

  final packageConfig = _findPackageConfig(Directory.current);
  final packageRoot = await _resolvePackageRoot(
    packageConfig: packageConfig,
    packageName: 'phosphoricons_flutter',
  );
  final packagePubspec = File(
    '${packageRoot.path}${Platform.pathSeparator}pubspec.yaml',
  );
  if (!packagePubspec.existsSync()) {
    throw StateError(
      'phosphoricons_flutter pubspec is missing: ${packagePubspec.path}',
    );
  }

  final declaredFonts = _parseDeclaredFonts(await packagePubspec.readAsLines());
  if (declaredFonts.isEmpty) {
    throw StateError(
      'No fonts were declared by phosphoricons_flutter at '
      '${packagePubspec.path}',
    );
  }

  for (final entry in declaredFonts.entries) {
    for (final assetPath in entry.value) {
      final fontFile = File(
        '${packageRoot.path}${Platform.pathSeparator}'
        '${assetPath.replaceAll('/', Platform.pathSeparator)}',
      );
      if (!fontFile.existsSync()) {
        throw StateError(
          'Required phosphoricons_flutter font is missing: ${fontFile.path}',
        );
      }
      await _loadFont(family: entry.key, file: fontFile);
    }
  }
}

Future<Map<String, File>> _filesByName(Directory directory) async {
  if (!directory.existsSync()) {
    throw StateError('Required font directory is missing: ${directory.path}');
  }
  return <String, File>{
    await for (final entity in directory.list())
      if (entity is File) _fileName(entity.path).toLowerCase(): entity,
  };
}

File _requiredFont(
  Map<String, File> fontFiles,
  String fileName,
  Directory fontRoot,
) {
  final file = fontFiles[fileName.toLowerCase()];
  if (file == null) {
    throw StateError(
      'Required test font is missing from ${fontRoot.path}: $fileName',
    );
  }
  return file;
}

File _findPackageConfig(Directory start) {
  var current = start.absolute;
  while (true) {
    final candidate = File(
      '${current.path}${Platform.pathSeparator}.dart_tool'
      '${Platform.pathSeparator}package_config.json',
    );
    if (candidate.existsSync()) {
      return candidate;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError(
        'Unable to find .dart_tool/package_config.json from ${start.path}',
      );
    }
    current = parent;
  }
}

Future<Directory> _resolvePackageRoot({
  required File packageConfig,
  required String packageName,
}) async {
  final json = jsonDecode(await packageConfig.readAsString());
  if (json is! Map<String, Object?>) {
    throw StateError('Invalid package config JSON: ${packageConfig.path}');
  }
  final packages = json['packages'];
  if (packages is! List<Object?>) {
    throw StateError(
      'Package config has no package list: ${packageConfig.path}',
    );
  }

  for (final package in packages) {
    if (package is Map<String, Object?> && package['name'] == packageName) {
      final rootUri = package['rootUri'];
      if (rootUri is! String || rootUri.isEmpty) {
        throw StateError(
          '$packageName has an invalid rootUri in ${packageConfig.path}',
        );
      }
      final resolved = packageConfig.parent.uri.resolve(rootUri);
      return Directory.fromUri(resolved);
    }
  }
  throw StateError(
    '$packageName is missing from package config: ${packageConfig.path}',
  );
}

Map<String, List<String>> _parseDeclaredFonts(List<String> lines) {
  final result = <String, List<String>>{};
  String? currentFamily;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('- family:')) {
      currentFamily = trimmed.substring('- family:'.length).trim();
      result.putIfAbsent(currentFamily, () => <String>[]);
      continue;
    }
    if (trimmed.startsWith('- asset:') && currentFamily != null) {
      result[currentFamily]!.add(trimmed.substring('- asset:'.length).trim());
    }
  }
  return result;
}

String _fileName(String path) => path.split(Platform.pathSeparator).last;

Future<void> _loadFont({required String family, required File file}) async {
  final bytes = await file.readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}
