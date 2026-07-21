---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.5.0
---

# Active Milestone

## Milestone 22 — Documentation Authority & Navigation Foundation

狀態：Active。

## Goal

建立可長期控制文件增長的 authority、navigation、current snapshot、README coverage 與 automated consistency foundation，使 AI 不必載入全部歷史文件，也不會將 plan、evidence 或 superseded guidance 誤認為 current authority。

## Approved Scope

```txt
22-0 Documentation Governance Planning Review       Completed
22-1 Current-State Contradiction Remediation        Completed
22-2 Documentation Index & AI Reading Contract     Completed
22-3 Current Project Snapshot Rewrite              Completed
22-4 Roadmap Active / Candidate Separation         Completed
22-5 README Coverage Baseline                      Completed
22-6 Documentation Lint Foundation                 Next
22-7 Final Review & Decision Extraction Gate       Approved after 22-6
```

## Current Gate

22-5 已通過 Task reviews 與 whole-phase implementation review。App、Package 與 production Feature README coverage 已完整，local contract 與 metadata 已統一。

下一個允許執行的階段是：

```txt
Milestone 22-6 — Documentation Lint Foundation
```

## Next Action

依核准 implementation plan：

1. 建立 documentation checker tests。
2. 實作 relative Markdown link checker。
3. 驗證 baseline、ID、status 與 README coverage consistency。
4. 加入固定 local `docs_check` command。
5. 完成 checker regression 與整階段提交。

## Non-goals

Milestone 22 不進行：

- Production runtime behavior 改動。
- Decision 001 至 022 的全面單檔 extraction。
- 所有 audit／plan artifact 的大量物理搬移。
- CHANGELOG 歷史分卷。
- 完整 CI/CD 建置。

## Authoritative Artifacts

- Design：`docs/superpowers/specs/2026-07-21-documentation-authority-navigation-foundation-design.md`
- Planning Review：`docs/audits/milestone_22_planning_review.md`
- Implementation Plan：`docs/superpowers/plans/2026-07-21-milestone-22-documentation-authority-navigation-foundation.md`
- Phase Reviews：`docs/audits/milestone_22/`

## Completion Rule

每個小階段依固定 Task implementation → Task review → whole-phase review → commit 流程執行。只有 22-7 final review 通過後，Milestone 22 才能標示 Completed / Archived。
