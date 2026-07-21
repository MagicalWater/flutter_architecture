---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-008-use-case-granularity
last_reviewed_baseline: 1.5.1
id: ADR-008
title: UseCase Granularity
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-005
---

# ADR-008 — UseCase Granularity

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 UseCase 的命名與責任粒度。

## Context

以功能分類建立大型 `AuthUseCase` 或 `UserUseCase`，容易讓單一 class 累積多個不相關行為並逐漸演變成 service façade。

## Decision

一個 UseCase 對應一個清楚的業務行為，例如：

```txt
LoginUseCase
LogoutUseCase
RestoreSessionUseCase
GetProfileUseCase
```

UseCase 不以功能名稱收納多個 commands，也不為單純技術步驟建立沒有業務語意的 UseCase。

## Consequences

- 檔案與型別數量可能增加，但 responsibility、測試與依賴更清楚。
- Presentation 可依明確行為注入所需 UseCase。
- 共用 orchestration 仍應由擁有該業務流程的 application／repository boundary 處理，不回到巨型 UseCase。

## Supersession

無。

## Related Decisions

- ADR-001：Clean Architecture dependency direction。
- ADR-005：Auth domain 與 data package boundary。

## Related Evidence

- [Aggregate Decision authority during migration](../architecture_decisions.md)

## Last Reviewed Baseline

1.5.1。
