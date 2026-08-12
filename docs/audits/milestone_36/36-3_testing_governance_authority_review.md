---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-36-task-36-3-testing-governance-authority
last_reviewed_baseline: 1.16.0
---

# Task 36-3 — Testing Governance Human Authority Alignment

## Scope

- `testing_governance.md`加入Foundation／Product Feature boundary與四種authoring disposition。
- 新增ADR-029，保存stable Risk-Based Test Authoring decision。
- ADR index擴充至ADR-029。

## Authority review

- Executable authoring policy仍由中央Skill擁有；Guide只提供human-readable semantics。
- ADR-029只擁有stable decision，不擁有Task sequencing或planner path mapping。
- ADR-023仍擁有Validation Execution；`validation_planner.py`沒有修改。
- Existing deletion／replacement governance沒有弱化。

Open P0：0。
Open P1 without disposition：0。

## Validation

```txt
python -m unittest \
  tools.docs.test_test_authoring_governance.TestAuthoringGovernanceContract.test_testing_governance_defines_four_dispositions \
  tools.docs.test_test_authoring_governance.TestAuthoringGovernanceContract.test_no_new_test_never_means_no_validation
→ PASS (2/2)

python tools\docs\check_docs.py .
→ PASS

git diff --check
→ PASS
```

Task 36-3：ACCEPTED。
