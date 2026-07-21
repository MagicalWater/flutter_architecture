---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-020-exception-failure-reporting
last_reviewed_baseline: 1.5.1
id: ADR-020
title: Exception Failure and Error Reporting
supersedes:
superseded_by:
related:
  - ADR-013
  - ADR-015
  - ADR-016
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-022
---

# ADR-020 — Exception, Failure and Error Reporting

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 expected operational failure、unexpected error、cancellation、protocol violation、Session lifecycle result、Exception→Failure mapping、degraded-mode reporting與 sensitive diagnostic data的責任邊界。

## Context

若 expected failure channel接受任意 `Object`，或 Bloc／Repository以 `error.toString()`把 unknown error包成普通 Failure，programming error會被吞掉並失去 stack trace。若所有 degraded operation都靜默忽略，cache與 preference failure又會失去可觀測性。Reporting同時必須避免 credential與敏感 payload進入 log。

## Decision

### Core categories

錯誤流程分成：

```txt
Expected operational failure
Unexpected programming / system error
Cancellation
Protocol violation
Session lifecycle result
```

Expected operational failure經 typed `AppException`、typed `Failure`與 `Result<T>`傳遞。Unexpected error保留原始 error與 stack trace，不轉 Failure。Cancellation是 control flow，預設不建立 user-facing Failure。External protocol violation可建立 typed protocol failure並 non-fatal report；internal invariant violation是 programming error。Session lifecycle使用自己的 typed result，不冒充 Exception／Failure。

### Failure contract

`FailureResult<T>`只能攜帶 `Failure`。Bloc不得以 `error.toString()`或 catch-all wrapping將 unknown error降級。

Failure提供跨 feature穩定 identity；operation context由 feature保存。`Failure.message`只作 diagnostic／fallback，不直接作 localized UI copy。不建立 operation-specific Failure class笛卡兒積，也不在 Failure上加入全域 `isRetryable`、`shouldClearSession`或 `shouldReport`萬用旗標。

Typed Failure使用少量穩定 kind表達 network、service、authentication、local state與 protocol semantics；HTTP status、backend code、transport kind、diagnostic code與 session identity維持分離欄位，不依模糊字串猜測。

### AppException and mapping ownership

Infrastructure／DataSource只捕捉可明確分類的第三方 operational exception，建立 typed `AppException`、保留 stack trace並加入安全 context；unknown error原樣重新拋出。

Repository只捕捉已知 `AppException`，依 operation語意映射 Failure，並決定 compensation、cache fallback與 cleanup。UseCase通常不重複 technical mapping。Bloc把 expected Failure寫入 state；若需清理 loading state後重拋 unexpected error，必須保留 stack trace。Presentation使用 Failure identity＋operation context建立 localized copy與 action。

不建立 catch-all Global Error Handler、Global Exception Mapper或 Generic Repository Mapper。允許 boundary-local的 transport、Auth或 Catalog mapper。

### Cancellation, protocol and lifecycle

- Expected query switching、subscription cancellation與 disposal不進一般 Failure或 reporting。
- External malformed response、missing required fields與 non-advancing cursor屬 protocol violation，可建立 typed protocol failure與 non-fatal report。
- Repository／Bloc宣告的 emission contract若被自身 implementation破壞，屬 internal invariant error。
- Auth refresh的 `sessionChanged`是 race-resolution result；temporary network／429／5xx不得清除 Session。
- `localStateFailure`只能由 typed local operational exception產生，unknown error不得降級成 lifecycle result。

### Degraded-mode policy

Catalog cache與 Theme／Locale preference的 non-blocking policy保留，但 expected failure仍需安全 diagnostic與 non-fatal reporting：

- Cache read failure可 remote fallback。
- Cache write failure不得吞掉 remote success。
- Recoverable cache corruption可清除受影響 read model後 remote fallback。
- Preference read failure可 fallback；write failure不回滾 runtime。
- Serialized queue只吸收已分類的 expected persistence failure，不吞 unknown error。

Unknown cache、codec、registry或 controller invariant error仍是 unexpected error。

### Reporting boundary

建立狹窄 `ErrorReporter` abstraction，接收 error、stack trace、severity與 safe diagnostic context。App是唯一 Composition Root，負責 Debug、Test、production或 Composite adapter組裝；package不直接依賴 Crashlytics、App localization或 Router。

Flutter framework、platform async與 Bloc error入口各自接到 reporting boundary，不由單一 global handler接管所有 policy。Expected UI failure通常不重複 report；unexpected error、protocol violation與重要 degraded-mode failure才進 reporting。

本 Decision不要求特定 provider dependency；production adapter可由 App Composition Root替換。

### Sensitive data

Exception、Failure、cause、context、log與 `toString()`不得包含 password、access／refresh token、Authorization header、Cookie、完整 request／response body、raw auth storage payload、非必要 PII或敏感 query parameter。

Safe context可包含 operation name、HTTP method、sanitized path template、HTTP status、backend code、transport kind、session generation、`hasSession`、resource identity、cache operation、page limit與 cursor存在與否，但不得保存 cursor值。

持有 credential、OTP、PIN、recovery code、private key或 device-binding secret的 value object／union不得使用會展開欄位的預設 `toString()`，除非另有經 review且不含原始 secret的安全摘要。

## Consequences

- Expected failure path具備型別保證，unknown error不會被普通 UI failure吞掉。
- Stack trace與 diagnostic identity可一路保留到 reporting boundary。
- Cache與 preference可維持 non-blocking UX，同時保有觀測能力。
- Retry、Session cleanup與 user-facing copy仍由擁有 operation語意的 boundary決定。
- Reporting provider與第三方 SDK不污染 reusable packages。
- Credential與敏感 payload不進一般 log或 `toString()`。

## Supersession

無。

## Related Decisions

- ADR-013：Transport、DataSource與 Repository boundary。
- ADR-015：Refresh lifecycle、Session identity與 temporary failure policy。
- ADR-016／017：Catalog protocol、cache fallback與 degraded-mode contract。
- ADR-018／019：Presentation surface與 localized copy責任。
- ADR-022：Authentication security敏感資料與 credential scope。

## Related Evidence

- [Core package README](../../packages/core/README.md)
- [API client README](../../packages/api_client/README.md)
- [Auth package README](../../packages/auth/README.md)
- [Catalog feature README](../../apps/flutter_architecture/lib/features/catalog/README.md)

## Last Reviewed Baseline

1.5.1。
