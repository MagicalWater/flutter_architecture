---
document_type: active-milestone
status: accepted
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.11.0
---

# Active Milestone

目前active milestone：

```txt
None
Baseline: 1.11.0
```

## Latest Completed Milestone

Milestone 29已完成Option D一次性整體遷移：保留既有SQLite file與v1～v6 migration contract，並將AuthUser、Catalog、schema、opener與CI authority完整切換至Drift。

- Final review：`docs/audits/milestone_29/29-10_final_review.md`
- Platform evidence：`docs/audits/milestone_29/29-9_platform_runtime_regression.md`
- Post-release validation：`docs/audits/milestone_29/29-10_post_release_validation.md`

- Feasibility audit：`docs/audits/drift_adoption_feasibility_audit.md`
- Design Spec：`docs/superpowers/specs/2026-07-24-milestone-29-drift-persistence-migration-design.md`
- Design review：`docs/audits/milestone_29/29-0_design_spec_review.md`
- Implementation Plan：`docs/superpowers/plans/2026-07-24-milestone-29-drift-persistence-migration.md`
- Plan review：`docs/audits/milestone_29/29-0_implementation_plan_review.md`

## Previous Completed Milestone

Milestone 28已建立typed connectivity三態、provider-neutral adapter、`connectivity_plus` reference implementation、App lifecycle recheck、全域offline banner與Catalog opt-in reconnect revalidation，並以Template Baseline 1.10.0封存。

- Architecture Decision：`docs/adr/adr-027-connectivity-offline-state-foundation.md`
- Design：`docs/superpowers/specs/2026-07-24-connectivity-offline-state-foundation-design.md`
- Implementation plan：`docs/superpowers/plans/2026-07-24-milestone-28-connectivity-offline-state-foundation.md`
- Platform evidence：`docs/audits/milestone_28/28-7_platform_runtime_evidence.md`
- Final review：`docs/audits/milestone_28/28-9_final_review.md`
- Post-release validation：`docs/audits/milestone_28/28-10_post_release_validation.md`

Backend reachability service、generic reconnect framework、write queue、production signing、Store distribution與physical-device network acceptance仍未納入Milestone 28。

## Historical Artifact Routing

- `docs/milestones/README.md`

## Current Next Action

```txt
Review candidates／backlog
→ 選擇下一個正式方向
→ 完成Design Spec與Implementation Plan後再建立active milestone
```
