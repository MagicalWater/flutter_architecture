import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/visual_diff.dart';

void main() {
  const perChannelTolerance = 8;
  const historicalReferenceCommit = 'c72501605c78588a10e29c9eab1ece3ac7d4bf8e';
  const historicalReferencePath =
      'docs/design_sources/pencil-compatibility-write-precheck/'
      'pencil-preview.png';
  final reference = File(
    '../../docs/design_sources/pencil-compatibility-write-precheck/'
    'pencil-preview.png',
  );
  final benchmark = File(
    '../../docs/design_sources/pencil-compatibility-write-precheck/'
    'historical-flutter-benchmark.png',
  );
  final candidate = File(
    'test/features/pencil_compatibility/goldens/'
    'write_precheck_windows.png',
  );
  final evidenceDirectory = Directory(
    '../../docs/audits/milestone_33/visual_validation',
  );
  late Directory historicalReferenceDirectory;
  late File historicalReference;

  setUpAll(() async {
    for (final file in <File>[reference, benchmark, candidate]) {
      if (!file.existsSync()) {
        throw StateError('Required visual input is missing: ${file.path}');
      }
    }
    await evidenceDirectory.create(recursive: true);
    await candidate.copy('${evidenceDirectory.path}/canonical-render.png');

    final historicalPreview = await Process.run('git', <String>[
      'show',
      '$historicalReferenceCommit:$historicalReferencePath',
    ], stdoutEncoding: null);
    if (historicalPreview.exitCode != 0 ||
        historicalPreview.stdout is! List<int>) {
      throw StateError(
        'Unable to load immutable historical Pencil preview from '
        '$historicalReferenceCommit:$historicalReferencePath.',
      );
    }
    historicalReferenceDirectory = await Directory.systemTemp.createTemp(
      'pencil-historical-reference-',
    );
    historicalReference = File(
      '${historicalReferenceDirectory.path}/pencil-preview.png',
    );
    await historicalReference.writeAsBytes(
      historicalPreview.stdout as List<int>,
      flush: true,
    );
  });

  tearDownAll(() async {
    if (historicalReferenceDirectory.existsSync()) {
      await historicalReferenceDirectory.delete(recursive: true);
    }
  });

  test(
    'canonical candidate meets the fixed Pencil reference thresholds',
    () async {
      final result = await comparePngs(
        reference: reference,
        actual: candidate,
        diffOutput: File('${evidenceDirectory.path}/reference-diff.png'),
        perChannelTolerance: perChannelTolerance,
      );

      if (result.differentPixelRatio > 0.08 ||
          result.meanAbsoluteChannelDelta > 8.0) {
        fail(
          'Visual thresholds failed: '
          'differentPixelRatio=${result.differentPixelRatio} (max 0.08), '
          'meanAbsoluteChannelDelta=${result.meanAbsoluteChannelDelta} '
          '(max 8.0), '
          'maxChannelDelta=${result.maxChannelDelta}.',
        );
      }
    },
  );

  test(
    'canonical candidate is no worse than the historical benchmark',
    () async {
      final benchmarkResult = await comparePngs(
        reference: historicalReference,
        actual: benchmark,
        diffOutput: File('${evidenceDirectory.path}/benchmark-diff.png'),
        perChannelTolerance: perChannelTolerance,
      );
      final candidateResult = await comparePngs(
        reference: reference,
        actual: candidate,
        diffOutput: File('${evidenceDirectory.path}/reference-diff.png'),
        perChannelTolerance: perChannelTolerance,
      );

      expect(
        candidateResult.differentPixelRatio,
        lessThanOrEqualTo(benchmarkResult.differentPixelRatio),
      );
      expect(
        candidateResult.meanAbsoluteChannelDelta,
        lessThanOrEqualTo(benchmarkResult.meanAbsoluteChannelDelta),
      );
    },
  );
}
