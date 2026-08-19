---
document_type: final-review
status: accepted
authoritative_for:
  - generated-platform-owner-alignment-holistic-review
last_reviewed_baseline: 1.25.2
---

# Generated / Platform Validation Owner Alignment — Holistic Review

## Result

**PASS — local implementation complete; release decision pending。**

## Review scope

- `.github/workflows/android.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/ios.yml`
- `tools/ci/run_release_validation.py`
- `tools/ci/run_local_ci.sh`
- `tools/ci/test_validation_planner.py`
- ADR-023
- `docs/guides/ci_cd_operations.md`
- accepted bounded Design / Plan

## Findings

### R1 — Ownership alignment

PASS。`CI / Generated Consistency`保留`verify_generated.sh`；Android Production GitHub-hosted與self-hosted routes都已移除該command；iOS原本就沒有內嵌generated consistency。

### R2 — Android build dependency

PASS。`build_android_production.sh`只委派`build_android_environment.sh`；後者直接執行platform config verification與`flutter build`，沒有讀取`verify_generated.sh`產生的temporary state。移除的是assertion duplication，不是build prerequisite。

### R3 — Runner-local prerequisites

PASS。Android Production仍保留runner-local `dart pub get`；iOS仍保留`flutter pub get`與`pod install`。本corrective沒有錯把不同runner filesystem的dependency preparation當成可共享evidence。

### R4 — Orchestration boundary

PASS。Planner仍是selection machine authority，release orchestrator仍負責family composition與result aggregation。Platform workflow不新增跨workflow probing，也不猜測CI是否存在。

### R5 — Test Retention Decision

Retain。只在既有critical owner保留小型negative contract assertions：Android workflow不得再次內嵌`tools/ci/verify_generated.sh`；核心CI／Android／iOS workflow不得恢復`pull_request` auto-trigger。它們保護stable ownership boundary，沒有新增test file或path-permutation portfolio。

### R6 — Core trigger alignment

PASS。`ci.yml`與`ios.yml`移除`pull_request -> main`，與`android.yml`一致由explicit `workflow_dispatch`建立核心validation run；branch push同樣不自動啟動。`observability-acceptance.yml`不在本scope，維持既有獨立PR-safe contract。

### R7 — Manual-local release backend

PASS。`run_release_validation.py`維持唯一release validation入口；`github-hosted`與`manual-local`共用clean local／remote candidate identity與canonical release planner。Manual-local logical evidence只執行planner-selected quality／tests／generated phases；Android／iOS只執行planner-selected development／production variants，且全部透過`run_local_ci.sh` managed entrypoint保存於checkout外artifact store。非macOS host遇到iOS requirement會在任何command開始前fail closed，不產生partial release evidence。

## Local evidence

- `python -m unittest tools.ci.test_validation_planner`：24/24 PASS。
- `python -m unittest discover -s tools/ci -p test_*.py`：55/55 PASS。
- `python -m unittest discover -s tools/docs -p test_*.py`：6/6 PASS。
- `dart run melos run analyze`：5 packages PASS。
- retained Flutter suites（`flutter_architecture`／`auth`／`api_client`）：PASS。
- clean checkpoint `c4772810e657a1171c85b22851092d2a837c4e48` 執行`tools/ci/verify_generated.sh`：PASS，wall-clock約165秒；沒有generated content drift。
- trigger-alignment checkpoint `0cdb362a253b5f6bcedebb8bc5fbda082917ef40` 重新驗證：52/52 CI tools、6/6 docs owners、5-package analyze、retained Flutter suites全部PASS；Git Bash執行Generated Consistency亦PASS，warm-cache wall-clock約57秒且沒有content drift。
- manual-local checkpoint `1b90e7523659e4b995410b07663288e6bc61756e` 的exact-range planner判定`docs_content + governance + tooling + validation_engine`，要求logical full + generated、Android/iOS皆false；依該plan執行55/55 CI tools、6/6 docs owners、5-package analyze、retained Flutter suites全部PASS。
- 同一checkpoint以新`run_local_ci.sh managed-validation-phase`實際執行Generated Consistency並成功aggregate managed run `release-manual-generated-1b90e75`；artifact root位於checkout外`%LOCALAPPDATA%/flutter_architecture/ci-artifacts`，generated content一致。
- `ci.yml`／`android.yml`／`ios.yml` contract test確認三份核心workflow皆含`workflow_dispatch`且不含`pull_request` trigger；YAML parse PASS。
- `python tools/docs/check_docs.py`：PASS。
- CI / Android / iOS workflow YAML parse：PASS。
- `git diff --check`：PASS。

Planner對manual-local extension exact changed range判定`docs_content + governance + tooling + validation_engine`，要求logical full + generated，但不要求Android／iOS platform build；本地validation依此完成，沒有因Level名稱人工加碼platform build。

## Release / remote evidence disposition

此變更會修改Android workflow，所以若要發布新的Template Baseline，fresh exact-candidate release planner應要求Android platform evidence；remote acceptance應證明Production job能在沒有Android-local generated step的情況下成功build。Same-SHA publication後不得重跑相同source suite。

Open P0 = 0。Open P1 without disposition = 0。
