---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-012-reusable-package-di-boundary
last_reviewed_baseline: 1.5.1
id: ADR-012
title: Reusable Package Dependency Injection Boundary
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-002
  - ADR-004
---

# ADR-012 — Reusable Package Dependency Injection Boundary

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 reusable package 與 App Composition Root 之間的 dependency injection ownership。

## Context

若 reusable package 直接依賴 `get_it`／`injectable` 或自行宣告 singleton lifecycle，package 會同時負責提供能力與決定在特定 App 中如何組裝，造成 Composition Root 分散。

## Decision

Reusable package 預設不直接依賴 DI framework，也不使用 `@injectable`、`@lazySingleton`、`@singleton` 等 annotation 宣告 App lifecycle。

Package class 使用 constructor injection 表達必要依賴。App 是唯一 Composition Root，負責：

- factory、lazy singleton 與 singleton lifecycle。
- interface 與 implementation binding。
- 第三方物件、plugin adapter 與 environment-specific implementation 初始化。

只有未來某 package 被正式設計為完整 feature module，且另有 Architecture Decision 時，才可提供由 App 主動呼叫的 registration module。

## Consequences

- Package 可被不同 App、測試或不同 DI framework 重用。
- Package public API 不暴露 App-specific DI lifecycle。
- Auth、API client、core 與 design system implementation 仍由 App module 統一組裝。

## Supersession

本 Decision 不取代 App 使用 `get_it + injectable` 的選型；它只限制 reusable package 不自行綁定該 framework。與 ADR-004 的 scope relation將在 ADR-004 extraction 時正式記錄。

## Related Decisions

- ADR-001：package promotion 與 dependency direction。
- ADR-002：Monorepo package organization。
- ADR-004：App dependency injection tool selection，尚待 Batch B extraction。

## Related Evidence

- [App README](../../apps/flutter_architecture/README.md)
- [Auth package README](../../packages/auth/README.md)
- [API client package README](../../packages/api_client/README.md)

## Last Reviewed Baseline

1.5.1。
