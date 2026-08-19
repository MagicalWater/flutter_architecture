---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-022-authentication-security-capability-boundaries
last_reviewed_baseline: 1.5.1
id: ADR-022
title: Authentication Security Capability Boundaries
supersedes:
  - ADR-015
superseded_by:
related:
  - ADR-005
  - ADR-006
  - ADR-012
  - ADR-015
  - ADR-020
  - ADR-021
---

# ADR-022 — Authentication Security Capability Boundaries

## Status

Accepted。此 Decision只在 credential-at-rest implementation scope部分取代 ADR-015；ADR-015的 refresh concurrency、Session identity、safe replay與 failure classification仍有效。

## Authoritative Scope

本 Decision定義 Authentication Security三種能力的責任拆分：

```txt
Credential-at-rest security
Server-issued OTP step-up authentication
Biometric-gated local session unlock
```

它同時定義 reusable Auth contract、App-owned plugin implementation、Session establishment gate、platform capability claim與安全 non-goals。

## Context

Secure credential migration、OTP challenge state machine與本機 biometric user-presence verification處理的是不同威脅與不同 lifecycle。若把三者視為單一「安全登入」功能，容易讓 storage migration、server authentication與 local device access control互相耦合，並造成 package暴露 plugin detail、OTP前提前建立 Session或 biometric能力被誤宣稱為 server authentication／Device Binding。

## Decision

### Capability separation

Authentication Security維持三個獨立 contract：

- Credential-at-rest security負責 secure credential source of truth、legacy migration、rotation、read-back validation、corruption與 cleanup。
- OTP step-up負責 server-issued challenge、verify、resend、expiration與 Session issuance state machine。
- Local unlock只負責本機 user-presence gate，在 credential restore與 Session commit前阻擋存取。

任一能力不得冒充另一能力：

- Secure storage不代表使用者已通過 server authentication。
- OTP不代表 credential已安全儲存。
- Biometric verification不代表 server authentication、cryptographic Device Binding或 biometric資料由 App保存。

### Secure credential authority

Access Token與 Refresh Token的 current credential-at-rest authority是 platform secure storage adapter；AuthUser等非 credential資料維持獨立 user persistence boundary。

Reusable Auth contract使用狹窄 abstraction描述 credential、legacy credential與 user store，不暴露 `flutter_secure_storage`、SharedPreferences、SQLite、Keystore或 Keychain class。

Legacy migration遵守 fail-closed identity policy：

- 只有完整 Token Pair且可驗證 user identity的 legacy資料具有 migration資格。
- 缺少 Refresh Token或 identity的單 access-token資料不得升級成有效 Session。
- 已驗證 secure credential是權威；legacy資料不得覆蓋它。
- Secure credential與 persisted user identity不一致時不得猜測，必須清除完整 Auth state並維持未登入。
- Secure read operational failure不得被解讀為 absence，也不得 fallback至 legacy authority。
- Corrupted secure credential不得由 legacy資料覆蓋。

Credential rotation、Login、Restore、Logout、passive invalidation與 migration共用 Auth lifecycle mutation authority。Credential與 User commit完成前不得建立 runtime Session；部分失敗採 compensating cleanup。

此 scope取代 ADR-015中以 SharedPreferences保存 Token Pair作為 current implementation的歷史做法，但不取代 ADR-015的 atomic credential snapshot、commit ordering與 refresh contract。

### OTP step-up state machine

Password Login結果使用 closed typed union：

```txt
authenticated
otpChallenge
```

不得以 nullable credential／challenge欄位組合表達。

OTP challenge尚未完成時：

- 不保存 credential。
- 不建立 runtime Session。
- 不通過 Protected Route。
- `SessionManager`維持 unauthenticated。

Verify成功是 OTP流程唯一可進入 credential → user → Session commit的 boundary；Direct Login authenticated與 Verify success共用相同 commit policy。

Challenge contract至少包含 opaque challenge identity、UTC expiration、masked destination、resend availability與 optional attempts metadata。Client不持久化 OTP code、不自行推導完整 destination或 attempts limit。

Resend成功必須回傳完整 replacement challenge；predecessor challenge及其 in-flight Verify／Resend response立即失去 authority。Login、Verify、Resend、Restore、Logout與 account switch共用 Auth lifecycle latest-intent generation，防止 stale response commit。

OTP provider、SMS delivery與 backend policy由 server／integration boundary擁有；App contract不綁定特定 SMS provider SDK。

### Biometric-gated local session unlock

Local unlock是本機 user-presence gate，不是 Device Binding。

規則：

- Preference與 device capability分離，預設 disabled，不因硬體存在自動啟用。
- 只有 authenticated user通過 biometric-only verification後才能 enable。
- Enabled cold start必須先完成 user-presence verification，之後才允許讀取 credential與執行既有 Repository restore。
- Locked／prompting階段 `SessionManager`維持 unauthenticated，因此 Guard、Dio、Refresh、Profile與 navigation不得提前取得 authenticated authority。
- Cancel、not-enrolled、unavailable、corruption與 lockout採 fail closed，提供 retry或 server-login出口，不自動 restore。
- App-owned coordinator負責 prompt、startup與 resume orchestration；Repository仍擁有 credential、User與 Session restore commit。
- Resume grace period是 App policy，prompt lifecycle抖動不得重複發出 prompt。

App不保存指紋、臉部或 biometric template。此能力不包含 Keystore／Secure Enclave key pair、public key registration、server challenge或 signature verification。

### Package, plugin and Composition Root ownership

`packages/auth`只定義純 Dart、Auth-specific狹窄 abstraction與 application／domain contract，例如 credential store、user store與 local user-presence verifier。

App layer負責：

- Secure storage、legacy storage、SQLite user store與 biometric plugin adapter。
- Plugin exception到 typed AppException的隔離。
- Platform configuration與 runtime capability evidence。
- 所有 lifecycle與 abstraction binding。

`flutter_secure_storage`與 `local_auth`只能由 App layer依賴與組裝。Domain、Auth package public contract與 API client不得暴露 plugin class、platform biometric enum或 native exception。

App維持唯一 Composition Root；不建立 Generic Secure Store、Generic Key-Value Store、Generic Authentication State Machine或 Generic Navigation Coordinator framework。

### Platform capability claims

Package dependency或 adapter存在不等於 platform runtime supported。Biometric support只能依 tracked runner、native configuration與 runtime evidence宣稱；未具備證據的平台維持 dependency-ready。

安全描述必須精確：local biometric只代表本機 user presence，不宣稱防止 rooted／jailbroken device、SIM swap、provider compromise、server compromise或 credential外洩後的所有攻擊。

### Sensitive data

Password、OTP code、access token、refresh token與 raw challenge identity不得出現在 generated／manual `toString()`、reporting context或 production log。Credential-bearing model預設停用欄位型 `toString()`，除非另有安全摘要且不包含原始值。

## Consequences

- Secure credential、OTP與 local unlock可以獨立 review、rollback與演進。
- OTP pending與 locked startup都不會建立半完成 Session。
- Package保持 plugin-neutral，App集中 native implementation與 capability claim。
- Credential migration與 refresh rotation共用既有 Session identity與 mutation boundary。
- Biometric能力不會被誤解為 server authentication或 Device Binding。

## Supersession

本 Decision部分取代 ADR-015的 credential-at-rest implementation：SharedPreferences不再是 current Token Pair authority，secure credential adapter與 migration policy由本 ADR擁有。

ADR-015的完整 credential snapshot invariant、persistence-first commit、refresh concurrency、single-flight、safe replay、Session generation與 failure classification仍有效。

## Related Decisions

- ADR-005：Auth package與 App presentation boundary。
- ADR-006：Route Guard只依賴 runtime Session authority。
- ADR-012：App是唯一 Composition Root，package不綁定 DI framework。
- ADR-015：Refresh、Session identity、credential commit與 replay contract。
- ADR-020：typed error、reporting與 sensitive-data contract。
- ADR-021：App-owned Auth startup與 navigation coordination。

## Related Evidence

- [Auth package README](../../packages/auth/README.md)
- [API client README](../../packages/api_client/README.md)
- [App README](../../apps/flutter_architecture/README.md)
- [Milestone 19 holistic final review](../audits/milestone_19_holistic_final_review.md)
- [Milestone 20 final review](../audits/milestone_20/milestone_20_final_review.md)
- [Milestone 21 final review](../audits/milestone_21/milestone_21_final_review.md)
- [Android security runtime evidence](../audits/milestone_21/21-5_android_security_runtime_review.md)

## Last Reviewed Baseline

1.5.1。
