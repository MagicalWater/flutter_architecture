---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-003-presentation-state-and-hooks
last_reviewed_baseline: 1.5.1
id: ADR-003
title: Presentation State and Hooks
supersedes:
superseded_by:
related:
  - ADR-007
  - ADR-018
---

# ADR-003 — Presentation State and Hooks

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 `flutter_bloc`、`flutter_hooks` 與 `hooked_bloc` 在 Presentation Layer 的責任分工。

## Context

業務狀態需要明確事件與 state flow；控制器等畫面暫態若全部進入 Bloc，會增加不必要的業務 state。傳統巢狀 Bloc widgets 也會降低 UI 可讀性。

## Decision

- `flutter_bloc` 負責業務狀態與明確 state transition。
- `flutter_hooks` 負責 UI-local transient state，例如 controller 與 focus lifecycle。
- `hooked_bloc` 可用於降低 Presentation 中 Bloc builder／listener 的巢狀。

這些工具只改變 presentation implementation，不授權跨 Feature 直接讀取其他 Feature 的 Bloc。

## Consequences

- Business state 與 UI-local state 有清楚 owner。
- Hook lifecycle 不進入 Domain 或 Data Layer。
- UI 可使用 hook-based Bloc integration，但仍必須遵守 Feature boundary。

## Supersession

無。

## Related Decisions

- ADR-007：跨 Feature 不依賴對方 Bloc。
- ADR-018：Design System 與 Feature presentation boundary。

## Related Evidence

- [Aggregate Decision authority during migration](../architecture_decisions.md)

## Last Reviewed Baseline

1.5.1。
