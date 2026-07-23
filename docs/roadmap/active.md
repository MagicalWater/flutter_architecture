---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.8.0
---

# Active Milestone

目前沒有active milestone：

```txt
None
Baseline: 1.8.0
```

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

Production Observability Foundation已完成capability audit、architecture design與formal review；目前仍未建立implementation plan或切換為active milestone。

- Capability audit：`docs/audits/production_observability_capability_audit.md`。
- Architecture design：`docs/superpowers/specs/2026-07-23-production-observability-foundation-design.md`。
- Formal review：`docs/audits/production_observability_design_review.md`。

下一步是新增Production Observability ADR、建立Milestone 27 implementation plan與planning promotion；不是重新進行同一份scope discovery，也不是直接修改production source。

```txt
approved candidate
→ ADR
→ implementation plan
→ planning review
→ active milestone promotion
```
