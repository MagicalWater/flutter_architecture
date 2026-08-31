import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';

final class CatalogCacheDaoException implements Exception {
  const CatalogCacheDaoException(this.cause);

  final Object cause;
}

abstract interface class CatalogCacheDao {
  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  });

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    bool replace = false,
  });

  Future<T> transaction<T>(Future<T> Function(CatalogCacheDao dao) action);
}

/// App-owned Drift 實作，承擔 Catalog cache 的 SQL boundary。
final class DriftCatalogCacheDao implements CatalogCacheDao {
  const DriftCatalogCacheDao(this._database);

  static const Set<String> _tables = <String>{
    'catalog_cache_page',
    'catalog_cache_page_item',
  };

  final AppDatabase _database;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    _validateTable(table);
    final selectedColumns = columns?.join(', ') ?? '*';
    final buffer = StringBuffer('SELECT $selectedColumns FROM $table');
    if (where != null) buffer.write(' WHERE $where');
    if (orderBy != null) buffer.write(' ORDER BY $orderBy');
    if (limit != null) buffer.write(' LIMIT $limit');

    return _guard(() async {
      final rows = await _database
          .customSelect(buffer.toString(), variables: _variables(whereArgs))
          .get();
      return <Map<String, Object?>>[
        for (final row in rows) Map<String, Object?>.from(row.data),
      ];
    });
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    _validateTable(table);
    final sql = StringBuffer('DELETE FROM $table');
    if (where != null) sql.write(' WHERE $where');
    return _guard(
      () => _database.customUpdate(
        sql.toString(),
        variables: _variables(whereArgs),
        updates: _tablesFor(table),
      ),
    );
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    bool replace = false,
  }) {
    _validateTable(table);
    if (values.isEmpty) {
      throw ArgumentError.value(values, 'values', 'Insert values不可為空');
    }
    final columns = values.keys.join(', ');
    final placeholders = List<String>.filled(values.length, '?').join(', ');
    final mode = replace ? 'INSERT OR REPLACE' : 'INSERT';
    return _guard(
      () => _database.customInsert(
        '$mode INTO $table ($columns) VALUES ($placeholders)',
        variables: _variables(values.values.toList(growable: false)),
        updates: _tablesFor(table),
      ),
    );
  }

  @override
  Future<T> transaction<T>(Future<T> Function(CatalogCacheDao dao) action) {
    return _guard(() => _database.transaction(() => action(this)));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SqliteException catch (error, stackTrace) {
      Error.throwWithStackTrace(CatalogCacheDaoException(error), stackTrace);
    }
  }

  List<Variable<Object>> _variables(
    List<Object?>? values,
  ) => <Variable<Object>>[
    for (final value in values ?? const <Object?>[]) Variable<Object>(value),
  ];

  Set<TableInfo<Table, Object?>> _tablesFor(String table) => switch (table) {
    'catalog_cache_page' => <TableInfo<Table, Object?>>{
      _database.catalogCachePage,
    },
    'catalog_cache_page_item' => <TableInfo<Table, Object?>>{
      _database.catalogCachePageItem,
    },
    _ => throw ArgumentError.value(table, 'table', 'Unsupported Catalog table'),
  };

  void _validateTable(String table) {
    if (!_tables.contains(table)) {
      throw ArgumentError.value(table, 'table', 'Unsupported Catalog table');
    }
  }
}
