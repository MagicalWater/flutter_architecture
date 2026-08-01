---
document_type: design-spec
status: accepted
authoritative_for:
  - r4-test-inventory-external-output-bugfix-design
last_reviewed_baseline: 1.14.0
---

# R4 — Test Inventory External Output Bugfix Design

## Requirement Decision

- Request：修復`F-A6-01`，讓test inventory CLI可輸出至repository外absolute path。
- Problem：CLI先成功寫CSV，之後`output.relative_to(root)`拋`ValueError`並exit 1。
- Expected behavior：root內output在summary顯示relative path；root外output顯示resolved absolute path；兩者皆exit 0。
- Value：Audit、CI與維護腳本可安全使用system temp output，不會false failure或留下語意不明的已寫檔。
- Classification：Level 2 — Bounded tooling bugfix。
- Decision：Accept。
- Scope：`tools/testing/inventory.py`、對應unit tests、R4 review evidence、central finding與必要routing。
- Non-goals：不改test discovery、classification、metadata、CSV schema或tracked M30 baseline；不處理R5；不merge、不push、不release。
- Design Spec required：Yes，採短型formal Design以維持Level 2 standard governance。
- Implementation Plan required：Yes。
- ADR required：No。
- Task governance：Standard。
- Regression：inventory unit tests、system-temp CLI、tracked baseline hash、docs checks。
- Release：No。

## User Authorization

使用者於2026-08-01授權沒有新decision時自動完成remaining remediation tasks。R4只有一個由confirmed failure唯一導出的behavior，standing authorization適用；integration仍未授權。

## Behavioral Contract

新增pure helper：

```python
def display_output_path(output: Path, root: Path) -> str:
    ...
```

規則：

1. `output`與`root`都先resolve。
2. output位於root內：回傳POSIX-style relative path。
3. output位於root外：回傳resolved absolute path字串。
4. helper不建立檔案、不吞其他I/O錯誤。
5. `main()`只用helper產生summary；write順序與CSV內容不變。

## Considered Approaches

### A — Catch ValueError inline

可修bug，但path policy不可獨立測試，main仍混合format與execution。

**Rejected。**

### B — Small pure display helper

可直接TDD root內／root外／relative input，改動最小且不碰inventory semantics。

**Selected。**

### C — 強制output必須在root內

與accepted Audit Plan及system-temp使用目的衝突。

**Rejected。**

## TDD Contract

RED tests：

- root內output回傳`tmp/inventory.csv`。
- root外output回傳resolved absolute path。
- CLI以system-temp output exit 0、file存在、stdout含absolute path。

GREEN只允許新增helper與替換summary expression。

## Acceptance Criteria

- New unit／CLI regression先RED後GREEN。
- Existing inventory tests全部通過。
- System-temp command exit 0。
- CSV仍包含current repository inventory。
- Tracked `docs/audits/milestone_30/30-2_test_inventory.csv` hash不變。
- `F-A6-01` Resolved by R4；`F-A1-04`保持Open。
- 未merge、未push、未release。

## Approval Closure

```txt
Focused Design review: PASSED
Whole-Design review: PASSED
Open P0: 0
Open P1 without disposition: 0
User authorization: standing authorization on 2026-08-01
Design status: ACCEPTED
```
