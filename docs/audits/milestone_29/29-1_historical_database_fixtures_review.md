---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-1-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-1 Historical Database Fixtures and Compatibility Harness Review

## Scope

本Task只建立v1～v6 legacy SQLite fixtures、正規化schema report、fixture copy helper與current sqflite expected migration tests。沒有修改production persistence source、DI或database authority。

## Fixture matrix

| Fixture | Historical contract與sentinel |
|---|---|
| v1 | 舊AuthUser schema、兩筆malformed identity；升級後清空 |
| v2 | 單筆AuthUser、non-unique position index、duplicate position與orphan item |
| v3 | unique position index與clean page data |
| v4 | `chain_revision`與cursor cycle sentinel |
| v5 | single-slot AuthUser與legacy orphan item |
| v6 | current clean schema與sentinel data |

## Focused review findings

### F-29-1-01 — Relative fixture path被sqflite重新導向

Severity：P1

Disposition：Resolved。

第一輪生成器使用relative path，`databaseFactoryFfi`將檔案建立於`.dart_tool/sqflite_common_ffi/databases/`，Flutter test亦因repository-root working directory找不到fixtures。生成器與tests已改用解析後的App absolute path，並移除誤生成檔案。

### F-29-1-02 — Raw SQLite hash不能作deterministic authority

Severity：P1

Disposition：Resolved。

Task以normalized JSON report作canonical authority，涵蓋`sqlite_master`、`table_info`、foreign keys、indexes、`user_version`、`foreign_key_check`與sentinel data。連續兩次生成的report diff一致；README明確禁止以raw file hash作schema authority。

### F-29-1-03 — v1需要同時覆蓋合法與malformed AuthUser

Severity：P1

Disposition：Resolved。

固定六個version fixtures下，v1保存malformed multi-row disposition，v2保存old-schema single-row preservation；兩者共同覆蓋v1～v4舊AuthUser schema的兩種歷史資料狀態。

## Re-review

- v1～v6 fixture均存在且`PRAGMA user_version`與檔名一致。
- v2保留duplicate position與orphan sentinel，current migration會dedupe並清除orphan。
- v4保留revision與cycle sentinel，不由fixture builder隱性修復。
- v1 multi-row AuthUser升級後清空；v2～v4 single-row升級後保留；v5／v6 single-slot保持一筆。
- current sqflite migration將所有fixture升級至v6，`foreign_key_check`為空。

## Whole-task holistic review

### Isolation

- fixture builder只位於test tree。
- Drift migration skeleton保持skip，明確留待Task 29-3啟用。
- production source、DI、dependencies與Web assets均未修改。

### Independence

- fixtures由legacy sqflite contract直接建立，不依賴未來Drift tables或generated schema。
- schema report可同時供Task 29-2 fresh-schema equivalence與Task 29-3 historical migration matrix使用。

### Documentation authority

- fixture README只說明test fixture contract。
- Design Spec仍為Milestone architecture authority。
- Implementation Plan仍為execution sequencing authority。
- current production snapshot與ADR不需於本Task更新。

## Validation

```text
dart run test/app/database/support/generate_legacy_fixtures.dart
flutter test test/app/database/legacy_fixture_integrity_test.dart
flutter test test/app/database/legacy_sqflite_expected_migration_test.dart
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

## Final disposition

```text
Task 29-1: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Production persistence modified: NO
Next Task: 29-2 Drift Schema and Database Foundation
```
