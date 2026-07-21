# 資料夾結構

> [!WARNING]
> **Historical / superseded first-phase guidance.** 本文件保存第一階段MVP的資料夾規劃，未包含目前完整App、Package與文件結構。Current repository overview請讀取root `README.md`與`docs/project_context.md`；accepted architecture decisions請讀取`docs/architecture_decisions.md`。

本專案採用 Monorepo 與 Feature First。

第一階段只建立 MVP 需要的結構。

## 最外層結構

```txt
root/
  apps/
    flutter_architecture/
  packages/
    core/
    api_client/
    auth/
  docs/
  melos.yaml
  analysis_options.yaml
  README.md
```

## apps/

`apps/` 放可以執行的 Flutter App。

目前只有一個 app：

```txt
apps/flutter_architecture/
```

App 負責：

- 啟動流程
- Router
- App-level DI
- Theme
- Feature 組合
- 頁面呈現

## packages/

`packages/` 放可重用或有明確邊界的 package。

第一階段先放三個：

```txt
packages/core/
packages/api_client/
packages/auth/
```

### packages/core

放跨 feature 會用到的基礎能力。

例如：

- `Result`
- `Failure`
- `AppException`
- Logger
- Storage abstraction

### packages/api_client

放網路層共用能力。

例如：

- Dio client
- Interceptor
- Mock API
- Auth API
- Profile API

### packages/auth

放與 auth/session 有關，但不一定屬於畫面的共用能力。

例如：

- Token storage contract
- Session manager
- Auth constants

第一階段如果內容不多，也可以先保持簡單，不要硬拆太深。

## App 內部結構

```txt
apps/flutter_architecture/lib/
  main.dart
  app/
    app.dart
    di/
    router/
    theme/
  features/
    auth/
    profile/
    protected/
    shell/
```

## Feature 結構

每個主要 feature 採用：

```txt
features/auth/
  presentation/
    bloc/
    pages/
    widgets/
  domain/
    entities/
    repositories/
    use_cases/
  data/
    data_sources/
    models/
    repositories/
```

## 各層責任

### presentation

負責 UI 與畫面狀態。

包含：

- Page
- Widget
- Bloc
- Event
- State
- Hooks

### domain

負責業務規則。

包含：

- Entity
- Repository Interface
- UseCase

### data

負責資料來源與外部實作。

包含：

- Model
- RepositoryImpl
- RemoteDataSource
- LocalDataSource

## 命名規則

推薦命名：

```txt
login_use_case.dart
get_profile_use_case.dart
auth_repository.dart
auth_repository_impl.dart
auth_remote_data_source.dart
auth_local_data_source.dart
```

避免命名：

```txt
manager.dart
helper.dart
handler.dart
service.dart
```

除非它真的有明確、單一、可解釋的責任。

## 第一階段不做的資料夾

第一階段先不建立大量文件與過度結構。

例如：

- `docs/adr/`
- `docs/mistakes/`
- `docs/evolution/`
- `docs/specification/`

這些未來要做時，先記錄在 `docs/backlog.md`。
