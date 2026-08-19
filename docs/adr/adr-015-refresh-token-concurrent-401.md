---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-015-refresh-token-concurrent-401
last_reviewed_baseline: 1.5.1
id: ADR-015
title: Refresh Token and Concurrent 401 Handling
supersedes:
superseded_by:
  - ADR-022
related:
  - ADR-005
  - ADR-006
  - ADR-012
  - ADR-013
  - ADR-020
  - ADR-021
  - ADR-022
---

# ADR-015 — Refresh Token and Concurrent 401 Handling

## Status

Accepted；credential storage implementation scope由 ADR-022部分取代。

## Authoritative Scope

本 Decision 定義 authenticated 401、refresh coordination、request replay、Session identity、credential commit ordering與被動 Session invalidation的責任邊界。

它不擁有目前 credential-at-rest provider、legacy migration或 biometric／OTP contract。

## Context

若把 refresh API、token persistence、Session invalidation、request replay與 navigation全部放入 Dio interceptor，會造成 package dependency cycle、重複 refresh、interceptor recursion、跨帳號 replay、Logout後舊 response復活 Session，以及 temporary transport failure被誤判為 credential失效。

因此 transport、Auth application flow、persistence、runtime Session與 App navigation必須保持分離。

## Decision

### Interceptor responsibility

`AuthHeaderInterceptor` 只讀取目前 runtime Session snapshot、加入 access token，並將 request所屬的 generation與 user identity寫入 metadata。它不呼叫 refresh、不清除 Session、不 replay request，也不操作 Router或 Bloc。

獨立的 `AuthRefreshInterceptor` 只處理符合下列條件的 authenticated 401：

```txt
statusCode == 401
requiresAuth == true
skipAuthRefresh != true
authRetryCount == 0
request 曾實際帶上 access token
```

Login、Refresh、public endpoint、沒有 token的 request與已 replay request不進入 refresh flow。

### Main and Refresh transport separation

App Composition Root建立不同 transport graph：

```txt
Main Dio
  ├── AuthHeaderInterceptor
  └── AuthRefreshInterceptor

Refresh Dio
  └── 不安裝 AuthHeaderInterceptor
  └── 不安裝 AuthRefreshInterceptor
```

Login與 refresh使用不同 Retrofit abstraction。`packages/api_client` 定義 transport所需的窄 refresh abstraction；`packages/auth` 提供讀取 credential、呼叫 refresh API、single-flight、rotation、Session update與 invalidation的實作。App負責 binding與 lifecycle。

### Single-flight identity

Single-flight由 Auth-side refresh coordinator擁有，不放在 interceptor內。同一時間只有相同 Session identity的 caller可共用同一個 refresh operation。

Identity至少包含：

```txt
sessionGeneration
userId
failedAccessToken
```

舊 operation completion清除 in-flight state時必須再次比對 identity，不能清除較新的 operation。

Login、Restore、Logout、Refresh commit與 passive invalidation對 credential與 runtime Session的複合修改，必須由共享 mutation coordinator序列化；refresh HTTP request本身不持有該 lock。

### Request and Session identity validation

每個 authenticated request保存送出時的 access token、generation與 user identity。

401返回時：

- 若 current generation與 userId仍相同，但 current access token已不同，代表同一 Session已有其他 operation完成 refresh，可直接使用 current token replay，不再次 refresh。
- 若 generation或 userId不同，代表 request所屬 Session已被 Logout、invalidation、relogin或 account switch取代；不得 refresh，也不得以新 Session token replay舊 request。

Refresh response在任何 persistence或 runtime commit前，都必須再次驗證 captured generation與 userId仍是 current identity。Stale response回傳 `sessionChanged`，不得寫入 credential、更新 Session或 replay request。

### Runtime and persistence authority

`SessionManager` 維持 runtime-only state holder，不負責 storage、refresh API或 Dio exception。HTTP request使用的 current access token authority是 runtime Session snapshot；App restart後的 restore authority是 Auth credential storage。

Refresh token不透過 SessionManager暴露給 Route Guard或其他跨 feature consumer。

Session generation在 Login成功、Restore成功、主動 Logout與 passive invalidation時遞增；同一 Session內的 access token rotation不建立新 generation。

Credential provider與 legacy migration由 authentication security Decision擁有，但以下 ordering仍屬本 Decision：

```txt
驗證 refresh response
→ 驗證 Session identity
→ 持久化完整 credential snapshot
→ 更新 runtime Session
→ 完成 refresh result
→ replay等待中的 request
```

Persistence失敗時不得更新 runtime token或 replay request，並依 Auth lifecycle contract執行補償式 cleanup與 Session clear。

### Failure classification

Refresh lifecycle使用 typed result，至少區分：

```txt
success
sessionExpired
temporarilyUnavailable
sessionChanged
localStateFailure
```

- Credential缺失、已知過期、server明確判定 invalid credential或 malformed rotation response可導致 `sessionExpired`。
- 無網路、DNS、timeout、429、5xx與其他 temporary backend／transport failure不得直接清除 Session。
- `sessionChanged` 是 race-resolution result，不是 Failure。
- `localStateFailure` 只來自已分類的 local operational failure；unknown error不得被降級為此結果。

被動 Session invalidation不等同使用者主動 Logout，也不經由 `LogoutUseCase`。Interceptor不得操作 Router或 Bloc；上層透過 Session authority transition反映未登入狀態。

### Replay policy

每個 request最多自動 replay一次，並標記：

```txt
authRetryCount = 1
```

Replay後再次收到401不觸發第二次 refresh。

只有可安全重建的 request可自動 replay。Stream body、Multipart／upload stream、已消耗 body、特殊 download flow與已取消 request必須明確 opt out或提供 transport-specific replay policy。

Refresh只解決身份 credential更新，不提供付款、下單等業務冪等性；非冪等 command仍需獨立 Idempotency Key contract。

Reactive server 401是最終 refresh protection。未來即使加入 proactive refresh，也不能移除401 handling。

## Consequences

- Concurrent 401不會對同一 Session重複呼叫 refresh。
- 舊 Session request不能被新帳號 token replay。
- Logout、relogin與 account switch不會被 stale refresh response覆蓋。
- Temporary failure保留 Session；只有明確 credential invalidation或不可恢復 local auth state才清除 Session。
- API client、Auth package、App Composition Root與 navigation維持單向責任。

## Supersession

Aggregate Decision 015中「SharedPreferences單一 JSON作為 Token Pair current implementation」已不再是 current credential-at-rest contract。該 scope由 ADR-022 secure credential authority取代，並已建立 reciprocal supersession relation。

Refresh concurrency、Session identity、safe replay、failure classification與 commit ordering仍有效。

## Related Decisions

- ADR-005：Auth package與 App presentation boundary。
- ADR-006：Route Guard只依賴 Session authority。
- ADR-012：App是唯一 Composition Root。
- ADR-013：Retrofit／Dio transport boundary。
- ADR-020：typed failure與 unknown error handling。
- ADR-021：App-owned Auth navigation coordination。
- ADR-022：credential-at-rest、OTP與 local unlock security umbrella。

## Related Evidence

- [Auth package README](../../packages/auth/README.md)
- [API client README](../../packages/api_client/README.md)
- [App README](../../apps/flutter_architecture/README.md)
- [Milestone 18 holistic audit](../audits/milestone_18_holistic_audit.md)
- [Milestone 19 holistic final review](../audits/milestone_19_holistic_final_review.md)

## Last Reviewed Baseline

1.5.1。
