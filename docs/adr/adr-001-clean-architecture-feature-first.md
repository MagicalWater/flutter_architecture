---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-001-clean-architecture-feature-first
last_reviewed_baseline: 1.5.1
id: ADR-001
title: Clean Architecture and Feature First
supersedes:
superseded_by:
related:
  - ADR-002
  - ADR-005
  - ADR-007
  - ADR-012
---

# ADR-001 — Clean Architecture and Feature First

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 App 與 Feature 的主要組織方式、Clean Architecture 依賴方向，以及跨 Feature 共用能力提升至 package 的基本條件。

## Context

單純 layer-first 會讓同一 feature 的程式分散；單純 feature-first 若沒有依賴規則，又容易讓 presentation、domain 與 data 互相穿透。

## Decision

Repository 採 Feature First folder structure，並在每個 feature 內維持 Clean Architecture 依賴方向：

```txt
presentation
  ↓
domain
  ↓
data
```

Domain 不依賴 presentation 或 data implementation。只有真正跨 Feature、具有穩定 contract 且具重用價值的能力，才提升至 `packages/`。

## Consequences

- Feature 邊界與依賴方向同時保持清楚。
- 同一業務功能通常包含 presentation、domain 與 data responsibility。
- 跨 Feature 共用不等於立即抽成 generic framework；提升 package 前仍需驗證穩定 consumer 與 boundary。

## Supersession

無。

## Related Decisions

- ADR-002：Monorepo 與 workspace 結構。
- ADR-005：Auth package boundary。
- ADR-007：跨 Feature state boundary。
- ADR-012：可重用 package 的 DI boundary。

## Related Evidence

- [Aggregate Decision authority during migration](../architecture_decisions.md)
- [Current project architecture snapshot](../project_context.md)

## Last Reviewed Baseline

1.5.1。
