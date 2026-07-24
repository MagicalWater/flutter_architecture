import 'package:flutter/services.dart';

const MethodChannel _databasePathChannel = MethodChannel(
  'flutter_architecture/database_path',
);

Future<String> getMobileDatabaseDirectory() async {
  final path = await _databasePathChannel.invokeMethod<String>(
    'getDatabaseDirectory',
  );
  if (path == null || path.trim().isEmpty) {
    throw StateError('Native database directory is unavailable');
  }
  return path;
}
