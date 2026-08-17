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
State: Task 40-7T README Title Artwork Corrective / user visual acceptance gate
Template Baseline: 1.20.0
```

## Current Scope

Milestone 40主體Tasks 40-1～40-6已完成。原Task 40-7與40-7R architecture-Hero方向均保留為rejected historical evidence；C01／C02沒有live README authority。使用者已把真正需求收斂為一張`Flutter Enterprise Architecture Template` typographic title artwork，因此40-7T以新的Level 1 Requirement Decision接管current corrective；不重做architecture diagram、不改documentation ownership。後續圖片生成只使用fresh discovered `chatgpt-web-generation`。Template Baseline維持1.20.0。

## Current Gate

Milestone 40 Tasks 40-1～40-6保持PASS。40-7T C01 title artwork已透過fresh discovered `chatgpt-web-generation`生成，focused／whole-candidate review均PASS；目前停在使用者actual visual acceptance gate。Markdown H1與兩張accepted architecture visuals仍保持不變；使用者核准前README保持目前安全狀態。

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
- Title Artwork Requirement Decision：`docs/audits/milestone_40/40-7t_title_artwork_requirement_decision.md`（accepted / Level 1 reduced scope）。
- Governance Integrity Review：`docs/audits/milestone_40/40-7t_governance_integrity_review.md`（accepted；repository-wide governance corruption not found）。
- Title Artwork Visual Review：`docs/audits/milestone_40/40-7t_title_artwork_review.md`（focused／holistic PASS；user visual acceptance pending）。

## Previous Closure

Milestone 39已完成Pencil-to-Flutter fidelity enforcement／recovery governance corrective並發布Template Baseline 1.20.0；closure evidence由`docs/audits/milestone_39/39-8_post_release_validation.md`擁有。
