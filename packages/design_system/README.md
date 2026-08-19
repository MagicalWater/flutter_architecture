---
document_type: package-readme
status: accepted
authoritative_for:
  - design-system-package-local-contract
last_reviewed_baseline: 1.5.1
---

# Design System Package

`design_system` 是可重用 UI foundation package，提供 tokens、Theme contracts與跨 feature 通用 presentation primitives。

## Responsibilities

- Spacing、Radius、Elevation、Icon Size tokens。
- `DsThemeId`、metadata、definition與 registry contract。
- Default／Ocean 的 Material 3 Light／Dark ThemeData。
- `DsSemanticColors` success／warning／info roles。
- 共用 status banner、content constraint、button content與 page-state surfaces。

## Non-responsibilities

- 不依賴 App、Feature、Bloc、GetIt／Injectable或 persistence implementation。
- 不擁有 theme preference、controller或 Appearance selector。
- 不接受 `Failure`、Bloc state、Catalog entity等 business types。
- 不建立 generic form、pagination、search或 responsive framework。
- 不 export raw palette。
- 不吸收single-screen exact radius／gradient／offset／artwork geometry或canonical viewport／DPR。
- 不把Pencil／feature asset path、source hash或provenance當Design System token。
- App／Feature artwork不會因為隨Theme Identity或Brightness切換就自動成為Design System responsibility；theme-aware selection與semantic ownership是不同軸。

Pencil/source-driven UI values進入本package前必須先做semantic／promotion decision。真正shared semantic、Theme Identity或validated reusable component才由Design System擁有；feature-local exact values留smallest correct owner，不能用generic `*VisualSpec`／`*VisualTokens`建立平行Design System。

## Design-space Measurement

Design System 的 shared design-derived measurements 由 `flutter_screenutil` 解析 runtime scale。Promotion 到 shared token 只改變 semantic ownership，不會把原本的設計稿 measurement 固定成 runtime logical constant。

目前 shared measurement contract：

- `DsSpace`、`DsRadius`、`DsIconSize` 使用 uniform `.r` scaling，也就是 `min(widthScale, heightScale)`。
- Consumer 直接使用 `DsSpace.md` 等 public token；token 已完成 scaling，不得再套 `.r/.w/.h`。
- 尚未 promotion 的 feature/component exact measurement 可直接使用 `.w/.h/.r`，由 measurement 的 axis / uniform semantics 決定。
- Padding、gap、radius、size、offset、x/y、`Positioned` coordinate 都可承載 scaled design measurement；layout correctness 由 relationship / spatial ownership 判斷，不以 widget 或 property 名稱禁止。
- Typography 本階段不把 `.sp` 當 repository default；system `TextScaler` 必須保持有效。

Product-specific `designSize` 由 App Composition Root 擁有，Design System 不保存產品 baseline。

## Public API

Consumer 只透過：

```dart
import 'package:design_system/design_system.dart';
```

使用 public API，不應 deep import `lib/src/`。Feature 應使用 Material `ColorScheme` 或 semantic theme extensions，不直接依賴 raw palette。

## Theme Contract

目前 production themes：

```txt
Default Theme  Light / Dark
Ocean Theme    Light / Dark
```

Ocean 使用獨立 palette、semantic colors與有限 typography／radius差異，證明 Theme Identity不是只替換 seed color。

Theme Identity可以作為App／Feature visual resolver的selection key，但`design_system`不因此擁有那些product-specific assets。真正Design-System-owned representation必須先滿足shared semantic／validated reusable component的promotion evidence。

`DsThemeId` 是 persistence與 registry共用的穩定識別值：

```txt
^[a-z][a-z0-9_-]*$
```

合法範例：`default`、`ocean`、`brand_v2`、`brand-v2`。不會隱式 trim或轉小寫；metadata display name不得為空白。

## Shared Surfaces

- `DsStatusBanner`：neutral／info／success／warning／error 非阻塞提示。
- `DsConstrainedContent`：最大寬度、置中與 page padding。
- `DsButtonContent`：Material button idle／loading content。
- `DsLoadingState`：blocking loading surface。
- `DsEmptyState`：empty surface與 optional actions。
- `DsBlockingErrorState`：blocking error與 retry actions。
- `DsMessageState`：一般 message surface。

Refresh、Append、Revalidation、Logout等 operation failure應保留原內容，使用 `DsStatusBanner`或 feature-local non-blocking UI，不使用 blocking error surface。

## Scroll Ownership

`DsEmptyState` 預設處理 viewport-aware scrolling。放入 feature-owned `ListView`／`CustomScrollView` 時使用：

```dart
const DsEmptyState(
  title: 'No results',
  scrollable: false,
)
```

外層 feature負責 scroll、pull-to-refresh與大型文字可到達性。

## Dependency and Composition

App 是唯一 Composition Root。App 選擇 Theme definition、保存 preference、restore controller並呈現 Appearance selector；Design System package只提供可組合 contract。

## Tests

測試遵守 repository test-by-exception。普通 responsive/layout/scaling probe 預設只作 temporary evidence，驗證完成後刪除；只有符合 current test-authoring critical retention 條件的 failure protection 才永久保留。

## Related Decisions

以 `docs/adr/README.md` 中的 ADR-018與 ADR-019為 authority。

本 README 只保存 current package contract；Milestone 15 的計畫、review、test count與 commit timeline留在 historical artifacts。
