---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-004-app-dependency-injection
last_reviewed_baseline: 1.5.1
id: ADR-004
title: App Dependency Injection
supersedes:
superseded_by:
  - ADR-012
related:
  - ADR-001
  - ADR-002
  - ADR-012
  - ADR-014
---

# ADR-004 — App Dependency Injection

## Status

Accepted；reusable package lifecycle scope 已由 ADR-012 部分取代。

## Authoritative Scope

本 Decision 定義 executable App 的 dependency injection tool selection 與 Composition Root registration responsibility。

## Context

Clean Architecture 會產生 Bloc、UseCase、Repository、DataSource、API client、database、storage 與 plugin adapter 等依賴。若全部手寫註冊，App Composition Root 容易膨脹並出現漏註冊或 lifecycle 不一致。

## Decision

App 使用：

- `get_it` 作為 DI container。
- `injectable` 產生 App-owned registration code。

App Composition Root 負責第三方物件、interface binding、environment-specific implementation 與 lifecycle selection。SharedPreferences、database、Dio、plugin adapter 等物件由 App module 建立或註冊。

Generated registration file 不可手動修改；需要調整時應修改 source registration declaration 後重新執行 code generation。

## Consequences

- App 的 dependency graph 有單一組裝入口。
- Registration boilerplate 可由 code generation 降低。
- 測試可在 App boundary 替換 implementation。
- Reusable package 不因本 Decision 自動獲得使用 `get_it`／`injectable` 或宣告 lifecycle 的權限。

## Supersession

ADR-012 部分取代本 Decision 可能被解讀為「所有 package 都可直接使用 `get_it`／`injectable`」的範圍。

仍然有效的 scope：App 可使用 `get_it + injectable`，且 App 是 lifecycle 與 interface binding owner。

被取代的 scope：reusable package 不得自行依賴 DI framework 或宣告 App lifecycle；該規則由 ADR-012 擁有。

## Related Decisions

- ADR-001：Clean Architecture dependency direction。
- ADR-002：App 與 package 的 Monorepo organization。
- ADR-012：Reusable package DI boundary，部分取代本 Decision 的 package scope。
- ADR-014：Configuration 由 bootstrap 建立後傳入 Composition Root。

## Related Evidence

- [App README](../../apps/flutter_architecture/README.md)
- [AGENTS dependency injection rules](../../AGENTS.md)

## Last Reviewed Baseline

1.5.1。
