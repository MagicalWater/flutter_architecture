---
document_type: design-plan-index
status: active
authoritative_for:
  - design-spec-and-implementation-plan-routing
last_reviewed_baseline: 1.25.0
---

# Design Specifications and Implementation Plans

`docs/superpowers/` 保存 accepted / proposed Design Spec 與 Implementation Plan。

## Authority

- Spec 擁有需求行為、scope、non-goals 與 technical design。
- Plan 擁有 execution sequence、file scope、validation 與 completion boundaries。
- Spec / Plan 不代表 implementation 已完成，也不取代 ADR、current snapshot、review evidence、release state 或 runtime truth。

## Current active artifacts

- Design：[`specs/2026-08-19-milestone-46-documentation-skill-governance-simplification-design.md`](specs/2026-08-19-milestone-46-documentation-skill-governance-simplification-design.md)
- Plan：[`plans/2026-08-19-milestone-46-documentation-skill-governance-simplification.md`](plans/2026-08-19-milestone-46-documentation-skill-governance-simplification.md)
- Current execution gate：[`../roadmap/active.md`](../roadmap/active.md)

## Historical routing

Completed / superseded specs and plans 保留原路徑，不在本 index 重複維護逐 Milestone 狀態。需要查歷史 Milestone 時由 [`../milestones/README.md`](../milestones/README.md) 路由到對應 Design / Plan / review / release evidence。

直接目錄：

```txt
docs/superpowers/specs/
docs/superpowers/plans/
```

## Reading rule

- Ordinary task 不讀歷史 Spec / Plan。
- Active Milestone execution 只讀 current accepted Spec + Plan + current gate。
- Historical investigation 先走 `docs/milestones/README.md`，再按需開對應 artifact。

## Lifecycle

```txt
Design proposed → review / user approval → accepted
Plan proposed → review / user approval → accepted
accepted Plan → implementation
completed artifact → historical evidence；不再改寫成 current state
```
