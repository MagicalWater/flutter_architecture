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
State: Task 40-7 user visual acceptance pending
Template Baseline: 1.20.0
```

## Current Scope

Milestone 40主體Tasks 40-1～40-6已完成；publication前追加的Task 40-7 Hero visual corrective因使用者否決visual acceptance而重新開啟。Current gate是確認40-7 review artifact實際inline render Hero、productized topology與C4 dependency contract三張驗收圖片，並取得使用者明確視覺核准；Template Baseline維持1.20.0。

## Current Gate

Milestone 40 Tasks 40-1～40-6保持PASS。Task 40-7 asset／README consumer／docs checks已GREEN，但先前review artifact只展示Markdown image syntax、未實際render圖片，使用者已明確否決該visual acceptance。40-7目前維持active，等待使用者檢視actual inline previews後核准；不得再以source path存在代替visual acceptance。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_40/40-r_requirement_decision.md`（accepted）。
- Design：`docs/superpowers/specs/2026-08-17-milestone-40-repository-landing-documentation-authority-design.md`（accepted；user approved 2026-08-17）。
- Design review：`docs/audits/milestone_40/40-0_design_spec_review.md`（accepted）。
- Implementation Plan：`docs/superpowers/plans/2026-08-17-milestone-40-repository-landing-documentation-authority.md`（accepted；user approved 2026-08-17）。
- Plan review：`docs/audits/milestone_40/40-p_implementation_plan_review.md`（accepted）。
- Holistic Final Review：`docs/audits/milestone_40/40-6_holistic_final_review.md`（accepted / completed）。
- Hero visual corrective：`docs/audits/milestone_40/40-7_repository_hero_visual_review.md`（active / user visual acceptance pending）。

## Previous Closure

Milestone 39已完成Pencil-to-Flutter fidelity enforcement／recovery governance corrective並發布Template Baseline 1.20.0；closure evidence由`docs/audits/milestone_39/39-8_post_release_validation.md`擁有。
