---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-006-auth-guard-session-authority
last_reviewed_baseline: 1.5.1
id: ADR-006
title: Auth Guard Session Authority
supersedes:
superseded_by:
related:
  - ADR-005
  - ADR-007
  - ADR-021
---

# ADR-006 — Auth Guard Session Authority

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Route Guard 的 authentication dependency boundary。

## Context

Route Guard 真正需要的是目前是否存在有效 Session，而不是 Auth Feature 使用哪一種 presentation state management implementation。

## Decision

Auth Guard 依賴穩定的 Session authority，例如 `SessionManager` 或窄化的 `AuthSessionReader`，不得依賴 `AuthBloc`。

Route Guard 只消費 authenticated authority，不負責 credential persistence、restore orchestration、refresh 或 UI navigation state。

## Consequences

- Router 不綁定 Auth presentation implementation。
- AuthBloc 未來替換為其他 state management 時，Guard contract 不需要改變。
- Locked、OTP pending 或未完成 restore 的階段，只要 Session authority 維持 unauthenticated，Protected Route 就不得放行。

## Supersession

無。

## Related Decisions

- ADR-005：Auth package 與 App presentation boundary。
- ADR-007：跨 Feature state dependency。
- ADR-021：App-owned Auth startup 與 navigation coordination。

## Related Evidence

- [Auth feature README](../../apps/flutter_architecture/lib/features/auth/README.md)

## Last Reviewed Baseline

1.5.1。
