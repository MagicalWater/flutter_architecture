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
Status: Active — Task 10 GitHub storage inventory and exact deletion manifest
```

## Current Problem

Repository目前以`CI_EXECUTION_MODE=self-hosted`執行可信`main`與manual workflow；Task 9已證明CI、Android與iOS self-hosted runs不會增加GitHub artifact或cache。現在的問題是cutover前累積的歷史GitHub storage仍存在，而刪除不可逆，必須先建立fresh inventory、exact-ID deletion manifest、integrity與inventory drift gate。

2026-07-30 Task 9 final inventory確認：

```txt
GitHub Actions artifacts: 110 / 7,835,943,504 bytes
GitHub Actions caches: 10 / 8,415,432,007 bytes
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

Design Spec與Implementation Plan均已取得使用者明確核准。Tasks 1–9已完成。Task 9已通過Windows／Mac manual-local、controlled failure、Observability secret-safe、self-hosted offline no-fallback、self-hosted CI／Android／iOS success與GitHub storage no-growth；正式Mac root為`/Users/water/Developer/ci-artifacts/flutter_architecture`。現在進入Task 10 exact inventory與deletion manifest；Task 10期間：

```txt
只允許只讀盤點、offline fixtures、exact ID分類與manifest integrity gate
不得依名稱、prefix、workflow或時間範圍直接送出DELETE
manifest必須完成雙層review並取得使用者再次明確核准後才可進入實際刪除
不得刪除GitHub artifacts或caches
```

## Current Next Action

```txt
建立GitHub artifact／cache offline API fixtures與RED tests
→ 實作只讀inventory與exact-ID candidate classification
→ 實作reviewed manifest、SHA-256、approval token與inventory drift gate
→ 對fresh GitHub inventory產生deletion manifest但不DELETE
→ focused review與whole-Task review
→ 停在不可逆刪除前的使用者明確核准gate
```
