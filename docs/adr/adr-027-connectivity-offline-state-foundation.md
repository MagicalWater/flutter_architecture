---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-027-connectivity-offline-state-foundation
last_reviewed_baseline: 1.9.0
id: ADR-027
title: Connectivity and Offline State Foundation
supersedes:
superseded_by:
related:
  - ADR-012
  - ADR-015
  - ADR-017
  - ADR-018
  - ADR-020
---

# ADR-027 — Connectivity and Offline State Foundation

## Status

Accepted。

## Authoritative Scope

本Decision定義App-owned typed connectivity state、platform adapter boundary、App lifecycle與reconnect transition ownership，以及Feature明確opt-in adoption規則。

它不擁有Catalog cache／SWR細節、Auth refresh replay、typed Failure分類、backend health monitoring或offline mutation同步。

## Context

Template Baseline 1.9.0已有Dio transport failure分類與Catalog feature-level Offline Cache，但沒有全域connectivity authority。

單次timeout、DNS、TLS、5xx或其他request failure只能說明該operation失敗；它們不能可靠證明裝置沒有網路介面。相反地，platform connectivity plugin回報有Wi-Fi或mobile route，也不能保證目標backend可達。

若Feature各自監聽plugin，會產生多重native subscription、lifecycle與resume競爭、state不一致及重複refresh。若在Dio加入global offline retry，又會誤重送command／非冪等request並與Auth refresh contract衝突。

## Decision

### Typed state

Connectivity authority只公開：

```txt
unknown
offline
online
```

- `unknown`：尚未完成可靠snapshot、provider查詢失敗、stream失效或平台無法提供可靠訊號。
- `offline`：目前沒有可用本機網路介面／route。
- `online`：至少存在一個可用本機網路介面／route。

`online`不是backend reachability保證；單次API failure不得反向覆蓋connectivity state。

### App ownership

App是唯一Composition Root與connectivity lifecycle owner：

- 建立provider adapter。
- 啟動native state subscription與current snapshot。
- 保存current typed state並只發布distinct change。
- 在App resume時要求recheck。
- 辨識真正`offline → online` reconnect transition。
- 處理provider error、stream termination與dispose。

Feature、Page、Bloc、Repository與reusable package不得直接依賴connectivity plugin。

### Startup and transition ordering

初始化先建立change stream subscription，再取得snapshot，避免兩者之間遺失transition。舊snapshot不得覆蓋較新的native event。

`unknown → online`只代表initial resolution，不算reconnect。只有已觀察到`offline → online`才可發布reconnect intent。

Provider error不等同offline；authority降級為`unknown`，且不得阻止App啟動或清除Session。

### Interface and backend separation

Connectivity Foundation不執行continuous ping或backend health probe。Backend availability仍由實際operation結果、service contract或未來獨立health capability判斷。

Presentation可在`offline`顯示本機離線context，但Feature operation Failure仍獨立存在。`online`時timeout或service failure仍可正常呈現。

### Feature opt-in

Connectivity transition只是重新嘗試的signal，不是自動retry命令。Feature必須明確opt-in並保留自己的data、cache、freshness、idempotency與operation ordering責任。

第一個adoption是Catalog：只有目前存在且已有可顯示資料的Catalog presentation可在reconnect後觸發non-blocking first-page revalidation。Catalog Repository繼續依ADR-017擁有Cache、SWR、TTL與Remote／Local coordination。

在第二個真實Feature證明相同adoption pattern前，不建立generic callback registry或Generic Offline framework。

### Retry and command safety

本Decision禁止：

- Global Dio connectivity retry interceptor。
- 所有request自動重送。
- Offline command queue、transaction outbox、sync engine或conflict resolution。
- 自動重送Login、Refresh Token、OTP、付款、交易或其他command API。

Auth 401 single-flight refresh與safe replay繼續由ADR-015擁有。

## Consequences

- App只有單一typed connectivity authority與native subscription owner。
- Feature可共享一致offline context，但不會取得provider dependency。
- Interface availability、backend reachability與operation failure保持分離。
- Catalog能以既有cache／SWR contract做有界reconnect adoption。
- 未來新增Feature仍須先定義資料與retry安全策略，不能自動繼承Catalog。

## Supersession

無。

## Related Decisions

- ADR-012：App-only Composition Root與package DI boundary。
- ADR-015：Auth refresh與safe replay。
- ADR-017：Catalog Offline Cache與SWR。
- ADR-018：Design System與page-state presentation boundary。
- ADR-020：Exception、Failure與reporting分類。

## Related Evidence

- [Capability audit](../audits/connectivity_offline_state_capability_audit.md)
- [Design spec](../superpowers/specs/2026-07-24-connectivity-offline-state-foundation-design.md)
- [Implementation plan](../superpowers/plans/2026-07-24-milestone-28-connectivity-offline-state-foundation.md)

## Last Reviewed Baseline

1.9.0。
