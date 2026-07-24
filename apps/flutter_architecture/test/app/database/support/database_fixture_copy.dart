import 'dart:io';

import 'package:path/path.dart' as p;

String appTestPath(String relativePath) {
  final current = Directory.current.absolute.path;
  final appRoot = p.basename(current) == 'flutter_architecture'
      ? current
      : p.join(current, 'apps', 'flutter_architecture');
  return p.join(appRoot, 'test', relativePath);
}

Future<File> copyDatabaseFixture({
  required String fixturePath,
  required Directory destinationDirectory,
  String? filename,
}) async {
  await destinationDirectory.create(recursive: true);
  final source = File(fixturePath);
  if (!await source.exists()) {
    throw StateError('Database fixture does not exist: $fixturePath');
  }

  final destination = File(
    p.join(destinationDirectory.path, filename ?? p.basename(fixturePath)),
  );
  if (await destination.exists()) {
    await destination.delete();
  }
  return source.copy(destination.path);
}
