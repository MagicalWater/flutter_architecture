/// SQLite 初始化的 fallback 實作。
///
/// Mobile 平台使用 sqflite 原生實作時，不需要額外初始化 databaseFactory。
Future<void> initializeDatabaseFactory() async {}
