import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'visual_diff.dart';

const updateReference = bool.fromEnvironment('UPDATE_PENCIL_RUNTIME_REFERENCE');

void main() {
  final canonical = File(
    '../../docs/design_sources/pencil-compatibility-write-precheck/'
    'pencil-preview.png',
  );
  final tracked = File(
    '../../docs/design_sources/pencil-compatibility-write-precheck/'
    'pencil-runtime-360x640.png',
  );

  test('runtime Pencil projection reference is fixed at 360x640', () async {
    expect(canonical.existsSync(), isTrue);

    if (updateReference) {
      await projectPng(
        source: canonical,
        output: tracked,
        width: 360,
        height: 640,
      );
    }

    expect(
      tracked.existsSync(),
      isTrue,
      reason:
          'Runtime reference is missing. Generate it only through the '
          'explicit UPDATE_PENCIL_RUNTIME_REFERENCE gate before candidate '
          'comparison.',
    );

    final dimensions = await _dimensions(tracked);
    expect(dimensions, const ui.Size(360, 640));

    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'pencil_runtime_reference_',
    );
    addTearDown(() async {
      if (temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
      }
    });
    final freshProjection = File('${temporaryDirectory.path}/runtime.png');
    await projectPng(
      source: canonical,
      output: freshProjection,
      width: 360,
      height: 640,
    );

    expect(
      await tracked.readAsBytes(),
      await freshProjection.readAsBytes(),
      reason:
          'Tracked runtime reference drifted from the fixed canonical '
          'projection algorithm.',
    );
  });
}

Future<ui.Size> _dimensions(File file) async {
  final codec = await ui.instantiateImageCodec(await file.readAsBytes());
  try {
    final frame = await codec.getNextFrame();
    try {
      return ui.Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}
