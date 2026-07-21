---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-1-checker-index-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-1 — Checker and ADR Index Foundation Review

## Scope

本 Task 建立 migration-aware ADR index 與 machine-verifiable integrity foundation，不擷取 Decision 正文、不切換 authority，也不要求 staged migration 期間立即具備 22 個 canonical ADR files。

## Implemented Contract

`tools/docs/check_docs.py` 現在檢查：

- canonical ADR `id` 必須使用 `ADR-NNN`。
- canonical filename 必須使用 `adr-NNN-<kebab-title>.md`，且編號與 ID 一致。
- `extracted` index row 指向的 ADR file 必須存在。
- canonical ADR file 必須在 index 中標記為 `extracted`，避免 orphan record。
- supersession target 必須存在。
- `supersedes` 與 `superseded_by` 必須 reciprocal。
- supersession relation 禁止 self edge與 cycle。
- `superseded` status 必須至少有一個 `superseded_by` target。

Checker只解析 YAML metadata、canonical filename與 index table，不分析 ADR prose，也不替代 semantic review。

## Migration-aware Behavior

`docs/adr/README.md` 已建立 Decision 001–022 skeleton：

```txt
22 rows = aggregate
0 rows = extracted
```

`aggregate` row不要求 canonical file，因此 Task 23-2至23-7可以逐批遷移。22／22 full extracted coverage只會在 Task 23-8 authority cutover前以獨立 RED test啟用。

Aggregate authority仍是：

```txt
docs/architecture_decisions.md
```

本 Task沒有修改或刪除 aggregate正文，也沒有改寫 legacy `000-*` 至 `005-*` placeholders。

## TDD Evidence

新增 fixture涵蓋：

- invalid ADR ID。
- ID／filename mismatch。
- missing extracted target。
- orphan canonical file。
- aggregate migration row allowance。
- missing target、non-reciprocal edge、self edge。
- supersession cycle。
- superseded without successor。

首次執行新增 tests 時，4 組 test method失敗，原因是 checker尚未提供 ADR validation；加入最小 implementation後全部通過。

## Immediate Review

### Correctness

- Parser只接受 canonical `adr-*.md`，不會把既有 legacy `000-*` placeholders誤判為 canonical ADR。
- Graph只由實際存在且具合法 `ADR-NNN` ID的 canonical records建立。
- Index `aggregate` row不產生 missing-file error，符合 staged migration gate。
- Index `extracted` row與 orphan file採雙向 coverage，避免只檢查其中一側。

### Scope

- 沒有啟用 full 22／22 extracted coverage。
- 沒有建立 ADR-001至ADR-022正文。
- 沒有修改 production runtime、dependencies或 platform configuration。
- 沒有提前處理 legacy routing cutover。

### Findings

| Finding | Severity | Disposition |
|---|---:|---|
| 23-1-F01 Invalid ID fixture originally combined two independent failures | P3 | Fixture拆為兩個 canonical files後 re-review通過 |
| 23-1-F02 Full coverage would block staged extraction | P1 | `aggregate` state明確豁免 missing canonical file；Task 23-8才啟用 full coverage |

Open P0／P1：0。

## Verification

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed
```

## Decision

Task 23-1 implementation與 immediate review通過。下一個允許執行的 Task是 23-2 Batch A Foundation Contracts；每個 ADR仍須逐一完成 semantic preservation review後才能切換 index row。
