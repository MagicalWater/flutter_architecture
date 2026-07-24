import 'package:drift/wasm.dart';
import 'package:flutter_architecture/app/database/app_database.dart';

const String appDatabaseWebName = 'flutter_architecture';

Future<AppDatabase> openAppDatabase() async {
  final result = await WasmDatabase.open(
    databaseName: appDatabaseWebName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return AppDatabase(result.resolvedExecutor);
}
