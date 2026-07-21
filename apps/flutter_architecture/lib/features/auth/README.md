# Auth Feature

App 內的 Auth feature 負責Auth presentation，以及需要Flutter plugin或App lifecycle的adapter。Auth domain、repository、use case、Session與refresh coordination位於`packages/auth`；App仍是唯一Composition Root。

## 負責什麼？

- Login與Logout presentation。
- OTP challenge、Verify與Resend presentation。
- Session expiration UI synchronization。
- Local unlock locked surface與設定入口。
- Flutter Secure Storage、SharedPreferences、SQLite與`local_auth`的App-owned adapters。

## 不負責什麼？

- Profile 頁面如何顯示
- Payment
- Notification
- App Theme
- Auth domain policy與credential lifecycle ordering
- App-level authentication navigation transition

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
  ├── FlutterSecureAuthCredentialStore
  ├── SharedPreferencesAuthLegacyCredentialStore
  └── SqfliteAuthUserStore
  ↓
FlutterSecureStorage + SQLite
  ↓
AuthBloc
  ↓
UI
```

Current persistence authority：

```txt
Credential Token Pair
  → FlutterSecureAuthCredentialStore
  → FlutterSecureStorage

Public AuthUser identity
  → SqfliteAuthUserStore
  → SQLite

Legacy SharedPreferences credential
  → migration / cleanup only
```

`SharedPreferencesAuthCredentialStore`只保留於legacy／regression test與歷史相容情境，不是production credential authority。

## OTP Flow

```txt
Login result = otpChallenge
  ↓
AuthBloc進入otpRequired
  ↓
AuthNavigationCoordinator導向OtpRoute
  ↓
Verify成功
  ↓
Secure credential → SQLite User → Session commit
  ↓
導向Profile
```

OTP完成前不得保存credential、建立Session或通過Protected Route。Resend只替換challenge，不修改credential或Session。

## Local Unlock Flow

```txt
App startup / grace-period-expired resume
  ↓
StartupLocalUnlockCoordinator
  ↓
enabled preference時先保持SessionManager = null
  ↓
biometric-only local user-presence verification
  ↓ verified
RestoreSessionUseCase
```

Cancel、not enrolled、unavailable與lockout均不得fallback自動restore。Biometric只驗證本機user presence，不是Server authentication，也不保存biometric資料。

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
- `AuthNavigationCoordinator`與`StartupLocalUnlockCoordinator`由App composition layer持有，不由Shell或Bloc直接操作Router。

## Auth 邊界分工

```txt
apps/flutter_architecture/lib/features/auth/
  presentation/  Login / OTP / Local Unlock UI + Bloc
  data/          Flutter plugin adapters與App-local persistence adapters

packages/auth/
  domain/        Entity + Repository Interface + UseCase
  data/          Model + RepositoryImpl + DataSource
  session/       Runtime Session、lifecycle generation與refresh coordination
```
