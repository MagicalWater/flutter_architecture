---
document_type: feature-readme
status: accepted
authoritative_for:
  - protected-feature-local-contract
last_reviewed_baseline: 1.5.0
---

# Protected Feature

Protected feature 是受 Route Guard 保護的 presentation example，用來證明 route access 與 feature UI 可以保持解耦。

## Responsibilities

- 顯示受保護頁面內容。
- 提供 authenticated-only route 的 regression fixture。
- 使用 Design System 與 localization 呈現頁面。

## Non-responsibilities

- 不判斷是否登入。
- 不直接導向 Login、OTP 或 Local Unlock。
- 不依賴 AuthBloc。
- 不保存或刷新 credential。

## Route Flow

```txt
User action
→ ProtectedRoute
→ AuthGuard
→ authenticated: ProtectedPage
→ unauthenticated: App-owned auth destination
```

AuthGuard 只依賴 `SessionManager`／Auth session abstraction；Protected feature 不知道 authentication presentation detail。

## Tests

測試應涵蓋 ProtectedPage widget surface、AuthGuard navigation與 Session change regression。

## Related Decisions

以 `docs/architecture_decisions.md` 的 Route Guard、Session與 Design System Decisions 為 authority。
