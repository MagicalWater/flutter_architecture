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
- Task 27-7 Design：`docs/superpowers/specs/2026-07-24-self-hosted-ci-execution-mode-design.md`
- Task 27-7 Implementation plan：`docs/superpowers/plans/2026-07-24-self-hosted-ci-execution-mode.md`
- Task 27-7 Design review：`docs/audits/milestone_27/27-7_self_hosted_ci_design_review.md`
- Task 27-7 Plan review：`docs/audits/milestone_27/27-7_self_hosted_ci_plan_review.md`

## Current Task

```txt
Task 27-7 — CI Execution Mode and Self-hosted Runner Foundation
```

Task 27-7目前已完成Design與Implementation Plan的完整審查，正在執行Task 1：activation與ADR authority同步。此Task將建立`manual-local`、`self-hosted`與`github-hosted`三種正式CI execution mode，讓可信`main` push與人工dispatch可由Mac self-hosted runner執行，同時保留人工本機與GitHub-hosted回退路徑。

Task 27-6已完成CI secret boundary、Android／iOS explicit symbol upload、staging controlled non-fatal入口與本機iOS runtime傳送證據。Firebase secrets與App設定已完成；Android remote event與symbolication已有證據。iOS新build的symbols已成功提交，Simulator第二次啟動後Crashlytics report endpoint回應HTTP 200；Firebase Console ingestion與最終symbolication closure仍待確認。Task 27-7不得取代或提前關閉Task 27-6。

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

完成Task 27-7 Task 1的ADR與current authority同步，接著進入Task 2 execution mode contract與舊`local`命名遷移。Task 27-7完成後，再依最新iOS Firebase Console證據關閉Task 27-6。
