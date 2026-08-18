---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.21.0
---

# Active Milestone

```txt
Active Milestone: Milestone 42 — Pencil Presentation Ownership & Visual Token Governance Corrective
State: Revised Design proposed / revision review PASS / user revised-Design approval pending / existing Plan suspended / Milestone 41 publication suspended
Template Baseline: 1.21.0 combined release candidate base
```

## Current Scope

Milestone 42處理Milestone 41 merge前fresh architecture review新增的presentation ownership與visual token governance finding。Current reference已移除whole-screen canonical coordinate owner，但`pages/write_precheck_projected_canvas.dart`仍混合page以外的render/layout/component責任，`PencilCompatibilityVisualSpec`亦混合visual authority metadata、palette、typography、layout/component tokens與gradients。Scope包含Presentation responsibility decomposition、Design System promotion/non-promotion contract、feature-local visual token boundary、machine/review enforcement與reference migration；不修改accepted `.pen`或降低visual fidelity。

## Current Gate

Milestone 41 Requirement、Design、Implementation Plan與Tasks 41-1～41-8均已完成並通過，但在merge／push前發現scope-adjacent P1 architecture finding；41 publication因此暫停而不是宣稱closed。Milestone 42首次Design曾accepted，但Plan approval前使用者新增P1：必須建立repository-wide UI Design Ownership Architecture並禁止generic `*VisualSpec` / `*VisualTokens` catch-all。Revised Design已完成雙層re-review PASS，目前等待使用者重新核准；existing Plan suspended，不得開始implementation。42完成後必須重新形成combined holistic/release candidate，再取得merge／push授權。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_41/41-r_requirement_decision.md`（accepted）。
- Design：`docs/superpowers/specs/2026-08-18-milestone-41-pencil-layout-architecture-corrective-design.md`（accepted；review PASS；user approved 2026-08-18）。
- Design Review：`docs/audits/milestone_41/41-0_design_spec_review.md`（completed / PASS）。
- Implementation Plan：`docs/superpowers/plans/2026-08-18-milestone-41-pencil-layout-architecture-corrective.md`（accepted；review PASS；user approved 2026-08-18）。
- Plan Review：`docs/audits/milestone_41/41-p_implementation_plan_review.md`（completed / PASS）。
- Task 41-8 Holistic Final Review：`docs/audits/milestone_41/41-8_holistic_final_review.md`（accepted / PASS；release decision = 1.21.0）。
- Milestone 42 Requirement Decision：`docs/audits/milestone_42/42-r_requirement_decision.md`（accepted；Milestone 41 publication suspended）。
- Milestone 42 Design：`docs/superpowers/specs/2026-08-18-milestone-42-pencil-presentation-token-governance-corrective-design.md`（Revision 1 proposed；revision review PASS；user revised-Design approval pending）。
- Milestone 42 Design Review：`docs/audits/milestone_42/42-0_design_spec_review.md`（completed / PASS）。
- Milestone 42 Implementation Plan：`docs/superpowers/plans/2026-08-18-milestone-42-pencil-presentation-token-governance-corrective.md`（proposed but suspended；必須在Revised Design重新核准後更新與re-review）。
- Milestone 42 Plan Review：`docs/audits/milestone_42/42-p_implementation_plan_review.md`（completed / PASS）。

## Previous Closure

Milestone 40已完成GitHub Repository Landing Page與documentation authority restructure，未升Template Baseline；Milestone 39的1.20.0 publication在Task 41-9完成前仍是最後一個已發布baseline authority。
