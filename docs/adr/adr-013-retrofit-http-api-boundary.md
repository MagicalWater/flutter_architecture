---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-013-retrofit-http-api-boundary
last_reviewed_baseline: 1.5.1
id: ADR-013
title: Retrofit HTTP API Boundary
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-005
  - ADR-012
  - ADR-014
---

# ADR-013 — Retrofit HTTP API Boundary

## Status

Accepted。

## Authoritative Scope

本 Decision 定義真實 HTTP API、Dio transport、DTO／Mapper、RemoteDataSource 與 Repository 之間的責任邊界。

## Context

若每個 endpoint 直接手寫 Dio request，method、path、query、body、serialization 與錯誤處理會重複且不一致。另一方面，Retrofit 與 wire DTO 若穿透到 Domain，會使業務模型依賴 transport detail。

## Decision

所有一般真實 HTTP endpoint 使用 Retrofit declaration 與 generated implementation。Dio 保留為底層 transport，負責 options、timeout、interceptor、header 與 request／response transport。

一般 Feature、Repository 與 DataSource 不直接呼叫 `dio.get`／`post`／`put`／`delete`。特殊 streaming、download 或 protocol bridge 若 Retrofit 無法合理表達，可在 `packages/api_client` 內建立封裝後的 Dio service，但 Dio 不得穿透 package boundary。

Mock 與 Retrofit implementation 遵守相同 API abstraction，由 App Composition Root 依 environment 選擇。

資料邊界：

```txt
HTTP JSON
  ↓ Retrofit / json_serializable
DTO
  ↓ feature-owned data mapper
Domain Model
```

- API model 使用 `XxxRequestDto`／`XxxResponseDto`／`XxxDto`。
- DTO 不等於 Domain Entity。
- Mapper 只負責純資料轉換。
- RemoteDataSource 建立 request DTO、呼叫 API abstraction 並隔離 transport exception。
- Repository 協調資料來源、副作用與 `AppException → Failure` mapping。
- Domain 不依賴 Dio、Retrofit、JSON annotation 或 generated client。

Authenticated endpoint 透過 request metadata 標記，由 auth transport boundary 統一加入 Authorization header，不在每個 method 手動組合 credential。

## Consequences

- 真實 API declaration 一致且可生成。
- Mock／Real implementation 可在 Composition Root 替換。
- Wire model、Domain model 與業務副作用維持分離。
- 只有形成新的跨系統架構規則時，特殊 transport 例外才需要新的 Architecture Decision。

## Supersession

無。

## Related Decisions

- ADR-001：Clean Architecture dependency direction。
- ADR-005：Auth data capability 與 App presentation boundary。
- ADR-012：API implementation lifecycle 由 App 組裝。
- ADR-014：Environment 與 Mock／Real selection configuration。

## Related Evidence

- [API client package README](../../packages/api_client/README.md)
- [Auth package README](../../packages/auth/README.md)
- [Milestone routing](../milestones/README.md)

## Last Reviewed Baseline

1.5.1。
