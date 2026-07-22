import 'dart:io';

import 'package:flutter/services.dart';

Future<void> loadDeterministicTestFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) {
    throw StateError(
      'FLUTTER_ROOT is required for deterministic golden tests.',
    );
  }

  final fontRoot = Directory(
    '$flutterRoot${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts',
  );

  final fontFiles = <String, File>{
    await for (final entity in fontRoot.list())
      if (entity is File) _fileName(entity.path).toLowerCase(): entity,
  };

  await _loadFont(
    family: 'Roboto',
    file: _requiredFont(fontFiles, 'roboto-regular.ttf', fontRoot),
  );
  await _loadFont(
    family: 'MaterialIcons',
    file: _requiredFont(fontFiles, 'materialicons-regular.otf', fontRoot),
  );
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

String _fileName(String path) => path.split(Platform.pathSeparator).last;

Future<void> _loadFont({required String family, required File file}) async {
  final bytes = await file.readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}
