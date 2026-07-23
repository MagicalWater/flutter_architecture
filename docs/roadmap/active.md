---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.8.0
---

# Active Milestone

目前active milestone：

```txt
Milestone 27 — Production Observability Foundation
Baseline: 1.8.0
```

## Active Scope

在既有App-owned `ErrorReporter`、ADR-020 error architecture、native environment mapping與CI foundation之上，建立provider-neutral production observability contract，並以Firebase Crashlytics作為唯一reference adapter。

包含release identity、fatal／unexpected／degraded routing、privacy／collection、provider failure isolation、Android mapping／Flutter symbols、iOS dSYM、CI secret boundary與remote acceptance。

不包含Sentry第二adapter、Firebase Analytics、business event tracking、APM、production signing、Store distribution或Connectivity／Offline foundation。

## Current Authority

- Architecture Decision：`docs/adr/adr-026-production-observability-provider-release-symbol-contract.md`
- Capability audit：`docs/audits/production_observability_capability_audit.md`
- Design：`docs/superpowers/specs/2026-07-23-production-observability-foundation-design.md`
- Implementation plan：`docs/superpowers/plans/2026-07-23-milestone-27-production-observability-foundation.md`
- Planning review：`docs/audits/milestone_27/27-0_planning_review.md`
- Planning artifacts holistic review：`docs/audits/milestone_27/27-0_planning_artifacts_holistic_review.md`

## Current Task

```txt
Task 27-5 — iOS Native and dSYM Pipeline
```

Task 27-4已完成Android environment config projection、conditional Google Services／Crashlytics Gradle wiring、R8 mapping與production Flutter split-debug-info pipeline，並通過phase review。真實Firebase config與remote upload尚未執行。

## Latest Completed Milestone

Milestone 26已建立development／staging／production的cross-platform native environment mapping、Android product flavors、iOS shared schemes與build configurations、bootstrap mismatch guard、environment-aware local／CI verification commands與產品採用指南，並以Template Baseline 1.8.0封存。

- Architecture Decision：`docs/adr/adr-025-native-environment-mapping-product-identity-contract.md`
- Design：`docs/superpowers/specs/2026-07-22-milestone-26-native-flavor-product-identity-foundation-design.md`
- Implementation plan：`docs/superpowers/plans/2026-07-22-milestone-26-native-flavor-product-identity-foundation.md`
- Final review：`docs/audits/milestone_26/26-8_final_review.md`
- Remote validation：`docs/audits/milestone_26/26-6_remote_validation.md`

Production signing、keystore、Apple Team、provisioning、AAB、IPA、TestFlight、Play Store與App Store publishing仍未納入Milestone 26。

## Historical Artifact Routing

- `docs/milestones/README.md`

## Current Next Action

依implementation plan執行Task 27-5，建立iOS Firebase config、build phase與dSYM pipeline。
