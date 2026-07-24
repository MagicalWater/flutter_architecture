---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-30-persistence-test-boundary-audit
last_reviewed_baseline: 1.11.0
---

# Task 30-3 — Historical and Persistence Boundary Audit

## Current production authority

```txt
AppDatabase / Drift
├─ DriftAuthUserStore
└─ DriftCatalogLocalDataSource / CatalogCacheDao
```

sqflite與`sqflite_common_ffi`只允許存在於historical fixture、migration／rollback oracle與dev test harness。

## Sqflite reference classification

### Keep — Historical migration／rollback oracle

| Test | Owner | Reason |
|---|---|---|
| `drift_historical_migration_test.dart` | Drift migration harness | 證明v1～v6升級至canonical v6 |
| `drift_rollback_compatibility_test.dart` | Rollback harness | 證明Drift migration未破壞SQLite file contract |
| `legacy_fixture_integrity_test.dart` | Fixture authority | 驗證checked-in binary、schema report與sentinel data |
| `legacy_sqflite_expected_migration_test.dart` | Historical oracle | 以舊sqflite contract產生expected result，避免同源驗證 |
| `app_database_foreign_key_test.dart` | Current database integration | 使用SQLite inspection驗證foreign key／cascade，不代表sqflite production owner |

### Keep／Archive — Historical implementation tooling

| Test／tool | Disposition | Replacement requirement |
|---|---|---|
| `sqflite_auth_user_store_test.dart` | Archive as historical implementation contract | Current AuthUser behavior由`drift_auth_user_store_test.dart`擁有；Task 30-4再決定是否搬移／改名 |
| `test/support/historical_sqflite_auth_user_store.dart` | Keep as fixture | 僅供historical expected／rollback與過渡rewrite使用 |
| `test/support/historical_sqflite_catalog_cache_dao.dart` | Keep as fixture | 僅供historical expected／rollback與過渡rewrite使用 |
| `test/support/historical_sqflite_schema.dart` | Keep as fixture | v1～v6 historical schema owner |
| `tools/milestone_19_5/` | Archive as historical manual tooling | 以local README固定正確命令與非CI authority |

### Rewrite — Current tests using historical fixture

| Test | Current issue | Replacement owner |
|---|---|---|
| `auth_single_active_user_persistence_test.dart` | business／migration orchestration以historical AuthUser store執行 | Task 30-4改為Drift integration或窄fake；legacy credential migration仍保留 |
| `catalog_local_data_source_test.dart` | current local behavior主要由historical DAO承載 | Task 30-5以Drift current integration與narrow fake分層 |
| `catalog_repository_cache_test.dart` | Repository policy綁定historical database implementation | Task 30-5以fake local contract驗證policy，另由Drift integration持有persistence mechanics |
| `catalog_data_layer_test.dart` | mapper／remote／repository smoke共用historical DAO setup | Task 30-5移除不必要DB coupling |
| `catalog_logout_persistence_test.dart` | 跨Auth cleanup／Catalog persistence使用兩個historical stores | Task 30-4／30-5建立current Drift composition integration |

### Keep — References that are policy assertions, not runtime dependency

- `app_database_path_policy_test.dart`
- `app_database_web_storage_policy_test.dart`
- `register_module_auth_persistence_test.dart`
- `ios_scaffold_contract_test.dart`
- `core_runtime_smoke_test.dart`

這些測試中的`sqflite`文字用於路徑、authority guard、platform compatibility或historical policy assertion，不代表current implementation dependency。

## Current owner comparison

### AuthUser

- Current production adapter已有`drift_auth_user_store_test.dart`，涵蓋single-slot read／replace／clear、malformed row與exception mapping。
- Historical `sqflite_auth_user_store_test.dart`仍驗證舊adapter CRUD／error behavior；其current replacement已存在，因此不得再作一般feature fixture。
- `auth_single_active_user_persistence_test.dart`仍有獨立價值：credential＋public user＋cleanup integration，但必須切換current persistence owner。

### Catalog

- `drift_catalog_local_data_source_test.dart`已涵蓋current Drift page write／read、replacement、revision、corruption與transaction semantics。
- 舊`catalog_local_data_source_test.dart`同時包含current business boundary、historical DAO exception mapping與v1～v4 migration cases，責任混合。
- Repository與Bloc不應知道DAO implementation；Repository cache policy應使用narrow fake local boundary，Drift mechanics留在current integration tests。

## Historical fixture server disposition

Root module invocation失敗的原因是tool使用local import：

```txt
from auth_fixture_server import ...
```

在其historical working directory執行則通過：

```txt
cd tools/milestone_19_5
python3 -m unittest test_auth_fixture_server.py
→ 7 passed
```

Disposition：Archive as historical manual tooling。新增local README固定正確命令；不納入current`tools/ci` discovery，也不刪除reproduction能力。

## Boundary rules accepted for following Tasks

1. Historical migration／rollback tests與helpers保持可執行。
2. Current AuthUser／Catalog persistence integration必須走Drift。
3. Repository policy tests優先使用窄fake，不以in-memory database作不必要fixture。
4. Historical adapter tests要搬移／改名時，必須先證明current replacement完整。
5. sqflite string／path policy assertion不等於implementation dependency。

