---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-021-auth-startup-navigation-coordination
last_reviewed_baseline: 1.5.1
id: ADR-021
title: Auth Startup and Navigation Coordination
supersedes:
superseded_by:
related:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-015
  - ADR-022
---

# ADR-021 — Auth Startup and Navigation Coordination

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Auth startup ownership、authentication transition到 App destination的映射，以及 Auth／Profile／Shell presentation與 App router之間的 navigation boundary。

## Context

若 `ShellPage` 負責 dispatch Auth restore，Shell presentation會承擔 authentication lifecycle ownership。若 Login／Profile page直接依賴 `ShellTab`或 tab index，feature presentation會反向知道 App navigation identity。

Auth lifecycle與跨 feature navigation因此必須提升到 App composition layer。

## Decision

Auth startup與 authentication transition到具體 route的映射由 App-owned coordinator擁有：

```txt
ArchitectureApp
  ↓ start
AuthNavigationCoordinator
  ↓ AuthStarted
AuthBloc
  ↓ authoritative authentication transition
AuthNavigationDestination
  ↓ App-owned route mapping
ShellRoute(LoginRoute / ProfileRoute)
```

規則：

- App-owned coordinator在 Router完成首個 frame掛載後觸發 Auth restore，避免快速 restore在 Router mount前導航。
- Shell不得 dispatch Auth lifecycle event。
- Auth feature只表達 login result與 Auth state，不 import `ShellTab`、tab index或具體 AutoRoute child identity。
- Profile feature只表達 logout result；Session authority transition驅動後續 App navigation。
- `unauthenticated → authenticated` 映射到 authenticated destination；current shell contract中為 Profile destination。
- authenticated identity轉為 unauthenticated時映射到 Login destination。
- 相同 authentication identity不重複導航；loading、failure或其他非 identity欄位變化不構成 navigation intent。
- 具體 `ShellRoute` child mapping只存在 App router／composition boundary。
- Auth destination使用 root replacement重整為單一 `ShellRoute`，確保 Protected等 root route在失去 authentication authority時被移除。
- AuthBloc不直接操作 Router；Domain與 reusable package不依賴 AutoRoute。

Shell仍可使用 `AutoTabsRouter`管理使用者主動 tab切換；這不等於 Shell擁有 Auth lifecycle或跨 feature authentication navigation。

## Consequences

- Auth restore不依賴 Shell是否已進入特定 tab。
- Login與 Profile presentation不持有 App route identity。
- Session失效可由單一 App authority清理 root navigation stack。
- 更換 Shell tab structure或 routing implementation時，不需要改 Auth domain／package contract。
- 不建立 Generic Navigation Coordinator framework；coordinator只處理 App目前明確的 Auth navigation workflow。

## Supersession

本 Decision未 supersede其他 Decision，也沒有被其他 Decision取代。

## Related Decisions

- ADR-005：Auth package與 App presentation boundary。
- ADR-006：Route Guard依賴 Session authority。
- ADR-007：跨 feature不直接依賴對方 Bloc或 presentation identity。
- ADR-015：refresh與 passive invalidation產生的 Session transition。
- ADR-022：OTP與 local unlock仍透過 App-owned Auth navigation orchestration。

## Related Evidence

- [App README](../../apps/flutter_architecture/README.md)
- [Auth feature README](../../apps/flutter_architecture/lib/features/auth/README.md)
- [Shell feature README](../../apps/flutter_architecture/lib/features/shell/README.md)
- [Profile feature README](../../apps/flutter_architecture/lib/features/profile/README.md)
- [Milestone 18 holistic audit](../audits/milestone_18_holistic_audit.md)

## Last Reviewed Baseline

1.5.1。
