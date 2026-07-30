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
Status: Active — Task 10 drift re-review completed / awaiting new independent cleanup approval
```

## Current Problem

Repository目前以`CI_EXECUTION_MODE=self-hosted`執行可信`main`與manual workflow；Task 9已證明CI、Android與iOS self-hosted runs不會增加GitHub artifact或cache。現在的問題是cutover前累積的歷史GitHub storage仍存在，而刪除不可逆，必須先建立fresh inventory、exact-ID deletion manifest、integrity與inventory drift gate。

2026-07-30 Task 9 final inventory確認：

```txt
GitHub Actions artifacts: 110 / 7,835,943,504 bytes
GitHub Actions caches: 8 / 6,403,177,326 bytes
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

Design Spec與Implementation Plan均已取得使用者明確核准。Tasks 1–10已完成。第一次Task 11核准後，fresh GET發現兩個舊cache已由GitHub移除，工具在任何DELETE前fail closed；舊manifest `48e2233a0cee0f5d9cad29e2`與approval均已失效。後續review又發現GitHub `expired`旗標會改變但不影響DELETE scope，因此以TDD把drift fingerprint收斂為exact deletion scope；intermediate manifest `b6af1142e872515b7f8252d1`也已supersede。Current reviewed manifest為`9772870197227aed2ff33db6`，範圍為110個artifacts與8個caches，共14,239,120,830 bytes。現在重新停在Task 11不可逆cleanup前的獨立使用者核准gate：

```txt
不得修改reviewed manifest或沿用drift後的scope
不得依名稱、prefix、workflow或時間範圍送出DELETE
必須取得對manifest ID、object count、bytes與不可逆範圍的再次明確核准
不得刪除GitHub artifacts或caches
```

## Current Next Action

```txt
報告replacement reviewed manifest ID、SHA、object count、bytes與不可逆影響
→ 取得使用者新的獨立明確cleanup核准
→ Task 11先fresh GET並驗證manifest hash與inventory無drift
→ 只有全部gate一致時依exact IDs刪除
→ 任一drift回到Task 10重新產生／review／核准
```
