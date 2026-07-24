---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-7-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-7 — Drift Schema and CI Governance Review

## Scope

將Drift historical/current schema snapshots、worker generation、Wasm hash與
change-aware classifier納入tracked CI authority。

## Implemented

- 匯出`drift_schema_v1.json`～`drift_schema_v6.json`與
  `drift_schema_current.json`。
- 新增`tools/database/export_drift_schemas.sh`作為唯一schema export command。
- 擴充`verify_generated.sh`：build_runner後重新匯出schema、重建
  `drift_worker.js`、移除非tracked side artifacts並執行schema governance tests。
- 新增Wasm SHA-256、snapshot existence與minimum-size contract tests。
- classifier將以下路徑視為database-critical：
  - App database Dart／`.drift` source。
  - Drift schema snapshots。
  - `sqlite3.wasm`、`drift_worker.dart`、`drift_worker.js`。
  - database tooling與schema governance tests。
- database-critical change觸發full CI、Android build與iOS build；docs-only仍維持
  lightweight path。

## Focused Review Findings

### Finding 1 — Web assets與snapshot原本只跑full CI、不觸發platform builds

新增classifier tests後，Wasm、worker、schema snapshots與database tooling cases如預期
先失敗。

**Disposition:** 新增`_is_database_critical_path`並由Android／iOS classifier共用。

### Finding 2 — Historical Drift snapshots不存在

Schema governance test先對v1 snapshot失敗。

**Disposition:** drift_dev可直接從checked-in SQLite fixture dump schema，已匯出
v1～v6；current則由`AppDatabase` source dump。

## Focused Re-review

- 26項classifier／schema governance tests全部通過。
- Unknown path仍fail-safe full matrix。
- Docs-only分類未被database rules擴張。
- Snapshot exporter輸入只使用checked-in fixtures與canonical AppDatabase source。
- `verify_generated.sh`仍要求clean working tree，不會掩蓋既有dirty state。

## Whole-task Review

- Generated source、schema snapshots、worker與Wasm全部有reproducible authority。
- CI不依賴手動記得執行Drift schema export。
- Schema／DAO／asset變更均進入generation、analyze、tests與platform builds。
- No new platform support claim。

## Validation

- `python3 -m unittest tools.ci.test_change_classifier tools.ci.test_drift_schema_governance`：26 passed。
- `bash tools/database/export_drift_schemas.sh`：passed。
- `dart run melos run build_runner` cold：17.83s。
- `dart run melos run build_runner` warm：7.03s。
- `dart run melos run docs_check`：passed。
- `dart run melos run analyze`：passed。
- Clean checkout `bash tools/ci/verify_generated.sh`：pending post-commit clean-tree gate。

## Exit Criteria

- Open P0：0。
- Open P1 without disposition：0。
- Task 29-7：passed；clean-tree generated verification於commit後立即執行。
