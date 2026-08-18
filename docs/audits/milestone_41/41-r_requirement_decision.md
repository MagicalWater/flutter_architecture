---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-41-pencil-layout-architecture-corrective-requirement
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Pencil-to-Flutter Constraint-based Layout Architecture Corrective Requirement Decision

## Request

修正目前 repository-local Pencil → Flutter workflow 對 layout architecture 的 authority／implementation／machine enforcement 不一致，避免 Agent 以「single renderer + 真 Flutter widgets」為理由，將 whole-screen Pencil canonical coordinates 機械轉成 `Stack + Positioned + visualScale` 的 fixed-coordinate reconstruction。

## Problem

Fresh read-only audit 在 Template Baseline `1.20.0` 確認：

1. Current `visual-validation.md` 已明文禁止把 canonical design-space `x/y` 機械套成所有 runtime viewport 的固定座標；ADR-028 也禁止全畫面 fixed-canvas scaling。
2. Current `flutter-mapping.md` 同時允許由 shared `visualScale` 投影 width／height／offset／padding／gap 等 visible geometry，邊界不足以阻止 Agent 把 whole-screen absolute coordinates 全部乘相同比例。
3. Current reference production implementation `WritePrecheckProjectedCanvas` 使用 `designWidth = 941`、global projection scale、custom `RenderStack.performLayout()`，把 `Positioned` parent data 的 `left/top/right/bottom/width/height` 直接乘同一個 scale；whole-screen root 由大量 projected `Positioned` 組成。
4. Milestone 33 Corrective 曾正式接受上述 projected single-renderer implementation，當時主要解決 canonical/runtime 兩套 whole-screen renderer 的問題；後續 Milestone 39 policy 前進到「不得機械套 canonical x/y」，但明確沒有重做既有 Pencil compatibility production UI，形成 current authority 與 accepted reference implementation drift。
5. `tools/docs/test_pencil_single_renderer_policy.py` 只驗證 policy text wording，不檢查 production source architecture。
6. `write_precheck_architecture_contract_test.dart` 對 fixed-canvas guard 只掃 top-level `write_precheck_view.dart`，沒有檢查它委派的 `write_precheck_projected_canvas.dart`；因此 current tests 會在 projected fixed-coordinate implementation 存在時仍 PASS。
7. Current pressure scenarios 覆蓋 FittedBox／Transform.scale、parallel whole-screen renderer、layout-health substitution，但沒有直接覆蓋「one renderer + Stack/Positioned + canonical coordinates × visualScale」shortcut。

## Current Behavior

- One accepted screen只能有one whole-screen visual tree。
- Canonical viewport是design/comparison space，不是Flutter logical breakpoint。
- Full-screen raster、top-level `FittedBox`／`Transform.scale`、parallel whole-screen renderer已禁止。
- Responsive geometry contract可用exact size、edge inset、alignment、sibling gap、proportion或container relationship。
- Current wording已禁止把canonical design-space x/y機械套成所有runtime viewport固定座標。
- 但current reference implementation與machine enforcement仍允許whole-screen projected absolute-coordinate reconstruction通過。

## Expected Behavior

1. Whole-screen／major-flow layout必須以Flutter constraint／relationship semantics實作；Pencil absolute coordinates只能用來推導edge inset、alignment、gap、proportion、container relationship或其他已接受responsive contract，不得直接成為整頁runtime coordinate model。
2. `Stack`／`Positioned`仍可用於真正具有overlay／freeform composition semantics的bounded local component；不得建立「全面禁止Stack」的錯誤規則。
3. Shared design scale可以投影局部visual dimensions、spacing、radius、stroke、icon size與feature-local typography，但不得作為whole-screen canonical `left/top/right/bottom` reconstruction engine。
4. Reference Pencil compatibility implementation必須符合current stable contract；若現有 projected canvas 不符合，Plan必須安排受治理的source/test migration，而不是只補Markdown。
5. Machine/static enforcement必須能抓到高風險whole-screen absolute-coordinate reconstruction；不得只搜尋`FittedBox`／`Transform.scale`關鍵字，也不得因custom RenderObject或helper wrapper而繞過。
6. Machine detector需避免把bounded local overlays誤判為architecture failure；若採heuristic signal，必須有reviewable evidence與明確false-positive boundary。
7. Behavioral pressure必須新增直接 scenario：single whole-screen renderer、真Flutter widgets、沒有FittedBox，但大量`Positioned`由canonical coordinates乘global scale；正確結果必須拒絕whole-screen coordinate reconstruction。
8. Visual fidelity仍必須維持；corrective不得藉「responsive architecture」自由重設計accepted `.pen`或降低canonical/runtime fidelity gate。
9. Test治理採minimum sufficient owner，不建立every-widget／every-Positioned測試地獄。

## Value

- 防止模板把Pencil設計稿誤實作成可縮放海報，而不是production responsive Flutter UI。
- 避免其他產品Agent從reference implementation學到錯誤layout pattern。
- 讓「one renderer」同時滿足single-tree與constraint-based layout，而不是只消除第二renderer。
- 保留局部freeform visual composition需要的`Stack`／`Positioned`能力，不做過度禁止。
- 讓policy、reference source、tests、pressure scenarios與machine enforcement形成一致authority chain。

## Classification

**Level 4 — Architecture／Milestone。**

### Evidence

- 影響repository-wide Pencil-to-Flutter stable layout contract與ADR-028。
- 影響domain Skill、Guide、pressure behavioral contract、machine enforcement與reference production implementation。
- Current accepted reference implementation與current stable policy存在P1 authority consistency conflict。
- 需要formal Design／Plan、full two-layer governance、cross-Task holistic review與新的Template Baseline release decision。
- 不涉及credential、database migration、security或不可逆platform state，因此不升級Level 5。

## Decision

**Accept — 建立 Milestone 41。**

## Scope

- 定義constraint／relationship-based Pencil geometry → Flutter layout stable contract。
- 明確界定合法bounded local `Stack`／`Positioned`與禁止whole-screen coordinate reconstruction。
- 補強`implementing-pencil-flutter-design`的Flutter mapping／visual validation／pressure scenarios。
- ADR-028 amendment gate；不建立第二個Pencil layout ADR，除非Design證明stable ownership無法由ADR-028承擔。
- 建立最小充分machine/static enforcement，能偵測global canonical-coordinate projection shortcut並保留bounded overlay例外。
- 修正Pencil compatibility reference implementation與其architecture／responsive／visual tests，使reference source不再示範current policy禁止模式。
- 保持accepted `.pen`與visual authority不變；本Milestone修implementation architecture，不重設計畫面。
- Fresh-agent behavioral pressure、full holistic regression與post-release validation。

## Non-goals

- 不全面禁止Flutter `Stack`／`Positioned`。
- 不把每個Pencil node轉成Flex／Constraint test，也不建立every-node geometry suite。
- 不改Pencil `.pen`內容或visual language來迎合implementation。
- 不建立第二套whole-screen renderer或test-only responsive renderer。
- 不放寬canonical／runtime visual thresholds、crop或ignore regions。
- 不建立generic layout DSL、code generator或global design-node database。
- 不重寫Pencil MCP、visual authority manifest foundation或representation/provenance system。

## Behavioral requirements required

Required。

## Design Spec required

Required。

## Implementation Plan required

Required。

## ADR required

Required gate。優先amend ADR-028；只有Design證明責任邊界需要獨立stable owner時才允許新ADR。

## Task governance mode

Full two-layer Task governance。

## Worktree／branch

Required。Current managed worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-1282d9ed
branch: milestone-41-pencil-layout-architecture-corrective
base: main@591a7d638a5e980846cb75d8f05c88b97410bdec
```

## Regression level

Full at Milestone holistic gate；individual Tasks仍使用`tools/ci/validation_planner.py`選擇Minimum Sufficient Validation。

## Release required

Required。這是repository-wide template architecture／governance corrective；exact Template Baseline version由accepted Design／Plan與release gate決定。

## Post-release validation

Required。至少包含published-main clean checkout、Pencil policy／layout architecture machine contracts、reference runtime validation與fresh isolated-agent pressure acceptance。

## Required Superpowers skills

- `brainstorming`：Design。
- `writing-plans`：Design accepted後。
- `test-driven-development`：依Test Authoring Decision使用。
- `verification-before-completion`：Task／Milestone gate。
- `finishing-a-development-branch`：integration／release。

Current DevSpace diagnostics顯示Superpowers plugin cache path缺失；不得因此降低repository governance。若對應workflow Skill不可載入，仍依repository contract建立等價formal Design／Plan／review evidence與approval gates。

## Required artifacts

- 本 Requirement Decision。
- Formal Design Spec與Design Task雙層review evidence。
- 使用者Design明確核准。
- Formal Implementation Plan與Plan Task雙層review evidence。
- 使用者Plan明確核准。
- ADR-028 amendment disposition。
- Machine/static layout enforcement與direct regression owner。
- Reference production implementation migration evidence。
- Fresh-agent behavioral pressure evidence。
- Per-Task review／validation evidence。
- Holistic final review、release與post-release closure evidence。
