---
document_type: phase-review
status: accepted
authoritative_for:
  - r4-test-inventory-external-output-tdd-review
last_reviewed_baseline: 1.14.0
---

# R4-1 — Test Inventory External Output TDD Review

## RED Evidence

`tools/testing/test_test_inventory.py`先import並測試`display_output_path`與external CLI。Production helper尚未存在時fresh失敗：

```txt
ImportError: cannot import name 'display_output_path'
```

另外pre-fix CLI reproduction為：

```txt
Exit: 1
CSV created: Yes
Failure: output.relative_to(root) ValueError
```

## GREEN Implementation

- 新增pure `display_output_path(output, root)`。
- Root內output回傳`relative_to(root).as_posix()`。
- Root外output回傳resolved absolute path。
- `main()`只替換summary display expression；discovery、classification、rows與CSV schema未變。

## Focused Findings

### F-R4-1-01 — Root內Windows path必須維持跨平台summary格式

- Severity：P2。
- Status：Resolved。
- Fix：root內使用`as_posix()`，regression要求`build/r4-inventory.csv`。

### F-R4-1-02 — External regression必須驗證file與stdout，而非只看exit

- Severity：P2。
- Status：Resolved。
- Fix：subprocess test同時assert return code 0、CSV存在與stdout含resolved absolute path。

## Validation

```txt
Inventory unit／CLI tests: 7 passed
External CLI: exit 0
Internal CLI: exit 0
External inventory: 146 files / 25,988 LOC / 896 cases
Internal inventory: 146 files / 25,988 LOC / 896 cases
Tracked M30 inventory pre-hash: 1b2bb28b391d0bb73f47b283e5308fc558a3c920
Tracked M30 inventory current hash: 1b2bb28b391d0bb73f47b283e5308fc558a3c920
git diff --check: PASSED
```

## Whole-Task Review

- Production diff限制為11行helper與summary call。
- Test discovery／metadata／CSV fields沒有改動。
- Temporary outputs已刪除。
- Tracked baseline未變。
- No docs authority、runtime、platform或integration變更。

## Disposition

```txt
Focused review: PASSED after two findings
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
R4-2 allowed: YES after independent commit
```
