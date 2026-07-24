---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-platform-ci-documentation-generated-contract-audit
last_reviewed_baseline: 1.11.0
---

# Task 30-7 — Platform, CI, Documentation and Generated Contract Audit

## Scope

盤點repository內CI、workflow、platform scaffold、documentation checker與generated consistency tests，確認每項assertion的primary owner、跨檔重複、失敗訊號與保留理由。

## Primary ownership map

| Contract | Primary owner | Supporting owner | Disposition |
|---|---|---|---|
| Path與range分類、unknown／invalid fail-safe | `tools/ci/test_change_classifier.py` | workflow matrix contracts只驗證workflow有呼叫classifier | Keep |
| Workflow classifier執行失敗時full-matrix fallback | `tools/ci/test_environment_workflow_matrix_contract.py` | classifier unit tests驗證分類器自身fail-safe | Keep both，責任不同 |
| Required job names與internal no-op | `tools/ci/test_environment_workflow_matrix_contract.py` | `test_ios_workflow_contract.py`只擁有iOS simulator gate name | Keep |
| Execution mode、trusted labels與self-hosted policy | `tools/ci/test_ci_execution_mode_contract.py` | workflows是被驗證對象 | Keep |
| iOS workflow permissions、toolchain、artifact與CocoaPods compatibility | `tools/ci/test_ios_workflow_contract.py` | environment matrix只驗證跨workflow matrix | Keep |
| Android／iOS observability build integration | platform-specific observability contract tests | acceptance workflow只驗證remote evidence gate | Keep |
| Environment manifest與native projection | `tools/ci/test_environment_contract.py` | workflow matrix驗證quality gate有執行它 | Keep |
| Generated Dart、Drift snapshots、Wasm與worker一致性 | `tools/ci/verify_generated.sh`＋`test_drift_schema_governance.py` | shell portability只驗證script可在macOS Bash 3執行 | Keep |
| Production source不得恢復sqflite authority | `tools/ci/test_no_sqflite_authority.py` | historical fixture tests不屬此owner | Keep |
| Documentation metadata、ADR graph、link與baseline | `tools/docs/test_check_docs.py` | `docs_check` runner執行current repository scan | Keep |
| Android／iOS native identity與plugin setup | App platform Dart contract tests | workflow tests不取代native scaffold inspection | Keep |

## Duplicate review

### Change classifier與workflow matrix

兩者都出現`change_classifier.py`與fail-safe文字，但失敗訊號不同：

- classifier tests驗證Python classification result與CLI output。
- workflow matrix tests驗證三份GitHub workflow確實呼叫classifier，且shell failure branch寫入full-matrix outputs。

刪除任一側都會留下boundary hole，因此不視為可刪重複。

### iOS workflow與environment workflow matrix

重疊只限stable simulator job name與classifier presence：

- matrix owner確保跨CI／Android／iOS matrix一致。
- iOS owner確保permissions、exact toolchain、concurrency、artifact、dependency manager與iOS-specific no-op behavior。

現有檔案loading與section extraction各自簡短，未證明需要新增`workflow_contract.py`或YAML DSL。

### Generated contracts

`verify_generated.sh`負責實際重新生成與diff；`test_drift_schema_governance.py`負責snapshot／Wasm asset存在與版本；`test_shell_portability_contract.py`負責script portability。三者是execution、artifact與shell boundary，不可合併成單一string assertion。

## Platform ownership

四個App platform tests維持current owner：

- Android application／native baseline。
- iOS identifier、Face ID、Keychain與build scripts。
- local_auth Android setup。
- secure storage Android security contract。

它們不與CI workflow tests重複，因為前者檢查repository native scaffold，後者檢查automation routing。

## Execution result

- CI Python contracts：88 tests passed，約0.36秒。
- Documentation checker unit tests：15 tests passed，約0.07秒。
- App platform Dart contracts：6 tests passed。
- Generated consistency：build runner、Drift schema v1～v6/current export、Web worker compile、Wasm governance與clean diff全部通過。

## Disposition

- Delete：0。
- Merge：0。
- Rewrite：0。
- Shared workflow parser：不建立，缺乏維護收益證據。
- Keep：所有current gates；每項已有primary owner與清楚supporting boundary。

本Task的成果是消除「看似重複」的ownership ambiguity，而不是為了產生diff強行刪除有效防線。
