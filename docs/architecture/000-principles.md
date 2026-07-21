# 設計原則

> [!WARNING]
> **Historical / superseded first-phase guidance.** 本文件保存第一階段MVP的設計背景，內文中的「目前」「第一階段」與scope限制不可用來判斷current state。Current snapshot請讀取`docs/project_context.md`；canonical Decisions請讀取`docs/adr/README.md`。

這份模板的第一階段目標是完成一個可用、清楚、可擴充的 Flutter MVP 架構模板。

不要在第一階段追求完整教科書，也不要加入過多進階功能。

## 原則 1：可讀性優先

不要為了少寫幾行而犧牲理解成本。

推薦：

```dart
final result = await loginUseCase.execute(params);
```

不推薦：

```dart
final result = await executor.run<Auth, LoginParams, AuthFailure>(params);
```

後者看起來抽象，但不一定更適合教學與長期維護。

## 原則 2：架構服務流程，不是服務資料夾

Clean Architecture 的重點不是資料夾長得很漂亮。

真正重要的是資料流清楚：

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

只要資料流不清楚，再多資料夾也沒有意義。

## 原則 3：Feature First

App 內部以 feature 為第一層分類。

例如：

```txt
features/auth/
  presentation/
  domain/
  data/
```

這樣可以讓 Auth 相關檔案集中在一起。

未來刪除、搬移、重構某個 feature 時，不需要在整個專案到處找檔案。

## 原則 4：Bloc 負責業務狀態，Hooks 負責 UI 暫態

Bloc 適合管理：

- 登入中
- 登入成功
- 登入失敗
- 使用者資料
- 是否已登入

flutter_hooks 適合管理：

- `TextEditingController`
- `FocusNode`
- `ScrollController`
- `AnimationController`
- 表單欄位的 UI 暫態

不要把 token 放在 Hook。

不要把 `TextEditingController` 放進 Bloc。

## 原則 5：hooked_bloc 只用在 Presentation Layer

`hooked_bloc` 可以減少 `BlocBuilder`、`BlocListener` 的巢狀。

但它只能出現在 UI 層。

不要讓 hooks 進入：

- Domain Layer
- Data Layer
- Repository
- UseCase
- DataSource

## 原則 6：Domain Layer 不知道外部實作

Domain Layer 不能知道：

- Dio
- SQLite
- SharedPreferences
- Flutter Widget
- API Response 格式

Domain Layer 只描述業務規則。

例如 `LoginUseCase` 只知道 `AuthRepository`，不知道登入 API 怎麼打。

## 原則 7：Repository Interface 放 Domain Layer

`AuthRepository` 是 Domain Layer 的抽象。

`AuthRepositoryImpl` 是 Data Layer 的實作。

原因：

UseCase 依賴的是業務抽象，不是資料來源細節。

## 原則 8：文件與註解使用繁體中文

文件與註解預設使用繁體中文。

技術名詞、套件名稱、類別名稱保留英文。

例如：

- Clean Architecture
- Feature First
- Bloc
- UseCase
- Repository
- DataSource
- Dio
- SQLite

這樣可以兼顧中文閱讀效率與實務術語。

## 原則 9：第一階段只做 MVP

目前只完成：

```txt
Auth + Profile + Protected Route
```

任何不是直接服務這條流程的想法，先放到 `docs/backlog.md`。

## 原則 10：不要過度抽象

這份模板是給人看的，不是給架構炫技用的。

所以第一階段不建立：

- 過度泛型的 BaseUseCase。
- 過度複雜的 BaseRepository。
- 無實際用途的 Manager / Helper / Service。

只有當重複性真的出現，再考慮抽象。
