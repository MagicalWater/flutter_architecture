import 'package:drift/drift.dart';

part 'app_database.g.dart';

typedef MigrationFailureInjector = void Function(int completedVersion);

@DriftDatabase(include: <String>{'schema/app_database.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor, {this.migrationFailureInjector});

  AppDatabase.forTesting(QueryExecutor executor) : this(executor);

  final MigrationFailureInjector? migrationFailureInjector;

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      await transaction(() async {
        for (var target = from + 1; target <= to; target++) {
          await _migrateTo(target);
          migrationFailureInjector?.call(target);
        }
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _migrateTo(int target) => switch (target) {
    2 => _createCatalogV2(),
    3 => _upgradeCatalogPositionIndex(),
    4 => _addCatalogChainRevision(),
    5 => _upgradeAuthUserToSingleActiveRecord(),
    6 => _removeCatalogCacheOrphans(),
    _ => throw StateError('Unsupported database migration target: $target'),
  };

  Future<void> _createCatalogV2() async {
    await customStatement('''
      CREATE TABLE catalog_cache_page (
        query TEXT NOT NULL,
        request_cursor TEXT NOT NULL,
        request_limit INTEGER NOT NULL,
        next_cursor TEXT,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (query, request_cursor, request_limit)
      )
    ''');
    await customStatement('''
      CREATE TABLE catalog_cache_page_item (
        query TEXT NOT NULL,
        request_cursor TEXT NOT NULL,
        request_limit INTEGER NOT NULL,
        item_id TEXT NOT NULL,
        item_position INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_description TEXT NOT NULL,
        PRIMARY KEY (query, request_cursor, request_limit, item_id),
        FOREIGN KEY (query, request_cursor, request_limit)
          REFERENCES catalog_cache_page (query, request_cursor, request_limit)
          ON DELETE CASCADE
      )
    ''');
    await customStatement('''
      CREATE INDEX catalog_cache_page_item_order_idx
      ON catalog_cache_page_item (
        query, request_cursor, request_limit, item_position
      )
    ''');
  }

  Future<void> _upgradeCatalogPositionIndex() async {
    await customStatement(
      'DROP INDEX IF EXISTS catalog_cache_page_item_order_idx',
    );
    await customStatement('''
      DELETE FROM catalog_cache_page_item
      WHERE rowid NOT IN (
        SELECT MIN(rowid)
        FROM catalog_cache_page_item
        GROUP BY query, request_cursor, request_limit, item_position
      )
    ''');
    await customStatement('''
      CREATE UNIQUE INDEX catalog_cache_page_item_position_idx
      ON catalog_cache_page_item (
        query, request_cursor, request_limit, item_position
      )
    ''');
  }

  Future<void> _addCatalogChainRevision() async {
    final columns = await customSelect(
      'PRAGMA table_info(catalog_cache_page)',
    ).get();
    if (columns.any((row) => row.read<String>('name') == 'chain_revision')) {
      return;
    }
    await customStatement('''
      ALTER TABLE catalog_cache_page
      ADD COLUMN chain_revision INTEGER NOT NULL DEFAULT 0
    ''');
  }

  Future<void> _upgradeAuthUserToSingleActiveRecord() async {
    final tables = await customSelect('''
      SELECT name FROM sqlite_master
      WHERE type = 'table' AND name = 'auth_user'
    ''').get();
    if (tables.isEmpty) {
      await _createCurrentAuthUserTable();
      return;
    }

    final rows = await customSelect('SELECT id, name FROM auth_user').get();
    await customStatement('ALTER TABLE auth_user RENAME TO auth_user_legacy');
    await _createCurrentAuthUserTable();
    if (rows.length == 1) {
      await customStatement(
        'INSERT INTO auth_user(slot, id, name) VALUES (1, ?, ?)',
        <Object?>[
          rows.single.read<String>('id'),
          rows.single.read<String>('name'),
        ],
      );
    }
    await customStatement('DROP TABLE auth_user_legacy');
  }

  Future<void> _createCurrentAuthUserTable() {
    return customStatement('''
      CREATE TABLE auth_user (
        slot INTEGER PRIMARY KEY CHECK (slot = 1),
        id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<void> _removeCatalogCacheOrphans() async {
    final tables = await customSelect('''
      SELECT name FROM sqlite_master
      WHERE type = 'table'
        AND name IN ('catalog_cache_page', 'catalog_cache_page_item')
    ''').get();
    if (tables.length != 2) return;

    await customStatement('''
      DELETE FROM catalog_cache_page_item
      WHERE NOT EXISTS (
        SELECT 1
        FROM catalog_cache_page
        WHERE catalog_cache_page.query = catalog_cache_page_item.query
          AND catalog_cache_page.request_cursor =
            catalog_cache_page_item.request_cursor
          AND catalog_cache_page.request_limit =
            catalog_cache_page_item.request_limit
      )
    ''');
  }
}
