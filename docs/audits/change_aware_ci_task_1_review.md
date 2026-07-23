---
document_type: phase-review
status: accepted
authoritative_for:
  - change-aware-ci-task-1-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Task 1 — Change Classifier Contract Review

## Scope

本review審查：

- `tools/ci/change_classifier.py`
- `tools/ci/test_change_classifier.py`
- `docs/superpowers/plans/2026-07-23-change-aware-ci-execution.md` Task 1

## TDD Evidence

RED：

```txt
ModuleNotFoundError: No module named 'tools.ci.change_classifier'
```

GREEN後focused suite通過15 tests；review finding修正後通過16 tests。

## Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-T1-R01 | P2 | 初版tests覆蓋path API與Git range，但未以subprocess驗證CLI GitHub output格式 | 新增manual dispatch CLI contract test，逐項驗證五個boolean outputs與非空reason |

## Contract Review

- Documentation-only只在全部path均為managed documentation時成立。
- `VERSION`與manual dispatch強制完整矩陣並設定`release_full=true`。
- Empty diff、all-zero base、missing Git object、unknown path與Git failure均fail-safe完整矩陣。
- Dart App source與packages觸發兩平台；Android／iOS native path只觸發相關平台。
- Classifier、classifier test與workflow classification wiring變更強制兩平台build。
- 一般`tools/**`變更執行full CI，但不無條件啟動平台build。
- GitHub output值使用小寫boolean，reason移除newline，不輸出shell command。
- 實作相容repository目前Python 3.9 host。

## Verification

```txt
python3 -m unittest tools.ci.test_change_classifier -v
python3 -m unittest tools.ci.test_change_classifier tools.ci.test_environment_workflow_matrix_contract tools.ci.test_shell_portability_contract -v
python3 -m py_compile tools/ci/change_classifier.py tools/ci/test_change_classifier.py
git diff --check
```

全部通過。

## Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Task 1 status: Completed / Reviewed
Task 2 allowed: Yes
```
