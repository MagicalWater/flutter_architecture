---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.21.0
---

# Active Milestone

```txt
Active Milestone: Milestone 41 — Pencil-to-Flutter Constraint-based Layout Architecture Corrective
State: Holistic PASS / 1.21.0 release candidate / merge-push authorization pending
Template Baseline: 1.21.0 release candidate
```

## Current Scope

Milestone 41處理current Pencil-to-Flutter stable policy與reference production implementation之間的layout architecture drift。Fresh audit已確認：current contract禁止canonical design-space `x/y`機械套成runtime固定座標，但`WritePrecheckProjectedCanvas`仍以whole-screen projected `Stack`／`Positioned`、global design scale與custom `RenderStack`縮放positioned parent data，且現有policy／architecture tests無法攔住。Scope包含constraint／relationship-based layout contract、bounded local overlay boundary、machine enforcement、reference implementation corrective與behavioral pressure；不修改accepted `.pen`或降低visual fidelity gate。

## Current Gate

Requirement、Design、Implementation Plan與Tasks 41-1～41-8均已完成並通過。Holistic final review決定發布Template Baseline `1.21.0`。下一個合法gate是Task 41-9的merge／push明確授權；授權前不得把release candidate宣稱為published-main或完成Milestone closure。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_41/41-r_requirement_decision.md`（accepted）。
- Design：`docs/superpowers/specs/2026-08-18-milestone-41-pencil-layout-architecture-corrective-design.md`（accepted；review PASS；user approved 2026-08-18）。
- Design Review：`docs/audits/milestone_41/41-0_design_spec_review.md`（completed / PASS）。
- Implementation Plan：`docs/superpowers/plans/2026-08-18-milestone-41-pencil-layout-architecture-corrective.md`（accepted；review PASS；user approved 2026-08-18）。
- Plan Review：`docs/audits/milestone_41/41-p_implementation_plan_review.md`（completed / PASS）。
- Task 41-8 Holistic Final Review：`docs/audits/milestone_41/41-8_holistic_final_review.md`（accepted / PASS；release decision = 1.21.0）。

## Previous Closure

Milestone 40已完成GitHub Repository Landing Page與documentation authority restructure，未升Template Baseline；Milestone 39的1.20.0 publication在Task 41-9完成前仍是最後一個已發布baseline authority。
