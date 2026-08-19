---
document_type: design-spec
status: accepted
authoritative_for:
  - change-aware-release-validation-design
last_reviewed_baseline: 1.25.0
---

# Change-aware Release Validation Design

## Status

Accepted。使用者已於 2026-08-19 明確核准本 Design；implementation 仍須等待 Implementation Plan accepted。

## Problem

Repository 已由 ADR-023、Milestone 35 與 Milestone 45 建立 Minimum Sufficient Validation：ordinary feature、package、database、native、dependency、validation-engine、documentation 與 governance change 會依 changed risk 選擇 focused／affected／workspace／full 與必要 platform evidence。

但 explicit `workflow_dispatch --mode release` 仍直接呼叫 `plan_validation([], manual=True, manual_mode="release")`，因此 manual release 不使用已傳入的 `base`／`head`，而固定產生 logical full、generated consistency、Android Development + Production、iOS Simulator + Production。這使 release intent 成為 validation scope override，而不是 publication freshness context。

## Goals

- Release validation 保持 fresh，但只 fresh 驗證 changed risk 真正要求的 evidence。
- Release intent 不再抹除 base/head change classification。
- Documentation／governance-only release 不執行 Flutter full、generated consistency、Android 或 iOS build。
- Android／iOS／generated／logical full 仍由 changed risk 或 explicit platform intent 升級。
- Unknown、invalid range、planner failure 維持 fail-safe；不得為降低成本而 fail-open。
- Publish same SHA 後仍只做 identity／artifact／workflow read-back，不重跑相同 source evidence。
- 不建立第二套 release path matrix；`validation_planner.py` 保持唯一 machine selection authority。

## Non-goals

- 不降低 production signing、Store publishing、deployment 或 protected Environment 的未來安全要求。
- 不把 release validation 改成永遠 focused。
- 不讓 operator 自行以「我覺得低風險」跳過 planner-selected evidence。
- 不重新設計 Test Authoring／Retention policy。
- 不把每個 package／feature 建立獨立 release workflow。
- 不因本 corrective 強制建立新的 Milestone 編號或大量 per-task audit artifacts。

## Core Decision

### Release 是 freshness gate，不是固定 validation level

Current：release intent → unconditional logical full → unconditional generated → unconditional Android → unconditional iOS。

Target：candidate changed range + release intent → change-aware release plan → selected evidence 必須 fresh → publication → same-SHA identity／artifact read-back。

`release` 仍是 explicit publication intent，但它不再自行把 `full_regression`、`generated_check`、`android_build`、`ios_build` 全部設為 `true`。

### Release candidate range authority

Release mode 必須有 deterministic candidate range，不能從 empty paths 規劃。

Canonical input：

```txt
base SHA = 本次 accepted change set 的 publication base
head SHA = exact release candidate SHA
```

Planner 對 `git diff --name-only <base> <head>` 執行與 ordinary change 相同的 canonical classification，再疊加 `release intent`。

Repository workflow 不得從 branch name、VERSION、CHANGELOG文字或最近一次 tag 猜 base。若 explicit release 沒有可驗證 base/head，必須 fail-safe 到 logical full；platform build仍只有在 changed risk／explicit platform intent／無法安全判定 platform impact 時才升級。

### Release freshness semantics

Release candidate 必須 fresh 執行 planner-selected evidence；holistic／task evidence reuse不能直接替代 release gate。Freshness不代表 scope expansion。

### Platform escalation

| Change class | Android | iOS | Reason |
|---|---:|---:|---|
| docs_content | no | no | 不改 runtime/build graph |
| governance | no | no | 不改 runtime/build graph |
| release_metadata | no | no | identity metadata 本身不改 platform bytes |
| app_feature | no by default | no by default | affected logical owners |
| app_shared | no by default | no by default | 若另命中platform-shared path再升級 |
| package | no by default | no by default | dependency closure先做logical evidence |
| generated / database | no by default | no by default | generated consistency是primary evidence |
| android_native | yes | no | Android primary boundary mutation |
| ios_native | no | yes | iOS primary boundary mutation |
| platform_shared | yes | yes | 共享native/environment contract |
| dependency | conditional | conditional | 無法安全判定才升級 |
| validation_engine | conditional | conditional | 依受影響platform contract升級 |
| unknown / invalid | no by default | no by default | fail-safe logical full；platform-sensitive boundary另升級 |

## Planner Design

`tools/ci/validation_planner.py` 保持唯一 validation selection authority。Release planning改為概念上的 `base_plan = plan_range(base, head)` 再 `release_plan = apply_release_freshness(base_plan)`。Release intent只標記 candidate/freshness metadata，不得無條件把 generated／Android／iOS／full regression改為true。

## Workflow Design

Manual `release` 必須把 deterministic base/head 交給 planner。若 `workflow_dispatch` 無天然 before SHA，第一版提供明確 `release_base` input；不得從 tag／VERSION prose 猜測。

Android / iOS workflows 消費同一 plan，不自行把 `release` 翻譯成 platform=true。

Planner execution failure時，YAML fallback不得形成第二套更昂貴 authority；先維持 logical full/generated safety，再只對無法安全排除的平台 impact 升級。

## Release Safety Invariants

1. Exact release candidate SHA 必須被明確識別。
2. Candidate changed range 必須可重現；無效 range fail-safe。
3. Planner／classifier mutation本身必須有 direct critical owner。
4. Platform-native mutation必須有對應 primary build evidence。
5. Generated/database mutation必須有 generated consistency evidence。
6. Dependency/toolchain mutation若無法安全判定platform impact，必須升級而不是跳過。
7. Release gate selected evidence必須fresh。
8. Publication後same SHA不重跑相同source suite。
9. Branch Protection stable check names不得因 optimization 漂移。
10. Workflow YAML不得建立與planner不同的path matrix。

## Documentation Authority Changes

- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- `docs/guides/ci_cd_operations.md`
- `.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- `docs/guides/testing_governance.md`

## Validation Strategy

Permanent critical owner只覆蓋代表 failure families：docs/governance release、Android-only、iOS-only、database/generated、dependency/validation-engine、invalid range、release freshness、workflow release base、YAML fallback一致性。不得恢復大型matrix test portfolio。

## Rollback

若 change-aware release 出現 false-negative：停止publication；以 explicit `full` + required platform modes補 evidence；修正 planner/workflow 後 fresh re-review。不得把「所有release永久full+雙平台」重新當無期限最終狀態。

## Acceptance Criteria

- Explicit release對candidate base/head做change-aware planning。
- docs/governance-only release不執行Flutter full、generated、Android、iOS。
- release metadata本身不觸發platform matrix。
- Android／iOS native change仍有對應fresh platform evidence。
- generated/database change仍有fresh generated consistency。
- dependency／validation-engine具保守但不粗暴的platform escalation。
- invalid range／planner failure不fail-open。
- same-SHA post-release仍只做identity/artifact verification。
- ADR、Guide、Skill reference與machine behavior無平行矛盾。
- Open P0 = 0；P1皆有disposition後才可接受Design。
