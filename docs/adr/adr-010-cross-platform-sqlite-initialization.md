---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-010-cross-platform-sqlite-initialization
last_reviewed_baseline: 1.10.0
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

本 Decision 定義Drift database opener、platform path與single-owner lifecycle boundary；它不定義某平台是否已達runtime supported。

## Context

App曾以sqflite在mobile、desktop與Web使用不同factory。Milestone 29完成整體遷移後，Drift成為唯一production database authority，platform差異仍須隔離在App-owned opener。

## Decision

Database platform差異隔離在App-owned opener，透過conditional import選擇implementation：

```txt
Native
  Drift NativeDatabase background executor

Web
  Drift WasmDatabase + drift_worker.js + sqlite3.wasm
```

`main.dart`與共用bootstrap不直接依賴`dart:io`進行平台分支。Composition Root只建立一個`AppDatabase` singleton，Auth與Catalog共用該instance。

Android／iOS沿用既有database directory與`flutter_architecture.db`檔名；Desktop使用App documents directory。sqflite僅允許存在於test-only historical compatibility harness。

Web採explicit reset disposition，不宣稱舊sqflite browser storage可自動保留。Web assets由repository追蹤與CI generation gate驗證。

## Consequences

- 共用bootstrap保持platform-safe。
- Platform implementation detail 不穿透 Feature、Domain 或 reusable package。
- 新平台可以在opener boundary新增implementation，而不修改上層資料存取contract。
- Drift是schema、migration與production lifecycle唯一authority。
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
- [Milestone 18 holistic audit](../audits/milestone_18_holistic_audit.md)

## Last Reviewed Baseline

1.10.0。
