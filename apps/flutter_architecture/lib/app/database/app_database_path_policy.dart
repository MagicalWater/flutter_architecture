import 'package:path/path.dart' as p;

const String appDatabaseFileName = 'flutter_architecture.db';

/// App database 目前要在哪一類原生平台建立檔案。
///
/// Mobile 使用平台提供的 database directory；desktop 則放在 documents directory。
enum AppDatabasePlatform {
  /// Android。
  android,

  /// iOS。
  ios,

  /// macOS。
  macos,

  /// Windows。
  windows,

  /// Linux。
  linux,
}

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
