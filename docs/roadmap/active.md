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
State: Design accepted / Implementation Plan accepted / execution admitted / Task 35-7 active
Template Baseline: 1.15.2
```

## Current Scope

審查並修正repository test execution cost與change-aware validation routing drift。Admission已確認目前問題不是單純tests過多，而是classifier／tier machine model／Guide wording造成over-validation，並由雙層Task的多個verification points放大成本。

- Admission audit：`docs/audits/milestone_35/35-0_test_execution_cost_admission_audit.md`
- Requirement Decision：Accepted — `docs/audits/milestone_35/35-r_requirement_decision.md`
- Design：Accepted — `docs/superpowers/specs/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance-design.md`
- Implementation Plan：Accepted — `docs/superpowers/plans/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance.md`
- Worktree：Created — `C:\Users\crazy\.devspace\worktrees\flutter_architecture-65b293eb` / `milestone-35-validation-governance`
- Production / CI mutation：Tasks 35-1～35-6 accepted / Task 35-7 cost acceptance active

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
→ Design Spec + Design雙層Task review：PASS / ACCEPTED
→ 使用者Design approval：APPROVED
→ Implementation Plan + Plan雙層Task review：PASS / ACCEPTED
→ 使用者Implementation Plan approval：APPROVED
→ Managed worktree / execution admission：PASS
→ Task 35-1 Validation Planner Contract RED：ACCEPTED
→ Task 35-2 Change Classification + Validation Planner GREEN：ACCEPTED
→ Task 35-3 Testing Inventory Tier Realignment：ACCEPTED
→ Task 35-4 CI and Local Consumer Cutover：ACCEPTED
→ Task 35-5 ADR-023 and Human/Agent Authority Synchronization：ACCEPTED
→ Task 35-6 Evidence Reuse and Duplicate Full-Run Guard：ACCEPTED
→ 下一步：Task 35-7 Before/After Routing and Execution-Cost Acceptance
```
