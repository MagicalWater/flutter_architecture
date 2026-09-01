---
document_type: package-readme
status: accepted
authoritative_for:
  - api-client-package-local-contract
last_reviewed_baseline: 1.27.0
---

# API Client Package

`api_client` 擁有同一 backend boundary 的 Dio／Retrofit transport contract、wire DTO、interceptors 與 mock APIs。

## Responsibilities

- Main Dio 與 Refresh Dio factory contract。
- Retrofit Auth、Refresh、Profile、Catalog APIs。
- Consumer-facing Auth／Refresh endpoint interfaces與Dio-owned adapters。
- Mock API implementations。
- Authorization header injection。
- Concurrent 401 refresh integration 與 safe request replay。
- Transport exception mapping、safe internal details與transport-neutral endpoint failure envelope。
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

Transport failures在package內轉為typed `AppException`。Auth／Refresh consumer透過`ApiEndpointException`取得safe backend code與endpoint顯式allowlist的immutable metadata；Dio `Response`、`RequestOptions`、headers、raw payload與未經審核的runtime path不得穿出package boundary，也不得進diagnostic message。

## Public API

```dart
import 'package:api_client/api_client.dart';
```

`api_client.dart` 只提供日常 consumer contract：consumer-facing endpoint、wire DTO、refresh contract 與 neutral endpoint exception。

Composition Root、Dio／Retrofit wiring、interceptor、mock implementation 或 transport infrastructure 才使用：

```dart
import 'package:api_client/api_client_infrastructure.dart';
```

Infrastructure barrel 會包含 default consumer API，加上 Dio factory、Auth interceptor contract、Retrofit declarations、Dio endpoint adapters、request extras、mock implementations，以及目前 App-owned transport DataSource 仍需要的 transport mapper。Safe transport detail types仍維持package internal implementation。Consumer不應deep import `lib/src/`。

## Dependency and Composition

Package不使用DI annotation。App Composition Root建立Dio，將Retrofit declarations包裝為Dio endpoint adapters，選擇Mock／Real endpoint，並注入token provider與refresher。

## Adding an Endpoint

新增同一 backend boundary 的 endpoint 時，依下列順序處理：

```txt
API abstraction / Retrofit declaration
→ wire DTO and serialization
→ generated Retrofit / Freezed / JSON source
→ consumer endpoint interface / Dio adapter
→ Mock / Real endpoint contract parity
→ public barrel export
→ authentication metadata and transport policy
→ transport exception mapping
→ Feature DataSource / Repository mapping
→ App DI selection / registration
→ Package and Feature tests
→ repository verification
```

完整 Feature integration 流程先讀：

- [How to Add a Feature](../../docs/guides/how-to-add-feature.md)

### 1. Declare the transport contract

一般 HTTP endpoint 使用 `lib/src/api/` 下的 Retrofit declaration。Method、path、query、body 與 response DTO 留在 transport boundary；不要讓 Dio、Retrofit annotation 或 generated client 穿透至 Domain。

新增或修改 declaration 後，必須由 source 重新產生對應 `*.g.dart`，不得手動編輯 generated file。

Architecture authority：

- [ADR-013 — Retrofit HTTP API Boundary](../../docs/adr/adr-013-retrofit-http-api-boundary.md)

### 2. Add wire DTOs and serialization

Wire model 放在 `lib/src/models/`，只表達 request／response payload。需要 Freezed／JSON serialization 時修改 source DTO，再執行 build runner；不要手動修改：

```txt
*.freezed.dart
*.g.dart
```

DTO 不承擔 Domain business state，也不得把 password、OTP code、access token、refresh token、Authorization header 或 raw credential payload 暴露在 diagnostic `toString()`、log 或 reporting context。

### 3. Keep Mock and Real APIs aligned

同一 abstraction 若已有 Mock／Real 選擇，新增 endpoint 時必須同步確認：

```txt
Retrofit implementation
Mock implementation
request and response contract
expected failure behavior
stateful mock behavior（若存在）
```

Mock 可以提供 deterministic fixture，但不得形成另一套 Domain contract。App 仍透過 `ApiImplementationSelector` 與 Composition Root 決定 environment implementation。

主要入口：

```txt
packages/api_client/lib/src/mocks/
apps/flutter_architecture/lib/app/di/api_implementation_selector.dart
apps/flutter_architecture/lib/app/di/register_module.dart
```

### 4. Export only supported public contracts

一般 Feature consumer 只應透過：

```dart
import 'package:api_client/api_client.dart';
```

使用 package public API。只有 Composition Root／transport infrastructure 才使用 `api_client_infrastructure.dart`。新增 abstraction、DTO 或 helper 時，先判斷它屬於 everyday consumer contract 還是 infrastructure wiring，再決定 export surface；不要因方便而把 package inventory 全部塞回 default barrel，也不要要求 consumer deep import `lib/src/`。

### 5. Apply authentication and replay policy

Authenticated endpoint 使用既有 request metadata／interceptor boundary，不在每個 method 手動組合 credential。

新增 endpoint 時必須判斷：

- 是否 public 或 authenticated。
- request 是否具備安全 replay 條件。
- 是否包含 stream、multipart、upload、progress callback 或其他不可自動 replay 的 body。
- repeated 401 是否會被 retry marker 阻止。
- refresh request 是否必須留在獨立 Refresh Dio，避免 recursion。

不要因新增 endpoint 而在 Feature、Repository 或 Retrofit method 內自行實作 token refresh。

相關 authority：

- [ADR-015 — Refresh Token Concurrent 401](../../docs/adr/adr-015-refresh-token-concurrent-401.md)
- [ADR-022 — Authentication Security Capability Boundaries](../../docs/adr/adr-022-authentication-security-capability-boundaries.md)

### 6. Preserve transport error boundaries

Transport error 透過既有 `TransportExceptionMapper` 與 safe details contract 轉為 typed `AppException`。不要直接把 Dio response、raw response body 或 credential-bearing payload 回傳給 Repository 或顯示層。

Feature DataSource 負責呼叫 API abstraction 與轉換 wire DTO；Repository implementation 負責協調 DataSource 並映射 Domain result／Failure。Package 不新增 Domain entity，也不決定 user-facing localization。

相關 authority：

- [ADR-020 — Exception, Failure and Reporting](../../docs/adr/adr-020-exception-failure-reporting.md)

### 7. Compose in the App

若 endpoint 需要新的 API abstraction、factory input 或 environment selection，App Composition Root 才負責實際 binding 與 lifecycle：

```txt
apps/flutter_architecture/lib/app/di/api_implementation_selector.dart
apps/flutter_architecture/lib/app/di/register_module.dart
apps/flutter_architecture/lib/app/di/injection.dart
```

`api_client` package 本身不加入 GetIt／Injectable annotation，也不依賴 App configuration。

DI authority：

- [ADR-012 — Reusable Package DI Boundary](../../docs/adr/adr-012-reusable-package-di-boundary.md)
- [Flutter Architecture App README](../../apps/flutter_architecture/README.md)

### 8. Select validation and regenerate when needed

Transport／refresh／replay／sensitive-output等critical failure若被改變，先確認是否已有direct regression owner；只有既有owner不足時才新增temporary或permanent test。可能的existing owners包含：

```txt
packages/api_client/test/
affected Feature data / repository tests
App DI selector / registration tests
serialization and sensitive-output regression
interceptor / replay behavior（若受影響）
```

先由repository planner選minimum sufficient validation：

```bash
python tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

只有Retrofit／serialization等generated declaration受影響時才執行build runner。若App runtime input、assets、configuration、plugin或native build contract受到影響，再依planner與[CI/CD Operations Guide](../../docs/guides/ci_cd_operations.md)執行相應Android／iOS representative build。

## Adding an External Client

新 external system 不應直接塞進既有 `api_client`。先評估它是否具有獨立的：

```txt
authentication
error format
rate limit
release lifecycle
base URL / environment policy
reuse boundary
```

若這些邊界與既有 backend 顯著不同，應先進入 architecture review，決定是否建立獨立 client package。此 README 只提供判斷入口，不建立新的 package splitting rule；正式責任仍由 canonical ADR、Documentation Hub 與 App Composition Root contract 擁有。

在 review 完成前，不要先建立 generic multi-client framework，也不要讓 Feature 直接知道底層協調了幾個 external systems。

## Tests

測試位於 `packages/api_client/test/`，遵守 test-by-exception，只保留 high-risk contract regression。目前 retained owners包含 Auth refresh／safe replay，以及 transport diagnostic／backend metadata sensitive-boundary protection。

## Related Decisions

架構 authority 位於 `docs/adr/README.md` 中的 ADR-013、014、015、020與022。
