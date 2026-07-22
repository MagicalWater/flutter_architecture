---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-24-ci-cd-foundation-planning-review
last_reviewed_baseline: 1.5.1
---

# Milestone 24-0 — CI/CD Foundation Planning Review

## Scope

本 review定義 Milestone 24將既有工程品質契約轉為 GitHub Actions repository-level automated gates的架構、風險、finding disposition、acceptance criteria與 implementation gate。

本階段只建立 planning authority與正式設計，不建立 `.github/workflows`、不修改 production signing、GitHub repository settings或 runtime behavior。

正式設計：

- `../../superpowers/specs/2026-07-22-milestone-24-ci-cd-foundation-design.md`

## Current Command Inventory

目前可直接供 CI重用：

```bash
dart pub get
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
dart run melos run build_runner
```

`docs_check`由 `tools/docs/check_docs.py`執行；`build_runner`已使用 dependency order與 concurrency 1，適合乾淨 workspace generation。

目前沒有 `.github/`、CI workflow、Flutter version pin、Java runtime pin或 tracked root `pubspec.lock`。

## Architecture Decisions

### Host and toolchain

```txt
Host: GitHub Actions
Runner: ubuntu-24.04
Flutter: 3.41.6 exact
Dart: Flutter bundled SDK
Java: Eclipse Temurin 17
```

不得以 `ubuntu-latest`、Flutter `stable`或 Java `latest`作為正式 gate authority。

### Workflow topology

採兩份 workflow：

```txt
ci.yml
android.yml
```

`ci.yml`處理 PR／main quality contract；`android.yml`處理 main／manual Android release APK artifact。第一版不建立 reusable workflow或跨 workflow dependency。

### Parallelization

Quality、Generated Consistency與 Tests平行。Android artifact為獨立 workflow，不在每個 PR執行。

### Generated source

CI執行 build runner後必須同時檢查 tracked diff與 untracked output；不得只確認 generator exit code，也不得由 CI自動 commit。

### Android artifact

使用：

```bash
flutter build apk --release -t lib/main.dart
```

Artifact使用 default development／Mock entrypoint與現有 debug signing，只作 repository verification，不是 production或 Play Store artifact。

### Cache

允許 Flutter SDK、Pub與單一 Gradle cache authority；不快取 `.dart_tool`、build output、generated source或 APK。Cache miss不得影響 correctness。

### Security

Workflow只需要 `contents: read`，不讀 secrets、不使用 `pull_request_target`。所有 GitHub與第三方 Actions pin完整 commit SHA。

## Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M24-PR01 Flutter、runner與 Java未由 repository pin | P1 | 固定 Ubuntu 24.04、Flutter 3.41.6與 Temurin 17 |
| M24-PR02 缺少 CI-specific薄層 tooling | P2 | 只建立 generated consistency與 Android artifact需要的 focused scripts |
| M24-PR03 Generated source只有人工 contract | P1 | Dedicated dirty-tree consistency gate |
| M24-PR04 Root `pubspec.lock`未追蹤 | P1 | Phase 24-1正式追蹤 root workspace lockfile |
| M24-PR05 `flutter build bundle`不是 Android artifact | P2 | Android CI使用 release APK build |
| M24-PR06 Floating Action tags有 supply-chain風險 | P1 | 所有 Actions pin full commit SHA |
| M24-PR07 Current snapshot仍含已過期 Milestone 23 active journal | P2 | Planning promotion同步改為 Milestone 24 current gate |
| M24-PR08 Root README milestone摘要未包含 Milestone 23 | P2 | Current status摘要同步 Milestone 23與 active Milestone 24 |
| M24-PR09 Artifact naming、retention與 signing classification未定義 | P2 | SHA traceability、14天 retention、verification-only metadata |
| M24-PR10 Branch Protection required checks未定義 | P2 | 文件化穩定 job names與人工設定建議 |

Open P0／P1 without disposition：0。

## Architecture Decision Gate

需要新增 ADR-023，因為 CI host、toolchain pin、merge gates、generated source authority、Android verification artifact、permissions與 Action pinning都會成為長期 repository contract。

ADR-023與 checker coverage調整屬 Phase 24-1。Planning phase不先建立 orphan ADR，也不在未加入 checker regression前直接改動 canonical ADR coverage。

## Implementation Phases

1. **24-1 — ADR／Reproducibility Foundation**：ADR-023、checker coverage、toolchain authority、tracked root lockfile與 focused scripts。
2. **24-2 — Pull Request Quality Workflow**：Quality、Generated Consistency、Tests、events、concurrency、cache與 permissions。
3. **24-3 — Android Artifact Workflow**：main／manual release APK、metadata、retention與 commit traceability。
4. **24-4 — Branch Protection and Operations**：required checks、failure、rerun、rollback與 future production extension guide。
5. **24-5 — Clean-run Validation**：cold／warm／cache-miss、fresh checkout與 artifact inspection。
6. **24-6 — Final Review and Archive**：full verification、finding closure、release與 archive decision。

## Acceptance Criteria

- Pull Request到 `main`自動執行 documentation check、workspace analyze、全部 Flutter tests與 generated consistency。
- Push到 `main`重新驗證並建立 SHA-traceable release APK。
- Manual dispatch可執行兩類 workflow。
- Runner、Flutter與 Java使用 exact策略。
- Root dependency resolution具有 tracked lockfile authority。
- Cache不成為 correctness prerequisite。
- Workflow minimal permissions、無 secrets、無 `pull_request_target`。
- Actions完整 SHA pinning。
- Artifact retention 14天並標記非 production signing。
- Branch Protection只提供建議，不宣稱已修改 settings。
- Final review Open P0／P1為0。

## Release Decision

Planning phase：No release，Baseline維持 `1.5.1`。

若 Milestone 24完整交付 automated gates與 Android artifact capability，final review優先評估 PATCH `1.5.2`；實際版本仍由 final holistic review依 runtime、public contract與 repository capability變更判定。

## Planning Gate Decision

Milestone 24-0通過。後續只允許從 Phase 24-1的 ADR／checker／reproducibility foundation開始；在該 phase review通過前，不建立正式 workflow。
