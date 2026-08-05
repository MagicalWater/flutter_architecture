import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Pencil compatibility feature remains presentation-only and anti-raster',
    () {
      final featureRoot = Directory('lib/features/pencil_compatibility');
      expect(featureRoot.existsSync(), isTrue);

      final dartFiles = featureRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList(growable: false);
      expect(dartFiles, isNotEmpty);

      final violations = <String>[];
      for (final file in dartFiles) {
        final normalizedPath = file.path.replaceAll('\\', '/');
        final source = file.readAsStringSync();

        if (normalizedPath.contains('/domain/') ||
            normalizedPath.contains('/data/')) {
          violations.add('$normalizedPath introduces a forbidden layer');
        }
        for (final forbidden in <String>[
          'Bloc',
          'Repository',
          'UseCase',
          'getIt',
          'injectable',
        ]) {
          if (source.contains(forbidden)) {
            violations.add('$normalizedPath contains $forbidden');
          }
        }
        if (source.contains('Image.asset(') || source.contains('Image.file(')) {
          violations.add('$normalizedPath embeds a raster image');
        }
      }

      final pageSource = File(
        'lib/features/pencil_compatibility/presentation/pages/'
        'write_precheck_view.dart',
      ).readAsStringSync();
      if (pageSource.contains('FittedBox(')) {
        violations.add('WritePrecheckView uses fixed-canvas FittedBox scaling');
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );
}
