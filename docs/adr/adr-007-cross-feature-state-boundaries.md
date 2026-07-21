---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-007-cross-feature-state-boundaries
last_reviewed_baseline: 1.5.1
id: ADR-007
title: Cross-feature State Boundaries
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-003
  - ADR-006
  - ADR-021
---

# ADR-007 — Cross-feature State Boundaries

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Feature 之間的 state 與 application communication boundary。

## Context

直接讀取其他 Feature 的 Bloc 會讓一個 Feature 依賴另一個 Feature 的 presentation detail，造成 state ownership、測試與替換困難。

## Decision

Page 只直接依賴自身 Feature 的 presentation boundary。跨 Feature 所需的狀態或行為，透過下列較穩定 contract 傳遞：

- SessionManager 或 application coordinator。
- Repository interface。
- UseCase。
- Domain abstraction。

不得為了取得其他 Feature 狀態而直接讀取、dispatch 或持有對方 Bloc。

## Consequences

- Profile、Auth、Shell 與其他 Feature 不以彼此 Bloc 作為 integration API。
- 跨 Feature orchestration 由 App composition、domain 或 application boundary 擁有。
- Feature-local Bloc 可獨立替換或測試。

## Supersession

無。

## Related Decisions

- ADR-001：Feature First 與依賴方向。
- ADR-003：Bloc 是 Presentation detail。
- ADR-006：Auth Guard 依賴 Session authority。
- ADR-021：Auth navigation orchestration 位於 App composition layer。

## Related Evidence

- [Profile feature README](../../apps/flutter_architecture/lib/features/profile/README.md)
- [Auth feature README](../../apps/flutter_architecture/lib/features/auth/README.md)

## Last Reviewed Baseline

1.5.1。
