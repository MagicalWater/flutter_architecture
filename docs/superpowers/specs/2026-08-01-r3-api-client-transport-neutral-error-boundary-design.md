---
document_type: design-spec
status: accepted
authoritative_for:
  - r3-api-client-transport-neutral-error-boundary-design
last_reviewed_baseline: 1.14.0
---

# R3 — API Client Transport-neutral Error Boundary Design

## Requirement Decision

- Request（需求）：修復`F-A2-01`，移除`packages/auth`對Dio type與raw response interpretation的依賴。
- Problem（問題）：Auth DataSource直接import Dio、catch `DioException`、讀取`Response.data`並呼叫Dio-specific mapper；`api_client` public barrel同時export Dio-specific mapping types。
- Current behavior（目前行為）：Retrofit API abstraction隔離request declaration，但transport exception type仍穿過package boundary。
- Expected behavior（預期行為）：Dio只存在`packages/api_client` transport implementation內；跨package只暴露endpoint interface、DTO與transport-neutral endpoint exception envelope。
- Value（價值）：恢復ADR-013 boundary、降低Auth transport耦合、讓Mock／Real failure contract一致、保留unknown error identity。
- Classification（分類）：Level 3 — Architecture refactor。
- Decision（決策）：Accept。
- Scope（範圍）：api_client endpoint contracts／Dio adapters／neutral exception、Auth DataSource與tests、App Composition Root與generated DI、package docs、finding closure。
- Non-goals（非目標）：不重寫Profile／Catalog endpoint architecture；不改refresh single-flight／replay；不改OTP business semantics；不新增generic multi-client framework；不處理R4／R5；不merge、不push、不release。
- Behavioral requirements required（是否需要行為需求）：Yes。
- Design Spec required（是否需要Design Spec）：Yes。
- Implementation Plan required（是否需要Implementation Plan）：Yes。
- ADR required（是否需要ADR）：No；ADR-013既有contract不變，本次修復implementation drift。
- Task governance mode（Task治理模式）：Full。
- Worktree／branch：既有隔離branch `audit/template-baseline-1.14-project-holistic`。
- Regression level（Regression等級）：api_client、auth、App DI focused tests；affected workspace analyze／tests；generated consistency；App bundle。
- Release required（是否需要發布）：No；只有未來merge到baseline時另走release gate。
- Required Skills：brainstorming、writing-plans、test-driven-development、karpathy-guidelines、executing-plans、verification-before-completion。

## User Authorization

使用者於2026-08-01授權在沒有新scope／architecture decision時自動完成remaining remediation tasks。R3採ADR-013唯一明確方向，不建立新的architecture rule，因此standing authorization適用。Merge、push、remote branch deletion與release仍未授權。

## Authority

- ADR-013：Dio不得穿透`api_client` package boundary。
- ADR-012：App擁有composition與implementation selection。
- ADR-020：Expected transport／backend failures使用typed exception／failure；unknown error不得吞掉。
- Auth package README：Auth是純Dart reusable package，不擁有transport implementation。

## Considered Approaches

### A — Auth catch Object後回呼Dio mapper

移除Auth的Dio import，但仍讓DioException先穿過boundary，再把`Object`交回api_client helper。

**Rejected：**只隱藏compile-time type，沒有真正封閉runtime boundary。

### B — Endpoint interface + api_client-owned adapters

保留Retrofit declaration作internal transport API，新增跨package endpoint interface；Real adapter在api_client內catch Dio並throw neutral envelope，Mock直接遵守同一endpoint contract。

**Selected。**

### C — 將OTP backend mapping全部移入api_client

api_client直接認識OTP business failure並產生Auth domain details。

**Rejected：**會反轉dependency，使transport package擁有Auth business semantics。

## Boundary Design

### Transport declarations

既有`AuthApi`與`AuthRefreshApi`繼續作Retrofit declarations，只供App Composition Root建立Real implementation與adapter使用。

### Consumer endpoints

新增：

```dart
abstract interface class AuthEndpoint {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request);
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request);
}

abstract interface class AuthRefreshEndpoint {
  Future<RefreshTokenResponseDto> refresh(RefreshTokenRequestDto request);
}
```

Auth DataSource只依賴這兩個interface。

### Neutral error envelope

新增`ApiEndpointException`：

- `AppException transportException`
- `String? backendCode`
- immutable `Map<String, Object?> backendMetadata`
- `int? get httpStatus`
- `toString()`不得輸出metadata、raw payload、credential或OTP code。

Envelope只保存backend error metadata所需的string-keyed map，不保存Dio `RequestOptions`、`Response`、header或raw transport object。

### Real adapters

- `DioAuthEndpoint implements AuthEndpoint`
- `DioAuthRefreshEndpoint implements AuthRefreshEndpoint`

Adapter規則：

1. 成功回傳原DTO。
2. `DioException`轉為`ApiEndpointException`。
3. Response body只有在是string-keyed map時抽取`code`與其餘metadata。
4. Unknown error使用`Error.throwWithStackTrace`保留identity與stack。
5. 不記錄或stringifyraw response。

### Mock adapters

`MockAuthApi`改為實作`AuthEndpoint`，backend failure直接throw neutral envelope，不再import Dio。`MockAuthRefreshApi`實作`AuthRefreshEndpoint`。

## Auth Mapping

### Login

- Catch `ApiEndpointException`。
- 重新拋出`transportException`並保留stack。
- Unknown error原樣拋出。

### OTP Verify／Resend

- 只讀`backendCode`與`backendMetadata`。
- Auth仍擁有`OtpFailureDetails`與metadata validation。
- Recognized OTP code轉為Auth session `AppException`。
- Unknown backend code退回transport exception。
- Malformed metadata維持protocol violation。

### Refresh

- 只讀neutral envelope的`httpStatus`。
- 401／403 → `InvalidRefreshCredentialException`。
- 其他known endpoint failure → `TemporaryRefreshException`。
- `FormatException`與malformed success response維持temporary protocol failure。
- Unknown error原樣拋出。

## Public API

`api_client.dart`export：

- Consumer endpoint interfaces。
- Dio endpoint adapters，供App Composition Root組裝。
- `ApiEndpointException`。
- DTO、Retrofit declarations、Mock endpoints及既有neutral helper。

不再export：

- `TransportFailureDetails`。
- `mapDioException`或任何signature含Dio type的mapper。

`rethrowMappedTransportException(Object, StackTrace)`可保留供App-ownedProfile／Catalog DataSource使用，但其public file不得暴露Dio-specific symbol。

## App Composition

`ApiImplementationSelector`回傳`AuthEndpoint`與`AuthRefreshEndpoint`：

- Mock：`MockAuthApi`／`MockAuthRefreshApi`。
- Real：`DioAuthEndpoint(AuthApi(dio))`／`DioAuthRefreshEndpoint(AuthRefreshApi(dio))`。

`RegisterModule`綁定endpoint types並注入Auth DataSource；generated DI由source重新產生。

## Dependency Result

R3完成後：

```txt
packages/auth/pubspec.yaml
  no dio dependency

packages/auth/lib + test
  no package:dio import

api_client public contracts
  no exported declaration whose signature exposes DioException／DioExceptionType
```

App Composition Root仍可依賴Dio，因其負責transport implementation selection。

## TDD Contract

### RED 1 — api_client adapter

先寫tests要求Dio adapter產生neutral envelope、抽取safe metadata、保留unknown error identity與safe `toString()`。

### RED 2 — Auth package independence

先將Auth tests改為使用neutral endpoint／envelope，並加入source／pubspec assertion禁止Dio dependency；在production migration前必須失敗。

### RED 3 — App Composition

先更新selector tests要求Real回傳Dio endpoint adapter、Mock回傳neutral endpoint，及DI resolution取得endpoint types；generated source更新前必須失敗。

## Task Design

### R3-1 — API Client Endpoint Boundary

新增interfaces、neutral exception、Dio adapters、Mock migration、internal mapper split與api_client tests。

### R3-2 — Auth Consumer Migration

以TDD把DataSources與tests切到neutral endpoint，移除Dio dependency。

### R3-3 — App Composition and Generated DI

更新selector／RegisterModule／tests，執行build_runner並驗證runtime composition。

### R3-4 — Holistic Closure

更新package docs與current snapshot必要摘要，只關閉`F-A2-01`，執行affected workspace full regression與App bundle。

## Validation

Focused：

```bat
cd packages/api_client && flutter test
cd packages/auth && flutter test
cd apps/flutter_architecture && flutter test test/app/di
```

Holistic：

```bat
dart pub get
dart run melos run build_runner
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture && flutter build bundle
```

另執行source assertions：Auth無Dio dependency／import、public barrel無Dio-specific mapper export、generated consistency與working tree hygiene。

## Acceptance Criteria

- Auth package不依賴或import Dio。
- Auth DataSource不接觸Dio response／request type。
- Mock／Real共用endpoint interface與neutral failure contract。
- OTP與refresh既有behavior全部通過。
- Unknown error identity與sensitive-output contract保持。
- App DI resolve成功、generated files由source產生。
- `F-A2-01` Resolved by R3；`F-A1-04`與`F-A6-01`保持Open。
- Open P0=0；Open P1 without disposition=0。
- 未merge、未push、未release。

## Design Approval Closure

```txt
Focused Design review: PASSED after findings disposition
Whole-Design review: PASSED
Open Design P0: 0
Open Design P1 without disposition: 0
User authorization: covered by standing authorization on 2026-08-01
Design status: ACCEPTED
```
