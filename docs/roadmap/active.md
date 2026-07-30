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
Status: Active — Task 2 artifact contract and root validation
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

Design Spec與Implementation Plan均已取得使用者明確核准。Task 1已將artifact ownership、transport、root、manifest、retention與cleanup durable contract寫入ADR-023，並完成focused review與whole-Task review。現在進入Task 2；在Task 2完成前：

```txt
不得修改workflows或CI scripts
不得修改CI_EXECUTION_MODE
不得建立artifact storage目錄
不得刪除GitHub artifacts或caches
```

## Current Next Action

```txt
Task 2以TDD建立artifact root與manifest contract
→ RED root／path／schema tests
→ minimal implementation
→ GREEN與portability regression
→ focused review與whole-Task review
→ validation與獨立commit
→ 自動進入Task 3
```
