import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/visual_diff.dart';

void main() {
  test('360x640 runtime candidate meets the fixed Pencil projection', () async {
    final reference = File(
      '../../docs/design_sources/pencil-compatibility-write-precheck/'
      'pencil-runtime-360x640.png',
    );
    final candidate = File(
      'test/features/pencil_compatibility/goldens/'
      'write_precheck_runtime_windows.png',
    );
    final diffOutput = File(
      'build/visual-validation/write_precheck_runtime_reference_diff.png',
    );

    for (final file in <File>[reference, candidate]) {
      expect(file.existsSync(), isTrue, reason: 'Missing ${file.path}');
    }

    final result = await comparePngs(
      reference: reference,
      actual: candidate,
      diffOutput: diffOutput,
      perChannelTolerance: 8,
    );

    if (result.differentPixelRatio > 0.08 ||
        result.meanAbsoluteChannelDelta > 8.0) {
      fail(
        'Runtime visual thresholds failed: '
        'differentPixelRatio=${result.differentPixelRatio} (max 0.08), '
        'meanAbsoluteChannelDelta=${result.meanAbsoluteChannelDelta} '
        '(max 8.0), '
        'maxChannelDelta=${result.maxChannelDelta}.',
      );
    }
  });
}
