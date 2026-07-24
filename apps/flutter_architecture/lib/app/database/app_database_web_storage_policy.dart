enum AppDatabaseWebUpgradeDisposition { explicitReset }

const AppDatabaseWebUpgradeDisposition appDatabaseWebUpgradeDisposition =
    AppDatabaseWebUpgradeDisposition.explicitReset;

const String legacySqfliteIndexedDbName = 'sqflite_databases';
const String legacySqfliteDatabasePath = '/flutter_architecture.db';
const String driftWebDatabaseName = 'flutter_architecture';

/// Web目前仍是Dependency-ready，未曾宣稱Supported或正式distribution。
///
/// 舊sqflite Web database位於不同IndexedDB/VFS contract，不能只因SQLite file
/// format相容就宣稱Drift會自動保留。Milestone 29採明確reset disposition。
const bool preserveLegacySqfliteWebStorageAutomatically = false;
