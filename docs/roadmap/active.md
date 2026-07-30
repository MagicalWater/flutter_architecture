---
document_type: active-milestone
status: accepted
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.13.0
---

# Active Milestone

目前active milestone：

```txt
Milestone 32 — CI產物本機化與GitHub儲存空間切換
Classification: Level 4 — Architecture／Milestone
Template Baseline: 1.13.0
Status: Active — Task 8 operations guide and runtime readiness
```

## Current Problem

Repository目前以`CI_EXECUTION_MODE=self-hosted`執行可信`main`與manual workflow。Self-hosted runner不消耗GitHub-hosted分鐘，但Android、iOS、Observability與failure evidence仍可能透過`actions/upload-artifact`進入GitHub Actions storage。

2026-07-30 fresh inventory確認：

```txt
GitHub Actions artifacts: 110 / 7,835,943,504 bytes
GitHub Actions caches: 15 / 10,211,585,781 bytes
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

Design Spec與Implementation Plan均已取得使用者明確核准。Tasks 1–7已完成durable authority、root／manifest contract、atomic writer、retention／capacity、safe local cleanup、manual-local／platform build integration、四份workflow local-first transport，以及Observability／failure evidence安全收斂。Task 7已完成controlled-event explicit opt-in、secret leakage scanner與blocked staging安全處置。現在進入Task 8；在Task 8完成前：

```txt
不得修改CI_EXECUTION_MODE
不得建立正式operator artifact root
不得刪除GitHub artifacts或caches
```

## Current Next Action

```txt
Task 8完成operator operations guide與runtime readiness
→ 建立root設定、查詢、pin／unpin、cleanup dry-run／apply／restore操作路徑
→ 加入static regression與runtime preflight contracts
→ 驗證clean checkout與正式Mac runtime前置條件
→ focused review與whole-Task review
→ validation與獨立commit
→ 自動進入Task 9
```
