---
document_type: phase-review
status: accepted
authoritative_for:
  - change-aware-ci-task-3-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Task 3 — Android Workflow Review

## Scope

本review審查：

- `.github/workflows/android.yml`
- `tools/ci/test_environment_workflow_matrix_contract.py`
- Task 1 change classifier contract
- Task 3 implementation plan與Android artifact既有contract

## TDD Evidence

RED階段新增Android classification、job condition、fallback與summary contracts。現有workflow因沒有`classify-changes`與`android-summary`而失敗，證明tests覆蓋新行為而非既有狀態。

GREEN階段加入：

- Ubuntu change classification job與full-history checkout。
- Classifier execution failure的full-matrix fallback。
- Development Debug與Production Release兩個job的`android_build=true`條件。
- `Android / Summary`的skip／success／failure aggregation。

## Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-T3-R01 | P1 | Android build jobs可合理skipped，但若只依GitHub workflow整體狀態，新增summary可能在build failure後仍成功而掩蓋requested build failure | Summary使用`if: always()`讀取classification與兩個job result；要求build時任一job非`success`即`exit 1` |
| CA-CI-T3-R02 | P1 | Classifier CLI若在Android workflow內崩潰，不能讓兩個build jobs因缺少outputs而skipped | 與CI workflow一致，non-zero execution寫入`android_build=true`與完整fail-safe outputs |
| CA-CI-T3-R03 | P2 | Docs-only時summary必須能區分合理skip與非預期job execution | `android_build=false`時要求兩個build result均為`skipped`，否則summary失敗 |

## Re-review

- Android workflow仍只在`main` push與manual dispatch建立，沒有擴張PR required checks。
- Development Debug與Release APK名稱、scripts、SHA-scoped artifact名稱與14天retention均保留。
- Docs-only只使用classification與summary Ubuntu jobs，不setup Java／Flutter、不建立artifact。
- `VERSION`、manual dispatch、invalid range與classifier execution failure均使`android_build=true`。
- Summary不會吞掉classification或requested build failure。
- Workflow沒有讀取signing／Store secrets，external Actions維持full SHA pin。
- YAML parser與相關contracts通過。

## Verification

```txt
Change classifier + workflow matrix contracts: 30 passed
Android workflow YAML parse: passed
Open P0: 0
Open P1 without disposition: 0
```

## Gate

```txt
Task 3 status: Completed / Reviewed
Task 4 allowed: Yes
```

