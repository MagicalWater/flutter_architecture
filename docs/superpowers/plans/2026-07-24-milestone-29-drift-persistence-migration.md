---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-29-drift-persistence-migration-execution-plan
last_reviewed_baseline: 1.10.0
---

# Milestone 29 Drift Persistence Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將App-owned sqflite persistence完整遷移為Drift，同時保留既有SQLite file、v1～v6 migration、AuthUser與Catalog Offline Cache correctness。

**Architecture:** App維持唯一Composition Root，新增單一`AppDatabase`作schema／migration authority，Auth與Catalog只透過App-owned DAO／adapter使用Drift。先以舊sqflite contract產生v1～v6 fixtures與expected結果，再完成Drift foundation、historical migration、feature parity、cross-platform opener與single-owner production cutover。

**Tech Stack:** Flutter、Dart、Drift、drift_dev、drift_flutter、temporary drift_sqflite bridge、sqlite3、build_runner、Melos、Flutter test、integration_test。

---

## Global execution rules

每個Task均執行：

```txt
implement
→ focused review
→ findings
→ fix
→ re-review
→ whole-task holistic review
→ documentation authority check
→ validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ commit
→ next Task
```

不得在Task 29-1 compatibility gate通過前切換production DI。不得在任何commit留下兩個production schema owner。

## Planned file map

### Database foundation

- Create `apps/flutter_architecture/lib/app/database/app_database.dart`：Drift database class、schemaVersion、migration strategy。
- Create `apps/flutter_architecture/lib/app/database/app_database.g.dart`：generated output。
- Create `apps/flutter_architecture/lib/app/database/connection/app_database_opener.dart`：platform-neutral opener contract。
- Create `apps/flutter_architecture/lib/app/database/connection/app_database_opener_io.dart`：Android/iOS/Desktop native path與background executor。
- Create `apps/flutter_architecture/lib/app/database/connection/app_database_opener_web.dart`：Wasm／worker opener。
- Create `apps/flutter_architecture/lib/app/database/connection/app_database_opener_stub.dart`：unsupported compile-time fallback。
- Create `apps/flutter_architecture/lib/app/database/schema/auth_user_table.dart`。
- Create `apps/flutter_architecture/lib/app/database/schema/catalog_cache_page_table.dart`。
- Create `apps/flutter_architecture/lib/app/database/schema/catalog_cache_page_item_table.dart`。
- Create `apps/flutter_architecture/lib/app/database/migrations/app_database_migrations.dart`。
- Create `apps/flutter_architecture/lib/app/database/dao/auth_user_dao.dart`。
- Create `apps/flutter_architecture/lib/app/database/dao/catalog_cache_dao.dart`。

### Compatibility and migration tests

- Create `apps/flutter_architecture/test/app/database/fixtures/v1.db`～`v6.db`。
- Create `apps/flutter_architecture/test/app/database/fixtures/README.md`。
- Create `apps/flutter_architecture/test/app/database/support/legacy_sqflite_fixture_builder.dart`。
- Create `apps/flutter_architecture/test/app/database/support/database_schema_report.dart`。
- Create `apps/flutter_architecture/test/app/database/support/database_fixture_copy.dart`。
- Create `apps/flutter_architecture/test/app/database/drift_historical_migration_test.dart`。
- Create `apps/flutter_architecture/test/app/database/drift_schema_equivalence_test.dart`。
- Create `apps/flutter_architecture/test/app/database/drift_rollback_compatibility_test.dart`。

### Feature adapters

- Rename `apps/flutter_architecture/lib/features/auth/data/stores/sqflite_auth_user_store.dart` to `drift_auth_user_store.dart`。
- Modify `apps/flutter_architecture/lib/features/catalog/data/data_sources/catalog_local_data_source.dart`。
- Modify corresponding tests under `test/features/auth/data/` and `test/features/catalog/data/`。

### Composition and platform

- Modify `apps/flutter_architecture/lib/app/di/register_module.dart`。
- Regenerate `apps/flutter_architecture/lib/app/di/injection.config.dart`。
- Modify `apps/flutter_architecture/lib/bootstrap.dart`。
- Remove legacy `database_initializer*.dart` after cutover acceptance。
- Replace `apps/flutter_architecture/web/sqflite_sw.js` with `drift_worker.js` at final Web cutover。
- Refresh `apps/flutter_architecture/web/sqlite3.wasm` from the resolved sqlite3 release line。

### Governance

- Modify `apps/flutter_architecture/pubspec.yaml`、root `pubspec.lock`。
- Modify `melos.yaml` or build scripts only if existing generation command does not include Drift.
- Modify CI classifier／generated consistency tests under `.github/` and `tools/ci/` as identified by Task 29-7.
- Add milestone phase reviews under `docs/audits/milestone_29/`。
- Update ADR、README、roadmap、CHANGELOG、VERSION only at their defined cutover／release Tasks。

## Task 29-1 — Historical Database Fixtures and Compatibility Harness

**Purpose:** 建立獨立於Drift schema的v1～v6舊資料庫fixtures、canonical schema report與expected migration結果。

**Files:**

- Create fixture builder、reporter、copy helper與fixture README。
- Create `drift_historical_migration_test.dart` skeleton，但此Task只測fixture integrity與current sqflite expected path。
- Modify no production source。

- [ ] **Step 1: Inventory current historical tests**

Read and map exact setup/data assertions from:

```txt
test/app/database/app_database_foreign_key_test.dart
test/features/auth/data/auth_single_active_user_persistence_test.dart
test/features/catalog/data/catalog_local_data_source_test.dart
```

Expected: a written matrix mapping v1～v6 schema/data cases to fixture seeds.

- [ ] **Step 2: Write fixture integrity tests first**

Create tests asserting each fixture exists, `PRAGMA user_version` matches filename, expected tables/indexes exist, and seeded sentinel rows are present.

Run:

```bash
cd apps/flutter_architecture
flutter test test/app/database/legacy_fixture_integrity_test.dart
```

Expected: FAIL because fixtures/support code do not exist.

- [ ] **Step 3: Implement legacy fixture builder**

Use `sqflite_common_ffi` test-only code to create each historical schema exactly from current migration history. Seed:

- v1 single-row and malformed multi-row AuthUser variants.
- v2 duplicate item positions and orphan-capable rows.
- v3 unique position index.
- v4 chain revisions and cursor cycle sample.
- v5 single-slot AuthUser.
- v6 current clean schema.

- [ ] **Step 4: Generate and track deterministic fixtures**

Run a repository script that deletes and recreates fixture files, then compare SHA/report output across two runs.

Expected: canonical reports identical; raw SQLite file hash may differ and is not the authority.

- [ ] **Step 5: Build schema report comparator**

Report normalized:

```txt
sqlite_master tables/indexes
table_info
foreign_key_list
index_list/index_info
user_version
foreign_key_check
selected sentinel data
```

- [ ] **Step 6: Validate current sqflite migrations against fixtures**

Copy each fixture to temp, open with current `AppDatabaseSchema`, migrate to v6, and save expected canonical report.

- [ ] **Step 7: Review and commit**

Validation:

```bash
dart run melos run docs_check
cd apps/flutter_architecture
flutter test test/app/database/legacy_fixture_integrity_test.dart
flutter test test/app/database/legacy_sqflite_expected_migration_test.dart
```

Commit:

```bash
git commit -m "test(database): 建立Drift歷史相容性fixtures"
```

## Task 29-2 — Drift Schema and Database Foundation

**Purpose:** 加入Drift dependencies、current v6 typed schema、database class與test-only executor，不切production DI。

- [ ] **Step 1: Resolve exact dependencies**

Use `dart pub add`／manual pubspec patch to add compatible stable versions of:

```yaml
dependencies:
  drift: <resolved stable>
  drift_flutter: <resolved stable>
dev_dependencies:
  drift_dev: <matching release line>
```

Add `drift_sqflite` only to dev/test scope if package constraints permit; if Flutter pub does not support dev-only runtime import needed by harness, document temporary dependency and removal gate.

- [ ] **Step 2: Write fresh-schema tests first**

Test exact table names, columns, PK order, FK cascade, unique index and check constraint using an in-memory Drift executor.

Expected initial FAIL: `AppDatabase` and tables missing.

- [ ] **Step 3: Define typed tables with explicit SQL names**

Implement explicit `$tableName`／column names and constraints. Use custom constraints where Drift DSL cannot emit byte-for-byte-equivalent SQL.

- [ ] **Step 4: Create `AppDatabase`**

Set `schemaVersion => 6`, constructor injection for tests, and `beforeOpen` foreign-key enable. Migration implementation remains minimal/failing for historical versions until Task 29-3.

- [ ] **Step 5: Generate code**

Run:

```bash
dart run melos run build_runner
```

Expected: generated `app_database.g.dart`, no unrelated generated diff.

- [ ] **Step 6: Run fresh schema tests**

Expected: current v6 schema report equals sqflite expected current schema.

- [ ] **Step 7: Commit**

```bash
git commit -m "feat(database): 建立Drift資料庫與schema基礎"
```

## Task 29-3 — Historical Migration Contract

**Purpose:** 讓Drift對v1～v6fixture執行完整等價migration。

- [ ] **Step 1: Enable failing migration matrix**

For each fixture copy, open with `AppDatabase`, assert v6 canonical report and sentinel data.

Expected: v1～v5 fail until migrations exist; v6 opens successfully.

- [ ] **Step 2: Implement versioned migration steps**

Implement exact transitions:

```txt
<2 create Catalog tables
2→3 dedupe position + unique index
<4 add chain_revision
<5 rebuild AuthUser with one-row-only preservation
<6 remove orphans
```

Use `customSelect`／`customStatement` for conditional inspection and cleanup where clearer than DSL.

- [ ] **Step 3: Add migration transaction and failure tests**

Inject a failing statement in test-only migration executor and assert no partially advanced `user_version`／schema.

- [ ] **Step 4: Add rollback compatibility test**

After Drift opens/migrates a v1～v6 copy without changing schema beyond v6, reopen the same file through sqflite and assert reads/cascade/index constraints still work.

- [ ] **Step 5: Validate all fixtures**

Run historical migration, schema equivalence, foreign key and rollback tests.

- [ ] **Step 6: Commit**

```bash
git commit -m "feat(database): 保留v1至v6歷史遷移契約"
```

## Task 29-4 — AuthUser Persistence Migration

**Purpose:** 以Drift DAO／adapter取代AuthUser sqflite implementation，保持package contract與lifecycle。

- [ ] **Step 1: Rewrite adapter tests against `AuthUserStore` contract**

Cover read/write/clear, slot check, replacement, database error mapping and malformed persisted state.

- [ ] **Step 2: Add `AuthUserDao`**

Expose only one-shot methods:

```dart
Future<AuthUserRow?> readActive();
Future<void> replaceActive({required String id, required String name});
Future<void> clearActive();
```

- [ ] **Step 3: Implement `DriftAuthUserStore`**

Map generated row to `auth.AuthUser`, preserve typed `AppException`, and never expose Drift outside App.

- [ ] **Step 4: Update DI tests using test-only `AppDatabase`**

Do not yet switch production opener; DI provider may be introduced behind an explicit test constructor/factory.

- [ ] **Step 5: Run Auth lifecycle regression**

Run all AuthUser, secure credential, local unlock, navigation and integration tests touching persistence.

- [ ] **Step 6: Commit**

```bash
git commit -m "refactor(auth): 將AuthUser persistence遷移至Drift"
```

## Task 29-5 — Catalog Offline Cache Migration

**Purpose:** 將Catalog SQL／transactions遷移至Drift，保留所有cursor-chain invariants。

- [ ] **Step 1: Freeze behavior tests**

Add explicit tests for first-page replacement rollback, append predecessor mismatch, chain revision monotonicity, cycle detection, duplicate position, orphan cleanup, malformed row cleanup and logout persistence.

- [ ] **Step 2: Add `CatalogCacheDao` primitives**

Provide typed page/item fetch, insert, delete and inspection operations. Do not move chain business decisions into generic DAO helpers.

- [ ] **Step 3: Rewrite `CatalogLocalDataSource` transaction bodies**

Use `AppDatabase.transaction`, typed selects/inserts and custom SQL only for complex cleanup. Maintain exact method signatures consumed by repository tests.

- [ ] **Step 4: Verify batch semantics**

If using `batch`, test duplicate item／position failure rolls back parent and all children. Otherwise retain per-row insert within transaction.

- [ ] **Step 5: Run Catalog regression**

Run data layer, local data source, repository cache, logout persistence, Bloc reconnect/SWR and integration tests.

- [ ] **Step 6: Commit**

```bash
git commit -m "refactor(catalog): 將Offline Cache遷移至Drift"
```

## Task 29-6 — Cross-platform Database Openers and Web Storage Disposition

**Purpose:** 建立native／Web production opener，完成同檔path與browser storage處置。

- [ ] **Step 1: Write opener contract tests**

Assert Android/iOS opener resolves exact `flutter_architecture.db`; Desktop resolves documented app documents path; database is created in background; close is idempotent.

- [ ] **Step 2: Implement native opener**

Use Drift native background executor with an explicit path callback. Do not use default `<name>.sqlite` filename.

- [ ] **Step 3: Investigate Web old storage**

Create an old sqflite Web build/profile fixture, record IndexedDB names/stores and database logical name, then test Drift opener against the same browser profile.

- [ ] **Step 4: Select and implement Web disposition**

Choose exactly one based on evidence:

```txt
in-place import
explicit reset
unsupported upgrade
```

Add automated browser/runtime evidence where possible and document manual steps where environment requires them.

- [ ] **Step 5: Replace Web assets**

Add matching `drift_worker.js` and `sqlite3.wasm`; keep `sqflite_sw.js` until Task 29-8 removal gate.

- [ ] **Step 6: Platform smoke**

Run host-capable native opener smoke and `flutter build web`. Record unavailable Windows/Linux host validation as explicit future runtime evidence requirements, not false passes.

- [ ] **Step 7: Commit**

```bash
git commit -m "feat(database): 建立Drift跨平台opener"
```

## Task 29-7 — Generated Code, Schema Snapshot and CI Governance

**Purpose:** 將Drift generation、schema snapshots、assets與classifier納入CI authority。

- [ ] **Step 1: Export tracked schema snapshots**

Configure Drift schema export and create versioned v1～v6/current artifacts used by migration tests.

- [ ] **Step 2: Add clean generation test**

Run build_runner from clean checkout and fail when generated diff remains.

- [ ] **Step 3: Extend change-aware classifier tests first**

Add failing cases for `.drift`, Drift Dart schema/DAO, schema snapshots, pubspec/lock, `sqlite3.wasm`, `drift_worker.js` and database tooling.

- [ ] **Step 4: Update classifier/workflows**

Database-critical changes trigger generation, analyze, tests and relevant platform builds. Docs-only behavior remains lightweight.

- [ ] **Step 5: Measure CI impact**

Record cold/warm generation and representative CI wall-clock in phase review.

- [ ] **Step 6: Commit**

```bash
git commit -m "ci(database): 納入Drift生成與schema治理"
```

## Task 29-8 — Production Single-owner Cutover and sqflite Authority Removal

**Purpose:** 在所有acceptance gate通過後，一次切換production DI並移除sqflite authority。

- [ ] **Step 1: Confirm cutover gate**

Require green v1～v6 migrations, Auth/Catalog parity, native opener, Web disposition, generated consistency and zero open P0/P1 without disposition.

- [ ] **Step 2: Switch Composition Root**

Replace `Future<Database>` provider with pre-resolved `AppDatabase`; inject DAO/adapter dependencies; update bootstrap close lifecycle.

- [ ] **Step 3: Regenerate injectable output**

Run build_runner and inspect generated DI for one `AppDatabase` singleton only.

- [ ] **Step 4: Remove legacy production source**

Delete `AppDatabaseSchema`, `database_initializer*.dart`, `SqfliteAuthUserStore` and direct sqflite imports.

- [ ] **Step 5: Remove dependencies/assets**

Remove `sqflite`, `sqflite_common_ffi`, `sqflite_common_ffi_web`, temporary `drift_sqflite` when no longer needed, and `sqflite_sw.js`. Keep fixture generation isolated through checked-in fixtures or a dedicated historical tool dependency only if governance review approves.

- [ ] **Step 6: Add no-sqflite authority guard**

CI/test grep production `lib/` for forbidden sqflite imports/API and fail on reintroduction.

- [ ] **Step 7: Update ADR and current docs**

Add canonical Drift persistence ADR, update ADR index, App/Auth/Catalog README, root README, AGENTS commands and project context.

- [ ] **Step 8: Commit**

```bash
git commit -m "feat(database): 切換Drift為唯一資料庫authority"
```

## Task 29-9 — Platform Runtime and Full Regression Validation

**Purpose:** 以production opener與release paths驗證cutover，不只依靠in-memory tests。

- [ ] **Step 1: Full repository verification**

Run:

```bash
dart pub get
dart run melos run build_runner
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture && flutter build bundle
```

- [ ] **Step 2: Android acceptance**

Install old sqflite build with seeded v1/v4/v6 data, upgrade to Drift build, verify AuthUser/Catalog data and run repository Android artifact build.

- [ ] **Step 3: iOS acceptance**

Use tracked Simulator workflow to seed old database, install/upgrade Drift build, verify same-file data and unsigned build.

- [ ] **Step 4: Web acceptance**

Execute selected storage disposition in browser, verify Wasm/worker load, reopen persistence and multi-tab behavior if worker sharing is enabled.

- [ ] **Step 5: Desktop matrix**

Run macOS opener/runtime locally. Run or document environment-blocked Windows/Linux builds according to repository platform policy.

- [ ] **Step 6: Write evidence**

Create `docs/audits/milestone_29/29-9_platform_runtime_regression.md` with commands, artifacts, runtime evidence, limitations and support claim disposition.

- [ ] **Step 7: Commit**

```bash
git commit -m "test(database): 完成Drift平台與回歸驗證"
```

## Task 29-10 — Holistic Final Review, Release and Post-release Validation

**Purpose:** 完成跨Task總審查、release、push與post-release validation。

- [ ] **Step 1: Milestone holistic review**

Review architecture direction, single authority, fixture provenance, schema equivalence, migration rollback, Auth/Catalog invariants, Web disposition, generated consistency and platform evidence.

- [ ] **Step 2: Fix all findings and re-review**

No release while Open P0 > 0 or P1 lacks disposition.

- [ ] **Step 3: Update release authority**

Update:

```txt
VERSION
CHANGELOG.md
docs/project_context.md
docs/roadmap.md
docs/roadmap/active.md
docs/milestones/README.md
docs/superpowers/README.md
```

Use a MINOR baseline release unless final review proves only PATCH semantics under repository policy.

- [ ] **Step 4: Final verification from clean state**

Re-run all standard commands, representative Android/iOS/Web builds and generated diff check.

- [ ] **Step 5: Release commit and push**

Use Conventional Commit in Traditional Chinese, then push `main` and confirm `main...origin/main = 0/0`.

- [ ] **Step 6: Post-release validation**

Validate remote CI, clean checkout dependency resolution, generation, tests, artifacts and upgrade fixture behavior. Record in `docs/audits/milestone_29/29-10_post_release_validation.md`.

## Plan acceptance matrix

| Requirement | Task |
|---|---|
| v1～v6 fixtures | 29-1 |
| Drift schema/database | 29-2 |
| Historical migration | 29-3 |
| AuthUser | 29-4 |
| Catalog | 29-5 |
| Native/Web/Desktop opener | 29-6 |
| Generated/schema/CI | 29-7 |
| sqflite authority removal | 29-8 |
| Platform runtime/regression | 29-9 |
| Holistic review/release/post-release | 29-10 |

## Final Plan disposition

```txt
Plan status: ACCEPTED
Production implementation started: NO
First implementation Task: 29-1
Cutover before Task 29-1 gate: PROHIBITED
Open P0: 0
Open P1 without disposition: 0
```

