---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.24.0
---

# Active Milestone

```txt
Active Milestone: Milestone 45 — Test-by-Exception Portfolio Reset & Development Governance Simplification
State: 1.24.0 release candidate / publication validation active
Template Baseline: 1.24.0
```

## Current Scope

Milestone 45 Requirement／Design／Implementation Plan均已accepted並完成local implementation、corrective review與focused retention collapse。Current permanent portfolio為18 files／4,442 LOC／137 static cases，相對admission baseline分別縮減89.9%／85.6%／87.8%；test-by-exception、temporary retention、`replacement = NONE`、lowest-sufficient classification、same-SHA reuse、explicit manual validation mode與observability acceptance降頻均已落地。`dev`已完成整合；Template Baseline `1.24.0` MINOR release candidate 已建立，publication validation active。Milestone 44本體與既有1.23.x evidence不重新開啟。

## Current Gate

Milestone 45 current gate：local holistic + corrective review + focused retention collapse已PASS，`dev`已完成整合；`1.24.0` MINOR release candidate 已建立。Current boundary 是 explicit release validation → `main` publication → published-main identity/post-release closure。

## Current Evidence

- Milestone 45 Requirement Decision：`docs/audits/milestone_45/45-r_requirement_decision.md`（accepted / Level 4）。
- Milestone 45 Combined Planning Review：`docs/audits/milestone_45/45-0_combined_planning_review.md`（PASS；Design／Plan user approved 2026-08-19）。
- Milestone 45 Design：`docs/superpowers/specs/2026-08-19-milestone-45-test-by-exception-governance-reset-design.md`（accepted）。
- Milestone 45 Implementation Plan：`docs/superpowers/plans/2026-08-19-milestone-45-test-by-exception-governance-reset.md`（accepted）。
- Milestone 45 Holistic Final Review：`docs/audits/milestone_45/45-1_holistic_final_review.md`（local implementation + corrective review PASS；portfolio 88.8% files／80.8% LOC reduction；`dev` integration complete）。

- Milestone 44 Requirement Decision：`docs/audits/milestone_44/44-r_requirement_decision.md`（accepted / Level 4）。
- Milestone 44 Design：`docs/superpowers/specs/2026-08-18-milestone-44-pencil-component-constraint-semantics-design.md`（accepted；revised雙層review PASS；user approved 2026-08-19）。
- Milestone 44 Design Review：`docs/audits/milestone_44/44-0_design_spec_review.md`（completed / PASS）。
- Milestone 44 Implementation Plan：`docs/superpowers/plans/2026-08-19-milestone-44-pencil-component-constraint-semantics-corrective.md`（accepted；Plan review PASS；user approved 2026-08-19）。
- Milestone 44 Plan Review：`docs/audits/milestone_44/44-p_implementation_plan_review.md`（accepted / PASS）。
- Task 44-1 Component Constraint RED：`docs/audits/milestone_44/44-1_component_constraint_red_review.md`（accepted RED；direct owner established）。
- Task 44-2 Constraint Authority：`docs/audits/milestone_44/44-2_constraint_authority_review.md`（accepted / PASS）。
- Task 44-3 Relationship Layout Corrective：`docs/audits/milestone_44/44-3_write_precheck_relationship_layout_review.md`（accepted / PASS；canonical/runtime golden PASS）。
- Task 44-4 Legal Overlay / Visual Fidelity：`docs/audits/milestone_44/44-4_legal_overlay_visual_fidelity_review.md`（accepted / PASS）。
- Task 44-5 Behavioral Pressure：`docs/audits/milestone_44/44-5_behavioral_pressure_review.md`（accepted / PASS；PTF-47～58 fresh PASS）。
- Task 44-6 Holistic Final Review：`docs/audits/milestone_44/44-6_holistic_final_review.md`（accepted / PASS；release decision = 1.23.0 candidate）。
- Task 44-7 Post-release Validation：`docs/audits/milestone_44/44-7_post_release_validation.md`（completed / PASS；Template Baseline 1.23.0 published；Milestone 44 closed）。
- C1 Requirement Decision：`docs/audits/milestone_44/44-c1_color_ownership_adoption_requirement_decision.md`（accepted / Level 3）。
- C1 Design：`docs/superpowers/specs/2026-08-19-milestone-44-post-closure-color-ownership-adoption-corrective-design.md`（accepted；user approved 2026-08-19）。
- C1 Implementation Plan：`docs/superpowers/plans/2026-08-19-milestone-44-post-closure-color-ownership-adoption-corrective.md`（accepted；user approved 2026-08-19）。
- C1 Tasks C1-1～C1-4：`docs/audits/milestone_44/44-c1_1_palette_bypass_red_review.md` 至 `44-c1_4_visual_affected_regression_review.md`（RED→ownership adoption→machine GREEN→visual/affected regression PASS）。
- C1-5 Holistic Corrective Review：`docs/audits/milestone_44/44-c1_5_holistic_corrective_review.md`（accepted / PASS；release decision = 1.23.1 PATCH candidate）。

- Milestone 43 Requirement Decision：`docs/audits/milestone_43/43-r_requirement_decision.md`（accepted / Level 4）。
- Milestone 43 Design：`docs/superpowers/specs/2026-08-18-milestone-43-presentation-component-architecture-design.md`（accepted；review PASS；user approved 2026-08-18）。
- Milestone 43 Design Review：`docs/audits/milestone_43/43-0_design_spec_review.md`（completed / PASS）。
- Milestone 43 Implementation Plan：`docs/superpowers/plans/2026-08-18-milestone-43-presentation-component-architecture.md`（accepted；Plan review PASS；user approved 2026-08-18）。
- Milestone 43 Plan Review：`docs/audits/milestone_43/43-p_implementation_plan_review.md`（accepted / PASS）。
- Task 43-5 Generic Feature Adoption：`docs/audits/milestone_43/43-5_generic_feature_adoption_review.md`（accepted / PASS）。
- Task 43-6 Behavioral Pressure：`docs/audits/milestone_43/43-6_behavioral_pressure_review.md`（accepted / PASS）。
- Task 43-7 Holistic Final Review：`docs/audits/milestone_43/43-7_holistic_final_review.md`（accepted / PASS；release decision = 1.22.0 candidate）。
- Task 43-8 Post-release Validation：`docs/audits/milestone_43/43-8_post_release_validation.md`（completed / PASS；Template Baseline 1.22.0 published；Milestone 43 closed）。

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
