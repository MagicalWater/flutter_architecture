---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-36-task-36-1-red-contract
last_reviewed_baseline: 1.16.0
---

# Task 36-1 — Test Authoring Decision Contract RED

## Purpose

先鎖定Milestone 36 accepted Design要求的authoring behavior，證明current central governance在Corrective前會失敗；本Task不先修改GREEN policy。

## RED contract

新增`tools/docs/test_test_authoring_governance.py`，要求：

- 中央Skill明確分開Test Authoring Decision與Validation Execution Decision。
- TDD不得等價為每Task新增test，雙層Task允許`0 new tests`。
- Feature Guide不得要求逐層最低測試配額，且reference feature不是test-density reference。
- Testing Governance具有四種authoring disposition。
- `no-new-test justified`不得被解讀為no validation。

Pressure scenarios新增trivial passthrough、existing-owner coverage、high-risk no-test escape與reference-density imitation controls。

## Expected RED

Current 1.16.0 authority尚未包含上述完整contract，因此focused unittest在Task 36-2 GREEN前**必須失敗**。此失敗是本Task的預期RED evidence，不宣稱central policy已完成。

## Fresh RED execution

```txt
python -m unittest tools.docs.test_test_authoring_governance
Ran 5 tests in 0.028s
FAILED (failures=5)
```

五個failure分別證明：

1. central Skill沒有Test Authoring Decision／Validation Execution Decision分離與`no-new-test justified`。
2. TDD／雙層Task沒有「每Task不必新增test／0 new tests」contract。
3. Feature Guide仍有`至少依實際變更覆蓋`逐層清單，且沒有test-density reference限制。
4. Testing Governance沒有四種authoring dispositions。
5. Testing Governance沒有`no-new-test justified ≠ no validation`規則。

RED與accepted Design一一對應，沒有依賴production source或Milestone 35 planner mutation。

## Review

- Focused review：PASS；tests只驗證stable governance wording／authority，不推測feature implementation細節。
- Whole-Task review：PASS；RED failures都是預期contract gap，不是環境或test harness failure。
- Open P0：0。
- Open P1 without disposition：0。

## Task state

```txt
Task 36-1: ACCEPTED RED
Focused contract result: EXPECTED FAIL (5/5)
Production feature mutation: NO
Next: Task 36-2 Central Test Authoring Governance GREEN
```
