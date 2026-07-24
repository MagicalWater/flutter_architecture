import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_architecture/app/database/app_database_mobile_directory.dart';
import 'package:flutter_architecture/app/database/app_database_path_policy.dart';
import 'package:path_provider/path_provider.dart';

Future<AppDatabase> openAppDatabase({
  Future<String> Function()? mobileDatabaseDirectory,
  Future<Directory> Function()? desktopDocumentsDirectory,
}) async {
  final platform = _currentPlatform();
  final mobileDirectory = switch (platform) {
    AppDatabasePlatform.android || AppDatabasePlatform.ios =>
      await (mobileDatabaseDirectory ?? getMobileDatabaseDirectory)(),
    _ => '',
  };
  final desktopDirectory = switch (platform) {
    AppDatabasePlatform.macos ||
    AppDatabasePlatform.windows ||
    AppDatabasePlatform.linux =>
      await (desktopDocumentsDirectory ?? getApplicationDocumentsDirectory)(),
    _ => Directory(''),
  };

  final path = resolveAppDatabasePath(
    platform: platform,
    mobileDatabaseDirectory: mobileDirectory,
    desktopDocumentsDirectory: desktopDirectory.path,
  );
  return AppDatabase(NativeDatabase.createInBackground(File(path)));
}

AppDatabasePlatform _currentPlatform() {
  if (Platform.isAndroid) return AppDatabasePlatform.android;
  if (Platform.isIOS) return AppDatabasePlatform.ios;
  if (Platform.isMacOS) return AppDatabasePlatform.macos;
  if (Platform.isWindows) return AppDatabasePlatform.windows;
  if (Platform.isLinux) return AppDatabasePlatform.linux;
  throw UnsupportedError('Unsupported native database platform');
}
