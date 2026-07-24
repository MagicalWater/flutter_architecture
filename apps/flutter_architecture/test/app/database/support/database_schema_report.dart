import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final class DatabaseSchemaReport {
  const DatabaseSchemaReport(this.value);

  final Map<String, Object?> value;

  String toCanonicalJson() => const JsonEncoder.withIndent('  ').convert(value);

  static Future<DatabaseSchemaReport> capture(Database database) async {
    final master = await database.rawQuery('''
      SELECT type, name, tbl_name, sql
      FROM sqlite_master
      WHERE name NOT LIKE 'sqlite_%'
      ORDER BY type, name
    ''');
    final tables = master
        .where((row) => row['type'] == 'table')
        .map((row) => row['name']! as String)
        .toList(growable: false);

    final tableInfo = <String, Object?>{};
    final foreignKeys = <String, Object?>{};
    final indexes = <String, Object?>{};
    for (final table in tables) {
      tableInfo[table] = await database.rawQuery('PRAGMA table_info("$table")');
      foreignKeys[table] = await database.rawQuery(
        'PRAGMA foreign_key_list("$table")',
      );
      final indexList = await database.rawQuery('PRAGMA index_list("$table")');
      indexes[table] = <String, Object?>{
        'list': indexList,
        'columns': <String, Object?>{
          for (final row in indexList)
            row['name']! as String: await database.rawQuery(
              'PRAGMA index_info("${row['name']}")',
            ),
        },
      };
    }

    return DatabaseSchemaReport(<String, Object?>{
      'userVersion': (await database.rawQuery(
        'PRAGMA user_version',
      )).single.values.single,
      'master': master,
      'tableInfo': tableInfo,
      'foreignKeys': foreignKeys,
      'indexes': indexes,
      'foreignKeyCheck': await database.rawQuery('PRAGMA foreign_key_check'),
      'sentinelData': <String, Object?>{
        for (final table in tables)
          table: await database.query(table, orderBy: _orderByFor(table)),
      },
    });
  }
}

String? _orderByFor(String table) => switch (table) {
  'auth_user' => 'id',
  'catalog_cache_page' => 'query, request_cursor, request_limit',
  'catalog_cache_page_item' =>
    'query, request_cursor, request_limit, item_position, item_id',
  _ => null,
};
