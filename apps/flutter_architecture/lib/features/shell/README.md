# Shell Feature

Shell feature 負責已進入主App後的外層layout與tab容器，不擁有authentication state transition或startup unlock orchestration。

## 負責什麼？

- AppBar
- NavigationBar
- Login / Catalog / Profile 的nested route容器
- ProtectedPage 的入口按鈕
- Appearance、Locale與Local Unlock設定入口

## 頁面關係

```txt
ShellPage(A)
  ├── LoginPage(B)
  ├── CatalogPage(C)
  ├── ProfilePage(D)
  └── ProtectedPage(E)
```

LoginPage、CatalogPage與ProfilePage是ShellPage的tab內容。

ProtectedPage 是獨立頁面，透過 AppBar action 開啟。

## Authentication navigation boundary

Shell不依賴`AuthBloc`，也不根據登入、OTP或local unlock state直接操作root router。

```txt
Auth presentation / StartupLocalUnlockCoordinator
  ↓
AuthNavigationCoordinator（App composition layer）
  ↓
LoginRoute / OtpRoute / LocalUnlockRoute / Profile destination
```

`AuthNavigationCoordinator`維持單一Shell並處理Login、OTP、locked與Profile destination transition。Shell只管理自己的tab selection與使用者主動開啟的AppBar actions。

Protected Route仍由`AuthGuard`依`SessionManager`判斷；Shell不自行判斷authentication authority。
