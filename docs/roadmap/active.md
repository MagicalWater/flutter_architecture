---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.21.0
---

# Active Milestone

```txt
Active Milestone: none
State: Milestone 41 + 42 published / post-release closure PASS
Template Baseline: 1.21.0
```

## Current Scope

目前沒有active Milestone。Milestone 41 constraint-layout corrective與Milestone 42 presentation/UI design ownership corrective已合併為Template Baseline 1.21.0並完成published-main post-release validation。下一個Presentation Component Architecture議題只存在於`docs/roadmap/candidates.md`，尚未完成Requirement Decision，不得直接implementation。

## Current Gate

Milestone 41 + 42 closure已完成；Task 42-10 fresh evidence確認Windows full regression、required iOS Simulator/Production verification與PTF-30～34 published-main acceptance全部PASS。Current maintenance state回到可接受新Requirement Decision；Milestone 43仍只是candidate。

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
- Milestone 42 Task 42-10：`docs/audits/milestone_42/42-10_post_release_validation.md`（completed / PASS；Template Baseline 1.21.0 published；Milestone 41 + 42 closed）。

## Previous Closure

Milestone 40已完成GitHub Repository Landing Page與documentation authority restructure；Milestone 41 + 42隨Template Baseline 1.21.0 publication正式封存。
