---
document_type: feature-readme
status: accepted
authoritative_for:
  - shell-feature-local-contract
last_reviewed_baseline: 1.27.0
---

# Shell Feature

Shell feature 擁有 App authenticated／public tabs 的外層 layout與使用者主動 actions，不擁有 authentication transition policy。

## Responsibilities

- `AppBar`、`NavigationBar` 與 nested tab layout。
- Login、Catalog、Profile tab container。
- 開啟 Protected route、Appearance、Locale 與 Local Unlock settings。
- 將 labels／tooltips交由 localization 提供。

## Non-responsibilities

- 不根據 AuthBloc 決定 Login、OTP、Local Unlock 或 Profile destination。
- 不實作 AuthGuard 或 Session policy。
- 不保存 theme、locale 或 local unlock preference。
- 不擁有 Feature business state。

## Page Composition

```txt
ShellPage
├── LoginPage
├── CatalogPage
├── ProfilePage
└── ProtectedPage (push route + guard)
```

`AutoTabsRouter` 管理 tab child；Shell 只管理 active index 與 UI action。

## Navigation Boundary

- `AuthNavigationCoordinator` 位於 App layer，擁有 authentication destination transition。
- `AuthGuard` 依賴 Session abstraction，決定 Protected route access。
- Shell 不監聽 AuthBloc，也不發出跨 feature state mutation。

## Appearance, Locale and Local Unlock

Shell 只開啟 App-owned dialogs。Theme／Locale controller、preference persistence與 local unlock policy composition不屬於 Shell。

## Tests

目前沒有 Shell feature-local retained test folder。Tab selection、actions、localized labels、theme／locale dialog composition與 Protected route action 只有在 changed risk 需要且既有 owner 不足時才新增。

## Related Decisions

以 `docs/adr/README.md` 中的 ADR-006、012、018、019、021與022為 authority。
