---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-42-cross-conversation-handoff
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Cross-Conversation Handoff Checkpoint

## Purpose

本文件固定 2026-08-18 對話切換前的 current authority，避免下一個對話依賴聊天記憶。

## Repository / Worktree

```txt
Source repository: D:\Developer\flutter_architecture
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-79898d55
Branch: milestone-42-pencil-presentation-token-governance-corrective
Base candidate: 6b35ebaa11558e23d066f7dbaa1052d809e43435
Template version identity: 1.21.0 release candidate
```

## Milestone 41 disposition

Milestone 41 的 constraint-based layout corrective 已完成 Requirement、Design、Plan、Tasks 41-1～41-8、holistic final review與 Windows release-candidate matrix；whole-screen canonical coordinate owner 已從 reference production screen 移除，machine mapping、architecture detector、visual/runtime acceptance與 PTF-27～29 均 PASS。

Milestone 41 尚未 merge／push／published-main，因此尚未 closure。2026-08-18 merge 前 fresh architecture review又發現 presentation responsibility 與 visual-token ownership 的獨立 P1 finding，故 publication 正式 suspended，交由 Milestone 42 在同一 1.21.0 candidate 上處理。不得把 Milestone 41 宣稱為 published 或 independently closed。

## Milestone 42 current state

- Requirement Decision：accepted。
- Classification：Level 4 — Architecture／Milestone。
- Requirement completion commit：`6bb1ee535e5d54815b22da729ecd84eb4871ea3a`。
- Design Spec：原版曾`accepted`；Plan approval前新增UI Design Ownership Architecture P1後已進入Revision 1並回`proposed`。
- Design Revision 1 two-layer re-review：PASS；Open P0 = 0；Open P1 without disposition = 0。
- User revised-Design approval：**尚未取得**。
- Implementation Plan：已建立但因Revised Design尚未重新核准而`proposed / suspended`；不得以舊Plan review直接進implementation。
- Production source / Design System / machine policy：Milestone 42 尚未修改。

## Confirmed Milestone 42 findings

1. `presentation/pages/write_precheck_projected_canvas.dart` 混合 page 以外的 layout/render mechanics、custom RenderObject、projection infrastructure 與 bounded section composition；雖未穿透 Clean Architecture layer，但 responsibility cohesion 不符合 current project architecture expectation。
2. `PencilCompatibilityVisualSpec` 同時擁有 canonical viewport/DPR、palette、typography、layout/component tokens、gradients，形成 catch-all visual authority。
3. ADR-028 允許 single-screen exact values feature-local，ADR-018 同時要求 shared semantic/theme authority集中於 Design System；current workflow缺少足夠明確的 token promotion/non-promotion enforcement，存在 `FeatureVisualSpec` 逃生艙風險。
4. Plan approval前使用者進一步要求：尺寸、顏色、typography、assets、gradient、geometry等UI design data不得再形成generic `*VisualSpec` / `*VisualTokens`小型Design System；必須整合既有Design System、asset/provenance、visual authority、layout與component ownership成repository-wide UI Design Ownership Architecture。

## Revised design direction pending user approval

Presentation ownership：

```txt
pages/       → Page / View orchestration
layout/      → projection / render mechanics
widgets/     → bounded screen/component composition
visual_authority/ → canonical comparison/source metadata only
```

Visual value ownership必須分類為：

```txt
visual-authority
design-system
feature-local
component-local
```

`PencilCompatibilityVisualSpec` 必須 retired；不得只 rename 成另一個 mega-class。Canonical viewport/DPR不得 promotion 到 Design System；shared semantic/theme values只有在 semantic identity／stable shared ownership成立時才 promotion；one-off exact geometry不得污染 Design System。

Revision 1再固定：

```txt
Design System semantic/theme authority
Asset / representation authority
Visual authority metadata
Layout owner
Smallest correct component owner
```

所有UI design data必須解析到上述owner之一。不得以`*VisualSpec`、`*VisualTokens`、`*UiSpec`、`*StyleConfig`同時集中colors/dimensions/typography/assets/geometry；asset path與provenance不得由visual token/spec owner接管。

## Next legal gate

下一個對話必須 fresh admission 後先讀 Requirement、Revised Design、Design Review、suspended Implementation Plan、Plan Review 與本 handoff。**下一個合法動作是取得使用者對 Milestone 42 Revised Design 的明確核准。** Revised Design核准前不得更新Plan為可核准狀態，也不得開始implementation或修改production source、Design System、machine policy。

Revised Design核准後：

```txt
update Implementation Plan to revised Design
→ Plan two-layer re-review
→ user Plan approval
→ Plan accepted + commit
→ implementation Tasks
→ holistic review
→ combined 1.21.0 release candidate
→ single merge / push
→ published-main + macOS/iOS post-release validation
→ Milestone 41 + 42 closure
```

## Required reading in next conversation

```txt
AGENTS.md
repository_identity.json
VERSION
docs/roadmap/active.md
docs/project_context.md
docs/audits/milestone_42/42-r_requirement_decision.md
docs/superpowers/specs/2026-08-18-milestone-42-pencil-presentation-token-governance-corrective-design.md
docs/audits/milestone_42/42-0_design_spec_review.md
docs/audits/milestone_42/42-handoff_checkpoint.md
docs/superpowers/plans/2026-08-18-milestone-42-pencil-presentation-token-governance-corrective.md
docs/audits/milestone_42/42-p_implementation_plan_review.md
docs/audits/milestone_41/41-8_holistic_final_review.md
```

