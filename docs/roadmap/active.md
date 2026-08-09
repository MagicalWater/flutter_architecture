---
document_type: active-milestone
status: accepted
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.15.2
---

# Active Milestone

目前active milestone：

```txt
Milestone 35 — Test Execution Cost & Change-Aware Validation Governance Corrective
State: Requirement Decision accepted / Design in progress
Template Baseline: 1.15.2
```

## Current Scope

審查並修正repository test execution cost與change-aware validation routing drift。Admission已確認目前問題不是單純tests過多，而是classifier／tier machine model／Guide wording造成over-validation，並由雙層Task的多個verification points放大成本。

- Admission audit：`docs/audits/milestone_35/35-0_test_execution_cost_admission_audit.md`
- Requirement Decision：Accepted — `docs/audits/milestone_35/35-r_requirement_decision.md`
- Design：Not started
- Implementation Plan：Not started
- Worktree：Not created
- Production / CI mutation：Not started

## Latest Completed Milestone

Milestone 34 — Pencil Asset / Vector / Typography Mapping & Provenance已發布Template Baseline 1.15.2並完成post-release validation。

- Final review：`docs/audits/milestone_34/34-5_holistic_final_review.md`
- Post-release validation：`docs/audits/milestone_34/34-6_post_release_validation.md`

## Current Next Action

```txt
Milestone 35 read-only admission：CONFIRMED
→ Problem：over-validation / test execution cost drift
→ Primary findings：classifier granularity、tier model drift、Guide wording drift
→ Clean Architecture：test-surface contributor，不是主要root cause
→ Two-layer Task governance：cost multiplier，不是主要root cause
→ Fresh baseline reconciliation：CONFIRMED
→ Requirement Decision：ACCEPT / Level 4
→ 下一步：Design Spec + Design雙層Task review
→ 使用者核准後才可建立Implementation Plan
→ Design／Plan／worktree／implementation目前均未開始
```
