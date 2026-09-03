/// Web storage 從舊 sqflite 實作切到 Drift 時採用哪種處理方式。
enum AppDatabaseWebUpgradeDisposition {
  /// 不嘗試自動搬舊資料；需要明確 reset 後建立新的 Drift storage。
  explicitReset,
}

const AppDatabaseWebUpgradeDisposition appDatabaseWebUpgradeDisposition =
    AppDatabaseWebUpgradeDisposition.explicitReset;

const String legacySqfliteIndexedDbName = 'sqflite_databases';
const String legacySqfliteDatabasePath = '/flutter_architecture.db';
const String driftWebDatabaseName = 'flutter_architecture';

/// Web 目前只是 dependency-ready，還不是正式支援的平台。
///
/// 舊 sqflite Web database 和 Drift 使用不同的 IndexedDB／VFS 儲存方式，不能只因
/// SQLite file format 相容就假設資料會自動保留，因此目前明確要求 reset。
const bool preserveLegacySqfliteWebStorageAutomatically = false;
