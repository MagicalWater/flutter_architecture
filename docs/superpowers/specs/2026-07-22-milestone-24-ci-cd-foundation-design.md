---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-24-ci-cd-foundation-design
last_reviewed_baseline: 1.5.1
---

# Milestone 24 — CI/CD Foundation Design

## Goal

將目前已存在的 repository engineering contract 轉為 GitHub Actions automated gates，讓 Pull Request、main branch 與手動執行都能在乾淨 runner 上重現 documentation、analysis、tests、generated source 與 Android release artifact 驗證。

本 Milestone 建立的是 repository-level CI foundation，不是特定產品的 deployment pipeline。

## Scope

第一版包含：

- GitHub Actions。
- Pull Request 到 `main` 的品質驗證。
- Push 到 `main` 的重新驗證與 Android release APK artifact。
- `workflow_dispatch` 手動執行。
- `dart pub get`、`docs_check`、workspace analyze、全部 Flutter tests。
- generated source consistency gate。
- 乾淨 runner Android release APK build。
- Pub／Flutter／Gradle cache、concurrency cancellation與穩定 job names。
- artifact naming、retention、commit traceability與 rollback policy。
- Branch Protection與 required checks建議。
- minimal permissions、Action SHA pinning與 supply-chain boundary。

## Non-goals

第一版不包含：

- Play Store或 App Store自動發布。
- Production keystore、正式簽章 secret或 production-ready artifact。
- iOS或其他平台 build。
- Firebase App Distribution、backend deployment或 environment promotion。
- 自動版本號、tag、GitHub Release或 release notes生成。
- Native product flavors。
- Dependabot或 dependency auto-update。
- 直接修改 GitHub repository Branch Protection settings。

## Repository Baseline

目前可直接重用的 root commands：

```bash
dart pub get
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
dart run melos run build_runner
```

目前 Android contract：

```txt
App: apps/flutter_architecture
Java source / target: 17
Kotlin jvmTarget: 17
Gradle: 8.14
Android Gradle Plugin: 8.11.1
Kotlin plugin: 2.2.20
Release signing: debug signing for local verification only
```

目前 repository尚無 `.github/`、Flutter version pin或 Java runtime pin；root `pubspec.lock`亦未被 Git追蹤。

## Toolchain Strategy

第一版 CI固定使用：

```txt
Runner: ubuntu-24.04
Flutter: 3.41.6 exact
Dart: Flutter bundled SDK
Java: Eclipse Temurin 17
Python: runner-provided Python 3
```

不得使用浮動 `ubuntu-latest`、Flutter `stable`或 Java `latest`作為正式 gate authority。

Flutter與 Java版本應由 repository-owned單一設定來源提供。第一版不為 CI額外導入 FVM；未來若 repository正式採用 FVM，才將 Flutter authority切換到 `.fvmrc`。

Root workspace包含 executable App，因此建議追蹤 root `pubspec.lock`，讓 CI驗證已核准的 dependency graph，而不是每次重新選擇不同 transitive versions。

## Workflow Topology

採兩份 workflow：

```txt
.github/workflows/ci.yml
.github/workflows/android.yml
```

不採單一大型 workflow，避免 repository quality contract與 Android artifact lifecycle耦合；第一版也不建立 reusable workflow，避免在只有一個 App與一個 Supported platform時過早抽象。

### CI workflow

Events：

```txt
pull_request -> main
push -> main
workflow_dispatch
```

Jobs：

```txt
Quality
Generated Consistency
Tests
```

三個 jobs平行執行。固定 display names作為 Branch Protection required checks，不將 Flutter版本或 runner版本放入名稱。

### Android workflow

Events：

```txt
push -> main
workflow_dispatch
```

第一版不在每個 PR建立 Android artifact。Android workflow是 self-contained artifact producer，不透過 `workflow_run`依賴另一份 workflow。

## Job Contracts

### Quality

```bash
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

### Generated Consistency

```bash
dart run melos run build_runner
git diff --exit-code
git status --porcelain
```

Gate必須同時偵測 tracked file修改、刪除與新產生的 untracked generated source。CI不得自動 commit generated files。

### Tests

```bash
dart run melos exec -- flutter test
```

第一版維持現有 Melos concurrency。只有在 CI證據顯示記憶體或 host interference不穩定時，才降為 `--concurrency=1`。

### Android Release Artifact

```bash
cd apps/flutter_architecture
flutter build apk --release -t lib/main.dart
```

使用 default development／Mock entrypoint，不提供假的 staging或 production URL。Artifact只證明 tracked Android runner能在乾淨 runner建立 release APK，不代表 production signing或可上架版本。

第一版只保存 APK，不額外建立 AAB。

## Concurrency

CI workflow：同一 PR或同一 ref的新 run取消舊 run，縮短 feedback時間。

Android workflow：main每個 commit都應保留對應 artifact build機會，因此不得因新 main push取消舊 commit build。Manual run的 concurrency identity需包含 ref與 SHA或 run identity，避免互相取消。

## Cache Strategy

Cache只用於加速，不是正確性前提。

允許：

- Flutter setup Action管理的 SDK cache。
- `~/.pub-cache`，key包含 runner OS、Flutter exact version與 `pubspec.lock` hash。
- 單一 Gradle cache authority；第一版優先使用 Java setup Action的 Gradle cache能力。

不快取：

- `.dart_tool/`。
- workspace `build/`。
- App build output。
- generated Dart source。
- APK artifact。

Cache miss、eviction或 restore failure後，正常 commands仍必須能從零完成驗證。

## Artifact Contract

Artifact logical name與檔名包含 commit short SHA；artifact內另保存 metadata：

```txt
repository
full commit SHA
Git ref
workflow run ID
Flutter / Dart / Java versions
build command
entrypoint
build mode
signing classification
```

Retention固定為14天。Artifact需明確標記：

```txt
Verification-only
Debug signing
Not production-ready
Not Play Store ready
```

舊 artifact不得被當成新 commit build成功的替代證據。

## Security and Supply Chain

Workflow top-level permissions預設：

```yaml
permissions:
  contents: read
```

第一版不讀取 repository secrets，不使用 `pull_request_target`，也不要求 write、OIDC、package、deployment或 pull request權限。

所有 GitHub與第三方 Actions都 pin到完整 commit SHA，並以註解保留 human-readable release version。Flutter setup Action需單獨確認維護來源，不使用會包辦整套 build且難以審查的未知 composite Action。

## Branch Protection Recommendation

建議 required checks使用穩定名稱：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
```

建議 main禁止 force push與 branch deletion，要求 Pull Request、required checks與 conversation resolution。是否要求 approval數與 branch up-to-date由 repository owner決定。

Milestone只文件化建議，不宣稱已修改 GitHub settings。未來若啟用 Merge Queue，CI需新增 `merge_group` event後才可將同一 checks用於 queue commit。

## Failure and Rollback Policy

- Quality、generated consistency或 tests失敗：blocking，不得 merge。
- Generated consistency失敗：開發者本地更新並提交 generated files；CI不自動修復。
- Main Android build失敗：視為 main regression，以修復 commit或人工 revert處理，不自動 revert。
- Cache問題：先以 cold path重試，不降低 gate規則規避 temporary outage。
- Workflow definition失敗：修復或 revert workflow commit；code revert不會自動修改 Branch Protection settings。
- GitHub或 network transient failure：允許 rerun或 manual dispatch，但不得以刪除 tests／checker作為處置。

## Architecture Decision

Milestone 24需要新增 ADR-023，保存以下 durable contract：

- GitHub Actions是 repository CI host。
- Exact runner／Flutter／Java pinning策略。
- PR quality gates與 main Android artifact責任。
- generated source consistency authority。
- verification-only signing與 secrets non-goal。
- Action SHA pinning與 minimal permissions。

ADR不保存 Action SHA清單、逐 step journal、測試數、artifact URL或 Milestone phase狀態。

## Delivery Phases

```txt
24-0 Planning authority and design acceptance
24-1 ADR-023, checker coverage and reproducibility foundation
24-2 Pull Request quality workflow
24-3 Android artifact workflow
24-4 Branch Protection and operations documentation
24-5 Clean-run and cache validation
24-6 Whole-milestone final review and archive
```

每個 phase遵守：

```txt
implementation
→ immediate review
→ fix / re-review
→ whole-phase review
→ verification
→ commit
```

## Acceptance Criteria

- Exact Ubuntu、Flutter與 Java版本可由 repository判斷。
- PR到 `main`自動執行 docs check、analyze、all tests與 generated consistency。
- Push到 `main`重新驗證並建立 SHA-traceable Android release APK。
- Manual dispatch可重跑 CI與 Android artifact。
- Cache miss不影響正確性。
- Root dependency graph具有明確 lockfile authority。
- Workflow使用 minimal permissions、不讀 secrets、不使用 `pull_request_target`。
- 所有 Actions pin完整 commit SHA。
- Artifact保存14天並明確標示 verification-only signing。
- Branch Protection文件使用穩定 required check names，但不假設 settings已被修改。
- ADR-023、planning review、phase reviews與 final review完整路由。
- Final review Open P0／P1為0。

## Release Decision Rule

Planning階段不改版本，Baseline維持 `1.5.1`。

若 Milestone完整交付 automated gates與 Android CI artifact，final review優先考慮 PATCH release `1.5.2`；若只完成文件或未形成可使用 repository capability，則 No release。
