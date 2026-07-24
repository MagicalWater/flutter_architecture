---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.13.0
---

# Active Milestone

目前active milestone：

```txt
Milestone 31 — Template Development Workflow Governance Recovery
Template Baseline: 1.13.0（已發布；治理閉合重新審查中）
```

## Recovery reason

Milestone 31 的原始執行未完整證明 Design Spec、Implementation Plan、各 implementation Task、holistic final review 與 post-release validation 均遵守雙層 Task 治理。既有實作與 1.13.0 release 保留，但 completed／archived 宣告撤回，直到 recovery review 建立可追溯證據。

## Current phase

```txt
Recovery Tasks 31-R0～31-R9：Accepted
Recovery Task 31-R10：Local final review accepted
Current state：Local recovery complete; post-release validation pending
Next：31-R11 push、clean-checkout、remote CI與post-release closure
```

## Current routing

- Recovery入口：`docs/audits/milestone_31/31-r0_governance_recovery.md`
- Design Spec：`docs/superpowers/specs/2026-07-24-milestone-31-template-development-workflow-governance-design.md`
- 原Implementation Plan：`docs/superpowers/plans/2026-07-24-milestone-31-template-development-workflow-governance.md`

## Closure rule

Milestone 31只有在Spec、Plan、每個Task、holistic review、fresh regression、clean-checkout與remote／post-release validation全部重新通過後，才可恢復Completed／Archived並清空active milestone。
