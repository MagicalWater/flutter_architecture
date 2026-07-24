---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.9.0
---

# Active Milestone

目前沒有active milestone：

```txt
None
Baseline: 1.9.0
```

## Latest Completed Milestone

Milestone 27已建立provider-neutral production observability contract、Firebase Crashlytics reference adapter、release identity、severity routing、privacy／collection policy、Android symbols、iOS dSYM、controlled remote acceptance，以及三種CI execution mode與trusted Mac self-hosted runner，並以Template Baseline 1.9.0封存。

- Architecture Decision：`docs/adr/adr-026-production-observability-provider-release-symbol-contract.md`
- Design：`docs/superpowers/specs/2026-07-23-production-observability-foundation-design.md`
- Implementation plan：`docs/superpowers/plans/2026-07-23-milestone-27-production-observability-foundation.md`
- Final review：`docs/audits/milestone_27/27-8_final_review.md`
- Remote acceptance：`docs/audits/milestone_27/27-6_ci_secrets_remote_acceptance_review.md`
- Self-hosted runtime evidence：`docs/audits/milestone_27/27-7_self_hosted_ci_runtime_evidence.md`

Sentry第二adapter、Analytics／APM、production signing、Store distribution、physical-device acceptance與Connectivity／Offline foundation仍未納入Milestone 27。

## Historical Artifact Routing

- `docs/milestones/README.md`

## Current Next Action

下一個正式方向必須先由`docs/roadmap/candidates.md`或`docs/backlog.md`完成scope review與planning promotion。

```txt
candidate review
→ design
→ planning review
→ active milestone promotion
```
