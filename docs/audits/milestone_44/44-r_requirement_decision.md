---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-44-requirement
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Pencil Component Constraint Semantics Corrective — Requirement Decision

## Requirement Decision

- **Request（需求）**：審查 current Pencil reference implementation 中大量座標式 UI 是否仍違反 constraint/relationship layout architecture；若存在缺口，建立可防止「component-local fixed canvas laundering」復發的 repository-wide corrective。另將 fresh audit 發現的 Flow/Coordinator 與 same-semantic color edge case 個別做 disposition，但不讓它們擴張本 Milestone 的 production implementation scope。
- **Problem（問題）**：Milestone 41 已禁止 whole-screen canonical `x/y × shared scale` page-flow reconstruction，Milestone 43 已建立 responsibility/state ownership，但 current reference implementation 仍可在每個 bounded section 內大量使用 `Positioned(left/top/width/height)` 與 design-space projection。現有 machine gate 能辨識 whole-screen fixed canvas，卻沒有辨識「把 screen 切成多個 flow regions 後，每個 region 仍退化成 local fixed canvas」的情況。這是已有 production evidence 的 correctness / governance defect；相較之下，Flow/Coordinator 是未造成 current production failure 的 completeness finding，same-semantic color 則已有正確 ownership 原則，只缺 edge-case clarification。
- **Current behavior（目前行為）**：
  - `write_precheck_content.dart` 仍約 1354 行，含大量 `Positioned`、`left/top/right/bottom` 與 `_positioned*` / `_local*` coordinate helpers。
  - `write_precheck_content_components.dart` 的 `WritePrecheckStep`、`WritePrecheckDataRow`、`WritePrecheckRecordTile`、`WritePrecheckSecondaryAction` 直接以 design-space `left/top` 作主要 component layout semantics。
  - `write_precheck_projection.dart` 提供 `designWidth = 941`、`px()`、`ProjectedComponent`、`ProjectedStack` 等 projection machinery；current policy允許 bounded overlay，但沒有限制 coordinate-driven composition 的密度、角色或「主 layout semantics」。
  - Repository-wide source scan顯示此類大量 production coordinate usage集中於 `features/pencil_compatibility/presentation/write_precheck`；普通 Catalog/Auth/Shell 並未出現同類 pervasive coordinate reconstruction。
  - ADR-032有Page/View/Section/Component/Surface/Layout/Shell與state escalation，但沒有正式 `Flow/Coordinator` responsibility role；此 finding 目前沒有 production failure evidence。
  - ADR-018已明文禁止「只要 Pencil exact 就全部 feature-local」，semantic ownership方向正確；same-semantic slight color drift 的裁決順序可作 bounded clarification，但不需要 Design System/Theme production refactor。
- **Expected behavior（預期行為）**：
  - 一般 app screen 與其一般 content components 都以 Flutter constraints、alignment、padding、Row/Column/Flex、intrinsic/parent relationships 作主要 layout semantics；`Stack/Positioned` 只負責真正 bounded overlay / artwork / ornament / badge 等 spatial layering，不得成為 text、row、button、card content 的普遍座標排版引擎。
  - Machine governance能 fail-closed 偵測「component-local fixed canvas laundering」而不誤禁合法 overlay。
  - Current Pencil reference implementation 逐區域改為 relationship-owned layout；只有有合理 spatial-layering rationale 的局部 visual 保留 coordinate placement。
  - Flow/Coordinator finding 記錄為 follow-up candidate，不在本 Milestone 建立新 framework、role implementation或 mandatory governance surface。
  - Pencil/Theme 色彩只做 bounded clarification / pressure hardening：raw hex 輕微差異不得自動製造 feature-local colors，也不得自動抹平 accepted intentional variants；除非後續發現實際 production misuse，否則不修改Theme/Design System production source。
- **Value（價值）**：阻止「形式上通過 screen-root constraint gate、實際上仍是大量 fixed coordinates」成為模板示範，並把 corrective scope 鎖定在已有 production evidence 的真正缺陷，避免 architecture Milestone 因相鄰議題無限膨脹。
- **Classification（分類）**：Level 4 — Architecture / Milestone。
- **Decision（決策）**：Accept。
- **Scope（範圍）**：ADR-028與必要ADR-032 review-question clarification、Pencil implementation mapping/pressure scenarios、machine architecture contract、Pencil reference `write_precheck` relationship-layout corrective、bounded same-semantic color clarification，以及必要 current authority/evidence。
- **Non-goals（非目標）**：禁止所有 `Positioned`；建立 universal responsive layout framework；在本 Milestone 正式導入 Flow/Coordinator role/framework/folder；重構 Theme/Design System production implementation；把所有 exact Pencil values 全部提升 Design System；重做 accepted `.pen` visual design；任意改變 golden threshold/crop/ignore region；全面重構所有歷史 Pencil 畫面。
- **Behavioral requirements required（是否需要行為需求）**：是。
- **Design Spec required（是否需要 Design Spec）**：是。
- **Implementation Plan required（是否需要 Implementation Plan）**：是。
- **ADR required（是否需要 ADR）**：是，主責更新 ADR-028；ADR-032只在需要補 component-local relationship ownership review question時修改；ADR-018最多做same-semantic color bounded clarification。Flow/Coordinator不在本 Milestone建立stable role。
- **Task governance mode（Task 治理模式）**：Full two-layer Task governance。
- **Worktree／branch**：Design/Plan accepted後建立 managed worktree；admission/design artifacts先在 current `main` 保存。
- **Regression level（Regression 等級）**：Full；Pencil visual/runtime authority、generic architecture contracts與repository docs/machine policy均為必要 gate。
- **Release required（是否需要發布）**：由 holistic review決定；若 production reference implementation / stable repository-wide contract變更，預期需要新的 Template Baseline。
- **Post-release validation（發布後驗證）**：若 release，required。
- **Required Superpowers skills（必要 Superpowers Skills）**：brainstorming → writing-plans（Design accepted後）→ TDD/systematic-debugging as routed → executing-plans/subagent-driven-development → review/verification。
- **Required artifacts（必要 artifacts）**：Requirement Decision、Design Spec、Design review、Implementation Plan、Plan review、per-Task review evidence、holistic final review；若 release，再加 post-release validation。

## Fresh admission evidence

```txt
repository_kind = template
VERSION = 1.22.0
main = origin/main = 8c2aab2a0b59b9484b89c7eb4031f7e79ecf3836
Milestone 43 = CLOSED
previous active milestone = none
```

## Initial architecture findings

### P1 — Bounded-overlay rule過寬，可掩護 component-local fixed canvas

Current ADR-028正確允許Hero badge/glow/ornament等bounded local overlay；但 implementation沒有 machine-level distinction between legitimate overlay 與 local fixed canvas。普通 labels/values/buttons/rows/cards 若主要依 design-space x/y 排列，即使被包進 bounded container，也不應自動被視為合法 overlay。

### P1 — Reference implementation responsibility仍過度集中

`write_precheck_content.dart` 雖已把 major sections改成 `Column + _flowRegion`，但單一 source仍同時擁有screen content composition、多個 major section implementation、status/header/progress/hero/summary/results/records/guidance/actions/footer以及大量 coordinate helpers。M43拒絕 line-count oracle是正確的，但本例存在的是多個獨立產品語意與change reasons，不是單純「檔案很長」。

### P2 — Flow/Coordinator stable role完整性 finding

Current governance能描述Shell/navigation與screen-level workflow state，但沒有正式命名multi-screen step workflow owner。這是合理的future governance candidate；目前repository沒有需要它才能修正的production failure，因此不升為本Milestone implementation scope。

### P2 — Same-semantic Pencil color reconciliation可再明確

Current authority方向正確，且已禁止「Pencil exact = feature-local」逃生艙。補強只需明確representation noise / semantic role / intentional variant / decoration的裁決順序與behavioral pressure；沒有production misuse evidence時不得藉此重構Theme/Design System。

## Requirement disposition

Open P0：0。

Open P1 without disposition：0（兩項P1 fixed-canvas/reference responsibility納入Milestone 44；Flow與color findings降為P2並已有bounded disposition）。

Requirement Decision：**ACCEPTED**。

