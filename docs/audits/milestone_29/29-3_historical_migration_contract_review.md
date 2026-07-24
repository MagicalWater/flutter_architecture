---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-3-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-3 — Historical Migration Contract Review

## Scope

讓`AppDatabase`對Task 29-1建立的v1～v6 legacy SQLite fixtures執行等價migration，並驗證失敗rollback與sqflite rollback compatibility。

## Focused findings

### F-29-3-01 — Drift onUpgrade不會替custom DDL自動提供完整rollback

Severity：P1。

Disposition：Resolved。所有逐版本migration step明確包在`AppDatabase.transaction`中。Injected v2→v3 failure驗證：`user_version`維持2、舊non-unique index仍存在、new unique index不存在。

### F-29-3-02 — v1 rollback test誤認fixture已有Catalog資料

Severity：P2。

Disposition：Resolved。v1本來只有malformed AuthUser seed；rollback compatibility改為使用sqflite在Drift migration後插入新的parent／child sentinel，再驗證cascade。

## Migration contract

```text
v1→v2：建立Catalog page/item與legacy order index
v2→v3：去除duplicate position、切換unique position index
v3→v4：加入chain_revision NOT NULL DEFAULT 0
v4→v5：重建AuthUser single-active-row；只保留恰好一筆legacy row
v5→v6：移除foreign-key啟用前遺留的orphan item
```

Migration仍維持schema version 6，沒有引入v7或新的data format。

## Whole-task holistic review

- v1 malformed multi-row AuthUser升級後安全清空。
- v2～v4 single AuthUser升級後保留並固定slot 1。
- v2 duplicate item position保留最早row並建立unique index。
- v4 chain revision與cursor cycle sentinel資料保留。
- v2／v5 orphan item完成清理。
- v6直接開啟不執行不必要schema mutation。
- Drift migration後同一file可由sqflite重新開啟、寫入並執行composite cascade。
- Production DI仍使用sqflite；single-owner cutover尚未發生。

## Documentation and authority

- `AppDatabase`現在擁有accepted Drift historical migration contract。
- `AppDatabaseSchema`仍是目前production open path的schema authority，直到Task 29-8。
- fixtures仍由legacy sqflite builder擁有，避免Drift自我驗證。

## Validation

```text
flutter test test/app/database/drift_historical_migration_test.dart
flutter test test/app/database/drift_rollback_compatibility_test.dart
flutter test test/app/database/drift_fresh_schema_test.dart
flutter test test/app/database/legacy_fixture_integrity_test.dart
flutter test test/app/database/legacy_sqflite_expected_migration_test.dart
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

## Final disposition

```text
Task 29-3: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Production cutover: NO
Next Task: 29-4 AuthUser Persistence Migration
```
