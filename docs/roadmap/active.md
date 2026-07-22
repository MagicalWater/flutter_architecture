---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.6.1
---

# Active Milestone

目前 active milestone：

```txt
Milestone 25 — iOS Platform Support Foundation
Baseline: 1.6.1
```

## Active Scope

Milestone 25建立tracked iOS runner、iOS 13 native contract、CocoaPods-compatible Flutter 3.41.6 integration、Swift Package Manager readiness audit、Simulator build／runtime evidence、macOS golden authority與GitHub-hosted iOS build gate。

- Design：`docs/superpowers/specs/2026-07-22-milestone-25-ios-platform-support-foundation-design.md`
- Planning Review：`docs/audits/milestone_25/25-0_planning_review.md`

本Milestone不包含Flutter 3.44+升級、pure-SPM migration、Apple Developer帳號治理、production signing、provisioning、App Store Connect、TestFlight、App Store上傳、Push Notifications、正式Bundle Identifier、多Scheme／多Flavor或Fastlane。

## Latest Completed Milestone

Milestone 24已將既有 docs checker、workspace analyze、全部 Flutter tests、tracked generated source與 Android release build contract轉為 GitHub Actions repository-level automated gates，並完成final review與封存。

- Planning Review：`docs/audits/milestone_24/24-0_planning_review.md`
- Architecture Decision：`docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- Implementation plan：`docs/superpowers/plans/2026-07-22-milestone-24-ci-cd-foundation.md`
- Final review：`docs/audits/milestone_24/24-6_final_review.md`
- Post-release remote validation：`docs/audits/milestone_24/24-7_post_release_remote_validation.md`

第一版範圍包含 Pull Request quality gates、main branch revalidation、manual dispatch、generated consistency、exact toolchain、cache、Android release APK artifact、Branch Protection guidance與 failure／rollback policy。

Template Baseline 1.6.1已補齊GitHub-hosted CI與Android remote evidence，並修正跨平台golden、Linux字型路徑與Node 24 Actions相容性。

Production signing、Play Store／App Store publishing、iOS build、GitHub Release、environment promotion與dependency auto-update不在本 Milestone。

## Historical Artifact Routing

- `docs/milestones/README.md`

## Current Next Action

建立並review Milestone 25 implementation plan，之後依逐Task implementation／review／修正／re-review／commit流程執行。

```txt
accepted design
→ implementation plan
→ plan review
→ phased implementation
```
