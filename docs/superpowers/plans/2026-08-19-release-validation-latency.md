---
document_type: implementation-plan
status: accepted
authoritative_for:
  - release-validation-latency-corrective-implementation-plan
last_reviewed_baseline: 1.25.1
---

# Release Validation Latency Corrective — Implementation Plan

## Goal

在不降低 1.25.1 release safety semantics 的前提下，把 exact-candidate release admission 從人工串行改成 planner-selected fan-out，並把 Android／iOS aggregate platform flag 細分為 build-kind selection。

本 Plan 採 Level 5 的最低充分範圍：四個 implementation units、既有 critical owner tests、one holistic implementation review；不建立新 Milestone、不建立 permutation-heavy test portfolio。

## Constraints

- `tools/ci/validation_planner.py` 維持唯一 validation selection authority。
- release orchestrator 不分類 changed paths、不修改 VERSION、不 merge、不 push `main`、不 publish。
- `android_build`／`ios_build` transitional aggregate 可保留相容，但 workflow build job 必須改用 build-kind outputs。
- unknown／invalid-range、dependency／toolchain、shared native／platform-shared 不因 latency corrective 降級。
- 不新增獨立 test file；新增 contract 併入既有 critical owner並在 GREEN 後做 Retention Decision。
- 不重寫 `validation_runner.py`，除非實作證據顯示 serialized planner contract不足。

## Unit 1 — Planner build-kind contract

**Files**

- `tools/ci/validation_planner.py`
- `tools/ci/test_validation_planner.py`
- `tools/ci/change_classifier.py`（只有 path specificity 確實不足時才改）

**Required behavior**

新增 planner outputs：

```text
android_development_build
android_production_build
ios_simulator_build
ios_production_build
```

Aggregate compatibility：

```text
android_build = android_development_build || android_production_build
ios_build = ios_simulator_build || ios_production_build
```

Routing 至少滿足：

- validation-engine-only release → Android Production + iOS Production；
- Android development-specific → Development；production-specific → Production；shared Android native → both；
- iOS simulator/development-specific → Simulator；production/device-specific → Production；shared iOS native → both；
- Android workflow file changed → Android both；iOS workflow file changed → iOS both；
- dependency/toolchain/platform-shared/invalid range → affected platforms both variants；
- docs/governance/release metadata/ordinary Dart change不因 release intent新增平台 variant。

Test Authoring：先以少量 table-driven representative cases形成 RED；GREEN 後 merge/remove path permutations，只保留 distinct failure families。

## Unit 2 — Workflow job selection

**Files**

- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `.github/workflows/ci.yml`（只同步 planner outputs／dispatch contract，不建立 platform selection authority）
- `tools/ci/test_validation_planner.py`

**Required behavior**

- Android Development job只依 `android_development_build`；Production job只依 `android_production_build`。
- iOS Simulator job只依 `ios_simulator_build`；Production job只依 `ios_production_build`。
- summary/fallback 可使用 aggregate，但不得因 aggregate=true重新把兩個 variant都啟動。
- planner execution failure仍先走 canonical classifier/fail-safe，build-kind fallback與 accepted Design 保持一致。
- workflow contract tests驗證 outputs wiring與 job conditions，不複製整份 YAML behavior。

## Unit 3 — Exact-candidate fan-out orchestrator

**Files**

- `tools/ci/run_release_validation.py`（new bounded CLI）
- `tools/ci/test_validation_planner.py`（orchestrator contract仍放既有 critical owner）

**Required behavior**

CLI shape：

```text
python tools/ci/run_release_validation.py \
  --base <release-base> \
  --head <candidate-sha> \
  --execution-mode github-hosted
```

第一版只支援 repository目前已使用且可驗證的 execution mode；不得為未需要的 scheduler做 generic framework。

流程：

1. assert clean/known repository + exact base/head；
2. 呼叫 canonical planner取得 release payload；
3. 對 selected CI／Android／iOS families **立即 fan-out dispatch**，不等待前一 family結束；
4. 收集 run IDs；
5. 等待 selected runs；
6. 驗證每個 run head SHA == candidate SHA、conclusion == success；
7. 任一 dispatch／SHA／conclusion failure → non-zero；
8. 輸出 concise evidence summary。

CLI 不得自行把 planner未選的平台補上，也不得在成功後 publish。

Implementation 優先使用 repository現有 GitHub CLI / workflow-dispatch contract，不新增 network abstraction。

## Unit 4 — Authority sync + holistic validation

**Files**

- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- `docs/guides/ci_cd_operations.md`
- `docs/guides/testing_governance.md`（只有 existing release wording需要同步時）
- implementation holistic review artifact

**Authority updates**

- ADR-023擁有 build-kind granularity、fan-out release evidence與 fail-closed semantics。
- CI/CD guide提供 single-command exact-candidate procedure與 operator examples。
- Testing guide只保存 validation/test distinction，不複製 orchestration implementation。

## Validation sequence

Implementation期間只執行 planner-selected／affected evidence，不因 Level 5 名稱手動擴大。

最低必要 local gates：

1. existing planner critical owner + new retained contracts；
2. workflow YAML parse／contract checks；
3. docs checker；
4. `git diff --check`；
5. current corrective range交給修正後 planner產生 Validation Execution Decision。

Release-candidate acceptance必須另外使用 exact candidate 驗證：

- orchestrator真的同時 dispatch selected families；
- returned workflow run SHA完全一致；
- selected build-kind jobs與 planner payload一致；
- wall-clock evidence證明 families並行啟動，而不是人工串行；
- 不要求固定時間 SLA，只記錄 dispatch/start/completion timestamps。

## Rollback

- build-kind false-negative → 停止 publication，explicit both variants補 evidence，revert至1.25.1 aggregate routing。
- orchestrator defect → 回退為手動 simultaneous dispatch；planner build-kind contract可獨立保留。
- 不以回退為理由恢復「所有 release 固定 full + all platform variants」。

## Completion gate

完成 implementation 後只建立 one holistic review，要求：

- accepted Design / Plan scope全部可追溯；
- Test Retention Decision完成；
- Open P0 = 0；Open P1 without disposition = 0；
- docs與machine contract一致；
- release disposition明確。

本 Plan 已於 2026-08-19 取得使用者明確核准，狀態為 `accepted`，正式授權 implementation。
