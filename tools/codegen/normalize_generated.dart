import 'dart:io';

const _generatedSuffixes = <String>['.freezed.dart', '.g.dart', '.gr.dart'];

void main() {
  final root = Directory.current;
  var changed = 0;

  for (final file in _walkTrackedGeneratedSources(root)) {
    final original = file.readAsStringSync();
    final normalized = original
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'[ \t]+$'), ''))
        .join('\n');

    if (normalized == original) continue;
    file.writeAsStringSync(normalized);
    changed++;
  }

  stdout.writeln('Normalized $changed generated file(s).');
}

Iterable<File> _walkTrackedGeneratedSources(Directory root) sync* {
  final pending = <Directory>[root];

  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    late final List<FileSystemEntity> entries;
    try {
      entries = current.listSync(followLinks: false);
    } on FileSystemException {
      if (!current.existsSync()) continue;
      rethrow;
    }

    for (final entity in entries) {
      if (entity is Directory) {
        if (!_shouldSkipDirectory(entity.path)) pending.add(entity);
        continue;
      }
      if (entity is File && _isTrackedGeneratedSource(entity.path)) {
        yield entity;
      }
    }
  }
}

bool _shouldSkipDirectory(String path) {
  final normalized = path.replaceAll('\\', '/');
  final name = normalized.substring(normalized.lastIndexOf('/') + 1);
  return name == '.dart_tool' || name == 'build' || name == '.git';
}

bool _isTrackedGeneratedSource(String path) {
  final normalized = path.replaceAll('\\', '/');
  if (normalized.contains('/.dart_tool/') || normalized.contains('/build/')) {
    return false;
  }
  return _generatedSuffixes.any(normalized.endsWith);
}
