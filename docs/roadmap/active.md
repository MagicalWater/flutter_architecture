---
document_type: active-milestone
status: accepted
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.14.0
---

# Active Milestone

目前active milestone：

```txt
Milestone 32 — CI產物本機化與GitHub儲存空間切換
Classification: Level 4 — Architecture／Milestone
Template Baseline: 1.14.0
Status: Active — Local release candidate completed / post-release validation required
```

## Current Problem

Repository目前以`CI_EXECUTION_MODE=self-hosted`執行可信`main`與manual workflow；managed local store與GitHub exact-ID cleanup均已完成。現在只剩release SHA的self-hosted post-release validation、storage no-growth與clean-checkout closure gate。

2026-07-30 Task 9 final inventory確認：

```txt
GitHub Actions artifacts: 0 / 0 bytes
GitHub Actions caches: 0 / 0 bytes
Self-hosted runner: water-mac-flutter-architecture / online / idle
```

Runtime inventory只由`docs/audits/ci_artifact_storage_cutover_candidate_handoff.md`與本Milestone後續runtime evidence保存；Roadmap不承擔可變數字的持續authority。

## Accepted Requirement Decision

```txt
Decision: Accept
Level: 4 — Architecture／Milestone
Design Spec: Required
Implementation Plan: Required after Design approval
ADR gate: Update ADR-023 after Design approval
Task governance: Full two-layer governance
Worktree: milestone-32-ci-artifact-storage-cutover
Release decision: Required
Post-release validation: Required
```

正式scope、non-goals、artifact ownership、retention、cleanup safety與runtime acceptance由：

- `docs/superpowers/specs/2026-07-30-milestone-32-ci-artifact-local-storage-cutover-design.md`
- `docs/audits/milestone_32/32-0_design_spec_review.md`

擁有。

## Current Gate

Design Spec與Implementation Plan均已取得使用者明確核准。Tasks 1～11 local execution與holistic review已完成。Final reviewed manifest `7ad138bb845e42cbb133d07c`依使用者獨立明確核准刪除110個artifacts與3個caches；113次exact-ID attempts全部成功，fresh inventory與逐IDre-query確認GitHub Actions storage為0 objects／0 bytes。Template Baseline已提升為1.14.0；目前只剩post-release gate：

```txt
release commit必須推送至main
self-hosted CI、Android與iOS必須在release SHA成功
Observability ordinary push必須保持skipped
GitHub artifact／cache必須維持0／0
clean-checkout governance validation必須通過
```

## Current Next Action

```txt
提交並推送Template Baseline 1.14.0 release commit
→ 在main release SHA執行self-hosted CI／Android／iOS
→ 確認Observability ordinary push skipped與GitHub storage維持0／0
→ clean-checkout validation
→ 建立post-release evidence並將active milestone設為None
```
