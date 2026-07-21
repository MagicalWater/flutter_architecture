---
document_type: active-milestone
status: completed
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.5.1
---

# Active Milestone

目前沒有 active milestone。最近完成：

```txt
Milestone 23 — Architecture Decision Record Extraction & Normalization
Status: Completed / Archived
Final review: Accepted
Release decision: No release; baseline remains 1.5.1
```

## Scope and Artifacts

本 Milestone 將 Decision 001–022 轉為 canonical single-file ADR、正式 index、可驗證 supersession graph與 legacy compatibility routing。

- Planning Review：`docs/audits/milestone_23/23-0_planning_review.md`
- Migration manifest：`docs/migrations/m23_adr_extraction_manifest.md`
- Implementation plan：`docs/superpowers/plans/2026-07-21-milestone-23-architecture-decision-record-extraction-normalization.md`

ADR-001至ADR-022已完成 extraction與 authority cutover；`docs/adr/README.md`現在是正式 Decision routing authority，舊 aggregate路徑維持 compatibility stub。

Milestone 22 — Documentation Authority & Navigation Foundation 已完成 final review、full verification 與 archive transition。

## Last Completed Milestone

```txt
Milestone 23 — Architecture Decision Record Extraction & Normalization
Status: Completed / Archived
Baseline: 1.5.1
```

Final review：

- `docs/audits/milestone_23/23-9_final_review.md`

Historical artifact routing：

- `docs/milestones/README.md`

## Current Next Action

從`docs/roadmap/candidates.md`選擇下一個候選方向，先完成scope與planning review，再提升為active milestone。

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
