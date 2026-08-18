---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-44-requirement
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Presentation Flow & Pencil Constraint Semantics Corrective — Requirement Decision

## Requirement Decision

- **Request（需求）**：審查並補強 Presentation `Flow/Coordinator` governance、Pencil exact color 與 Theme/Design System semantic ownership，以及 current Pencil reference implementation 中大量座標式 UI 是否仍違反 constraint/relationship layout architecture；若存在缺口，建立可防止未來復發的 repository-wide corrective。
- **Problem（問題）**：Milestone 41 已禁止 whole-screen canonical `x/y × shared scale` page-flow reconstruction，Milestone 43 已建立 responsibility/state ownership，但 current reference implementation 仍可在每個 bounded section 內大量使用 `Positioned(left/top/width/height)` 與 design-space projection。現有 machine gate 能辨識 whole-screen fixed canvas，卻沒有辨識「把 screen 切成多個 flow regions 後，每個 region 仍退化成 local fixed canvas」的情況。ADR-032 亦未正式定義 multi-screen `Flow/Coordinator` owner；ADR-018/028 雖已規定 semantic identity 高於 raw value，但尚缺 same-semantic / slightly-different Pencil color 的明確 reconciliation algorithm。
- **Current behavior（目前行為）**：
  - `write_precheck_content.dart` 仍約 1354 行，含大量 `Positioned`、`left/top/right/bottom` 與 `_positioned*` / `_local*` coordinate helpers。
  - `write_precheck_content_components.dart` 的 `WritePrecheckStep`、`WritePrecheckDataRow`、`WritePrecheckRecordTile`、`WritePrecheckSecondaryAction` 直接以 design-space `left/top` 作主要 component layout semantics。
  - `write_precheck_projection.dart` 提供 `designWidth = 941`、`px()`、`ProjectedComponent`、`ProjectedStack` 等 projection machinery；current policy允許 bounded overlay，但沒有限制 coordinate-driven composition 的密度、角色或「主 layout semantics」。
  - Repository-wide source scan顯示此類大量 production coordinate usage集中於 `features/pencil_compatibility/presentation/write_precheck`；普通 Catalog/Auth/Shell 並未出現同類 pervasive coordinate reconstruction。
  - ADR-032有Page/View/Section/Component/Surface/Layout/Shell與state escalation，但沒有正式 `Flow/Coordinator` responsibility role。
  - ADR-018已明文禁止「只要 Pencil exact 就全部 feature-local」，但沒有把 representation noise、semantic variant、component variant、intentional decorative exactness的裁決順序寫成可執行 contract。
- **Expected behavior（預期行為）**：
  - 一般 app screen 與其一般 content components 都以 Flutter constraints、alignment、padding、Row/Column/Flex、intrinsic/parent relationships 作主要 layout semantics；`Stack/Positioned` 只負責真正 bounded overlay / artwork / ornament / badge 等 spatial layering，不得成為 text、row、button、card content 的普遍座標排版引擎。
  - Machine governance能 fail-closed 偵測「component-local fixed canvas laundering」而不誤禁合法 overlay。
  - Current Pencil reference implementation 逐區域改為 relationship-owned layout；只有有合理 spatial-layering rationale 的局部 visual 保留 coordinate placement。
  - ADR-032新增 optional `Flow/Coordinator` owner，只在 multi-screen / multi-step presentation workflow 有獨立 transition semantics 時存在，不建立 mandatory `flows/` skeleton。
  - Pencil/Theme 色彩先依 semantic role 判斷 ownership；raw hex 輕微差異不得自動製造 feature-local colors，也不得自動抹平 accepted intentional variants。
- **Value（價值）**：阻止「形式上通過 screen-root constraint gate、實際上仍是大量 fixed coordinates」成為模板示範；同時補齊跨 screen flow orchestration 與 semantic color promotion 的架構空洞，讓新產品不會複製錯誤 reference implementation。
- **Classification（分類）**：Level 4 — Architecture / Milestone。
- **Decision（決策）**：Accept。
- **Scope（範圍）**：ADR-032、ADR-018/028、Pencil implementation mapping/pressure scenarios、machine architecture contract、Pencil reference `write_precheck` layout decomposition與必要 current authority/evidence。
- **Non-goals（非目標）**：禁止所有 `Positioned`；建立 universal responsive layout framework；強制每個 feature 有 Flow；把所有 exact Pencil values 全部提升 Design System；重做 accepted `.pen` visual design；任意改變 golden threshold/crop/ignore region。
- **Behavioral requirements required（是否需要行為需求）**：是。
- **Design Spec required（是否需要 Design Spec）**：是。
- **Implementation Plan required（是否需要 Implementation Plan）**：是。
- **ADR required（是否需要 ADR）**：是，更新 ADR-018/028/032；除非 Design review發現現有ADR無法容納，否則不新增平行ADR。
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

### P1 — Flow/Coordinator stable role缺口

Current governance能描述Shell/navigation與screen-level workflow state，卻沒有清楚回答multi-screen step workflow由誰擁有，容易導致「全塞Page/Bloc」或「每個navigation都造Flow」兩種相反錯誤。

### P1 — Same-semantic Pencil color reconciliation不夠可執行

Current authority方向正確，但缺少具體順序，Agent仍可能把同一semantic role因數個RGB差異拆成多個feature token，或反向把真正 intentional context variant錯誤合併。

## Requirement disposition

Open P0：0。

Open P1 without disposition：0（上述四項均納入 Milestone 44 Design scope）。

Requirement Decision：**ACCEPTED**。

