---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.20.0
---

# Active Milestone

```txt
Active Milestone: Milestone 40 — GitHub Repository Landing Page & Documentation Authority Restructure
State: Task 40-7R Hero Visual Corrective / Design reconsideration after C02 rejection
Template Baseline: 1.20.0
```

## Current Scope

Milestone 40主體Tasks 40-1～40-6已完成。原Task 40-7 Hero attempt因invalid governance與generic visual被rejected。40-7R Requirement、Design與Plan已accepted；40-7R-1 visual-family extraction完成，Image MCP依Plan生成C01與唯一replacement C02。C01因pseudo-text／UI-like execution defect rejected；C02因hardware／server-rack identity、repository-family mismatch與~2:1比例失敗而rejected。Regeneration budget已耗盡，C03禁止；目前必須回Design decision。Template Baseline維持1.20.0。

## Current Gate

Milestone 40 Tasks 40-1～40-6保持PASS。40-7R C01／C02均已形成actual visual evidence並被review拒絕；C02觸發accepted Plan的identity-loop stop condition。README仍維持無Hero安全狀態。下一步不是生成C03，而是使用者核准新的Design disposition或維持no-Hero fallback。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_40/40-r_requirement_decision.md`（accepted）。
- Design：`docs/superpowers/specs/2026-08-17-milestone-40-repository-landing-documentation-authority-design.md`（accepted；user approved 2026-08-17）。
- Design review：`docs/audits/milestone_40/40-0_design_spec_review.md`（accepted）。
- Implementation Plan：`docs/superpowers/plans/2026-08-17-milestone-40-repository-landing-documentation-authority.md`（accepted；user approved 2026-08-17）。
- Plan review：`docs/audits/milestone_40/40-p_implementation_plan_review.md`（accepted）。
- Holistic Final Review：`docs/audits/milestone_40/40-6_holistic_final_review.md`（accepted / completed）。
- Rejected Hero attempt：`docs/audits/milestone_40/40-7_repository_hero_visual_review.md`（rejected / invalid governance evidence）。
- Corrective Requirement Decision：`docs/audits/milestone_40/40-7r_hero_visual_requirement_decision.md`（accepted）。
- Corrective Design：`docs/superpowers/specs/2026-08-17-milestone-40-hero-visual-corrective-design.md`（accepted；user approved 2026-08-17）。
- Corrective Design review：`docs/audits/milestone_40/40-7d_hero_visual_design_review.md`（accepted）。
- Corrective Implementation Plan：`docs/superpowers/plans/2026-08-17-milestone-40-hero-visual-corrective.md`（accepted；user approved 2026-08-17）。
- Corrective Plan review：`docs/audits/milestone_40/40-7p_hero_visual_plan_review.md`（accepted）。
- Visual-family extraction：`docs/audits/milestone_40/40-7r_1_visual_family_extraction.md`（accepted）。
- Candidate generation evidence：`docs/audits/milestone_40/40-7r_2_candidate_generation_review.md`（completed；C01／C02 rejected）。
- Candidate visual review：`docs/audits/milestone_40/40-7r_3_hero_candidate_review.md`（completed／FAIL；return to Design）。

## Previous Closure

Milestone 39已完成Pencil-to-Flutter fidelity enforcement／recovery governance corrective並發布Template Baseline 1.20.0；closure evidence由`docs/audits/milestone_39/39-8_post_release_validation.md`擁有。
