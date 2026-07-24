import 'package:flutter_architecture/app/database/app_database_web_storage_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Web upgrade明確採explicit reset且不宣稱自動保留', () {
    expect(
      appDatabaseWebUpgradeDisposition,
      AppDatabaseWebUpgradeDisposition.explicitReset,
    );
    expect(legacySqfliteIndexedDbName, 'sqflite_databases');
    expect(legacySqfliteDatabasePath, '/flutter_architecture.db');
    expect(driftWebDatabaseName, 'flutter_architecture');
    expect(preserveLegacySqfliteWebStorageAutomatically, isFalse);
  });
}
