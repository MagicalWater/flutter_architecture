import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

final class VisualDiffResult {
  const VisualDiffResult({
    required this.differentPixelRatio,
    required this.meanAbsoluteChannelDelta,
    required this.maxChannelDelta,
  });

  final double differentPixelRatio;
  final double meanAbsoluteChannelDelta;
  final int maxChannelDelta;
}

Future<VisualDiffResult> comparePngs({
  required File reference,
  required File actual,
  required File diffOutput,
  required int perChannelTolerance,
}) async {
  if (perChannelTolerance < 0 || perChannelTolerance > 255) {
    throw ArgumentError.value(
      perChannelTolerance,
      'perChannelTolerance',
      'must be between 0 and 255',
    );
  }

  final referenceImage = await _decodePng(reference);
  final actualImage = await _decodePng(actual);

  if (referenceImage.width != actualImage.width ||
      referenceImage.height != actualImage.height) {
    throw StateError(
      'PNG dimensions differ: '
      '${referenceImage.width}x${referenceImage.height} != '
      '${actualImage.width}x${actualImage.height}',
    );
  }

  final diffRgba = Uint8List(referenceImage.rgba.length);
  var differentPixels = 0;
  var totalAbsoluteChannelDelta = 0;
  var maxChannelDelta = 0;

  for (var offset = 0; offset < referenceImage.rgba.length; offset += 4) {
    var pixelIsDifferent = false;
    for (var channel = 0; channel < 4; channel++) {
      final delta =
          (referenceImage.rgba[offset + channel] -
                  actualImage.rgba[offset + channel])
              .abs();
      totalAbsoluteChannelDelta += delta;
      if (delta > maxChannelDelta) {
        maxChannelDelta = delta;
      }
      if (delta > perChannelTolerance) {
        pixelIsDifferent = true;
      }
    }

    if (pixelIsDifferent) {
      differentPixels++;
      diffRgba[offset] = 255;
      diffRgba[offset + 1] = 0;
      diffRgba[offset + 2] = 0;
      diffRgba[offset + 3] = 255;
    } else {
      final grayscale = _grayscale(
        actualImage.rgba[offset],
        actualImage.rgba[offset + 1],
        actualImage.rgba[offset + 2],
      );
      diffRgba[offset] = grayscale;
      diffRgba[offset + 1] = grayscale;
      diffRgba[offset + 2] = grayscale;
      diffRgba[offset + 3] = 255;
    }
  }

  await diffOutput.parent.create(recursive: true);
  await _writePng(
    file: diffOutput,
    width: referenceImage.width,
    height: referenceImage.height,
    rgba: diffRgba,
  );

  final pixelCount = referenceImage.width * referenceImage.height;
  return VisualDiffResult(
    differentPixelRatio: differentPixels / pixelCount,
    meanAbsoluteChannelDelta:
        totalAbsoluteChannelDelta / referenceImage.rgba.length,
    maxChannelDelta: maxChannelDelta,
  );
}

int _grayscale(int red, int green, int blue) =>
    (red * 0.299 + green * 0.587 + blue * 0.114).round().clamp(0, 255);

Future<_DecodedPng> _decodePng(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    final frame = await codec.getNextFrame();
    try {
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        throw StateError('Unable to decode PNG as raw RGBA: ${file.path}');
      }
      return _DecodedPng(
        width: frame.image.width,
        height: frame.image.height,
        rgba: Uint8List.fromList(byteData.buffer.asUint8List()),
      );
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

Future<void> _writePng({
  required File file,
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
          final byteData = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (byteData == null) {
            throw StateError('Unable to encode diff PNG: ${file.path}');
          }
          await file.writeAsBytes(
            byteData.buffer.asUint8List(),
            flush: true,
          );
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
