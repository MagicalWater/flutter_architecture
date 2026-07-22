---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.7.0
---

# Active Milestone

```txt
Milestone 26 — Native Flavor & Product Identity Foundation
Baseline: 1.7.0
Current task: 26-0 Planning Review and Architecture Design completed
Next task: 26-1 Environment Mapping Contract
```

## Scope

將Dart `development`／`staging`／`production` environment延伸為Android product flavor、iOS shared scheme、native identity、display name、entrypoint綁定與repository verification contract。

Milestone 26不包含production signing、keystore、Apple Team、provisioning、AAB、IPA、TestFlight、App Store或Play Store publishing。

## Current Authority

- Design：`docs/superpowers/specs/2026-07-22-milestone-26-native-flavor-product-identity-foundation-design.md`
- Planning review：`docs/audits/milestone_26/26-0_planning_review.md`
- ADR draft：`docs/audits/milestone_26/adr-025_draft.md`
- Implementation plan：`docs/superpowers/plans/2026-07-22-milestone-26-native-flavor-product-identity-foundation.md`

## Current Gate

Planning findings M26-PR01–M26-PR14均已有disposition，Open P0／P1為0。

下一步只能執行Task 26-1；每個Task必須完成implement、self-review、findings、fix、re-review、Open P0／P1=0、validation與commit。未經明確要求不得push。

## Historical Artifact Routing

- `docs/milestones/README.md`
