# Auth Feature

Auth feature 負責登入、登出與自動登入恢復。

## 負責什麼？

- Login
- Logout
- Restore Session
- Token persistence
- User cache

## 不負責什麼？

- Profile 頁面如何顯示
- Payment
- Notification
- App Theme

## Runtime Flow

```txt
LoginPage
  ↓
AuthBloc
  ↓
LoginUseCase
  ↓
AuthRepository
  ↓
AuthRepositoryImpl
  ├── AuthRemoteDataSource
  │     ↓
  │   AuthApi
  │     ├── MockAuthApi
  │     └── _AuthApi（Retrofit generated）
  │
  └── AuthLocalDataSource
  ↓
SharedPreferences + SQLite
  ↓
AuthBloc
  ↓
UI
```

## Layer

```txt
presentation/  UI + Bloc
domain/        Entity + Repository Interface + UseCase
data/          Model + RepositoryImpl + DataSource
```
