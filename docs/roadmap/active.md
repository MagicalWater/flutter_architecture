---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.10.0
---

# Active Milestone

目前active milestone：

```txt
Milestone 29 — Drift Persistence Migration
Baseline: 1.10.0
```

## Active Scope

已接受Drift adoption feasibility audit與Milestone 29 Design Spec。正式方向為Option D一次性整體遷移，目標是在保留既有SQLite file、v1～v6 migration、AuthUser與Catalog correctness的前提下，將App database authority完整切換為Drift。

Design Spec與Implementation Plan均已接受。production persistence仍未修改；下一步依Plan開始Task 29-1 historical fixtures與compatibility harness，該gate通過前不得切換production DI。

- Feasibility audit：`docs/audits/drift_adoption_feasibility_audit.md`
- Design Spec：`docs/superpowers/specs/2026-07-24-milestone-29-drift-persistence-migration-design.md`
- Design review：`docs/audits/milestone_29/29-0_design_spec_review.md`
- Implementation Plan：`docs/superpowers/plans/2026-07-24-milestone-29-drift-persistence-migration.md`
- Plan review：`docs/audits/milestone_29/29-0_implementation_plan_review.md`

## Latest Completed Milestone

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
Task 29-1 — Historical Database Fixtures and Compatibility Harness
→ 完整Task review、validation與commit
→ 自動進入Task 29-2
```
