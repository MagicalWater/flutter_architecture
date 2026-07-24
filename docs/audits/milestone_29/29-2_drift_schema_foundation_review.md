---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-2-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-2 — Drift Schema and Database Foundation Review

## Scope

本 Task 建立 Drift dependencies、current v6 typed schema、`AppDatabase` 與 test-only in-memory executor；production DI 與既有 sqflite authority 均未切換。

## Dependency resolution findings

### F-29-2-01 — Stable generator 與既有 analyzer toolchain 衝突

Severity：P1。

Root cause：`drift_dev 2.34.x`需要 analyzer 13；原有 Freezed 3.2.5 只支援 analyzer 10。較舊 Drift generator又與Melos 8的`cli_util` constraint互斥。

Disposition：Resolved with approved toolchain upgrade。

- Flutter：3.44.8。
- Dart：3.12.2。
- analyzer：13.0.0。
- Freezed：4.0.0-dev.2。
- Drift：2.34.2 resolved line。
- drift_dev：2.34.5 resolved line。
- drift_flutter：0.3.1。
- Workspace SDK lower bound：3.12.0。

沒有保留 dependency override。

### F-29-2-02 — Analyzer 13掃描build artifacts

Severity：P1。

Disposition：Resolved。`analysis_options.yaml`明確排除`**/build/**`與`**/.dart_tool/**`，避免第三方SwiftPM checkout與generated build artifact進入repository source analysis。

### F-29-2-03 — 新Flutter lint造成無關constructor重構

Severity：P2。

Disposition：Resolved。`prefer_initializing_formals`屬純style規則，與本Milestone database migration無關；明確維持disabled，避免把大量既有constructor style refactor混入Task 29-2。

### F-29-2-04 — Freezed prerelease輸出包含trailing whitespace

Severity：P1。

Disposition：Resolved。Freezed 4.0.0-dev.2與dev.3均可重現；repository build_runner入口在generator完成後執行`tools/codegen/normalize_generated.dart`，只正規化tracked generated Dart source的行尾空白，不改變語意或手寫source。

## Schema focused review

- `auth_user`保留`slot INTEGER PRIMARY KEY CHECK (slot = 1)`、`id UNIQUE`與NOT NULL。
- `catalog_cache_page`保留composite primary key與`chain_revision DEFAULT 0`。
- `catalog_cache_page_item`保留composite primary key、composite foreign key與`ON DELETE CASCADE`。
- `catalog_cache_page_item_position_idx`保留explicit unique index。
- `query`以quoted SQL identifier表示，實際SQLite名稱仍為`query`。
- `schemaVersion`維持6。
- `beforeOpen`啟用`PRAGMA foreign_keys = ON`。

## Re-review and holistic review

- Fresh schema tests已驗證table/index inventory、AuthUser check與cascade。
- v1～v6 legacy fixture tests仍通過。
- Production `RegisterModule`、database initializer、AuthUser store與Catalog source均未改為Drift。
- Reusable packages未依賴Drift implementation。
- Generated Freezed／Injectable差異來自核准的generator upgrade，已由全量tests驗證。

## Documentation and authority

- `AppDatabase`目前是accepted future authority foundation，不是production open boundary。
- `AppDatabaseSchema`仍是production schema／migration authority，直到Task 29-8 single-owner cutover。
- current snapshot與ADR尚不提前切換。

## Validation

```text
dart pub get
dart run build_runner build
flutter test test/app/database/drift_fresh_schema_test.dart
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
```

結果：全部通過；App tests 442 passed、1 planned skip，其他packages全數通過。

## Final disposition

```text
Task 29-2: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Production persistence cutover: NO
Next Task: 29-3 Historical Migration Contract
```
