---
document_type: phase-review
status: accepted
authoritative_for:
  - change-aware-ci-task-4-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Task 4 — iOS Workflow Review

## Scope

本review審查：

- `.github/workflows/ios.yml`
- `tools/ci/test_environment_workflow_matrix_contract.py`
- `tools/ci/test_ios_workflow_contract.py`
- Task 1 change classifier contract
- Task 4 implementation plan與既有iOS artifact／diagnostics contract

## TDD Evidence

RED：

- iOS workflow沒有`Classify Changes`job。
- `Simulator Build`固定使用`macos-15`。
- Simulator toolchain、contract、build與artifact steps沒有`ios_build`條件。
- Production Release job沒有change-aware job-level condition。
- Classifier execution failure沒有full-matrix fallback。

GREEN：

- 新增Ubuntu classification job與五個classifier outputs。
- `Simulator Build`名稱維持不變且永遠建立。
- `ios_build=true`使用`macos-15`；否則使用`ubuntu-24.04`。
- Docs-only路徑只執行同job no-op，不setup Flutter、不執行Xcode／CocoaPods、不上傳artifact。
- Production Release job只有`ios_build=true`時建立macOS job。
- Classifier execution failure回退完整矩陣。

## Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-T4-R01 | P1 | Required-check候選`iOS / Simulator Build`若整個job skipped，Branch Protection status語意不可靠 | 保留原job名稱並永遠建立；docs-only改用Ubuntu runner在同job執行no-op |
| CA-CI-T4-R02 | P1 | Classifier Python若非零退出，可能讓iOS build被錯誤略過 | classification shell加入fail-safe outputs，強制`full_ci`、Android與iOS build為true |
| CA-CI-T4-R03 | P1 | Docs-only若只切換runner但未guard全部macOS/toolchain steps，Ubuntu no-op仍會執行不相容命令或artifact upload | Checkout、toolchain、cache、diagnostics、contracts、build與artifact steps全部使用`ios_build=true` step condition |
| CA-CI-T4-R04 | P2 | 初版contract未明確驗證failure diagnostics也受`ios_build=true`保護 | 將`Upload iOS failure diagnostics`加入docs-only guarded-step regression |

## Re-review

- `Simulator Build`沒有job-level `if:`，stable check名稱不漂移。
- Dynamic runner expression只在需要build時啟動`macos-15`。
- Docs-only路徑只使用Ubuntu並成功執行no-op。
- Production Release job在docs-only時skipped，不啟動macOS。
- Development／production artifact名稱、SHA traceability與retention維持不變。
- Failure diagnostics仍只在實際iOS build失敗時上傳，retention維持7天。
- External Actions仍使用full SHA pin，permissions與secret boundary未改變。

## Validation

```txt
Focused classifier / workflow / iOS contracts: PASS
iOS workflow YAML parse: PASS
Documentation check: PASS
git diff --check: PASS
```

## Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Task 4 status: Completed / Reviewed
Task 5 allowed: Yes
```
