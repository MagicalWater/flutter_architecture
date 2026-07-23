---
document_type: design-plan-index
status: active
authoritative_for:
  - design-spec-and-implementation-plan-routing
last_reviewed_baseline: 1.5.1
---

# Design Specifications and Implementation Plans

`docs/superpowers/` 保存經討論形成的 design specification，以及核准後可執行的 implementation plan。

## Authority

- Spec 是核准設計、scope 與非目標的 artifact。
- Plan 是執行順序、檔案範圍、驗證與 commit 邊界的 artifact。

Spec 與 Plan 都不代表 implementation 已完成，也不取代 current snapshot、Architecture Decision、review evidence 或 release history。

## 目錄

```txt
docs/superpowers/specs/
  Design specifications

docs/superpowers/plans/
  Task-based implementation plans
```

目前已核准、尚未開始production implementation的最新計畫：

- [`plans/2026-07-23-milestone-27-production-observability-foundation.md`](plans/2026-07-23-milestone-27-production-observability-foundation.md)

## Reading rule

執行某個 Milestone 或 phase 時，只讀該工作相關的 spec、plan 與 review；不要把所有歷史 plans 加入 AI 每次進入 repository 的必讀集合。

目前最新已核准、尚未進入implementation的架構設計：

- [`specs/2026-07-23-production-observability-foundation-design.md`](specs/2026-07-23-production-observability-foundation-design.md)：Production Observability Foundation scope、provider策略、platform／CI boundary與Task拆分。

## Lifecycle

```txt
Draft / Proposed spec
→ Review and approval
→ Implementation plan
→ Phase implementation and review
→ Final review
→ Historical artifact
```

工作完成後，Spec 與 Plan 保留作為歷史與可追溯性證據，但 current state 必須回寫至其唯一 authority，而不是持續更新舊 Plan。
