---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.5.1
---

# Active Milestone

目前 active milestone：

```txt
Milestone 23 — Architecture Decision Record Extraction & Normalization
Current phase: 23-0 ADR Extraction Planning Review
Planning gate: Accepted
Implementation status: Not started
```

## Scope and Artifacts

本 Milestone 將 Decision 001–022 轉為 canonical single-file ADR、正式 index、可驗證 supersession graph與 legacy compatibility routing。

- Planning Review：`docs/audits/milestone_23/23-0_planning_review.md`
- Migration manifest：`docs/migrations/m23_adr_extraction_manifest.md`
- Implementation plan：`docs/superpowers/plans/2026-07-21-milestone-23-architecture-decision-record-extraction-normalization.md`

23-0 尚未拆分任何 Decision。Final cutover前 `docs/architecture_decisions.md` 仍是正式 authority。

Milestone 22 — Documentation Authority & Navigation Foundation 已完成 final review、full verification 與 archive transition。

## Last Completed Milestone

```txt
Milestone 22 — Documentation Authority & Navigation Foundation
Status: Completed / Archived
Baseline: 1.5.1
```

Final review：

- `docs/audits/milestone_22/22-7_final_review.md`

Historical artifact routing：

- `docs/milestones/README.md`

## Current Next Action

依 accepted plan 開始 Task 23-1：ADR index與 migration-aware checker foundation。

```txt
Task implementation
→ immediate Task review
→ fix / re-review
→ next Task
→ whole-phase implementation review
→ fix / re-review
→ commit
→ unified report
```
