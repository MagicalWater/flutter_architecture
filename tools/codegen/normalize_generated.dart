import 'dart:io';

const _generatedSuffixes = <String>[
  '.freezed.dart',
  '.g.dart',
  '.gr.dart',
];

void main() {
  final root = Directory.current;
  var changed = 0;

  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !_isTrackedGeneratedSource(entity.path)) continue;

    final original = entity.readAsStringSync();
    final normalized = original
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'[ \t]+$'), ''))
        .join('\n');

    if (normalized == original) continue;
    entity.writeAsStringSync(normalized);
    changed++;
  }

  stdout.writeln('Normalized $changed generated file(s).');
}

bool _isTrackedGeneratedSource(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (normalized.contains('/.dart_tool/') || normalized.contains('/build/')) {
    return false;
  }
  return _generatedSuffixes.any(normalized.endsWith);
}
