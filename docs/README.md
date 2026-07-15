# 文件索引

這裡放的是第一階段 MVP 需要的架構文件。

目前目標是完成一份可以作為新專案起點的 Flutter Enterprise Architecture Template。

不是教科書完整版。
不是大型開源專案完整版。
不是無限擴張的架構展示。

## 目前文件

```txt
docs/
  README.md
  roadmap.md
  backlog.md
  architecture/
    000-principles.md
    001-folder-structure.md
    002-clean-architecture.md
```

## 閱讀順序

新的 AI coding agent / assistant 請先閱讀 root `AGENTS.md`，再依照 README 的文件導覽恢復專案上下文。

架構補充文件建議照這個順序閱讀：

1. `docs/architecture/000-principles.md`
2. `docs/architecture/001-folder-structure.md`
3. `docs/architecture/002-clean-architecture.md`
4. `docs/roadmap.md`
5. `docs/backlog.md`

## 語言規範

文件與註解預設使用繁體中文。

以下內容保留英文：

- 套件名稱，例如 `flutter_bloc`、`auto_route`、`dio`。
- 架構名詞，例如 `Clean Architecture`、`Feature First`。
- Layer 名稱，例如 `Presentation Layer`、`Domain Layer`、`Data Layer`。
- 類別名稱，例如 `AuthBloc`、`LoginUseCase`、`AuthRepository`。
- API 名稱，例如 `Authorization`、`Bearer Token`。

## 核心流程

架構不是背資料夾，而是理解資料流。

```txt
登入按鈕
  ↓
AuthBloc
  ↓
LoginUseCase
  ↓
AuthRepository
  ↓
AuthRepositoryImpl
  ↓
AuthRemoteDataSource
  ↓
AuthApi
  ├── MockAuthApi
  └── _AuthApi（Retrofit generated）
  ↓
AuthLocalDataSource
  ↓
SharedPreferences + SQLite
  ↓
AuthBloc 更新狀態
  ↓
UI 更新
```
