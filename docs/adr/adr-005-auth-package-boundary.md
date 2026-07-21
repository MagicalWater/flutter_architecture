---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-005-auth-package-boundary
last_reviewed_baseline: 1.5.1
id: ADR-005
title: Auth Package Boundary
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-012
  - ADR-013
---

# ADR-005 — Auth Package Boundary

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Auth domain／data capability 與 App-owned Auth presentation 的 package boundary。

## Context

Authentication 不只是單一登入頁。Credential、Session、restore、logout、refresh 與其他 authentication lifecycle 會被 Router、Profile、API client 與 App startup 使用，若綁在 App 內某個 presentation feature，跨 feature dependency 會反向依賴 Auth UI detail。

## Decision

Auth reusable capability 位於：

```txt
packages/auth
  domain
  data
  session
```

App presentation 位於：

```txt
apps/flutter_architecture/lib/features/auth
  presentation
```

`packages/auth` 擁有 Auth domain model、Repository contract／implementation、UseCase、Session abstraction 與純 Dart application coordination。Auth Bloc、Page、Router mapping、plugin adapter 與 App Composition Root wiring 留在 App。

## Consequences

- Auth capability 可被 App 中多個 feature 透過穩定 contract 使用。
- Presentation technology 不成為 Route Guard、Profile 或 transport 的 dependency。
- Plugin implementation 與 lifecycle 仍由 App 組裝，不因移入 package 而分散 Composition Root。

## Supersession

無。

Aggregate 內的「長期應調整」與「後續移動」是已完成遷移前的歷史措辭；canonical contract 使用目前有效邊界，不保存 implementation completion journal。

## Related Decisions

- ADR-001：跨 feature 共用能力可提升至 package。
- ADR-006：AuthGuard 依賴 Session authority，不依賴 AuthBloc。
- ADR-007：跨 feature 不直接依賴對方 Bloc。
- ADR-008：Auth UseCase 依業務行為拆分。
- ADR-012：Package 不自行綁定 DI framework。
- ADR-013：Auth remote boundary 透過 API abstraction 與 data layer mapping。

## Related Evidence

- [Auth package README](../../packages/auth/README.md)
- [Auth feature README](../../apps/flutter_architecture/lib/features/auth/README.md)
- [App README](../../apps/flutter_architecture/README.md)

## Last Reviewed Baseline

1.5.1。
