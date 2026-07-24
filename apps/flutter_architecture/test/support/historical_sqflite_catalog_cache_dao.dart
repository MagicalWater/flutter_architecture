import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:sqflite/sqflite.dart';

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
  }) => _guard(
    () => _database.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    ),
  );

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) => _guard(
    () => _database.delete(table, where: where, whereArgs: whereArgs),
  );

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    bool replace = false,
  }) => _guard(
    () => _database.insert(
      table,
      values,
      conflictAlgorithm: replace ? ConflictAlgorithm.replace : null,
    ),
  );

  @override
  Future<T> transaction<T>(Future<T> Function(CatalogCacheDao dao) action) {
    final database = _database;
    if (database is Transaction) return action(this);
    return _guard(
      () => (database as Database).transaction(
        (transaction) => action(SqfliteCatalogCacheDao(transaction)),
      ),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(CatalogCacheDaoException(error), stackTrace);
    }
  }
}
