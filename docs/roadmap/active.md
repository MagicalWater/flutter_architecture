---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.17.0
---

# Active Milestone

目前 active milestone：

```txt
Active Milestone: Milestone 37 — Template-to-Product Repository Bootstrap & Adoption Governance
State: Execution — Tasks 37-1 through 37-5 completed; Task 37-6 isolated bootstrap acceptance next
Template Baseline: 1.17.0
```

## Scope

Milestone 37只處理「Flutter Template repository 如何正式出生為新的 Product repository」：

- GitHub Template Repository／`Use this template` newcomer contract；
- machine-readable repository lifecycle與template provenance；
- first-Agent admission與fail-closed routing；
- repository identity transition；
- delegation至既有native product identity adoption；
- fresh no-handoff product admission acceptance。

明確不處理產品需求、MVP、Feature、UI／UX、Backend、產品roadmap、Store distribution、signing或automatic upstream template sync。

## Current Planning Authority

- Requirement Decision：Accepted — `docs/audits/milestone_37/37-r_requirement_decision.md`
- Design：Accepted — `docs/superpowers/specs/2026-08-14-milestone-37-template-to-product-repository-bootstrap-design.md`
- Design review：PASS — `docs/audits/milestone_37/37-0_design_spec_review.md`
- Implementation Plan：Accepted — `docs/superpowers/plans/2026-08-14-milestone-37-template-to-product-repository-bootstrap.md`
- Plan review：PASS — `docs/audits/milestone_37/37-p_implementation_plan_review.md`

## Completed Execution Tasks

- Task 37-1 Repository Identity RED Contract：Completed — `f3df3ed`
- Task 37-2 Canonical Manifest／Verifier／docs_check GREEN：Completed — `98ce9b0`
- Task 37-3 Central Admission Routing／Bootstrap Skill：Completed — `4af02d8`
- Task 37-4 ADR-030／Human Adoption Procedure：Completed — `aa63239`
- Task 37-5 Template Repository Current-Authority Integration：Completed — `docs/audits/milestone_37/37-5_current_authority_integration_review.md`

## Latest Completed Milestone

Milestone 36 — Test Authoring Cost & Risk-Based Testing Governance Corrective已發布Template Baseline 1.17.0並完成published-main post-release validation。

- Final review：`docs/audits/milestone_36/36-8_holistic_final_review.md`
- Post-release validation：`docs/audits/milestone_36/36-9_post_release_validation.md`

## Current Next Action

```txt
Milestone 37 Requirement Decision：ACCEPTED
→ Design：ACCEPTED / review PASS
→ Implementation Plan：ACCEPTED / review PASS
→ Tasks 37-1 ～ 37-5：COMPLETED
→ Current next action：Task 37-6 isolated Template → Product bootstrap acceptance
```
