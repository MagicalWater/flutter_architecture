---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-42-pencil-presentation-token-governance-corrective-design
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Pencil Presentation Ownership & Visual Token Governance Corrective Design

## 1. Goal

在不改 accepted `.pen`、不降低 visual fidelity、也不建立新的 generic UI framework 的前提下，修正兩個 stable architecture problems：

1. Pencil reference presentation source 的責任混放：`pages/` 同時承擔 page orchestration、layout/render mechanics、section composition。
2. `PencilCompatibilityVisualSpec` catch-all：canonical metadata、palette、typography、layout/component tokens與gradients沒有明確 owner，且缺少 Design System promotion decision。

## 2. Governing principles

### 2.1 Clean Architecture 與 Presentation architecture分開判定

Clean Architecture的核心仍是 dependency direction；`presentation/pages` 裡有大檔案本身不構成 layer violation。但 repository 另外要求 responsibility cohesion：

```txt
Page / View
→ screen orchestration only

Widget / Component
→ bounded visual composition

Layout / Rendering
→ reusable or screen-scoped presentation mechanics

Visual authority metadata
→ comparison/source identity

Design System
→ shared semantic/theme/reusable presentation authority
```

不以 file length、class count或「每個widget一檔」當 architecture truth。

### 2.2 Design System 不是所有 Pencil 數值的垃圾桶

Token promotion不是「看到 color/size 就搬進 package」。只有 shared semantic identity、stable theme responsibility或 validated reusable consumer成立時才提升。

### 2.3 Feature-local visual spec 不是 Design System 逃生艙

Feature-local只允許 screen/component exact authority。若一個值實際代表 app-wide surface、text、brand、status、typography或跨 screen semantic，必須走 Design System mapping/promotion decision。

## 3. Presentation source ownership

### 3.1 Target structure

Reference implementation目標結構：

```txt
features/pencil_compatibility/presentation/
├─ pages/
│  ├─ write_precheck_page.dart
│  └─ write_precheck_view.dart
├─ layout/
│  ├─ write_precheck_projection.dart
│  └─ projected_visual_primitives.dart
├─ widgets/
│  └─ write_precheck/
│     ├─ write_precheck_content.dart
│     ├─ write_precheck_header.dart
│     ├─ write_precheck_progress.dart
│     ├─ write_precheck_hero.dart
│     ├─ write_precheck_summary.dart
│     ├─ write_precheck_results.dart
│     ├─ write_precheck_records.dart
│     ├─ write_precheck_guidance.dart
│     ├─ write_precheck_actions.dart
│     └─ write_precheck_footer.dart
├─ visual_spec/
│  ├─ write_precheck_visual_authority.dart
│  └─ write_precheck_visual_tokens.dart
└─ write_precheck_copy.dart
```

Exact file count不是contract；若兩個小component放在同一檔更清楚可以合併。不可退化成「一個2,000行 renderer file換成20個沒有責任邊界的碎檔」。

### 3.2 `pages/` contract

`pages/` 可以：

- 建立 route/page/view；
- 組合 screen-level Scaffold、LayoutBuilder、ScrollView、providers；
- 委派 content component。

`pages/` 不應直接擁有：

- custom `RenderObject` / `MultiChildRenderObjectWidget`；
- projection/render calibration infrastructure；
- 大量 section-local decoration/component implementations；
- shared visual token definitions。

### 3.3 Layout/render mechanics

Milestone 41已證明 bounded local projection仍對 accepted raster fidelity有責任，因此本Milestone不假設 projection helper必須刪除。它應移到明確的 `layout/` owner，且 contract 仍受 Milestone 41 限制：

- 不得擁有 whole-screen page coordinate plane；
- 不得決定 sibling section placement；
- 只服務 bounded local visual calibration。

## 4. Visual value ownership model

每個 Pencil-derived visual value必須落在以下之一：

### 4.1 Visual Authority Metadata

例：

```txt
canonicalSize
canonicalDevicePixelRatio
canonical frame identity / comparison assumptions
```

Owner：feature visual-authority adapter或initiative mapping，不是 Design System。

原因：它描述 comparison/source contract，不描述產品 theme。

### 4.2 Shared Semantic / Theme Token

例：

```txt
app background semantic
surface semantic
primary/secondary text semantic
brand accent
warning/info/success semantic
global typography family/scale
```

Owner：`packages/design_system` 的 public `ThemeData` / `ColorScheme` / semantic extension / public token。

Promotion條件至少一項成立且沒有反證：

1. 跨兩個以上 screen/feature具有同一 semantic identity；
2. 明確是 Theme Identity的一部分；
3. adopter/product design authority定義為 global token；
4. Design System已有等價 public semantic owner。

只有「顏色值一樣」不構成 promotion。

### 4.3 Validated Reusable Component Token / Primitive

例：跨多個consumer共同使用的 button/container/status appearance。

Owner：Design System，但需要 stable component semantics或 consumer evidence；禁止為單一 Pencil screen建立 `DsWritePrecheck*`。

### 4.4 Feature / Component Exact Token

例：

```txt
Write-precheck hero local radius
records card exact local gap
screen-specific decorative gradient
bounded artwork dimensions
```

Owner：feature `visual_spec/` 或 component-local token group。

條件：值的語意只對該 accepted screen/component成立，且沒有跨 feature semantic responsibility。

### 4.5 One-off Local Geometry

只在單一 component使用、沒有 reusable token semantics的 offset/size/gap，不放進 catch-all spec，直接由該 component local constant擁有。

## 5. `PencilCompatibilityVisualSpec` disposition

Current class必須 retired；不能只rename。

### 5.1 `canonicalSize` / DPR

移至 `WritePrecheckVisualAuthority`（或等價名稱），只描述 canonical comparison contract。

### 5.2 Palette

逐項分類，不預設全部升 Design System。

Reference Pencil compatibility screen是template proof，可能刻意展示與default/ocean theme不同的 accepted visual language，因此不能為了消除local colors就污染global template theme。Decision rule：

- 若對應 current DS semantic role且 visual contract允許 theme mapping → 使用 DS public semantic owner；
- 若 Pencil exact color是此 proof screen 的 accepted local art direction且非 template-wide theme → 保留 `WritePrecheckVisualTokens` feature-local semantic palette；
- 若未來 product master `.pen` 定義同一 palette 為 app-wide → 在產品 Requirement/Design中 promotion到 Design System，不沿用 proof screen的local例外。

### 5.3 Typography

`fontFamily`／fallback先判斷是否為 product/global typography。Template proof若要求 exact Noto Sans TC 而 current Design System不以它作全域 theme，則保留 feature-local typography contract；不得偷偷改 global theme。若產品 adopted design將它定義為全域 typography，則由 Design System Theme Identity擁有。

### 5.4 Radius / dimensions / gradients

- 已與 `DsRadius` / `DsSpace` 等價且不犧牲 fidelity者使用 public DS token。
- exact value不等價、只服務這個screen/component者保留 local。
- component-only value優先移至component-local，避免重新製造 `WritePrecheckVisualTokens` mega-class。

## 6. Machine-readable token disposition

擴充 initiative-local `implementation_mapping.json`（或由現有mapping schema承擔）加入 risk-selected visual token ownership evidence，不建立 global token registry。

建議 record：

```json
{
  "id": "write-precheck-text-primary",
  "kind": "visual-token",
  "semantic_role": "primary-text",
  "owner": "feature-local|design-system|visual-authority|component-local",
  "disposition": "exact|verified-equivalent|intentional-local|promoted",
  "consumer_scope": "write-precheck",
  "evidence": "..."
}
```

Rules：

- `design-system` owner必須指向 public API，不得 deep import `lib/src/`；
- `intentional-local` 必須有 local-scope reason；
- app/global semantic token不得標成 `intentional-local`逃避 promotion；
- `unresolved` fail closed。

只記錄 risk-selected shared-looking values，不要求 every numeric literal都進 mapping。

## 7. Governance contract changes

### ADR-018 amendment

補充：Pencil/source-driven feature在引入 raw visual values前必須做 semantic/promotion decision；feature-local exact tokens是例外，不是第二套 theme system。

### ADR-028 amendment

補充：Pencil → Flutter mapping必須同時做：

```txt
layout ownership decision
+ representation/provenance decision
+ visual token ownership decision
```

並明確禁止：

```txt
FeatureVisualSpec = whole product design-system substitute
```

### Skill / Guide

`implementing-pencil-flutter-design` extraction後，在Flutter mapping前新增 token ownership classification；若發現global semantic token沒有owner，停止implementation並回Design System mapping，不得先 hardcode feature-local。

## 8. Enforcement

### 8.1 Presentation architecture contract

Direct test/review owner檢查 reference screen：

- `pages/` 不包含 custom RenderObject implementation；
- page/view僅委派 content/layout owners；
- projection helpers不再位於 pages；
- whole-screen coordinate shortcut仍由Milestone 41 detector負責。

不以行數作hard fail。

### 8.2 Token governance contract

Machine owner驗證：

- old `PencilCompatibilityVisualSpec`不存在；
- mapping的 risk-selected tokens均有resolved owner；
- Design System owner只使用public API；
- intentional-local有scope/reason；
- canonical metadata不被誤放Design System。

## 9. Reference migration sequence

```txt
RED architecture/token ownership evidence
→ extract layout/render helpers from pages
→ extract bounded screen components
→ classify/retire PencilCompatibilityVisualSpec
→ promote only proven shared semantics
→ keep exact local values at smallest correct owner
→ visual/runtime fidelity recovery
→ ADR/Skill/Guide sync
→ behavioral pressure
→ combined holistic/release gate
```

## 10. Behavioral pressure scenarios

新增至少三題：

### PTF-30 — FeatureVisualSpec escape hatch

Agent把 Login/Home/Settings 共用的 background/text/brand colors全部複製進各自 FeatureVisualSpec，理由是「Pencil exact」。Expected：FAIL，先辨識 shared semantic/theme authority。

### PTF-31 — Single-screen exact token pollution

Agent把一個 Hero 特有 `radius=17`、decorative gradient提升成 global `DsRadius.hero`／`DsGradient.hero`，只有一個consumer。Expected：FAIL/redirect local，避免 Design System pollution。

### PTF-32 — Presentation responsibility

Agent把 page、custom RenderObject、15個section widgets與projection helpers全部放進 `pages/screen_canvas.dart`，dependency direction仍正確。Expected：architecture review FAIL；不是Clean layer violation，而是 presentation ownership/cohesion failure。

## 11. Visual acceptance

Migration後必須維持：

- canonical golden PASS；
- supported runtime golden/diff PASS；
- critical geometry PASS；
- responsive/layout health PASS；
- semantics/copy PASS。

禁止更新 accepted golden、threshold、crop或`.pen`來迎合structure refactor。

## 12. Success criteria

1. `pages/`只保留page/view orchestration，render/layout infrastructure與bounded components有明確 owner。
2. `PencilCompatibilityVisualSpec` retired，沒有同功能 mega-class replacement。
3. Risk-selected visual values有明確 `visual-authority / design-system / feature-local / component-local` ownership。
4. Shared semantic token不能用「Pencil exact」逃避 Design System；single-screen exact token也不能污染Design System。
5. ADR-018、ADR-028、Skill、Guide與machine contract一致。
6. PTF-30～32 fresh behavioral pressure符合預期。
7. Accepted `.pen`與visual fidelity未改。
8. Open P0=0、undisposed P1=0。

