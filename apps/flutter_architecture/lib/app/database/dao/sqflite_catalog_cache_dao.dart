import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:sqflite/sqflite.dart';

/// Transitional adapter kept only until the production opener cutover gate.
///
/// Catalog behavior no longer depends on sqflite APIs directly. Task 29-8
/// removes this adapter together with the remaining sqflite authority.
final class SqfliteCatalogCacheDao implements CatalogCacheDao {
  const SqfliteCatalogCacheDao(this._database);

  final DatabaseExecutor _database;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) {
    return _guard(
      () => _database.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      ),
    );
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return _guard(
      () => _database.delete(table, where: where, whereArgs: whereArgs),
    );
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    bool replace = false,
  }) {
    return _guard(
      () => _database.insert(
        table,
        values,
        conflictAlgorithm: replace ? ConflictAlgorithm.replace : null,
      ),
    );
  }

  @override
  Future<T> transaction<T>(Future<T> Function(CatalogCacheDao dao) action) {
    final database = _database;
    if (database is Transaction) {
      return _guard(() => action(this));
    }
    if (database is Database) {
      return _guard(
        () => database.transaction(
          (transaction) => action(SqfliteCatalogCacheDao(transaction)),
        ),
      );
    }
    throw StateError('Unsupported sqflite executor: ${database.runtimeType}');
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(CatalogCacheDaoException(error), stackTrace);
    }
  }
}
