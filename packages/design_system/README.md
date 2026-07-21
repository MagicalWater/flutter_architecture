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

測試位於 `packages/design_system/test/`，應涵蓋 token contract、registry validation、Theme matrix、semantic colors、callbacks、Semantics、text scaling與少量 stable gallery goldens。

## Related Decisions

以 `docs/architecture_decisions.md` 的 Design System Foundation與 Localization boundary Decisions 為 authority。

本 README 只保存 current package contract；Milestone 15 的計畫、review、test count與 commit timeline留在 historical artifacts。
