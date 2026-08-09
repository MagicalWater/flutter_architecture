---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-1-validation-planner-contract-red
last_reviewed_baseline: 1.15.2
---

# Task 35-1 — Validation Planner Contract RED Review

## Scope

Task 35-1只建立corrective RED contract，不修改production routing、classifier implementation、CI workflow或validation semantics。

Files：

- `tools/ci/test_validation_planner.py`
- `tools/ci/test_change_classifier.py`
- 本review evidence。

Admission base：

```txt
branch: milestone-35-validation-governance
managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-65b293eb
execution admission commit: 6dc8a0d
accepted Plan base: b28f4692c9a3d6546b903dac1b41601dedc735b2
```

## RED evidence

Command：

```powershell
python -m unittest tools.ci.test_validation_planner
```

Observed：

```txt
Ran 3 tests
2 PASS
1 expected FAIL

Expected failure:
Milestone 35 expected RED: tools.ci.validation_planner is missing;
the deterministic Minimum Sufficient Validation planner has not been implemented yet.
```

兩個GREEN assertions同時鎖定current over-validation：

- ordinary App feature source → `full_ci=true`, `android_build=true`, `ios_build=true`。
- package source → `full_ci=true`, `android_build=true`, `ios_build=true`。

這些是corrective baseline evidence，不是target behavior。

## Existing fail-safe regression

Command：

```powershell
python -m unittest tools.ci.test_change_classifier
```

Result：

```txt
Ran 24 tests
OK
```

因此unknown path、invalid range、manual dispatch、VERSION、native與database-critical既有contract在Task 35-1仍GREEN。

## Focused review findings

### F-35-1-01 — Missing-module RED不得吞掉nested dependency failure

Severity：P2。

初始RED以任何`ModuleNotFoundError`都解讀為planner尚不存在；未來若planner存在但其內部import缺失，會產生誤導。

Disposition：Resolved。只在`error.name == "tools.ci.validation_planner"`時轉為expected RED；其他missing dependency重新raise。

### F-35-1-02 — RED不得修改舊assertion來假裝新behavior已存在

Severity：P1 design guard。

Disposition：PASS。`test_change_classifier.py`只加強current reason evidence；沒有把現有full-ci expectations改成target GREEN。Target semantics留給Task 35-2。

## Fresh focused re-review

收緊missing-module判斷後重新執行RED，預期仍應只有planner missing contract失敗；existing classifier suite仍須保持GREEN。

## Whole-Task review

- Canonical scenario corpus已包含docs、governance、tooling、test-only、feature、shared app、package、generated、database、Android、iOS、dependency、validation engine、unknown、release與mixed change。
- Expected planner schema欄位已完整鎖定。
- Current ordinary feature／package over-escalation已有explicit evidence。
- Existing fail-safe沒有被弱化。
- 尚未建立`validation_planner.py`，也未修改production routing。

Open P0：0。

Open P1 without disposition：0。

## Documentation authority check

本Task只新增phase evidence，不修改Testing Governance、ADR-023、AGENTS、Guide或historical Milestone 30 authority。

## Required validation

Task completion前fresh執行：

```txt
python -m unittest tools.ci.test_validation_planner → expected RED only (3 tests / 2 PASS / 1 expected FAIL)
python -m unittest tools.ci.test_change_classifier → PASS (24 tests)
python tools/docs/check_docs.py . → PASS
git diff --check → PASS
```

## Disposition

```txt
Task 35-1: ACCEPTED RED CONTRACT
Production routing changed: NO
Open P0: 0
Open P1 without disposition: 0
Next task after commit: 35-2 Change Classification + Validation Planner GREEN
```

