import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_schema_report.dart';
import 'legacy_sqflite_fixture_builder.dart';

Future<void> main() async {
  final current = Directory.current.absolute.path;
  final appRoot = p.basename(current) == 'flutter_architecture'
      ? current
      : p.join(current, 'apps', 'flutter_architecture');
  final output = Directory(
    p.join(appRoot, 'test', 'app', 'database', 'fixtures'),
  );
  await LegacySqfliteFixtureBuilder().buildAll(output);
  sqfliteFfiInit();

  final reports = Directory(p.join(output.path, 'reports'));
  await reports.create(recursive: true);
  for (var version = 1; version <= 6; version++) {
    final database = await databaseFactoryFfi.openDatabase(
      p.join(output.path, 'v$version.db'),
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    try {
      final report = await DatabaseSchemaReport.capture(database);
      await File(
        p.join(reports.path, 'v$version.json'),
      ).writeAsString('${report.toCanonicalJson()}\n');
    } finally {
      await database.close();
    }
  }
}
