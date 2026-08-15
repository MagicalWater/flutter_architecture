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

Task 38-7 isolated `manual-local` acceptance另外發現root `repository_infrastructure.json`尚未被change classifier辨識，導致單獨產品化infrastructure manifest時被誤判為`unknown`並fail-safe full matrix。這是Milestone 38新增machine authority未同步到validation routing的governance gap，因此Task 38-6重新開啟corrective：

- `repository_infrastructure.json`納入governance path classification；
- existing change-classifier與validation-planner owners新增direct RED／GREEN coverage；
- manifest-only change現在維持focused governance validation，不再不必要觸發full Flutter／Android／iOS matrix；真正unknown path仍保持fail-safe full。

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
- Task 38-7 corrective後：`python -m unittest tools.ci.test_change_classifier tools.ci.test_validation_planner tools.ci.test_ci_execution_mode_contract`：PASS，70 tests。
- Task 38-7 corrective後：`python -m unittest discover -s tools/ci -p "test_*.py"`：PASS，265 tests。
- Corrective candidate tree：`d55e4ff215ee6656e438bbfdefe6420b04ee5319`。
- Candidate planner：`validation_level=full`、`full_regression=true`、`generated_check=true`、`android_build=true`、`ios_build=true`，原因為`validation_engine` corrective。
- Fresh `tools`／`docs_check`：PASS。
- Fresh workspace `flutter analyze`：5 packages PASS。
- Fresh workspace `flutter test`：5 packages PASS；app suite 493 cases PASS。
- Fresh generated consistency：PASS；build_runner／Drift schemas／web drift worker重新產生後無tracked diff。
- Fresh Android Production Release verification：PASS；artifact metadata綁定candidate `d55e4ff215ee6656e438bbfdefe6420b04ee5319`，package id `com.example.flutterarchitecture`，mapping present，Flutter symbols 3。
- Fresh GitHub-hosted iOS workflow run `31840983670`：overall SUCCESS，head SHA精確為`d55e4ff215ee6656e438bbfdefe6420b04ee5319`；`Production Release Build`與`Simulator Build`均SUCCESS，兩者皆走unsigned verification route，未使用production signing secret。
- 上述full-matrix evidence完成後只追加本review evidence文字；final commit前對該docs-only delta另跑planner-selected docs validation與`git diff --check`，不重新解讀為runtime code change。
