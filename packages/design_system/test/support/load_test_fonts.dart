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

  await _loadFont(
    family: 'Roboto',
    file: File('${fontRoot.path}${Platform.pathSeparator}roboto-regular.ttf'),
  );
  await _loadFont(
    family: 'MaterialIcons',
    file: File(
      '${fontRoot.path}${Platform.pathSeparator}materialicons-regular.otf',
    ),
  );
}

Future<void> _loadFont({required String family, required File file}) async {
  if (!file.existsSync()) {
    throw StateError('Required test font is missing: ${file.path}');
  }

  final bytes = await file.readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}
