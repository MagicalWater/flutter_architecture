---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.9.0
---

# Active Milestone

目前active milestone：

```txt
Milestone 28 — Connectivity and Offline State Foundation
Baseline: 1.9.0
```

## Active Scope

建立App-owned typed connectivity authority，明確區分本機網路介面可用性、backend reachability與單次operation failure，並以Catalog既有Offline Cache／SWR作為第一個feature opt-in reconnect integration。

- Design：`docs/superpowers/specs/2026-07-24-connectivity-offline-state-foundation-design.md`
- Implementation plan：`docs/superpowers/plans/2026-07-24-milestone-28-connectivity-offline-state-foundation.md`
- Planning review：`docs/audits/connectivity_offline_state_plan_review.md`
- Architecture Decision：`docs/adr/adr-027-connectivity-offline-state-foundation.md`

Implementation依Task 28-1～28-8執行；所有Task完成後仍需Milestone holistic final review、release、push與post-release validation。

## Latest Completed Milestone

Milestone 27已建立provider-neutral production observability contract、Firebase Crashlytics reference adapter、release identity、severity routing、privacy／collection policy、Android symbols、iOS dSYM、controlled remote acceptance，以及三種CI execution mode與trusted Mac self-hosted runner，並以Template Baseline 1.9.0封存。

- Architecture Decision：`docs/adr/adr-026-production-observability-provider-release-symbol-contract.md`
- Design：`docs/superpowers/specs/2026-07-23-production-observability-foundation-design.md`
- Implementation plan：`docs/superpowers/plans/2026-07-23-milestone-27-production-observability-foundation.md`
- Final review：`docs/audits/milestone_27/27-8_final_review.md`
- Post-release validation：`docs/audits/milestone_27/27-9_post_release_remote_validation.md`
- Remote acceptance：`docs/audits/milestone_27/27-6_ci_secrets_remote_acceptance_review.md`
- Self-hosted runtime evidence：`docs/audits/milestone_27/27-7_self_hosted_ci_runtime_evidence.md`

Sentry第二adapter、Analytics／APM、production signing、Store distribution、physical-device acceptance與Connectivity／Offline foundation仍未納入Milestone 27。

## Historical Artifact Routing

- `docs/milestones/README.md`

## Current Next Action

```txt
執行Milestone 28 implementation plan
→ 每個Task完整審查循環與commit
→ Milestone holistic final review
```
