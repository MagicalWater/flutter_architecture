---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-30-test-inventory-baseline
last_reviewed_baseline: 1.11.0
---

# Task 30-2 — Test Inventory, Ownership and Baseline

## Reproducible command

```bash
python3 tools/testing/inventory.py
```

Machine-readable result：

- `docs/audits/milestone_30/30-2_test_inventory.csv`

本文件的表格保存Milestone起始baseline；CSV由inventory command持續反映目前tracked snapshot，因此後續Task新增governance tests或受控cleanup後，CSV數字會依current tree更新。

Inventory tool使用`git ls-files`取得tracked files，辨識`*_test.dart`、`test_*.py`與tracked integration tests，再以deterministic repository-relative path排序。工具只做盤點與初始分類，不會因檔名自動刪除或修改tests。

## Confirmed baseline

| Metric | Result |
|---|---:|
| Test files | 134 |
| Test LOC | 23,066 |
| Static cases | 769 |
| Dart／Flutter files | 119 |
| Dart／Flutter cases | 659 |
| Python files | 15 |
| Python cases | 110 |

## Suite distribution

| Suite | Files |
|---|---:|
| Auth | 46 |
| Observability | 19 |
| Other | 14 |
| Database | 11 |
| Catalog | 9 |
| Design System | 7 |
| CI | 7 |
| Connectivity | 5 |
| Localization | 5 |
| Platform | 4 |
| Theme | 4 |
| API Client | 2 |
| Documentation | 1 |

Auth數量包含API refresh、App-owned credential／local unlock與integration coverage；因此高於只按feature／package path統計的早期估算。

## Initial category distribution

| Primary category | Files |
|---|---:|
| Business invariant | 88 |
| CI | 14 |
| Architecture boundary | 10 |
| Implementation contract | 10 |
| Historical-only | 5 |
| Platform | 3 |
| Migration compatibility | 3 |
| Visual | 1 |

這是Task 30-2的initial primary classification。後續Task可依實際owner review調整，但必須保留disposition evidence。

## Production／historical classification

| Classification | Files | Initial disposition |
|---|---:|---|
| Current | 123 | Keep／Audit |
| Historical | 5 | Keep／Audit |
| Current with historical fixture | 5 | Rewrite／Audit |
| Historical mixed | 1 | Rewrite／Archive |

已確認的六個優先邊界案例：

- `sqflite_auth_user_store_test.dart`：historical implementation contract與current owner混合。
- Catalog data-layer四個一般feature test files：使用historical sqflite fixture驗證current behavior。
- `catalog_logout_persistence_test.dart`：跨Auth cleanup與Catalog public cache，且使用historical Auth／Catalog stores。

Historical-only初始分類保留migration、rollback、fixture與Milestone 19.5 tooling；Task 30-3將逐項確認其正確owner與執行方式。

## Largest files

| LOC | Cases | Path |
|---:|---:|---|
| 1,170 | 36 | `catalog_bloc_test.dart` |
| 1,128 | 34 | `auth_credential_migration_coordinator_test.dart` |
| 1,047 | 27 | `catalog_repository_cache_test.dart` |
| 808 | 25 | `catalog_local_data_source_test.dart` |
| 799 | 20 | `auth_refresh_interceptor_test.dart` |
| 758 | 19 | `auth_repository_persistence_test.dart` |
| 751 | 25 | `auth_session_refresher_test.dart` |

大型檔案只列為responsibility review候選，不因LOC直接拆分。

## Runtime baseline

```txt
Full Flutter workspace regression
Result: passed
Wall time: 20.54s
App result: 467 tests passed

tools/ci Python contracts
Result: 88 passed
Wall time: 0.38s

tools/docs checker tests
Result: 15 passed
Wall time: 0.07s
```

目前沒有證據支持把deterministic tests移到nightly。Task 30-8必須在rationalization後重新量測至少兩次。

## Initial coverage owners

- Auth：credential authority、repository persistence、session refresh、request replay、local unlock與App adapters分層review。
- Catalog：Drift persistence、local boundary、repository cache policy、Bloc orchestration與Widget rendering分層review。
- Database：current Drift schema／DAO、historical migration／rollback與fixture integrity。
- CI／Platform：classifier、workflow matrix、execution mode、generated consistency與native scaffold。
- Preference／visual：Theme、Locale、Design System與golden owner。

## Next action

Task 30-3逐項審查16個Dart test files中的sqflite mention／import，確認哪些是合法historical oracle、哪些是current test綁錯implementation，並處理Milestone 19.5 fixture server的execution authority。

