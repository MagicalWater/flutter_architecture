import 'package:flutter_architecture/app/database/app_database_path_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('Android與iOS沿用既有sqflite database directory與精確檔名', () {
    for (final platform in <AppDatabasePlatform>[
      AppDatabasePlatform.android,
      AppDatabasePlatform.ios,
    ]) {
      expect(
        resolveAppDatabasePath(
          platform: platform,
          mobileDatabaseDirectory: p.join('legacy', 'databases'),
          desktopDocumentsDirectory: p.join('ignored', 'documents'),
        ),
        p.join('legacy', 'databases', 'flutter_architecture.db'),
      );
    }
  });

  test('Desktop使用App documents directory與精確檔名', () {
    for (final platform in <AppDatabasePlatform>[
      AppDatabasePlatform.macos,
      AppDatabasePlatform.windows,
      AppDatabasePlatform.linux,
    ]) {
      expect(
        resolveAppDatabasePath(
          platform: platform,
          mobileDatabaseDirectory: p.join('ignored', 'databases'),
          desktopDocumentsDirectory: p.join('app', 'documents'),
        ),
        p.join('app', 'documents', 'flutter_architecture.db'),
      );
    }
  });
}
