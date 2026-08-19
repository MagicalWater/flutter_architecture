---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-018-design-system-theme-boundaries
last_reviewed_baseline: 1.25.2
id: ADR-018
title: Design System and Theme Boundaries
supersedes:
superseded_by:
related:
  - ADR-003
  - ADR-012
  - ADR-016
  - ADR-017
  - ADR-019
  - ADR-020
---

# ADR-018 — Design System and Theme Boundaries

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Design System package、Theme Identity／Theme Mode、design tokens、shared presentation primitives、App-owned preference與 feature integration的責任邊界。

## Context

若 feature直接宣告 raw color、spacing、typography與 loading／empty／error surfaces，視覺規則會分散且難以支援多主題。若 Design System反過來接收 Bloc state、Failure或 domain entity，又會使 reusable UI package依賴 feature semantics。

Theme Identity與 Theme Mode也必須分離；Light／Dark是同一 Theme Identity的顯示 variant，不是兩套獨立品牌主題。

## Decision

### Package ownership

`packages/design_system`是純 Flutter UI foundation，負責：

- Primitive、semantic與經穩定 consumer驗證的 component tokens。
- Theme definition、registry、Light／Dark `ThemeData`與 Material component themes。
- Material contract不足時的少量 semantic `ThemeExtension`。
- Primitive components與跨 feature共用的 page-state surfaces。
- Accessibility-friendly presentation contract。

它不負責 App bootstrap、Router、Bloc、Repository、UseCase、DataSource、persistence、DI registration或 feature business semantics。App仍是唯一 Composition Root。

### Theme Identity and Mode

主題系統包含兩個獨立維度：

```txt
Theme Identity
  品牌色、semantic colors、typography、radius、elevation與 component appearance

Theme Mode
  system / light / dark
```

每個 Theme Identity必須同時提供 Light與 Dark variant。`system`只根據 platform brightness選擇目前 identity的 variant。

Theme ID是可持久化的 stable value，使用 lowercase contract：以小寫英文字母開頭，只允許小寫英文字母、數字、底線與連字號；不進行隱式 trim或 lowercase。Registry必須拒絕 duplicate ID、確認 default存在，並將 unknown／removed ID fallback至 default。

### Token and theme hierarchy

Design tokens分成：

```txt
Primitive Tokens
Semantic Tokens
Component Tokens
```

Raw palette保持 package internal。Feature使用 Material `ColorScheme`、public semantic extension、public layout tokens與 public primitives，不得 import raw palette或 deep import `lib/src/`。

Material `ThemeData`與 component themes優先；`ThemeExtension`只補 success、warning、info等 Material contract未完整表達的 semantic role，不作為所有 raw token的容器。

### Design-space measurement scaling

Shared design-derived measurement 被 promotion 到 Design System 後，仍保留 design-space scaling；promotion 只改變 semantic ownership，不把設計稿數值轉成固定 runtime logical constant。

- App Composition Root 擁有 product-specific design baseline 與 `ScreenUtilInit` lifecycle。
- `packages/design_system` 可以依賴 shared sizing engine，解析 spacing、inset、radius、icon size、component geometry 等 shared design-derived tokens。
- Current `DsSpace`、`DsRadius`、`DsIconSize` 使用 uniform `.r = min(widthScale, heightScale)` semantics；caller 直接消費 resolved token，不得再次 scaling。
- Single-consumer exact measurement 留在 smallest correct presentation owner，可依 measurement semantics 使用 `.w/.h/.r`。
- Scaling legality 不依 property 名稱決定；padding、offset、x/y、`left/top/right/bottom` 等都可以是 design-space measurement。Layout architecture 另依 relationship / spatial ownership 判斷。
- Typography 不因 geometry scaling 自動採 `.sp`；system `TextScaler` 與 accessibility contract 必須保持有效。

### Feature boundary

Feature可以把自己的 state映射成純 presentation properties後交給 Design System primitive，但不得把 Bloc state、Failure、Catalog snapshot或 domain entity直接傳入 Design System。

Blocking與 non-blocking operation surface必須分離。Initial blocking error可使用 blocking error surface；Refresh、Append、Revalidation等 failure必須保留既有內容與 operation context，使用 non-blocking notice或 feature-local UI。

不為單一 feature情境建立尚未被多個 consumer驗證的 generic component framework。

### UI Design Ownership Architecture

Pencil/source-driven UI不得用`FeatureVisualSpec`、`FeatureVisualTokens`、`FeatureUiSpec`、`StyleConfig`或等價catch-all建立第二套Design System。每個risk-selected UI design value必須先解析到正確owner：

```txt
shared semantic / Theme Identity / validated reusable component
→ packages/design_system public API

raster / vector / icon / font / texture representation
→ asset / representation provenance authority

canonical viewport / DPR / comparison assumptions
→ visual-authority metadata

screen / section placement mechanics
→ presentation layout owner

single-screen exact geometry / decoration
→ smallest correct component owner
```

Promotion判斷依semantic identity、stable theme responsibility與consumer evidence，不依raw value相同。反方向也禁止把single-consumer exact radius、gradient、offset或artwork geometry提升成global Design System token。

Feature-local owner只允許窄責任、可解釋的exact visual authority，例如同一accepted proof多個bounded components共用的local palette或typography。它不是「只要Pencil exact就全部放feature-local」的逃生艙，也不得同時承擔colors、dimensions、typography、asset paths、gradients與canonical metadata。

Accepted Pencil/source中近似但不完全相同的raw colors不得只依hex差異自動新增feature-local token。裁決順序固定為：先排除alpha blending／anti-alias／raster sampling／gradient sample／export difference等representation noise；再判斷是否為不同semantic role；若為同semantic role，只有具明確intentional contextual variant且有stable cross-consumer semantics時才promotion為semantic/component variant；純單一component decoration則留smallest correct component owner。反方向也不得為了Theme一致而抹平accepted intentional semantic/context variant。

Asset path/provenance不得由visual token/spec owner接管；Design System也不保存canonical viewport/DPR或initiative-specific comparison metadata。

Runtime asset integration必須再區分三個互不取代的軸：

```txt
ownership axis
→ Design System / App-Product / Feature / smallest component owner

selection axis
→ static / Theme Identity / Brightness / bounded semantic state

provenance axis
→ accepted source / transformation / repository destination / content hash / consumer
```

Repository使用FlutterGen產生package-local typed asset accessor。FlutterGen只擁有bundle path的generated access，不擁有semantic identity、Theme selection或representation provenance；generated accessor已存在時，production consumer不得重新手寫相同bundle path。

Theme-aware asset以stable `DsThemeId`與resolved `Brightness`作selection input，不以raw `Color` equality、seed color或screenshot sampled color反推。目前visual即使會隨Theme Identity切換，其ownership仍依change responsibility決定；App／Feature artwork不會因theme-aware就自動promotion到Design System。只有存在實際selection／semantic mapping時才建立bounded resolver；generated directory accessor本身已能清楚表達owner時，不為形式再包一層asset registry。

App-owned theme-aware visual resolver必須使用`DsThemeRegistry`既有resolve/default semantics；不得建立第二套Theme fallback registry。Feature取得Theme Identity時只依賴App提供的presentation-level read contract，不直接讀theme preference persistence implementation。

### App-owned preference

Theme preference至少包含 stable `themeId`與 `system | light | dark` mode。App負責 preference model、versioned persistence、bootstrap restore、controller lifecycle、registry composition、`MaterialApp` wiring與 selector UI；Design System不依賴 persistence implementation。

Preference mutation採 runtime-first與 serialized complete-snapshot writes：

- Runtime立即套用最新選擇。
- Persistence failure不回滾目前 UI，也不阻止較新 mutation繼續保存。
- Latest preference必須成為最後 persisted snapshot。
- Bootstrap read failure使用 default theme＋system mode啟動，保留 non-blocking diagnostic，不阻止 `runApp`。
- Invalid／missing persisted value與 storage exception需分開處理。

Bootstrap在 `runApp`前完成 restore，避免明顯 theme flash。

### Accessibility

Design System與 feature integration不得禁止 system text scaling，不以固定高度承載可換行文字。Shared surfaces與主要 interaction需維持適當 Semantics、touch target、narrow viewport與 Light／Dark可用性。

## Consequences

- Feature視覺依賴集中在 semantic theme contract，不綁定 raw palette。
- Theme Identity可和 system／light／dark交叉組合。
- Theme Identity／Brightness可選擇不同runtime asset representation，而不改變asset的App／Feature／Component ownership。
- Design System維持 reusable UI package，不知道 Auth、Catalog、Cache、Failure或 localization workflow。
- Theme preference與 persistence lifecycle由 App明確擁有。
- Presentation migration不得改變既有 Auth、Pagination、SWR或 cache state machine。

## Supersession

無。

## Related Decisions

- ADR-003：Presentation state與 Hooks責任。
- ADR-012：Reusable package不綁定 App DI framework。
- ADR-016／017：Catalog operation與 cache state由 feature映射至 presentation surfaces。
- ADR-019：Design System只顯示呼叫方提供的 localized strings。
- ADR-020：Failure identity與 user-facing surface責任分離。

## Related Evidence

- [Design System package README](../../packages/design_system/README.md)
- [App README](../../apps/flutter_architecture/README.md)
- Historical implementation details：Git history / `CHANGELOG.md`

## Last Reviewed Baseline

1.25.2；Design-space scaling integration補入shared design-derived measurement runtime scaling、App-owned baseline與property-neutral scaling contract；Milestone 42補入repository-wide UI Design Ownership Architecture、Design System promotion/non-promotion與anti-catch-all contract；Milestone 44再補same-semantic raw color的representation-noise／semantic-role／contextual-variant／component-decoration裁決順序；Asset Runtime Integration補入FlutterGen generated access、theme-aware selection與ownership/provenance axis分離。
