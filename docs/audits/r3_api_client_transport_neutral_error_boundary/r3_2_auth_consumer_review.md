---
document_type: phase-review
status: accepted
authoritative_for:
  - r3-auth-consumer-migration-review
last_reviewed_baseline: 1.14.0
---

# R3-2 — Auth Consumer Migration Review

## TDD Evidence

### RED

`auth_transport_independence_test.dart`先建立，production migration前fresh失敗：

- `packages/auth/pubspec.yaml`仍含Dio dependency。
- Auth DataSources仍使用`AuthApi`／`AuthRefreshApi`與Dio types。

RED原因精確對應`F-A2-01`，不是fixture或test syntax錯誤。

### GREEN

- `AuthRemoteDataSource`改依賴`AuthEndpoint`。
- `AuthRefreshRemoteDataSource`改依賴`AuthRefreshEndpoint`。
- OTP只讀`ApiEndpointException.backendCode`與immutable metadata。
- Refresh只讀neutral transport exception的httpStatus／transport kind。
- Auth pubspec、source與tests移除Dio dependency／imports／types。

## Focused Findings

### F-R3-2-01 — Independence test掃描到自己的禁止字串

- Severity：P2。
- Status：Resolved。
- Fix：contract test排除自身檔案，只掃描production與其他behavior tests。
- Fresh re-review：pubspec、lib與其餘tests全部納入。

### F-R3-2-02 — 三個repository tests仍以AuthApi作fake contract

- Severity：P1。
- Status：Resolved。
- Affected：OTP repository、persistence race、secure login tests。
- Fix：fake type改為`AuthEndpoint`，method與behavior不變。
- Fresh re-review：repository persistence／race／compensation cases全部通過。

## Behavior Preservation

- OTP invalid／expired／exhausted／cooldown／invalidated metadata mapping維持。
- Malformed OTP metadata仍是protocol violation。
- Unknown endpoint erroridentity維持。
- Refresh 401／403仍觸發invalid credential；400／408／429／5xx與connection failures仍temporary。
- Session generation、single-flight、account switch、cleanup與persistence ordering未改變。

## Mechanical Boundary Evidence

```txt
Auth pubspec direct Dio dependency: absent
Auth lib package:dio imports: 0
Auth behavior test package:dio imports: 0
DioException／DioExceptionType references outside contract scanner: 0
AuthRemoteDataSource endpoint field: present
AuthRefreshRemoteDataSource endpoint field: present
```

## Validation

```txt
Focused migrated tests: 49 passed after scanner fix
Auth full tests: 156 passed
Auth analyze: No issues found
Mechanical boundary assertions: PASSED
git diff --check: required before commit
```

## Disposition

```txt
Focused review: PASSED after two findings
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
R3-3 allowed: YES after independent commit
```
