import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/visual_diff.dart';

void main() {
  test('360x640 runtime preserves the accepted canonical renderer', () async {
    final pencilReference = File(
      '../../docs/design_sources/pencil-compatibility-write-precheck/'
      'pencil-runtime-360x640.png',
    );
    final canonicalGolden = File(
      'test/features/pencil_compatibility/goldens/write_precheck_windows.png',
    );
    final candidate = File(
      'test/features/pencil_compatibility/goldens/'
      'write_precheck_runtime_windows.png',
    );
    final projectedCanonical = File(
      'build/visual-validation/write_precheck_projected_canonical_360x640.png',
    );
    final rendererDiffOutput = File(
      'build/visual-validation/write_precheck_runtime_renderer_diff.png',
    );
    final pencilDiagnosticDiffOutput = File(
      'build/visual-validation/write_precheck_runtime_pencil_diagnostic_diff.png',
    );

    for (final file in <File>[pencilReference, canonicalGolden, candidate]) {
      expect(file.existsSync(), isTrue, reason: 'Missing ${file.path}');
    }

    await projectPng(
      source: canonicalGolden,
      output: projectedCanonical,
      width: 360,
      height: 640,
    );

    final rendererResult = await comparePngs(
      reference: projectedCanonical,
      actual: candidate,
      diffOutput: rendererDiffOutput,
      perChannelTolerance: 8,
    );

    // ignore: avoid_print
    print(
      'RUNTIME_RENDERER_CALIBRATION '
      'differentPixelRatio=${rendererResult.differentPixelRatio} '
      'meanAbsoluteChannelDelta='
      '${rendererResult.meanAbsoluteChannelDelta} '
      'maxChannelDelta=${rendererResult.maxChannelDelta}',
    );

    if (rendererResult.differentPixelRatio > 0.10 ||
        rendererResult.meanAbsoluteChannelDelta > 4.0) {
      fail(
        'Runtime renderer-calibration thresholds failed: '
        'differentPixelRatio=${rendererResult.differentPixelRatio} '
        '(max 0.10), '
        'meanAbsoluteChannelDelta='
        '${rendererResult.meanAbsoluteChannelDelta} (max 4.0), '
        'maxChannelDelta=${rendererResult.maxChannelDelta}.',
      );
    }

    final pencilDiagnostic = await comparePngs(
      reference: pencilReference,
      actual: candidate,
      diffOutput: pencilDiagnosticDiffOutput,
      perChannelTolerance: 8,
    );

    // Direct Pencil/runtime pixels cross renderer and downsample boundaries.
    // Keep the metric as diagnostic evidence; Gate A + renderer-calibrated
    // Gate B + Android semantic/user review own acceptance.
    // ignore: avoid_print
    print(
      'RUNTIME_PENCIL_DIAGNOSTIC '
      'differentPixelRatio=${pencilDiagnostic.differentPixelRatio} '
      'meanAbsoluteChannelDelta='
      '${pencilDiagnostic.meanAbsoluteChannelDelta} '
      'maxChannelDelta=${pencilDiagnostic.maxChannelDelta}',
    );
  });
}
