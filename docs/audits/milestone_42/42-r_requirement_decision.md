---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-42-pencil-presentation-token-governance-requirement
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Pencil Presentation Ownership & Visual Token Governance Corrective Requirement Decision

## Request

在 Milestone 41 merge／push 前處理 fresh architecture review 新發現：Pencil compatibility reference implementation 雖已移除 whole-screen canonical coordinate ownership，但 presentation source 仍把 page orchestration、layout／rendering mechanics、section composition 與大量 visual calibration 壓在 `pages/write_precheck_projected_canvas.dart`；同時 `PencilCompatibilityVisualSpec` 將 canonical metadata、raw palette、typography、layout／component尺寸與 gradients 混在同一 feature-local class。建立正規 presentation ownership 與 Design System token promotion governance，避免未來 Pencil → Flutter implementation 以「feature-local visual spec」繞過既有 Design System。

## Problem

Fresh read-only review 以 Milestone 41 `1.21.0` release candidate `6b35ebaa11558e23d066f7dbaa1052d809e43435` 為基底確認：

1. `write_precheck_view.dart` 是合理的 screen/view orchestration，但 `write_precheck_projected_canvas.dart` 超過 2,000 行，位於 `presentation/pages/` 卻同時擁有 projection math、Inherited projection scope、TextScaler、custom RenderObject、bounded projection helpers、screen content flow與多個 section/component composition。
2. 這沒有穿透 Clean Architecture 的 Presentation → Domain dependency direction，但違反 presentation responsibility cohesion；`pages/` 目錄實際承擔 renderer infrastructure 與 component implementation，增加 hidden architecture shortcut 與後續維護風險。
3. `PencilCompatibilityVisualSpec` 同時包含 `canonicalSize`／DPR、raw colors、font family／fallback、text style factory、max content width、多組 component radius與 gradients。它不是單一責任的 visual contract，而是 authority metadata + palette + typography + layout tokens + component tokens 的 catch-all。
4. ADR-028 允許「單一畫面特有數值保留 feature-local visual specification」；ADR-018 同時要求 feature 優先依賴 Material `ColorScheme`、public semantic extension、public layout tokens與 Design System primitives，不應讓 raw color／spacing／typography 任意分散。
5. Current authority 缺少可執行的 token promotion decision：Agent 可以把整套產品 palette／typography 放進 `FeatureVisualSpec`，再以「Pencil exact values」為理由避開 Design System，文字規則目前不足以 fail closed。
6. 反方向也有風險：若把每個 Pencil exact radius／gap／screen-specific gradient 都提升到 Design System，會造成 single-consumer token 污染、generic framework 膨脹與錯誤 abstraction。

## Current Behavior

- Clean Architecture dependency direction仍正確；本問題集中在 Presentation layer 的責任與 shared UI authority。
- `packages/design_system` 已擁有 primitive／semantic／validated component tokens、Theme definitions與 shared primitives。
- ADR-028 已允許 feature-local visual specification，但沒有要求每個 local token 保存 promotion／non-promotion rationale。
- Pencil compatibility screen 目前的 page orchestration、component tree與 projection mechanics高度集中在一個 `pages/` implementation file。
- `PencilCompatibilityVisualSpec` 是唯一集中 visual constants 的 owner，但 owner 粒度過大且語意不明確。

## Expected Behavior

1. `pages/` 只擁有 route/page/view orchestration；bounded component composition移至 `widgets/` 或等價 presentation component owner；projection／rendering mechanics移至 `layout/` 或等價明確 owner。
2. 不以「檔案行數」作 architecture rule；判斷依 responsibility、dependency與ownership。Machine/review contract應抓責任混放，而不是粗暴設定最大行數。
3. 建立 Pencil visual value 的 canonical ownership classes：
   - **visual-authority metadata**：canonical viewport、DPR、source／comparison identity；不屬 Design System。
   - **shared semantic/theme tokens**：品牌／surface／text／status semantic、全域 typography／spacing／radius；有穩定跨 consumer價值時由 `packages/design_system` 擁有。
   - **validated reusable component tokens/primitives**：多 consumer或明確 reusable contract成立後提升 Design System。
   - **feature/component exact tokens**：只對 accepted screen／component有意義的 exact geometry、gradient、local decoration留在 feature presentation。
   - **one-off local geometry**：只由單一 component使用且沒有 token語意者留在 component local scope，不建立 global `VisualSpec` entry。
4. Feature-local token 必須是明確的例外 owner，而不是 Design System 逃生艙；若值具有跨 screen／跨 feature semantic identity，Plan必須提升或映射至 Design System。
5. 不把所有 Pencil raw colors／exact dimensions機械提升到 Design System；promotion以 semantic identity、stability、consumer evidence與theme responsibility判斷。
6. `PencilCompatibilityVisualSpec` 不得繼續作 catch-all；需要拆成可審查 ownership，並由 mapping／review evidence記錄每類 token disposition。
7. Reference source migration不得改 accepted `.pen`、golden、visual thresholds或screen semantics；structural refactor必須維持 canonical/runtime visual fidelity。
8. 補強 `implementing-pencil-flutter-design`／ADR-028／ADR-018 的 token promotion與 presentation ownership contract，讓未來新產品不重複此模式。
9. Machine/static enforcement採 minimum sufficient owner：禁止把 custom RenderObject／rendering infrastructure藏在 page owner；驗證 feature visual token disposition，而不是 every-value lint。

## Value

- 保持 Feature First 與 Clean Architecture 的 dependency direction，同時提升 Presentation layer 的責任清晰度。
- 防止 `pages/` 變成 screen-specific monolith／renderer dump。
- 防止 Design System 被 feature-local catch-all架空，也防止 Design System 被 single-screen exact values污染。
- 讓 Pencil exact fidelity 與 shared design governance可以同時成立。
- 為後續產品的 Login／Home／Settings／其他 Pencil screens建立一致 token promotion決策方式。

## Classification

**Level 4 — Architecture／Milestone。**

### Evidence

- 影響 `packages/design_system` stable ownership、ADR-018、ADR-028與 repository-wide Pencil-to-Flutter workflow。
- 影響 Presentation source organization、token authority、machine/review enforcement與 reference implementation。
- 若錯誤處理會造成 shared contract污染或 Design System bypass，屬 stable architecture boundary。
- 不涉及database／credential／security／irreversible platform state，因此不升 Level 5。

## Decision

**Accept — 建立 Milestone 42。Milestone 41 publication暫停，不回寫41-8為失敗；42以41 release candidate為基底，完成後重新執行combined release holistic gate。**

## Scope

- Presentation responsibility audit與reference source decomposition。
- `PencilCompatibilityVisualSpec` token-by-token ownership classification與migration。
- Design System promotion／non-promotion decision contract。
- ADR-018／ADR-028 amendment gate與 Pencil workflow/Skill sync。
- 最小充分architecture／token governance regression owners。
- Reference canonical/runtime visual fidelity revalidation。
- Combined release candidate holistic review與publication decision。

## Non-goals

- 不建立generic UI framework、layout DSL或token registry database。
- 不因單一screen exact值就擴充Design System所有spacing／radius／gradient。
- 不以檔案最大行數作architecture policy。
- 不建立每個widget一檔的形式主義；component拆分依責任與可審查 ownership。
- 不改accepted `.pen`、visual language、golden或threshold來配合refactor。
- 不把Presentation-only proof硬造Domain／Data／Bloc／Repository。

## Behavioral requirements required

Required。

## Design Spec required

Required。

## Implementation Plan required

Required。

## ADR required

Required gate。優先amend ADR-018與ADR-028；只有現有owner無法清楚承擔時才允許新增ADR。

## Task governance mode

Full two-layer Task governance。

## Worktree／branch

Required。Current managed worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-79898d55
branch: milestone-42-pencil-presentation-token-governance-corrective
base: 6b35ebaa11558e23d066f7dbaa1052d809e43435
```

## Regression level

Full at Milestone holistic gate；individual Tasks依`tools/ci/validation_planner.py`執行Minimum Sufficient Validation。

## Release required

Required combined disposition。Milestone 41尚未published，因此42完成後重新形成單一release candidate；不得先發布41再立刻發布42以製造無意義版本 churn。

## Post-release validation

Required。Published-main clean checkout、Design System/Pencil architecture contracts、reference visual/runtime與fresh behavioral pressure均需驗證。

## Required artifacts

- 本 Requirement Decision。
- Formal Design Spec與Design雙層review evidence。
- 使用者Design明確核准。
- Formal Implementation Plan與Plan雙層review evidence。
- 使用者Plan明確核准。
- ADR-018／ADR-028 disposition。
- Presentation ownership與token promotion machine/review contracts。
- Reference source/token migration evidence。
- Visual/runtime fidelity evidence。
- Holistic final review、combined release與post-release closure evidence。
