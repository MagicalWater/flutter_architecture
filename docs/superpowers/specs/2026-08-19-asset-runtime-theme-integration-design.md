# Asset Runtime Ownership & Theme-aware Representation Integration — Design

Status: **accepted**

Accepted: 2026-08-19 by explicit user approval after whole-Design review.

## 1. Goal

在不重做既有 Theme System、Design System 或 representation/provenance contract 的前提下，補上 runtime typed asset access 與 Theme-aware visual representation selection。

FlutterGen 是機械 generator；repository architecture 仍決定 asset owner、selection semantics 與 provenance owner。

## 2. Current authority

Current stable architecture已存在：

- `DsThemeId` + `DsThemeRegistry`：Theme Identity selection。
- `DsThemeDefinition`：Light / Dark `ThemeData` factory。
- ADR-018：Design System / Theme / feature-local / smallest-owner UI Design Ownership。
- ADR-028 + `asset-and-typography-mapping.md`：asset representation identity與 provenance。
- App：唯一 Composition Root，擁有 theme preference、controller、registry composition、`MaterialApp` wiring。

Gap 是 runtime visual asset access與theme-aware selection，不是 representation source authority。

## 3. Rejected extremes

### A. Raw path everywhere — Reject

```dart
Image.asset('assets/images/home/hero.png')
```

理由：consumer同時擁有 semantic identity與bundle path，rename/typo與 package path coupling散落。

### B. One global mega `AppAssets` — Reject

把所有 App、Feature、component assets集中在一個 class，只是把 path string 搬家；責任與 change reason仍混合。

### C. Assets inside `DsThemeDefinition` — Reject as default

`DsThemeDefinition`是 reusable Design System Theme contract。Product/feature artwork即使隨 Theme Identity 切換，也不因此成為 Design System asset。

只有真正由 Design System reusable Theme Identity 擁有的 visual representation，未來才可在 Design System自己的 bounded theme visual contract中存在；不是本 Design 的 default route。

### D. Provenance in runtime constants — Reject

禁止把 source node、content hash、transformation、destination metadata複製進 `AppAssets` / `FeatureAssets` / Theme resolver。

## 4. Three independent responsibilities

### 4.1 Generated Asset Access

FlutterGen owns only:

```txt
pubspec asset declarations
→ generated package-local Dart accessor
→ typed/path-safe runtime reference
```

Recommended production usage：

```dart
Assets.images.home.hero.image()
```

Framework API需要 raw path時才使用 generated `.path`，不要重新手寫 literal。

Generated source屬 build output authority，不得手改。

### 4.2 Semantic Runtime Ownership

Owner hierarchy：

```txt
Design System reusable asset
→ packages/design_system

App / Product shared identity or artwork
→ App-owned asset scope

Feature visual identity
→ affected Feature presentation asset scope

Single-component exact visual
→ smallest correct component owner
```

Generated directory nesting可以直接表達足夠清楚的 ownership 時，不要求額外 wrapper class。

Example：

```dart
Assets.images.nfc.scannerFrame
```

若只有 NFC feature 使用且 directory owner已明確，consumer可直接使用 generated accessor；不要形式化再包一層 `NfcAssets`。

只有當 selection / semantic mapping / multiple physical representations需要 encapsulation 時，才建立 bounded typed owner/resolver。

### 4.3 Representation / Provenance

Existing authority remains:

```txt
accepted source
→ export/source identity
→ transformation
→ repository destination
→ content hash
→ Flutter owner / consumer
```

FlutterGen / runtime resolver只能 consume resolved destination，不得成為 source/hash authority。

## 5. Theme-aware Asset Selection

Theme-aware asset selection是一個 **selection axis**，不是 ownership axis。

### 5.1 Selection inputs

合法 input：

- `DsThemeId`
- resolved `Brightness`
- bounded semantic state（例如 status variant），若該 owner確實需要

禁止以：

- raw `Color` equality
- seed color
- screenshot sampled color

判斷 asset representation。

### 5.2 Owner stays local

Examples：

| Visual | Owner | Selection |
|---|---|---|
| Product logo | App/Product | static or Theme Identity |
| Home hero with Default/Ocean variants | App/Product or Home feature，依change ownership | `DsThemeId` + brightness |
| NFC scanner frame variants | NFC feature | `DsThemeId` / brightness |
| Reusable DS status illustration | Design System | DS semantic/theme contract |
| Single component ornament | component | static / local state |

Theme selection不會自動promotion ownership。

## 6. Resolver Shape

Repository不建立一個涵蓋所有產品 visuals 的 universal framework。採 **bounded resolver**。

App-owned reference shape：

```dart
abstract interface class AppThemeVisuals {
  AssetGenImage get sampleHero;
}

AppThemeVisuals resolveAppThemeVisuals({
  required DsThemeId themeId,
  required Brightness brightness,
}) { ... }
```

這個 contract只在 App真的有 App-owned theme-aware visual consumer時存在。

Feature equivalent應留 feature：

```dart
NfcThemeVisuals resolveNfcThemeVisuals(...)
```

不建立：

```txt
GlobalThemeAssetRegistry
AllFeatureAssetRegistry
UniversalVisualResolver
```

## 7. Composition / Context access

Theme-aware resolver不得要求 Feature deep-read `ThemeController` internals。

Runtime consumer能從 current Flutter context取得：

- resolved `Brightness`：`Theme.of(context).brightness`
- Theme Identity：由 App 提供 stable presentation-level access，不要求 consumer讀 persistence store。

Design implementation時優先重用 current `ThemeControllerScope` / existing App composition pattern；若 current context API只暴露 controller且會造成 feature coupling，Plan必須選最小的 read-only Theme Identity exposure，而不是新建 DI/global singleton。

## 8. FlutterGen Adoption

Use current stable `flutter_gen_runner` 5.15.x line，exact resolved version由 Plan/lockfile resolution固定。Current upstream requirement supports Dart pub workspaces and `build_runner >=2.12.0`; repository current `build_runner 2.15.0` satisfies that compatibility floor。

Integration principles：

- package-local `pubspec.yaml`擁有自身 assets / FlutterGen config。
- workspace generation使用 upstream-supported workspace flow。
- 不引入另一套自製 asset generator。
- Generated output納入 repository current generated-code policy；不得手改。
- 如果 package assets需要 implicit package parameter，使用 FlutterGen package output capability，不手拼 `packages/foo/...` path。

## 9. Minimal Reference Implementation

為了證明 contract，App新增一組極小、非產品 art-direction 的 reference visual assets：

```txt
Default Light
Default Dark
Ocean Light
Ocean Dark
```

要求：

- 四個 assets只用來驗證 theme-aware typed selection。
- 不把 reference asset當新的 Pencil/brand visual authority。
- consumer保持 bounded，不重構現有產品 screen。
- Design/Plan implementation若可用 deterministic existing neutral fixture assets 達成，不新增額外複雜美術。

## 10. Color / Theme Boundary

本 Design 不改變 ADR-018 existing Color semantics：

- Theme/shared semantic color → Theme / DS owner。
- feature-local shared semantic → narrow feature owner。
- component exact decoration → smallest owner，可保留 literal。

Theme-aware image selection只新增 visual representation axis，不讓 Theme System吸收所有 image ownership。

## 11. Architecture Violations

以下視為 stable violation：

1. Production UI在已有 FlutterGen accessor時重新手寫相同 bundle path。
2. 用 raw color equality決定 theme asset。
3. App/Feature artwork只因「會隨 Theme換」就 promotion 到 Design System。
4. 建立 global mega asset registry混合無共同 change reason 的 assets。
5. Runtime asset constants保存 source hash / provenance metadata形成第二 authority。
6. Feature為了取得 Theme Identity直接依賴 preference persistence implementation。
7. One-off generated asset accessor已有清楚 owner，仍機械建立無行為 wrapper class。

## 12. ADR disposition

Amend ADR-018：

- 增加 runtime asset ownership與theme-aware representation selection作為 UI Design Ownership Architecture 的 extension。
- 明確區分 ownership axis、selection axis、provenance axis。
- FlutterGen只作 generated access mechanism，不成為 semantic authority。

ADR-028只在 implementation review發現 representation/provenance wording需要一行 cross-reference時同步；預設 stable representation rules不變。

## 13. Validation strategy

不恢復大量 tests。Validation遵守 test-by-exception：

- FlutterGen generation / compile evidence。
- 一個最小 resolver behavioral check或等價 focused runtime evidence，證明 Theme Identity + brightness mapping正確。
- analyzer / relevant package checks。
- validation planner決定 changed-risk scope。
- temporary test若只用來證明 mapping，在 GREEN後做 Retention Decision；只有 resolver mapping屬 critical stable invariant且 failure難以由 compile/runtime直接發現時才保留 permanent test。

## 14. Acceptance criteria

1. FlutterGen取代 future raw path string access作 repository default。
2. Generated accessor不擁有 semantic/theme/provenance responsibility。
3. Theme-aware asset selection可以表達 Default/Ocean × Light/Dark。
4. App / Feature / Component ownership不因 Theme selection被提升或混合。
5. Feature不直接依賴 persistence取得 Theme Identity。
6. Existing representation/provenance authority保持 single owner。
7. 沒有 mega registry / generic VisualSpec / universal resolver。
8. ADR-018、package docs、source與generator config一致。
9. Focused generation/compile/behavior evidence通過，validation scope由 planner決定。

