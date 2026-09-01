---
document_type: guide
status: active
authoritative_for:
  - feature-addition-operational-procedure
last_reviewed_baseline: 1.27.0
---

# How to Add a Feature

## Purpose

本 Guide 提供在本 repository 新增完整 Feature 時的操作順序、讀取路徑、integration points 與驗證步驟。

它不重新定義 Clean Architecture、Feature First、DI、Route Guard、Localization、Persistence 或 Failure contract。架構規則仍以 [Architecture Decision index](../adr/README.md)、[Project Context](../project_context.md) 與受影響 App／Feature／Package README 為準。

若本 Guide 的摘要與 canonical ADR 或 local README 衝突，必須以 authority 為準並修正本 Guide。

## Pre-reading Route

Fresh admission 只固定讀：

```txt
AGENTS.md
repository_identity.json
VERSION
```

接著只依 Feature 實際需要讀取：

```txt
apps/flutter_architecture/README.md
相近 Feature README
受影響 Package README
docs/adr/README.md 的相關 ADR（只有對應 boundary in scope）
相關 source 與 tests
```

`docs/project_context.md`、`docs/roadmap.md`、歷史 Milestone evidence 不屬於新增普通 Feature 的固定前置讀取；只有 project-wide capability 或 roadmap disposition 真正在 scope 時才載入。

可優先參考：

- [Auth Feature](../../apps/flutter_architecture/lib/features/auth/README.md)：完整 Auth／OTP／Session presentation boundary。
- [Catalog Feature](../../apps/flutter_architecture/lib/features/catalog/README.md)：Remote／Local data coordination、pagination 與 cache。
- [Profile Feature](../../apps/flutter_architecture/lib/features/profile/README.md)：單一 query use case 與 presentation mapping。
- [Protected Feature](../../apps/flutter_architecture/lib/features/protected/README.md)：Guarded route fixture。
- [Shell Feature](../../apps/flutter_architecture/lib/features/shell/README.md)：App shell 與 navigation composition。

這些Feature是architecture、behavior與owner boundary reference，**不是test-density reference**。不得因Auth／Catalog／Profile已有較多test files或cases，就把相同layer／case密度複製到普通產品Feature。

## 1. Decide Feature Responsibility

先確認需求應留在 App Feature，還是提升為 reusable package。

預設新增於：

```txt
apps/flutter_architecture/lib/features/<feature>/
```

只有能力同時符合下列條件，才考慮提升至 `packages/`：

- 真正跨 Feature 重用。
- 具有穩定且可獨立描述的 contract。
- 不依賴 App Router、Widget、Bloc、generated localization 或 plugin implementation。
- 提升後不會讓 package 反向依賴 App。

依賴方向與 package boundary 由下列 authority 擁有：

- [ADR-001 — Clean Architecture and Feature First](../adr/adr-001-clean-architecture-feature-first.md)
- [ADR-005 — Auth Package Boundary](../adr/adr-005-auth-package-boundary.md)
- [ADR-012 — Reusable Package DI Boundary](../adr/adr-012-reusable-package-di-boundary.md)

不要先建立 generic Feature framework、generic Repository、generic Pagination 或 generic Cache abstraction。先完成具體 Feature，再以實際重複需求決定是否抽象。

## 2. Create the Feature Skeleton

依需求建立必要層級：

```txt
apps/flutter_architecture/lib/features/<feature>/
  presentation/
  domain/
  data/
```

不需要的層不要為了形式完整而建立空目錄。

常見責任：

```txt
presentation/
  Page、Widget、Bloc、presentation localization mapping

domain/
  Entity、Repository interface、optional UseCase、business policy

data/
  DTO mapping、DataSource、Repository implementation、local adapter coordination
```

Feature 內的 exact structure 應優先跟隨最相近的既有 Feature，而不是建立新的全域慣例。

### Presentation structure依責任建立，不依folder模板建立

Presentation細分由[ADR-032 — Presentation Component Responsibility and State Ownership](../adr/adr-032-presentation-component-responsibility-state-ownership.md)擁有。`Page`、`View`、`Section`、`Component`、`Surface`、`Layout`是responsibility roles，不是每個Feature都必須建立的資料夾或class tree。

實作時先問「誰擁有這個change reason／lifecycle／state authority」，不要先問「它應該放pages還是widgets」。小Feature可以單一source完成相鄰責任；只有owner真正分離才拆檔。`setState`、Hook、Controller本身不是架構異味；純UI lifecycle state只有在升級為workflow／async ordering／retry/failure/concurrency responsibility後才需要Cubit／Bloc。

小型Feature可以只有：

```txt
presentation/
  feature_page.dart
```

只要該source仍是一個coherent primary responsibility，就不需要為了形式建立`pages/`、`widgets/`、`components/`。反之，如果一個Page/View同時擁有route orchestration、獨立section implementation與custom RenderObject/layout engine，即使全部都在Presentation，也應依change reason拆到正確owner。

常見判斷：

| 問題 | 預設owner |
|---|---|
| route/screen admission、自己Bloc binding、screen-level effect | Page |
| screen state → loading/error/content composition | View |
| screen內具獨立產品語意的bounded區塊 | Section |
| bounded且有穩定input/output的UI unit | Component |
| Dialog/BottomSheet/Overlay本身UI與local interaction | Surface implementation owner |
| 何時打開Surface、結果如何接回flow | Invocation owner |
| projection/custom RenderObject/layout algorithm | Layout owner |
| TextEditing/Focus/Scroll/Animation controller、expand/collapse | local State/Hook/Controller |
| workflow transition、async ordering、retry/failure/concurrency | Cubit/Bloc |

不要因為檔案很長就直接拆，也不要因為存在兩個private widgets就一個class一檔。真正的extract signals是不同change reason、lifecycle、state/navigation/layout authority，或已形成可獨立review/test/replace/reuse的boundary。

Handwritten `part`／`part of`仍是同一Dart library；把不同owner搬到不同folder但繼續用`part of`綁在一起，不算完成responsibility separation。Generated `part`不受此規則限制。

Feature-local UI promotion到Design System仍依[ADR-018](../adr/adr-018-design-system-theme-boundaries.md)：single-screen exact component留feature-local，只有shared semantic、Theme Identity或validated reusable component才promotion。

## 3. Define Domain Contracts First

先定義對 Presentation 有意義的 Domain contract：

- Entity 或 value object。
- Repository interface。
- 只有真正需要獨立 application/domain behavior owner 時才建立 UseCase。
- 預期失敗的 typed contract。

UseCase 粒度由 [ADR-008 — Use Case Granularity](../adr/adr-008-use-case-granularity.md) 擁有。

若一個 UseCase 只把同一組參數原樣交給單一 Repository method，且不包含 policy、validation、mapping、ordering、compensation 或 orchestration，預設不要建立；Presentation 可直接依賴 Repository interface。

不要讓 Domain import：

```txt
Flutter Widget / BuildContext
Dio / Retrofit
SQLite implementation
GetIt / Injectable
AutoRoute
AppLocalizations
```

Expected operational failure 與 unknown error 的處理方式由 [ADR-020 — Exception, Failure and Reporting](../adr/adr-020-exception-failure-reporting.md) 擁有。

## 4. Add Data and External Integration

### Remote API

同一 backend 的一般 HTTP endpoint 應使用 `packages/api_client` 既有 Retrofit boundary，並保持 wire DTO 與 Domain model 分離。

先閱讀：

- [API Client Package README](../../packages/api_client/README.md)
- [ADR-013 — Retrofit HTTP API Boundary](../adr/adr-013-retrofit-http-api-boundary.md)

Feature data layer 通常負責：

```txt
RemoteDataSource
→ 呼叫 API abstraction
→ 映射 transport exception
→ 轉換 wire DTO

Repository implementation
→ 協調 DataSource
→ 轉換 Domain result / Failure
```

### Persistence

先判斷資料類型與 authority：

- Credential：使用既有 secure credential boundary。
- Public relational／queryable data：考慮 App-owned SQLite。
- 小型 user preference：考慮 App-owned preference store。
- Legacy storage：只能依已核准 migration policy 使用。

不要把所有 API response 自動寫入 SQLite，也不要自行建立 generic HTTP cache。

SQLite lifecycle、schema 與 migration 由 App database boundary 擁有。若新增 schema，必須同時處理 fresh-create、incremental upgrade、affected DataSource 與 migration tests。

相關 authority：

- [Flutter Architecture App README](../../apps/flutter_architecture/README.md)
- [ADR-010 — Cross-platform SQLite Initialization](../adr/adr-010-cross-platform-sqlite-initialization.md)
- [ADR-017 — Catalog Offline Cache and SWR](../adr/adr-017-catalog-offline-cache-swr.md)
- [ADR-022 — Authentication Security Capability Boundaries](../adr/adr-022-authentication-security-capability-boundaries.md)

## 5. Compose Dependencies in the App

App 是唯一 Composition Root。

Feature 或 reusable package 使用 constructor injection 表達依賴；App 決定 implementation、lifecycle 與 environment selection。

主要入口：

```txt
apps/flutter_architecture/lib/app/di/register_module.dart
apps/flutter_architecture/lib/app/di/api_implementation_selector.dart
```

需要 generated DI 時，修改 source annotations 或 registration source，再執行 build runner。不要手動修改：

```txt
injection.config.dart
*.g.dart
*.freezed.dart
*.gr.dart
```

DI authority：

- [ADR-004 — App Dependency Injection](../adr/adr-004-app-dependency-injection.md)
- [ADR-012 — Reusable Package DI Boundary](../adr/adr-012-reusable-package-di-boundary.md)

## 6. Integrate Routes and Navigation

新增 route 時先判斷：

- 普通 App route。
- Authenticated-only guarded route。
- Authentication destination transition。
- Shell tab／nested route。

主要入口：

```txt
apps/flutter_architecture/lib/app/router/app_router.dart
apps/flutter_architecture/lib/app/router/auth_guard.dart
apps/flutter_architecture/lib/app/navigation/auth_navigation_coordinator.dart
```

Feature Bloc 不直接操作 Router，也不要跨 Feature 讀取其他 Feature 的 Bloc。

Authentication destination transition 由 App-owned `AuthNavigationCoordinator` 擁有；Feature 只表達自身 intent 與 state，不知道具體 Shell tab 或 route stack identity。

Route Guard 與 authentication navigation authority：

- [ADR-006 — Auth Guard Session Authority](../adr/adr-006-auth-guard-session-authority.md)
- [ADR-007 — Cross-feature State Boundaries](../adr/adr-007-cross-feature-state-boundaries.md)
- [ADR-021 — Auth Startup and Navigation Coordination](../adr/adr-021-auth-startup-navigation-coordination.md)

修改 AutoRoute declaration 後執行 build runner，並 review generated route diff；不要手動修改 `app_router.gr.dart`。

## 7. Add Localization

所有 App chrome 與 Feature user-facing copy 由 App localization resources 擁有。

主要入口：

```txt
apps/flutter_architecture/lib/l10n/app_en.arb
apps/flutter_architecture/lib/l10n/app_zh_TW.arb
apps/flutter_architecture/lib/app/localization/
```

若 generator 需要 base `zh` resource，維持既有 generator contract，不因此擴張公開 supported locales。

Feature expected failure 應在 presentation boundary 映射為 localized copy。不要：

- 直接顯示 diagnostic `Failure.message`。
- 讓 Domain、Data 或 reusable package import `AppLocalizations`。
- 將 server content 寫入 ARB。

Localization authority：

- [ADR-019 — Localization, Locale and Failure Mapping](../adr/adr-019-localization-locale-failure-mapping.md)
- [Design System Package README](../../packages/design_system/README.md)

## 8. Decide Tests by Risk and Failure Owner

先依[Testing Governance](testing_governance.md)完成 **Test Authoring Disposition**，不要從architecture layer反推「每層至少一組tests」。

```txt
new / changed observable behavior
→ risk / invariant / failure mode
→ existing owner是否已充分覆蓋
→ Required | Recommended | no-new-test justified | Should-not-add
→ 若新增test，放到最接近failure source的primary owner
```

典型owner仍可能位於Domain、Data、Presentation或App integration，但layer存在本身不是新增test的理由。例如：

- 有business policy／non-trivial validation的UseCase可以是Required owner。
- pure passthrough UseCase若只會產生「repository called once」test，通常是Should-not-add。
- persistence transaction／migration新增failure mode時通常Required。
- Bloc有ordering／cancellation／state-machine風險時由Bloc owner測；單純把既有result映射到UI不要求複製相同invariant。
- styling／copy-only變更可`no-new-test justified`，但仍需執行planner-selected affected validation。

常見位置：

```txt
apps/flutter_architecture/test/features/<feature>/
apps/flutter_architecture/test/app/
packages/<package>/test/
```

測試應驗證 contract 與 observable behavior，不只複製 implementation detail。

若 Feature 使用 Design System shared surfaces，依需要覆蓋 narrow viewport、large text、Semantics 或 golden regression；不要為每個畫面都新增脆弱 golden。

## 9. Create the Feature README

每個 production Feature 必須建立：

```txt
apps/flutter_architecture/lib/features/<feature>/README.md
```

README 至少說明：

- Responsibilities。
- Non-responsibilities。
- Dependency／data flow。
- 重要 lifecycle 或 integration boundary。
- Tests location。
- Related Decisions。

Feature README 保存 local current contract，不保存逐 Task journal、commit timeline、歷史測試數或完整 ADR 正文。

README coverage 由 repository documentation checker 驗證。

## 10. Decide Whether an ADR Is Required

只有變更會改變穩定責任邊界時，才新增或更新 ADR，例如：

- Dependency direction。
- App／Package ownership。
- Persistence authority。
- Runtime lifecycle ownership。
- Security contract。
- Cross-feature state authority。
- External system boundary。

只新增一個遵守既有規則的 Feature，通常不需要新 ADR。

若需要 Decision，先完成討論與 design review，再更新 [ADR index](../adr/README.md) 與 canonical record；不要把 Guide 或 Feature README 當成 Decision authority。

## 11. Generate and Verify

Feature完成mutation後，先由repository-owned **Minimum Sufficient Validation** planner依Task／commit range產生validation plan；不要自行把Feature工作提升成full workspace regression：

```bash
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

一般single Feature change預期從focused／affected開始，並依實際App shared boundary、package dependency、generated、database或native影響升級。Planner回傳的test／analyze／generated／platform scopes是執行authority；Agent不得自行猜測或補成full。

只有planner要求full、Milestone holistic、manual full、release或post-release gate才執行fresh full workspace regression。

若修改 App runtime flow，再執行：

```bash
cd apps/flutter_architecture
flutter build bundle
```

若修改 Android／iOS native capability、environment mapping 或 verification artifact，依 [CI/CD Operations Guide](ci_cd_operations.md) 與 [Native Environment Adoption Guide](native_environment_adoption.md) 執行對應平台驗證。

Commit 前確認：

- Generated diff 來自 source change，且沒有手動修改 generated file。
- Feature README 與 current implementation 一致。
- 沒有新增跨 Feature Bloc dependency。
- 沒有讓 reusable package 依賴 App／DI framework／plugin implementation。
- 沒有將 historical plan 或 audit 當成 current authority。
- Minimum Sufficient Validation plan要求的docs／analyze／tests／generated／必要build全部通過。
- Test Authoring Disposition已記錄；若為`no-new-test justified`，reason與existing owner／risk rationale清楚，且沒有缺失的Required owner。

## Completion Checklist

```txt
[ ] 已閱讀相關 ADR、App／Feature／Package README
[ ] 已確認 Feature 與 Package responsibility
[ ] Domain contract 不依賴 framework／transport implementation
[ ] DataSource／Repository mapping 與 persistence authority清楚
[ ] App Composition Root 已完成 DI registration
[ ] Route／Guard／Coordinator boundary正確
[ ] User-facing copy已 localization
[ ] 已完成Test Authoring Disposition；新增tests由risk／failure owner驅動，不由layer／class數驅動
[ ] Feature README已建立或更新
[ ] 已完成 ADR decision gate
[ ] Generated source已更新且review
[ ] docs_check、analyze、tests與必要build通過
```
