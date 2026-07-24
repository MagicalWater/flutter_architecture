---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-5-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-5 — Catalog Offline Cache Migration Review

## Scope

本 Task 將 `CatalogLocalDataSource` 從直接依賴 sqflite API 改為依賴
App-owned `CatalogCacheDao` boundary，保留既有 cursor-chain business rules、
transaction rollback、corruption cleanup、revision 與 logout persistence 行為。

Production single-owner opener cutover 仍依 approved plan 保留至 Task 29-8；因此本
Task 同時提供 transitional `SqfliteCatalogCacheDao`，僅供既有 production graph 與
legacy behavior tests 使用。真正 Drift path 由 `DriftCatalogCacheDao` 與獨立測試驗證。

## Implemented

- 新增 `CatalogCacheDao` 最小 query／insert／delete／transaction contract。
- 新增 `DriftCatalogCacheDao`，以 `AppDatabase` custom SQL 執行既有明確 SQL。
- 新增 `CatalogCacheDaoException`，統一 provider exception boundary。
- 新增 transitional `SqfliteCatalogCacheDao`，標明 Task 29-8 removal gate。
- `CatalogLocalDataSource` 不再引用 `Database`、`DatabaseExecutor`、
  `ConflictAlgorithm` 或 `DatabaseException`。
- 保留所有 cursor chain、cycle detection、chain revision、cleanup 與 transaction
  business decisions在 feature boundary，不下沉到 generic DAO。
- 新增 Drift round-trip、first-page chain reset/revision 與 constraint rollback tests。

## Focused Review Findings

### Finding 1 — Provider exception未統一

初版只捕捉 Drift `SqliteException`，導致 transitional sqflite regression無法映射為
`AppExceptionKind.localStorage`。

**Disposition:** 新增 `CatalogCacheDaoException`，由各 provider adapter保留原始 cause
與 stack後統一拋出，feature只辨識 DAO boundary exception。

### Finding 2 — Repository test helpers仍傳入raw Database

Analyzer指出六個 `_ThrowingCatalogLocalDataSource` call site仍使用raw sqflite
`Database`。

**Disposition:** 全部明確包成 `SqfliteCatalogCacheDao`，不在 feature contract洩漏
provider type。

## Focused Re-review

完成上述 findings 修正後，重新執行 provider boundary 與 call-site focused review：

- `CatalogLocalDataSource` 已無 `Database`、`DatabaseExecutor`、
  `ConflictAlgorithm`、`DatabaseException` 或直接 sqflite import。
- Drift 與 transitional sqflite implementation皆只透過 `CatalogCacheDao` contract
  進入 feature boundary。
- Provider operational failures皆先包裝為 `CatalogCacheDaoException`，再由 feature
  映射為既有 `AppExceptionKind.localStorage`，unknown non-provider errors不被吞掉。
- Repository、data layer、logout與local source tests的raw `Database` call sites皆已
  明確包裝為 `SqfliteCatalogCacheDao`。
- 真正 Drift execution path由 `drift_catalog_local_data_source_test.dart`直接覆蓋，
  不是只依賴 transitional adapter通過。

Focused re-review結果：無新增 P0／P1 finding。

## Whole-task Review

- Cursor-chain decision ownership未移動。
- First-page replacement仍在單一transaction內刪除following pages並遞增revision。
- Append predecessor mismatch、cycle與stale revision仍拒絕寫入。
- Duplicate item identity造成的constraint failure會回滾parent與children。
- Malformed persisted rows仍清除指定page或整條chain。
- Logout仍只清除Auth state，不刪除public Catalog cache。
- Transitional adapter有明確 removal gate，不宣稱production已完成single-owner cutover。

## Validation

- `flutter test test/features/catalog/data/catalog_local_data_source_test.dart`
  - 25 passed
- `flutter test test/features/catalog/data/drift_catalog_local_data_source_test.dart`
  - 3 passed
- Catalog data + Bloc regression
  - 104 passed
- `dart run melos run analyze`
  - passed
- `dart run melos run docs_check`
  - passed；初次檢查發現review metadata不符合repository schema，修正為
    `phase-review`／`accepted`並補齊authority與baseline後重新通過
- `git diff --check`
  - passed

## Documentation Authority Check

- 本文件是 Task 29-5 review evidence authority，不取代approved Design Spec或
  Implementation Plan。
- Production single-owner cutover仍由Task 29-8負責；本 Task未提前宣稱sqflite
  production authority已移除。
- Transitional `SqfliteCatalogCacheDao` removal gate已明確記錄，未形成永久雙owner
  架構承諾。
- `docs_check`已確認metadata、authority identifier與baseline格式符合文件治理規則。

## Exit Criteria

- Open P0: 0
- Open P1 without disposition: 0
- Task 29-5: passed
- Next: Task 29-6 — Cross-platform Database Openers and Web Storage Disposition
