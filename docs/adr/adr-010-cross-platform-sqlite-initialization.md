---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-010-cross-platform-sqlite-initialization
last_reviewed_baseline: 1.5.1
id: ADR-010
title: Cross-platform SQLite Initialization
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-012
  - ADR-014
---

# ADR-010 — Cross-platform SQLite Initialization

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 SQLite platform initialization 隔離與 conditional import boundary；它不定義某平台是否已達 runtime supported。

## Context

`sqflite` 在 mobile、desktop 與 Web 使用不同 database factory／初始化方式。若 executable entrypoint 直接 import `dart:io` 或散落平台判斷，Web compilation 與 App bootstrap 責任會變得脆弱。

## Decision

SQLite platform 差異隔離在 App-owned database initializer，透過 conditional import 選擇 implementation：

```txt
Mobile
  sqflite native

Desktop
  sqflite_common_ffi

Web
  sqflite_common_ffi_web
```

`main.dart` 與共用 bootstrap 不直接依賴 `dart:io` 進行平台分支。Database instance 與 lifecycle 仍由 App Composition Root 建立。

Web asset setup 屬操作步驟，由 guide／README 保存，不作為本 ADR 的平台支援證據。

## Consequences

- 共用 bootstrap 保持 Web compilation-safe。
- Platform implementation detail 不穿透 Feature、Domain 或 reusable package。
- 新平台可以在 initializer boundary 新增 implementation，而不修改上層資料存取 contract。
- Conditional implementation 或 dependency 存在，只代表 dependency-ready；Supported classification 必須由 tracked runner、artifact 與 runtime evidence 另外判定。

## Supersession

無。

## Related Decisions

- ADR-001：Infrastructure detail 不得反向穿透 Domain／Presentation。
- ADR-012：Database implementation 與 lifecycle 由 App Composition Root 組裝。
- ADR-014：Bootstrap 與 environment configuration owner。

## Related Evidence

- [Current platform classification](../project_context.md#platform-capability)
- [App README](../../apps/flutter_architecture/README.md)
- [Milestone 18 documentation baseline review](../audits/milestone_18/18-6_documentation_baseline.md)

## Last Reviewed Baseline

1.5.1。
