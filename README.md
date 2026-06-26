# Flutter Enterprise Architecture Template

這是一份可以直接作為新專案起點的 Flutter 架構模板。

它的目標不是展示所有技巧，而是建立一個清楚、穩定、可擴充的專案骨架。

## 目前範圍

這個階段只做 MVP，不繼續擴張範圍。

包含：

- Clean Architecture
- Feature First
- Monorepo：`apps/` + `packages/`
- Presentation Layer：Bloc + flutter_hooks + hooked_bloc
- Router：auto_route + Route Guard + Nested Route
- DI：get_it + injectable
- Model：freezed + json_serializable
- Network：Dio + Mock API
- Storage：SharedPreferences + SQLite
- Reactive：RxDart

## 專案結構

```txt
root/
  apps/
    flutter_architecture/
  packages/
    core/
    api_client/
    auth/
  docs/
```

## Demo Flow

這個模板只實作四個頁面：

```txt
ShellPage(A)
  ├── LoginPage(B)
  ├── ProfilePage(C)
  └── ProtectedPage(D)
```

需求：

- `ShellPage` 有 `AppBar` 與底部導航欄。
- 底部導航欄有 Login 與 Profile 兩個頁面。
- Login 頁面按下登入後，透過完整 Clean Architecture 流程呼叫 Mock API。
- 登入成功後保存 token 與 profile。
- Profile 頁面顯示目前登入的使用者名稱。
- 沒登入時 Profile 頁面顯示尚未登入。
- `AppBar` 右上角按鈕可以進入 Protected 頁面。
- Protected 頁面需要登入才能進入。
- 沒登入時，`Route Guard` 會導回 Login 頁面。

## Runtime Flow

```txt
UI
  ↓
Bloc
  ↓
UseCase
  ↓
Repository Interface
  ↓
RepositoryImpl
  ↓
DataSource
  ↓
ApiClient / SQLite / SharedPreferences
```

## 開發方式

請先閱讀：

```txt
docs/README.md
docs/roadmap.md
docs/architecture/000-principles.md
docs/architecture/001-folder-structure.md
docs/architecture/002-clean-architecture.md
docs/backlog.md
```

目前先完成 MVP，未來想法放進 `docs/backlog.md`，不在第一階段實作。
