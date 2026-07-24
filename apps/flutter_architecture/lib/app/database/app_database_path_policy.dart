import 'package:path/path.dart' as p;

const String appDatabaseFileName = 'flutter_architecture.db';

enum AppDatabasePlatform { android, ios, macos, windows, linux }

String resolveAppDatabasePath({
  required AppDatabasePlatform platform,
  required String mobileDatabaseDirectory,
  required String desktopDocumentsDirectory,
}) {
  final directory = switch (platform) {
    AppDatabasePlatform.android ||
    AppDatabasePlatform.ios => mobileDatabaseDirectory,
    AppDatabasePlatform.macos ||
    AppDatabasePlatform.windows ||
    AppDatabasePlatform.linux => desktopDocumentsDirectory,
  };
  return p.join(directory, appDatabaseFileName);
}
