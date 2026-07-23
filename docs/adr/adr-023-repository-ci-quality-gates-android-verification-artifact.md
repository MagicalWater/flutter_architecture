---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-023-repository-ci-quality-gates-android-verification-artifact
last_reviewed_baseline: 1.8.0
id: ADR-023
title: Repository CI Quality Gates and Platform Verification Artifacts
supersedes: []
superseded_by: []
related:
  - ADR-002
  - ADR-009
  - ADR-011
  - ADR-014
  - ADR-024
---

# ADR-023 — Repository CI Quality Gates and Platform Verification Artifacts

## Status

Accepted。

## Authoritative Scope

本Decision定義repository CI host、execution mode、required quality gates、toolchain reproducibility、generated source consistency、Android verification artifact、iOS Simulator build gate與CI security boundary。

## Context

Repository已具備workspace commands、documentation checker、全量tests、tracked generated source與Android supported runner，但這些品質契約仍依賴人工執行。若沒有repository-level automated gates，Pull Request與main commit無法持續證明文件、架構、generated source、tests與Android artifact維持一致。

CI本身也會引入runner drift、floating Action、secret exposure、cache dependency與production artifact誤解，因此需要durable boundary，而不是只新增一份workflow YAML。

## Decision

GitHub Actions是repository CI control plane。Repository正式支援三種互斥的CI execution mode：

```txt
manual-local
self-hosted
github-hosted
```

`manual-local`表示GitHub不派送任何hosted或self-hosted execution job，由操作者明確執行repository-owned本機腳本；`self-hosted`表示GitHub只把可信`main` push與`workflow_dispatch`工作派送至repository-scoped Mac runner；`github-hosted`表示沿用GitHub提供的Ubuntu／macOS runner。

Manual dispatch可以使用`repository-default`作為sentinel，表示沿用repository variable的execution mode。`repository-default`不是第四種execution mode，不得保存為current mode。

Self-hosted runner使用`water`帳號下的獨立runner workspace與完整專用labels。Pull Request、fork Pull Request、Dependabot Pull Request與未合併branch不得進入此runner。Unknown、空白或legacy mode必須fail closed，不得猜測執行端，也不得自動fallback到GitHub-hosted runner產生非預期費用。

三種execution mode必須共用repository-owned scripts作為build、test與symbol handling實作來源。Workflow只負責event policy、runner routing、secret materialization與artifact transport，不得維護平行build contract。

在`github-hosted`模式下，Pull Request到`main`與Push到`main`都必須先建立穩定、可審查的change classification。Repository-owned classifier依changed paths輸出`full_ci`、`android_build`與`ios_build`；unknown path、無效Git range與classifier execution failure一律fail-safe到完整矩陣。

在`self-hosted`模式下，只有`main` push與`workflow_dispatch`可以建立execution jobs；Pull Request checks可以顯示為skipped，但`skipped`不得被解讀為已完成驗證。Branch Protection required checks必須依實際mode治理，不得要求一個在該mode永久不執行的job成功。

在`github-hosted`模式下，穩定required checks `CI / Quality`、`CI / Generated Consistency`、`CI / Tests`與`iOS / Simulator Build`不得因documentation-only而消失。Documentation-only時，required job仍以原名稱建立並在同一job內完成明確no-op；不得以不同名稱summary取代。`VERSION`變更與`workflow_dispatch`強制完整CI及Android／iOS代表build。

支援iOS後，`iOS / Simulator Build`維持穩定check名稱：需要iOS驗證時使用GitHub-hosted `macos-15`執行Development Debug Simulator clean build；documentation-only時同一job改用Ubuntu完成no-op，不啟動macOS runner。Production另使用`tools/ci/build_ios_production.sh`建立generic-device unsigned Release verification。兩者都不使用Apple Team、certificate、provisioning profile或signing secret。

CI使用固定runner OS major version、exact Flutter version與Java 17。Executable workspace追蹤root `pubspec.lock`，使乾淨runner驗證已知dependency graph。

Generated source維持tracked。CI重跑generator後必須檢查Git tree；任何changed、deleted或untracked generated file都使gate失敗，CI不得自動commit。

Android artifact使用default development／Mock entrypoint與repository既有verification signing。Artifact必須帶commit traceability與明確的非production classification。`flutter build bundle`不能替代Android APK artifact驗證。

Cache只用於加速Pub、Flutter SDK與Gradle dependency取得；cache miss不得改變correctness。`.dart_tool`、workspace build output、generated source與APK不作為shared cache authority。

Workflow permissions採最小權限，不讀取secrets，不使用`pull_request_target`。所有external Actions pin immutable full commit SHA。

iOS workflow只在失敗時上傳有界限的toolchain與build diagnostics，不上傳`.app`作為distribution artifact。Simulator build只能證明native integration與unsigned build contract，不能宣稱App Store readiness或實體裝置驗證完成。

Production signing、Store publishing、GitHub Release、environment promotion與deployment credentials必須由未來獨立release workflow與protected Environment決定，不屬本Decision第一版實作。

## Consequences

- Merge contract由人工checklist提升為repository-enforced checks。
- Toolchain與dependency graph變更必須透過reviewable repository change發生。
- Generated source omission會在PR被阻擋。
- 只有change classification要求Android驗證時，main commit才建立可追溯的Android verification APK；documentation-only不建立平台artifact。
- Pull Request與main commit可由獨立`iOS / Simulator Build`check阻擋不可建置的iOS native state，且不需要repository signing secrets。
- Documentation-only不執行analyze、generated consistency、全部Flutter tests或Android／iOS代表build，避免evidence-only commit形成無限驗證循環。
- CI workflow與pinned Actions需要後續maintenance；Dependabot不因本Decision自動加入。
- Self-hosted runner不消耗GitHub-hosted execution minutes，但會引入本機可用性、持久workspace、cache與secret清理責任。
- Runner離線時job維持queued；不得自動切換至GitHub-hosted runner。操作人員必須恢復runner或明確切換mode。
- GitHub Branch Protection settings仍需repository管理者依文件人工設定，code不能宣稱已完成settings變更。

## Supersession

本Decision未取代既有ADR。

## Related Decisions

- ADR-002：Monorepo與Melos workspace contract。
- ADR-009：版本與變更紀錄治理。
- ADR-011：文件Single Authority原則。
- ADR-014：App environment entrypoint與production validation boundary。
- ADR-024：iOS Runner、native dependency與verification layering contract。

## Related Evidence

- [Milestone 24 planning review](../audits/milestone_24/24-0_planning_review.md)
- [Milestone 24 implementation plan](../superpowers/plans/2026-07-22-milestone-24-ci-cd-foundation.md)
- [Change-aware CI design](../superpowers/specs/2026-07-23-change-aware-ci-execution-design.md)
- [Change-aware CI planning review](../audits/change_aware_ci_plan_review.md)
- [Task 27-7 self-hosted CI design](../superpowers/specs/2026-07-24-self-hosted-ci-execution-mode-design.md)
- [Task 27-7 self-hosted CI plan](../superpowers/plans/2026-07-24-self-hosted-ci-execution-mode.md)

## Last Reviewed Baseline

1.8.0。
