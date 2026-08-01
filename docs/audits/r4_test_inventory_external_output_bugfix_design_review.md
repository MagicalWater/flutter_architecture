---
document_type: planning-review
status: accepted
authoritative_for:
  - r4-test-inventory-external-output-bugfix-design-review
last_reviewed_baseline: 1.14.0
---

# R4 — Test Inventory External Output Bugfix Design Review

## Reproduction Evidence

```txt
Command: python tools/testing/inventory.py --root . --output <system-temp>/flutter-architecture-r4-red.csv
Exit: 1
CSV created: Yes
Failure: Path.relative_to(root) ValueError during summary
```

## Focused Findings

### F-R4-D01 — Inline catch不利於path behavior獨立測試

- Severity：P2。
- Status：Resolved in Design。
- Fix：新增pure `display_output_path` helper。

### F-R4-D02 — 修summary不可改inventory semantics

- Severity：P1。
- Status：Resolved in Design。
- Fix：Scope明確禁止discovery、classification、CSV schema與tracked baseline mutation；驗收包含baseline hash。

### F-R4-D03 — External output成功後仍需證明CLI stdout

- Severity：P2。
- Status：Resolved in Design。
- Fix：加入subprocess regression，驗證exit、file與absolute path summary。

## Whole-Design Review

- Problem、expected behavior與test oracle明確。
- Pure helper是最小修改，沒有generic path abstraction。
- Tooling-only變更不需要ADR、Flutter tests或platform build。
- R5與integration明確排除。

## Disposition

```txt
Focused review: PASSED after three findings
Whole-Design review: PASSED
Open P0: 0
Open P1 without disposition: 0
Design status: ACCEPTED
Implementation allowed: NO — accepted Plan required
```
