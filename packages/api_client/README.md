---
document_type: package-readme
status: accepted
authoritative_for:
  - api-client-package-local-contract
last_reviewed_baseline: 1.5.0
---

# API Client Package

`api_client` 擁有同一 backend boundary 的 Dio／Retrofit transport contract、wire DTO、interceptors 與 mock APIs。

## Responsibilities

- Main Dio 與 Refresh Dio factory contract。
- Retrofit Auth、Refresh、Profile、Catalog APIs。
- Mock API implementations。
- Authorization header injection。
- Concurrent 401 refresh integration 與 safe request replay。
- Transport exception mapping 與 safe failure details。
- Login、Refresh、Profile、Catalog 與 OTP wire DTO。

## Non-responsibilities

- 不建立 Domain entity 或決定 business result。
- 不保存 credential、Auth User 或 runtime Session。
- 不操作 Bloc、Router 或 logout UI。
- 不持有 GetIt／Injectable registration。

## Dio Topology

```txt
Main Dio
├── AuthHeaderInterceptor
└── AuthRefreshInterceptor

Refresh Dio
└── no auth refresh interceptor
```

Main Dio 的 authenticated 401 可委派 `AuthRefresher`；Refresh Dio 必須與 Main Dio 分離，避免 refresh recursion。

## Refresh and Safe Replay

- Concurrent 401 使用 single-flight refresh orchestration。
- Request 必須符合 session identity 與 replay-safety contract 才能自動重送。
- Stream、multipart、upload、progress callback 與不安全 request 不自動 replay。
- Retry marker 防止 repeated 401 infinite loop。
- Interceptor 不直接清理 persistence；credential lifecycle 由 `packages/auth` orchestration 負責。

## OTP Wire Contract

Transport DTO 包含：

- `OtpChallengeDto`
- `VerifyOtpRequestDto`
- `ResendOtpRequestDto`
- `AuthenticatedResponseDto`

OTP code、password、Authorization 與 token 不得出現在 diagnostic `toString()`、logs 或 reporting safe context。

## Error Contract

Transport failures 由 `TransportExceptionMapper` 轉為 typed `AppException`／safe details。HTTP response body、Authorization header 與 credential-bearing payload 不得直接進 diagnostic message。

## Public API

```dart
import 'package:api_client/api_client.dart';
```

Public barrel export APIs、DTOs、Dio factory、interceptors、request extras、mock APIs 與 transport mapping contracts。Consumer 不應 deep import `lib/src/`。

## Dependency and Composition

Package 不使用 DI annotation。App Composition Root 建立 Dio、選擇 Mock／Real API、注入 token provider 與 refresher。

## Tests

測試位於 `packages/api_client/test/`，重點包括 interceptors、safe replay、concurrent 401、DTO serialization、transport mapping、OTP sensitive output 與 Mock／Real contract。

## Related Decisions

架構 authority 位於 `docs/architecture_decisions.md` 的 API Client、Environment、Refresh Token、Exception Architecture 與 OTP Decisions。
