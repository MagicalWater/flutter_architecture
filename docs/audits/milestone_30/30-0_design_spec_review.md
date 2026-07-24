---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-30-design-spec-review-evidence
last_reviewed_baseline: 1.11.0
---

# Milestone 30 Design Spec Review

## Scope

Review target：

- `docs/superpowers/specs/2026-07-24-milestone-30-test-suite-audit-rationalization-governance-design.md`

Review依據：

- Template Baseline 1.11.0 current source、tests、CI與Milestone 29 closure evidence。
- Repository-wide test audit：134 files、23,066 LOC、769 static cases。
- `兩層 Task 治理模型.md`的單一Task審查循環。

## Focused review findings

### F-30-0-01 — 不可把sqflite名稱直接視為刪除條件

Severity：P1

Disposition：Resolved。

Spec建立current production與historical harness雙分類，明定v1～v6 migration、rollback、fixture integrity與schema oracle必須保留；只有一般feature tests意外使用historical implementation時才Rewrite。

### F-30-0-02 — 跨層相似情境不等於重複coverage

Severity：P1

Disposition：Resolved。

Spec加入primary-owner principle，分離DAO persistence mechanics、Repository policy、Bloc orchestration與Widget rendering；只有責任與failure signal相同才可Reduce／Merge。

### F-30-0-03 — Shared contract extraction不可先於實際重複證據

Severity：P1

Disposition：Resolved。

Task順序改為先完成Auth／Catalog rationalization，再抽取已證明穩定的fixture與focused helper，禁止以generic framework作為Milestone成果。

### F-30-0-04 — 目前執行成本不足以支持nightly分流

Severity：P1

Disposition：Resolved。

Full Flutter workspace約20.54秒，Python contracts低於0.5秒。Spec維持快速deterministic tests於相關CI，只把platform build、historical tooling與external acceptance依責任分層。

### F-30-0-05 — Delete／Merge需要正式replacement evidence

Severity：P1

Disposition：Resolved。

Spec要求deletion manifest逐項記錄old coverage、reason、replacement owner、replacement test與validation，禁止只以「過期」、「重複」或檔案大小刪除。

### F-30-0-06 — 大型檔案不可只按LOC拆分

Severity：P2

Disposition：Resolved。

Spec改以責任、fixture lifecycle與failure domain作拆分標準，列出Auth與Catalog大型檔案的候選責任邊界，但不設機械式LOC上限。

## Re-review

- Goals與non-goals一致，沒有把case count下降當成功標準。
- Auth、Catalog、Database、CI／Platform與Preference coverage均有owner規則。
- Historical sqflite harness有明確保留與archive政策。
- Execution tiers不降低目前deterministic regression。
- Inventory、deletion manifest與長期governance各有authority。

## Whole-task holistic review

### Architecture

- App仍是唯一Composition Root。
- 測試重構不改變package dependency direction。
- Production Drift與historical sqflite責任分離。

### Safety

- Auth security、Catalog concurrency、migration／rollback、platform與generated coverage列為不可降低防線。
- Delete／Merge均要求replacement mapping與validation。

### Scope

- Milestone保持有界，不重建整套test framework。
- Task 30-2～30-11有清楚順序與gate。

## Documentation governance and authority

- 本Spec是Milestone 30 design authority。
- 本review保存planning findings，不取代Spec。
- Roadmap只更新active routing，不複製完整設計。
- 尚未提前宣稱test rationalization已完成。

## Validation

本Task只修改managed documentation，執行：

```txt
dart run melos run docs_check
```

## Final disposition

```txt
Design Spec: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Production tests modified: NO
Next Task: Milestone 30 Implementation Plan
```

