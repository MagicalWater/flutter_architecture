---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-002-monorepo-melos
last_reviewed_baseline: 1.5.1
id: ADR-002
title: Monorepo and Melos Workspace
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-012
---

# ADR-002 — Monorepo and Melos Workspace

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 App、packages、Dart Pub Workspaces 與 Melos 的 repository ownership。

## Context

本模板需要同時管理 executable App 與多個具明確 boundary 的 reusable packages，並提供一致的 workspace command 與 code generation ordering。

## Decision

Repository 使用 Monorepo：

```txt
root/
  apps/
  packages/
```

Root `pubspec.yaml` 是 Dart Pub Workspaces 與 Melos 8 的主要設定來源。Workspace package 使用 `resolution: workspace`。Melos command 透過 `dart run melos ...` 執行，不依賴全域安裝。

需要 code generation 的 workspace command 必須依 dependency graph 順序執行，避免下游 package 在上游 generated sources 尚未完成前啟動。

## Consequences

- App 與 reusable packages 可在同一 repository 協同開發與驗證。
- Root workspace configuration 是 package discovery 與 command orchestration authority。
- `melos.yaml` 不再作為主要設定來源；操作命令細節由 `AGENTS.md` 維護。

## Supersession

無。

## Related Decisions

- ADR-001：Feature 與 package 的組織原則。
- ADR-012：package 不自行決定 DI lifecycle。

## Related Evidence

- [Agent commands](../../AGENTS.md)
- [Current repository map](../project_context.md)

## Last Reviewed Baseline

1.5.1。
