---
document_type: package-readme
status: accepted
authoritative_for:
  - auth-package-local-contract
last_reviewed_baseline: 1.27.0
---

# Auth Package

`auth` 是 reusable Auth Domain／Data／Session package。它定義 authentication business contract 與純 Dart orchestration，但不擁有 Flutter UI、Router、DI framework 或 platform plugin composition。

## Responsibilities

- Login、Logout、Restore Session use cases。
- OTP Verify／Resend use cases與 challenge result。
- Auth repository contract與 implementation。
- Credential／Legacy credential／Auth User store interfaces。
- Secure credential migration coordination。
- Runtime `SessionManager` 與 session generation identity。
- Concurrent refresh orchestration與 lifecycle cleanup policy。
- Local unlock preference／policy與 local user-presence abstraction。

## Non-responsibilities

- 不實作 Flutter Secure Storage、SharedPreferences、SQLite 或 `local_auth` plugin adapter。
- 不操作 AuthBloc、Widget、Router 或 navigation destination。
- 不標註 GetIt／Injectable annotations。
- 不依賴Dio／Retrofit或解讀transport response；DataSource只使用`AuthEndpoint`／`AuthRefreshEndpoint`與neutral `ApiEndpointException`。
- 不提供 Device Binding、Passkey 或 biometric data storage。

## Package Layers

```txt
domain/
  Entity + Repository Interface + Failure details

data/
  RepositoryImpl + DataSource + Store contract + Migration + Lifecycle

session/
  Runtime Session + generation-aware mutation

refresh/
  AuthSessionRefresher

local_unlock/ + local_user_presence/
  Pure Dart policy and abstraction
```

## Authentication Result

Login 或 OTP verification 可能回傳：

```txt
Authenticated result
→ persist credential and Auth User
→ publish runtime Session

OTP challenge
→ no authenticated Session yet
→ presentation navigates to OTP flow
```

OTP challenge 完成前不得建立 authenticated Session。

## Credential Authority

Package 定義 `AuthCredentialStore`，實際 production adapter 由 App 以 Flutter Secure Storage 提供。

```txt
Credential Token Pair
→ AuthCredentialStore interface
→ App-owned Flutter Secure Storage adapter

Legacy credential
→ AuthLegacyCredentialStore
→ migration / cleanup only

AuthUser
→ AuthUserStore
→ App-owned SQLite adapter
```

Migration 採 write secure authority first、read-back／validation、再 best-effort cleanup legacy authority；unknown error 不能被降級或吞掉。

## Session and Refresh

- `SessionManager` 擁有 runtime session stream、generation 與 user identity。
- Refresh 使用 identity-aware single-flight。
- Rotated token pair 必須 persistence-first，再更新 runtime access token。
- Logout／relogin／account switch 後，舊 request 或舊 refresh response 不得覆蓋新 Session。
- Invalid refresh credential 觸發 Auth lifecycle destructive cleanup；temporary／unknown failures保留原 Session semantics。

## Local Unlock Boundary

- `LocalUnlockPreferenceStore` 與 `LocalUnlockPolicy` 是純 Dart contract；preference 對外只表達 enabled / disabled，未知 durable state 以 failure fail closed。
- `LocalUserPresenceVerifier` 只表達本機 user-presence verification。
- App 擁有 `local_auth` adapter、startup coordinator、lifecycle coordination、settings UI 與 navigation。
- Local unlock 不解密或另存 biometric data，也不等於 cryptographic Device Binding。

## Public API

```dart
import 'package:auth/auth.dart';
```

Public barrel export Domain、Repository、Session、Refresh、Store、Migration、Lifecycle 與 local unlock contracts。Consumer 不應 deep import `lib/src/`。

## Tests

測試位於 `packages/auth/test/`，遵守 test-by-exception，只保留 high-risk contract regression。目前 retained owners包含 credential migration、refresh race／generation cleanup，以及 sensitive-output protection。

## Related Decisions

架構 authority位於 `docs/adr/README.md` 中的 ADR-005、006、015、021與022。
