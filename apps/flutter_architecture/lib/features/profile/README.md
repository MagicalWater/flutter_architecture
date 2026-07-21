---
document_type: feature-readme
status: accepted
authoritative_for:
  - profile-feature-local-contract
last_reviewed_baseline: 1.5.1
---

# Profile Feature

Profile feature 負責取得並顯示目前 authenticated user 的 remote profile read model。

## Responsibilities

- `ProfilePage` 與 `ProfileBloc` presentation。
- 呼叫 `GetProfileUseCase`。
- 顯示 loading、content、unauthenticated 與 failure state。
- 在 Session expiration 後與 current Auth state 同步。

## Non-responsibilities

- 不執行 Login、Logout、Restore 或 token refresh。
- 不保存 token 或 Auth User。
- 不決定 route access；Auth navigation 與 AuthGuard 位於 App layer。
- 不跨 feature 直接讀取 AuthBloc。

## Dependencies and Flow

```txt
ProfilePage
→ ProfileBloc
→ GetProfileUseCase
→ ProfileRepository
→ ProfileRemoteDataSource
→ ProfileApi (Mock | Retrofit)
```

跨 feature authentication state 透過 `SessionManager`／Domain abstraction 協調，不透過 presentation coupling。

## Presentation Contract

- Blocking loading／error 使用 Design System page-state surfaces。
- User-facing message 由 localization resources 產生。
- Diagnostic failure message 不直接顯示。
- Remote profile content 是 server content，不進 ARB。

## Tests

測試位於 `test/features/profile/`，應涵蓋 success、expected／unexpected failure、Session expiration、localized UI與 route composition regression。

## Related Decisions

以 `docs/architecture_decisions.md` 的 Session、API Client、Design System、Localization與 Failure Architecture Decisions 為 authority。
