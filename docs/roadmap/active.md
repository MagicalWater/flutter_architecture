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
None
Baseline: 1.10.0
```

## Active Scope

目前沒有active milestone。新的正式方向必須先完成capability audit、scope review、Design Spec與Implementation Plan治理循環，再提升為active。

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
評估下一個candidate
→ 完成capability audit與正式規劃治理
→ 核准後才建立新的active milestone
```
