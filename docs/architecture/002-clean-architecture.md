# Clean Architecture

本專案採用 Clean Architecture，但用 Feature First 的資料夾方式組織。

也就是：

- 外觀上是 Feature First。
- 依賴方向仍然遵守 Clean Architecture。

## 主要依賴方向

```txt
Presentation Layer
  ↓
Domain Layer
  ↓
Data Layer
  ↓
External World
```

更具體一點：

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

## Presentation Layer

Presentation Layer 負責畫面與使用者互動。

包含：

- Page
- Widget
- Bloc
- Event
- State
- Hook

可以依賴：

- Domain Layer
- Flutter
- flutter_bloc
- flutter_hooks
- hooked_bloc

不應該依賴：

- RepositoryImpl
- DataSource
- Dio
- SQLite
- SharedPreferences

原因：

UI 不應該知道資料從哪裡來。

UI 只需要知道目前狀態，以及使用者操作後要送出什麼事件。

## Domain Layer

Domain Layer 是業務核心。

包含：

- Entity
- Repository Interface
- UseCase

可以依賴：

- Dart core
- core package 裡的通用型別，例如 `Result`、`Failure`

不應該依賴：

- Flutter
- Dio
- SQLite
- SharedPreferences
- API Model
- JSON serialization

原因：

Domain Layer 不應該知道外部世界怎麼實作。

例如登入可能來自：

- REST API
- GraphQL
- Firebase
- Mock API
- SQLite Cache

但 `LoginUseCase` 不應該知道這些差異。

它只需要依賴 `AuthRepository`。

## Data Layer

Data Layer 負責把外部資料轉成 Domain 可以理解的資料。

包含：

- Model
- DTO
- RepositoryImpl
- RemoteDataSource
- LocalDataSource

可以依賴：

- Domain Layer
- Dio
- SQLite
- SharedPreferences
- API Client

Data Layer 的責任：

- 呼叫 API。
- 讀寫 SQLite。
- 讀寫 SharedPreferences。
- 將 Model 轉成 Entity。
- 將外部 exception 轉成 `Failure`。

## Repository Interface 與 RepositoryImpl

Repository Interface 放在 Domain Layer：

```txt
features/auth/domain/repositories/auth_repository.dart
```

RepositoryImpl 放在 Data Layer：

```txt
features/auth/data/repositories/auth_repository_impl.dart
```

原因：

UseCase 只依賴抽象，不依賴實作。

```txt
LoginUseCase
  ↓
AuthRepository
```

實際資料來源由 Data Layer 決定：

```txt
AuthRepositoryImpl
  ↓
AuthRemoteDataSource
  ↓
AuthApiClient
```

## 登入流程範例

```txt
LoginPage
  ↓ 使用者按下登入
AuthBloc
  ↓ 呼叫 UseCase
LoginUseCase
  ↓ 依賴 Repository Interface
AuthRepository
  ↓ 實際執行者
AuthRepositoryImpl
  ↓ 呼叫遠端資料來源
AuthRemoteDataSource
  ↓ 呼叫 API package
AuthApiClient
  ↓ 回傳 mock token/profile
Mock API
  ↓ 保存 token/profile
AuthLocalDataSource
  ↓ 寫入本地
SharedPreferences + SQLite
  ↓ 回傳登入結果
AuthBloc
  ↓ 更新 UI 狀態
LoginPage / ProfilePage
```

## 本階段的重點

第一階段只需要把這條流程跑通：

```txt
Login → Save Token → Get Profile → Auto Login → Route Guard
```

不要加入太多額外情境。

例如 Refresh Token、Offline Cache、Pagination 都先放在 Backlog。
