---
document_type: feature-readme
status: accepted
authoritative_for:
  - auth-feature-local-contract
last_reviewed_baseline: 1.5.1
---

# Auth Feature

App 內的 Auth feature 擁有 Login、OTP 與 Session state 的 presentation。Auth Domain／Data／Session contract 位於 `packages/auth`，navigation coordination 與 platform adapters 位於 App layer。

## Responsibilities

- Login、OTP Verify／Resend、Logout UI 與 Bloc。
- Restore／Session expiration 的 presentation synchronization。
- 顯示 expected authentication failure 的 localized UI。
- 將 user intent 轉交單一 UseCase。

## Non-responsibilities

- 不保存 credential、Auth User 或 local unlock preference。
- 不直接操作 Dio、Router、Flutter Secure Storage、SQLite 或 `local_auth`。
- 不決定 Auth navigation destination；由 App-owned coordinator 負責。
- 不負責 Profile、Catalog 或 Protected feature behavior。

## Dependencies

```txt
presentation
→ packages/auth public API
→ packages/core Result / Failure contract
→ design_system public primitives
```

Feature 不 deep import package `lib/src/`，也不跨 feature 讀取 Bloc。

## Login and OTP Flow

```txt
LoginPage
→ AuthBloc
→ LoginUseCase
→ AuthRepository
→ Authenticated | OtpChallenge | Failure

OtpPage
→ AuthOtpBloc
→ VerifyOtpUseCase / ResendOtpUseCase
→ Authenticated | Updated Challenge | Failure
```

OTP challenge 完成前不建立 authenticated Session。`AuthNavigationCoordinator` 觀察 Auth state 並在 Login、OTP、Profile／Shell destinations 間切換。

## Credential and Restore Flow

```txt
AuthRepositoryImpl
├── AuthRemoteDataSource
├── AuthCredentialStore
├── AuthLegacyCredentialStore
└── AuthUserStore
```

Production authority：

```txt
Credential Token Pair
→ FlutterSecureAuthCredentialStore
→ Flutter Secure Storage

Public AuthUser
→ SqfliteAuthUserStore
→ SQLite

Legacy SharedPreferences credential
→ migration / cleanup only
```

`SharedPreferencesAuthCredentialStore`只保留於 legacy／regression test與歷史相容情境，不是 production credential authority。

## Refresh and Session Expiration

- `AuthRefreshInterceptor` 不操作 Bloc 或 Router。
- `AuthSessionRefresher` 使用 identity-aware single-flight。
- Rotated token pair persistence-first，再更新 `SessionManager`。
- Invalid refresh credential 由 Auth lifecycle cleanup 清除 persistence 與 runtime Session。
- AuthBloc 監聽 SessionManager stream，自然切換 UI state。

## Local Unlock Boundary

- `StartupLocalUnlockCoordinator` 與 lifecycle coordinator 位於 App layer。
- `LocalUnlockPage` 只呈現 locked／verifying／failure UI 與 retry／use login intent。
- `local_auth` adapter與 preference persistence 由 App 擁有。
- Local unlock 只驗證本機 user presence，不保存 biometric data，也不是 Device Binding。

## Tests

主要測試位於：

- `test/features/auth/`
- `test/app/auth/`
- `test/app/navigation/`

應涵蓋 Login、OTP、Restore、Logout、Session expiration、navigation、local unlock lifecycle與 sensitive output。

## Related Decisions

以 `docs/architecture_decisions.md` 中的 Auth／Session／Refresh／Secure Credential／OTP／Local Unlock Decisions 為正式 authority。

本 README 只保存 feature-local current contract，不記錄 Milestone journal。
