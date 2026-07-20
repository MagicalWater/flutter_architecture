# Auth Feature

App 內的 Auth feature 只負責登入、登出、自動登入恢復與 Session state 的 presentation；Auth domain / data / refresh 能力位於 `packages/auth`。

## 負責什麼？

- Login
- Logout
- Restore Session
- Session expiration UI synchronization

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
  ├── SharedPreferencesAuthCredentialStore
  ├── SharedPreferencesAuthLegacyCredentialStore
  └── SqfliteAuthUserStore
  ↓
SharedPreferences + SQLite
  ↓
AuthBloc
  ↓
UI
```

## Refresh / Session Expiration Flow

```txt
Authenticated API 401
  ↓
AuthRefreshInterceptor
  ↓
AuthSessionRefresher（single-flight）
  ├── Refresh Dio → AuthRefreshApi
  ├── 保存 rotated Token Pair
  └── 更新 SessionManager access token
  ↓
安全 replay 原 request
```

規則：

- Interceptor 不直接操作 AuthBloc、Router 或 LogoutUseCase。
- Invalid refresh credential 由 `packages/auth` 清除 persistence 與 SessionManager。
- AuthBloc 監聽 SessionManager stream，自然切換為未登入狀態。
- Logout / relogin 或帳號切換後，舊 request 與舊 refresh response 不得覆蓋新 Session。

## Auth 邊界分工

```txt
apps/flutter_architecture/lib/features/auth/
  presentation/  UI + Bloc

packages/auth/
  domain/        Entity + Repository Interface + UseCase
  data/          Model + RepositoryImpl + DataSource
  session/       Runtime Session 與 refresh coordination
```
