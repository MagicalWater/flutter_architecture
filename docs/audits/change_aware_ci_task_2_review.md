---
document_type: phase-review
status: accepted
authoritative_for:
  - change-aware-ci-task-2-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Task 2 Review

## Scope

本review審查Task 2的repository CI change-aware execution：

- `.github/workflows/ci.yml`
- `tools/ci/test_environment_workflow_matrix_contract.py`
- Task 1 classifier CLI integration
- `CI / Quality`、`CI / Generated Consistency`與`CI / Tests`required-check語意

## TDD Evidence

新增workflow contracts後，既有workflow以三項預期failure進入RED：

- 缺少`Classify Changes`job與classifier wiring。
- Generated Consistency與Tests缺少stable-job internal no-op。
- Analyze沒有依`full_ci`分類執行。

完成最小implementation後，contract tests通過；首次YAML parser檢查發現no-op inline command包含冒號而無法解析，修正為block scalar後重新通過。

## Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-T2-R01 | P1 | Classifier Python若非零退出，classification job會失敗，後續required jobs因`needs`被skipped，未符合classification failure fail-safe full matrix | 先新增failing workflow contract，再於classification step加入shell fallback，非零退出時寫入`full_ci=true`、Android／iOS build true與明確reason；re-review通過 |
| CA-CI-T2-R02 | P1 | 初版no-op `run:`使用含冒號的plain scalar，Ruby YAML parser拒絕workflow | 改為block scalar，YAML parser重新通過 |

## Final Contract

- `Classify Changes`使用Ubuntu與`fetch-depth: 0`。
- PR比較base／head SHA，push比較before／current SHA，manual dispatch由classifier強制full matrix。
- `CI / Quality`永遠執行documentation、workflow contracts與whitespace。
- Flutter／Java setup、dependency resolution與analyze只在`full_ci=true`執行。
- `CI / Generated Consistency`與`CI / Tests`job永遠建立；docs-only在原job內no-op成功，不建立替代Gate。
- Classifier execution failure由workflow shell fallback轉為full matrix，不會默默略過required work。
- Docs-only quality path直接執行repository Python documentation checker，不需要啟動Flutter toolchain。

## Verification

```txt
Change classifier + workflow contracts: 26 passed
Focused CI-related contracts: 39 passed
CI YAML parse: passed
git diff --check: passed
```

## Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Task 2 status: Completed / Reviewed
Task 3 allowed: Yes
```

