import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'visual_diff.dart';

void main() {
  late Directory temporaryDirectory;
  final pencilPreview = File(
    '../../docs/design_sources/pencil-compatibility-write-precheck/'
    'pencil-preview.png',
  );

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'visual_diff_test_',
    );
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('identical pixels produce zero metrics and grayscale output', () async {
    final pixels = Uint8List.fromList(<int>[
      10,
      20,
      30,
      255,
      200,
      100,
      50,
      255,
    ]);
    final reference = await _writePng(
      directory: temporaryDirectory,
      name: 'reference.png',
      width: 2,
      height: 1,
      rgba: pixels,
    );
    final actual = await _writePng(
      directory: temporaryDirectory,
      name: 'actual.png',
      width: 2,
      height: 1,
      rgba: pixels,
    );
    final diff = File('${temporaryDirectory.path}/diff.png');

    final result = await comparePngs(
      reference: reference,
      actual: actual,
      diffOutput: diff,
      perChannelTolerance: 0,
    );

    expect(result.differentPixelRatio, 0);
    expect(result.meanAbsoluteChannelDelta, 0);
    expect(result.maxChannelDelta, 0);
    expect(diff.existsSync(), isTrue);

    final decoded = await _decodePng(diff);
    expect(decoded.width, 2);
    expect(decoded.height, 1);
    expect(decoded.rgba, <int>[18, 18, 18, 255, 124, 124, 124, 255]);
  });

  test('single-pixel delta reports ratio, mean, max and opaque red', () async {
    final reference = await _writePng(
      directory: temporaryDirectory,
      name: 'reference.png',
      width: 2,
      height: 1,
      rgba: Uint8List.fromList(<int>[0, 0, 0, 255, 10, 20, 30, 255]),
    );
    final actual = await _writePng(
      directory: temporaryDirectory,
      name: 'actual.png',
      width: 2,
      height: 1,
      rgba: Uint8List.fromList(<int>[0, 0, 0, 255, 20, 40, 60, 255]),
    );
    final diff = File('${temporaryDirectory.path}/diff.png');

    final result = await comparePngs(
      reference: reference,
      actual: actual,
      diffOutput: diff,
      perChannelTolerance: 0,
    );

    expect(result.differentPixelRatio, 0.5);
    expect(result.meanAbsoluteChannelDelta, 7.5);
    expect(result.maxChannelDelta, 30);
    expect((await _decodePng(diff)).rgba, <int>[0, 0, 0, 255, 255, 0, 0, 255]);
  });

  test('dimension mismatch throws StateError and writes no diff', () async {
    final reference = await _writePng(
      directory: temporaryDirectory,
      name: 'reference.png',
      width: 1,
      height: 1,
      rgba: Uint8List.fromList(<int>[0, 0, 0, 255]),
    );
    final actual = await _writePng(
      directory: temporaryDirectory,
      name: 'actual.png',
      width: 2,
      height: 1,
      rgba: Uint8List.fromList(<int>[0, 0, 0, 255, 0, 0, 0, 255]),
    );
    final diff = File('${temporaryDirectory.path}/diff.png');

    await expectLater(
      comparePngs(
        reference: reference,
        actual: actual,
        diffOutput: diff,
        perChannelTolerance: 0,
      ),
      throwsA(isA<StateError>()),
    );
    expect(diff.existsSync(), isFalse);
  });

  test('a delta equal to tolerance matches but one above differs', () async {
    final reference = await _writePng(
      directory: temporaryDirectory,
      name: 'reference.png',
      width: 2,
      height: 1,
      rgba: Uint8List.fromList(<int>[0, 0, 0, 255, 0, 0, 0, 255]),
    );
    final actual = await _writePng(
      directory: temporaryDirectory,
      name: 'actual.png',
      width: 2,
      height: 1,
      rgba: Uint8List.fromList(<int>[8, 0, 0, 255, 9, 0, 0, 255]),
    );

    final result = await comparePngs(
      reference: reference,
      actual: actual,
      diffOutput: File('${temporaryDirectory.path}/diff.png'),
      perChannelTolerance: 8,
    );

    expect(result.differentPixelRatio, 0.5);
    expect(result.meanAbsoluteChannelDelta, 17 / 8);
    expect(result.maxChannelDelta, 9);
  });

  test('negative tolerance is rejected before decoding', () async {
    await expectLater(
      comparePngs(
        reference: File('${temporaryDirectory.path}/missing-reference.png'),
        actual: File('${temporaryDirectory.path}/missing-actual.png'),
        diffOutput: File('${temporaryDirectory.path}/diff.png'),
        perChannelTolerance: -1,
      ),
      throwsArgumentError,
    );
  });

  test(
    'projects canonical Pencil preview to exact runtime dimensions',
    () async {
      final sourceBytesBefore = await pencilPreview.readAsBytes();
      final output = File('${temporaryDirectory.path}/runtime.png');

      await projectPng(
        source: pencilPreview,
        output: output,
        width: 360,
        height: 640,
      );

      final decoded = await _decodePng(output);
      expect(decoded.width, 360);
      expect(decoded.height, 640);
      expect(await pencilPreview.readAsBytes(), sourceBytesBefore);
    },
  );

  test(
    'projection is byte deterministic for the same input and target',
    () async {
      final first = File('${temporaryDirectory.path}/first.png');
      final second = File('${temporaryDirectory.path}/second.png');

      await projectPng(
        source: pencilPreview,
        output: first,
        width: 360,
        height: 640,
      );
      await projectPng(
        source: pencilPreview,
        output: second,
        width: 360,
        height: 640,
      );

      expect(await first.readAsBytes(), await second.readAsBytes());
    },
  );

  for (final dimensions in <(int, int)>[(0, 640), (360, 0), (-1, 640)]) {
    test('projection rejects invalid dimensions $dimensions', () async {
      await expectLater(
        projectPng(
          source: pencilPreview,
          output: File('${temporaryDirectory.path}/invalid.png'),
          width: dimensions.$1,
          height: dimensions.$2,
        ),
        throwsArgumentError,
      );
    });
  }

  test('projection propagates missing-source FileSystemException', () async {
    await expectLater(
      projectPng(
        source: File('${temporaryDirectory.path}/missing.png'),
        output: File('${temporaryDirectory.path}/runtime.png'),
        width: 360,
        height: 640,
      ),
      throwsA(isA<FileSystemException>()),
    );
  });
}

Future<File> _writePng({
  required Directory directory,
  required String name,
  required int width,
  required int height,
  required Uint8List rgba,
}) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(rgba);
  try {
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    try {
      final codec = await descriptor.instantiateCodec();
      try {
        final frame = await codec.getNextFrame();
        try {
          final png = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (png == null) {
            throw StateError('Unable to encode test PNG.');
          }
          final file = File('${directory.path}/$name');
          await file.writeAsBytes(png.buffer.asUint8List(), flush: true);
          return file;
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } finally {
      descriptor.dispose();
    }
  } finally {
    buffer.dispose();
  }
}

Future<_DecodedPng> _decodePng(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    final frame = await codec.getNextFrame();
    try {
      final rgba = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (rgba == null) {
        throw StateError('Unable to decode PNG bytes.');
      }
      return _DecodedPng(
        width: frame.image.width,
        height: frame.image.height,
        rgba: rgba.buffer.asUint8List(),
      );
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

final class _DecodedPng {
  const _DecodedPng({
    required this.width,
    required this.height,
    required this.rgba,
  });

  final int width;
  final int height;
  final Uint8List rgba;
}
