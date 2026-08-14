---
document_type: phase-review
status: active
authoritative_for:
  - milestone-38-task-38-6-ci-profile-runtime-contract
last_reviewed_baseline: 1.18.0
---

# Task 38-6 — CI Profile Runtime Contract & Public/Trusted Runner Safety Review

## Scope

重新驗證`manual-local`、`self-hosted`、`github-hosted`三種execution profile與current workflows的machine contract，修正Milestone 37公開倉庫corrective後留下的stale test owner。

## Test Authoring Disposition

**Required** for新failure modes；優先擴充existing `test_ci_execution_mode_contract.py` owner，不按workflow建立重複test files。

## Finding / Corrective

額外`tools/ci` holistic probe在Task 38-5發現：existing test仍要求literal `vars.CI_EXECUTION_MODE == 'github-hosted'`，但current public-compatible workflow已改為`contains([self-hosted, github-hosted], vars.CI_EXECUTION_MODE)`以允許PR classifier安全啟動並在runner selection層阻止trusted self-hosted PR。

此finding為stale test expectation，不是workflow runtime regression。Test已改為鎖定current combined-mode expression與PR denial invariant。

## Runtime Contract Review

- Missing／empty／legacy／unknown repository execution mode仍由`resolve_execution_mode` fail closed。
- PR classifier可在public/untrusted PR建立，但trusted self-hosted runner只能由main push或explicit manual dispatch選中。
- Workflows不存在runner-offline → github-hosted fallback route；self-hosted runner offline時保持queued/blocked semantic。
- CI／Android／iOS verification workflows不讀`${{ secrets.* }}`，因此`github-hosted` verification不依賴production signing/provider secrets。
- Observability provider secrets仍只存在explicit trusted `workflow_dispatch` remote-acceptance jobs；PR-safe path不讀secret。
- Artifact transport contract仍由existing tests鎖定，repository default為local/no-remote transport語意；GitHub upload只有explicit manual exception paths。
- Repository-owned direct third-party Actions refs仍由public security contract要求immutable full SHA。
- Open P0：0。
- Undisposed P1：0。

## Validation

- `python -m unittest discover -s tools/ci -p "test_*.py"`：PASS，263 tests。
- planner-selected completion validation與docs check待fresh執行。
