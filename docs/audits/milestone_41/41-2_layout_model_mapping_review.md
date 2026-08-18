---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-2-layout-model-mapping
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-2 Layout Model Mapping Review

## Scope

擴充 initiative-local Pencil implementation mapping，使 accepted screen root 在 production mapping 前必須有 machine-readable layout model；不建立 global layout registry，也不解析 `.pen`。

## Machine contract

`implementation_mapping.json` schema 升為 `2`，新增 `screen_layouts`。Layout model vocabulary：

```txt
constraint-relationship
intentional-spatial-canvas
unresolved
```

Rules：

- `screen_layouts` 缺失或空集合：FAIL。
- `unresolved` 在 production acceptance：FAIL。
- `intentional-spatial-canvas` 無 accepted approval reference：FAIL。
- resolved layout 無 evidence reference：FAIL。
- current tracked proof 已 migration 到 schema 2；不回填 historical artifacts。

## Test Authoring Decision

Required。新增 direct validator owners 驗證 missing layout、unresolved、spatial approval 與 accepted spatial exception。

## Fresh validation

```txt
python -m unittest tools.visual.test_pencil_implementation_mapping
14 tests PASS
```

## Review

Focused review確認 layout model 與 representation disposition 分工：前者擁有 screen page-layout semantics，後者維持 icon／asset／typography／drawing identity，不互相覆蓋。

```txt
Open P0: 0
Open P1 without disposition: 0
Task 41-2: PASS
```
