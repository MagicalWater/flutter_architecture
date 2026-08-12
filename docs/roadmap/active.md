---
document_type: active-milestone
status: accepted
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.16.0
---

# Active Milestone

目前active milestone：

```txt
Active Milestone: Milestone 36 — Test Authoring Cost & Risk-Based Testing Governance Corrective
State: Design accepted / Implementation Plan proposed and reviewed / awaiting user Plan approval
Template Baseline: 1.16.0
```

## Active Scope

Milestone 36處理Test Authoring／Maintenance Hell的制度性風險，不重做Milestone 35的test execution routing。核心目標是讓新增tests由risk／invariant／failure mode驅動，而不是由Task／class／architecture layer數量驅動。

- Requirement Decision：Accepted — `docs/audits/milestone_36/36-r_requirement_decision.md`
- Design：Accepted — `docs/superpowers/specs/2026-08-12-milestone-36-test-authoring-cost-risk-based-testing-governance-design.md`
- Design review：PASS — `docs/audits/milestone_36/36-0_design_spec_review.md`
- Implementation Plan：Proposed — `docs/superpowers/plans/2026-08-12-milestone-36-test-authoring-cost-risk-based-testing-governance.md`
- Plan review：PASS — `docs/audits/milestone_36/36-p_implementation_plan_review.md`
- Managed worktree：Not created；必須等待Design＋Plan accepted。

## Latest Completed Scope

審查並修正repository test execution cost與change-aware validation routing drift。Admission已確認目前問題不是單純tests過多，而是classifier／tier machine model／Guide wording造成over-validation，並由雙層Task的多個verification points放大成本。

- Admission audit：`docs/audits/milestone_35/35-0_test_execution_cost_admission_audit.md`
- Requirement Decision：Accepted — `docs/audits/milestone_35/35-r_requirement_decision.md`
- Design：Accepted — `docs/superpowers/specs/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance-design.md`
- Implementation Plan：Accepted — `docs/superpowers/plans/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance.md`
- Worktree：Created — `C:\Users\crazy\.devspace\worktrees\flutter_architecture-65b293eb` / `milestone-35-validation-governance`
- Production / CI mutation：Tasks 35-1～35-9 accepted / Template Baseline 1.16.0 published and closed

## Latest Completed Milestone

Milestone 35 — Test Execution Cost & Change-Aware Validation Governance Corrective已發布Template Baseline 1.16.0並完成published-main post-release validation。

- Final review：`docs/audits/milestone_35/35-8_holistic_final_review.md`
- Post-release validation：`docs/audits/milestone_35/35-9_post_release_validation.md`

## Current Next Action

```txt
Milestone 36 read-only admission：CONFIRMED
→ Problem：test authoring / maintenance overgrowth risk
→ Milestone 30：existing test ownership／rationalization保留
→ Milestone 35：validation execution planner保留
→ Requirement Decision：ACCEPT / Level 4
→ Design Spec：ACCEPTED
→ Design雙層Task review：PASS
→ 使用者Design approval：APPROVED
→ Implementation Plan：PROPOSED
→ Plan雙層Task review：PASS
→ 下一步：等待使用者明確核准Implementation Plan
→ Plan accepted後才建立managed worktree／implementation
```
