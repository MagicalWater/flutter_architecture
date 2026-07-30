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
Status: Active — Implementation Plan drafting and review
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

Design Spec已於2026-07-30 13:41（Asia/Taipei）取得使用者明確核准並轉為`accepted`。目前允許建立proposed Implementation Plan；在Plan完成完整雙層Task治理並取得使用者明確核准前：

```txt
不得修改ADR-023
不得修改workflows或CI scripts
不得修改CI_EXECUTION_MODE
不得建立artifact storage目錄
不得刪除GitHub artifacts或caches
```

## Current Next Action

```txt
使用writing-plans建立proposed Implementation Plan
→ focused review與findings修正
→ fresh re-review與whole-Plan review
→ 使用者明確核准Plan
→ 才可開始implementation
```
