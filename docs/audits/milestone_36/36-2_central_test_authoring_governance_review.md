---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-36-task-36-2-central-authoring-governance
last_reviewed_baseline: 1.16.0
---

# Task 36-2 — Central Test Authoring Governance GREEN Review

## Scope

中央`governing-template-development`現在擁有唯一可執行Test Authoring Decision policy，並以`references/test-authoring.md`保存四種disposition與risk gate。

## Key contract

- Test Authoring Decision與Validation Execution Decision分離。
- TDD不等於每個Task／class／layer新增test。
- `Required`／`Recommended`／`no-new-test justified`／`Should-not-add`成為canonical dispositions。
- `0 new tests + planner-selected validation PASS`是合法Task outcome。
- Required security／persistence／migration／concurrency風險不能用no-new-test逃避。

## Review

- Central authority：PASS；policy只存在中央Skill reference，沒有把machine selection搬入Skill。
- Milestone 35 boundary：PASS；`validation_planner.py`責任未修改。
- Scope：PASS；未修改product source、feature tests或CI planner。
- Open P0：0。
- Open P1 without disposition：0。

## Validation

```txt
python -m unittest \
  tools.docs.test_test_authoring_governance.TestAuthoringGovernanceContract.test_central_skill_separates_authoring_from_validation \
  tools.docs.test_test_authoring_governance.TestAuthoringGovernanceContract.test_tdd_does_not_require_new_test_per_task
→ PASS (2/2)

python tools\docs\check_docs.py .
→ PASS

git diff --check
→ PASS
```

Task 36-2：ACCEPTED。
