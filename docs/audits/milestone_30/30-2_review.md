---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-task-30-2-review-evidence
last_reviewed_baseline: 1.11.0
---

# Task 30-2 Review — Test Inventory, Ownership and Baseline

## Focused review findings

### F-30-2-01 — Early inventory omitted Python and integration tests

Severity：P1

Disposition：Resolved。Tool明確納入tracked`test_*.py`與integration test Dart files，最終回復134 files／23,066 LOC／769 cases。

### F-30-2-02 — Static classification不可自動做 destructive disposition

Severity：P1

Disposition：Resolved。Tool只輸出Keep／Audit、Rewrite／Audit或Rewrite／Archive initial disposition；Delete必須等Task 30-9 replacement manifest。

### F-30-2-03 — Historical判斷不可只看`sqflite`

Severity：P1

Disposition：Resolved。只有明確historical／rollback／fixture／expected migration路徑先分類historical；一般Catalog data tests標記為current-with-historical-fixture，交由Task 30-3人工review。

### F-30-2-04 — Case counter必須可測且deterministic

Severity：P2

Disposition：Resolved。新增四個Python unit tests，涵蓋discovery、Dart cases、Python cases、repository-relative row與sorting。

## Focused re-review

- `python3 tools/testing/test_inventory.py`可重現exact baseline。
- CSV包含Spec要求的11個欄位。
- 所有tracked test files都有row與initial owner。
- Tool沒有修改或刪除任何既有test。

## Whole-task holistic review

- Inventory是current audit evidence，不取代各feature／package architecture authority。
- Classification保留人工review gate，沒有以heuristic直接執行cleanup。
- Runtime baseline證明目前主要問題是ownership與coupling，而非嚴重wall-time問題。

## Documentation authority check

- CSV保存machine-readable inventory。
- `30-2_test_inventory.md`保存baseline摘要與next action。
- 本review保存findings與disposition。
- Roadmap只更新next Task。

## Validation

```txt
python3 -m unittest tools.testing.test_test_inventory
→ 4 passed

python3 tools/testing/test_inventory.py
→ files=134 loc=23066 cases=769

dart run melos run docs_check
git diff --check
```

## Final disposition

```txt
Task 30-2: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Existing tests deleted: 0
Next Task: 30-3 Historical and Persistence Boundary Audit
```

