---
document_type: active-milestone
status: accepted
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.17.0
---

# Active Milestone

目前active milestone：

```txt
Active Milestone: Milestone 36 — Test Authoring Cost & Risk-Based Testing Governance Corrective
State: Task 36-8 holistic accepted / local 1.17.0 release ready / publication pending
Template Baseline: 1.17.0 local release identity
```

## Active Scope

Milestone 36處理Test Authoring／Maintenance Hell的制度性風險，不重做Milestone 35的test execution routing。核心目標是讓新增tests由risk／invariant／failure mode驅動，而不是由Task／class／architecture layer數量驅動。

- Requirement Decision：Accepted — `docs/audits/milestone_36/36-r_requirement_decision.md`
- Design：Accepted — `docs/superpowers/specs/2026-08-12-milestone-36-test-authoring-cost-risk-based-testing-governance-design.md`
- Design review：PASS — `docs/audits/milestone_36/36-0_design_spec_review.md`
- Implementation Plan：Accepted — `docs/superpowers/plans/2026-08-12-milestone-36-test-authoring-cost-risk-based-testing-governance.md`
- Plan review：PASS — `docs/audits/milestone_36/36-p_implementation_plan_review.md`
- Managed worktree：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-98449518` / `milestone-36-test-authoring-governance`

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
→ Implementation Plan：ACCEPTED
→ Plan雙層Task review：PASS
→ 使用者Implementation Plan approval：APPROVED
→ Managed worktree / execution admission：PASS
→ Task 36-1 Test Authoring Decision Contract RED：ACCEPTED / expected 5 failures captured
→ Task 36-2 Central Test Authoring Governance GREEN：ACCEPTED
→ Task 36-3 Testing Governance Human Authority Alignment：ACCEPTED
→ Task 36-4 Feature Guide and Reference-Role Corrective：ACCEPTED
→ Task 36-5 Double-Layer Task Governance and TDD Behavioral Review：ACCEPTED
→ Fresh ChatGPT behavioral pressure：PASS；Scenario A的5個Tasks只需要2類new regression owners
→ Historical failed harness：Codex CLI 401只保留為execution failure，不計behavioral evidence
→ Operator constraint：後續不得使用Codex／Codex CLI
→ Task 36-6 Reference Feature Test Density Audit：ACCEPTED / existing tests deleted 0
→ Auth／Catalog／Profile：architecture／behavior references retained；test-density quota explicitly rejected
→ Task 36-7 Risk-Based Authoring Acceptance Corpus：ACCEPTED
→ Low-risk 0-new-test controls：PASS / High-risk direct-owner controls：PASS
→ Task 36-8 Holistic Final Review and Release Disposition：ACCEPTED
→ Local Template Baseline：1.17.0 / MINOR
→ Fresh holistic validation：docs 57/57、CI Python 246/246、inventory 11/11、5-workspace analyze、full Flutter regression PASS（App 493 cases）
→ 下一步：等待publication authorization；之後integrate/push main並執行Task 36-9 published-main post-release validation
```
