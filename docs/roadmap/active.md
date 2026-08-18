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
State: Tasks 42-1～42-9 accepted / combined Milestone 41+42 release candidate PASS / merge-push authorization pending
Template Baseline: 1.21.0 combined release candidate base
```

## Current Scope

Milestone 42處理Milestone 41 merge前fresh architecture review新增的presentation ownership與UI design ownership governance finding。Current implementation已完成`pages/`／`layout/`／`widgets/`責任拆分並退休`PencilCompatibilityVisualSpec` catch-all；scope進一步建立repository-wide UI Design Ownership Architecture、Design System promotion/non-promotion、asset/provenance與visual-authority separation、machine/review enforcement與fresh behavioral pressure；不修改accepted `.pen`或降低visual fidelity。

## Current Gate

Milestone 41 Requirement、Design、Implementation Plan與Tasks 41-1～41-8均已完成並通過，但在merge／push前發現scope-adjacent P1 architecture finding；41 publication因此暫停而不是宣稱closed。Milestone 42 Revised Design與rebuilt Implementation Plan均已accepted；Tasks 42-1～42-9已accepted。Combined Milestone 41+42 holistic / release candidate已fresh PASS，下一個合法gate是使用者merge／push authorization；Task 42-10 publication / post-release closure在授權前不得開始。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_41/41-r_requirement_decision.md`（accepted）。
- Design：`docs/superpowers/specs/2026-08-18-milestone-41-pencil-layout-architecture-corrective-design.md`（accepted；review PASS；user approved 2026-08-18）。
- Design Review：`docs/audits/milestone_41/41-0_design_spec_review.md`（completed / PASS）。
- Implementation Plan：`docs/superpowers/plans/2026-08-18-milestone-41-pencil-layout-architecture-corrective.md`（accepted；review PASS；user approved 2026-08-18）。
- Plan Review：`docs/audits/milestone_41/41-p_implementation_plan_review.md`（completed / PASS）。
- Task 41-8 Holistic Final Review：`docs/audits/milestone_41/41-8_holistic_final_review.md`（accepted / PASS；release decision = 1.21.0）。
- Milestone 42 Requirement Decision：`docs/audits/milestone_42/42-r_requirement_decision.md`（accepted；Milestone 41 publication suspended）。
- Milestone 42 Design：`docs/superpowers/specs/2026-08-18-milestone-42-pencil-presentation-token-governance-corrective-design.md`（Revision 1 accepted；revision review PASS；user revised-Design approved 2026-08-18）。
- Milestone 42 Implementation Plan：`docs/superpowers/plans/2026-08-18-milestone-42-pencil-presentation-token-governance-corrective.md`（rebuilt accepted；fresh Plan review PASS；user approved 2026-08-18）。
- Milestone 42 Design Review：`docs/audits/milestone_42/42-0_design_spec_review.md`（completed / PASS）。
- Milestone 42 Plan Review：`docs/audits/milestone_42/42-p_implementation_plan_review.md`（completed / PASS）。
- Milestone 42 Tasks 42-1～42-8：`docs/audits/milestone_42/42-1_ownership_red_review.md` 至 `42-8_behavioral_pressure_review.md`（accepted；visual authority unchanged；PTF-30～34與edge/positive controls PASS）。
- Milestone 42 Task 42-9：`docs/audits/milestone_42/42-9_combined_holistic_final_review.md`（accepted / PASS；combined 1.21.0 release candidate；Open P0=0 / Open P1 without disposition=0）。

## Previous Closure

Milestone 40已完成GitHub Repository Landing Page與documentation authority restructure，未升Template Baseline；Milestone 39的1.20.0 publication在Task 41-9完成前仍是最後一個已發布baseline authority。
