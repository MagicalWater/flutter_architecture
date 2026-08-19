---
document_type: design-plan-index
status: active
authoritative_for:
  - design-spec-and-implementation-plan-routing
last_reviewed_baseline: 1.26.1
---

# Design Specifications and Implementation Plans

`docs/superpowers/` 是需要 formal Design Spec / Implementation Plan 時的工作入口，不是 completed artifact 的永久倉庫。

## Authority

- Spec 擁有需求行為、scope、non-goals 與 technical design。
- Plan 擁有 execution sequence、file scope、validation 與 completion boundaries。
- Spec / Plan 不代表 implementation 已完成，也不取代 ADR、current snapshot、review evidence、release state 或 runtime truth。

## Current active artifacts

目前沒有 active Design Spec / Implementation Plan。Current execution gate：[`../roadmap/active.md`](../roadmap/active.md)。

## Historical routing

Completed / superseded specs 與 plans 在 retention decision 後通常由 ADR、source、guide、consolidated closure 與 Git history 承接，不要求永久留在 repository。需要查歷史 Milestone 時由 [`../milestones/README.md`](../milestones/README.md) 定位 retained evidence 或 Git history。

## Reading rule

- Ordinary task 不讀歷史 Spec / Plan。
- Active Milestone execution 只讀 current accepted Spec + Plan + current gate。
- Historical investigation 先走 `docs/milestones/README.md`，再按需開對應 artifact。

## Lifecycle

```txt
Design proposed → review / user approval → accepted
Plan proposed → review / user approval → accepted
accepted Plan → implementation
completed artifact → retention decision → durable evidence / Git history
```
