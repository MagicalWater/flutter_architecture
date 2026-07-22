---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.6.1
---

# Active Milestone

目前沒有 active milestone：

```txt
None
Latest completed: Milestone 24 — CI/CD Foundation
Baseline: 1.6.1
```

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

Review `docs/roadmap/candidates.md`與`docs/backlog.md`，經正式planning review後再提升下一個active milestone。

```txt
Candidate review
→ scope / non-goals
→ planning review
→ active promotion
```
