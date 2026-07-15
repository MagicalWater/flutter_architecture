# Profile Feature

Profile feature 負責取得並顯示目前登入者資料。

## 負責什麼？

- 呼叫 GetProfileUseCase
- 顯示目前登入的使用者名稱
- 未登入時顯示尚未登入

## 不負責什麼？

- Login
- Logout
- Token 保存
- Route Guard

## Runtime Flow

```txt
ProfilePage
  ↓
ProfileBloc
  ↓
GetProfileUseCase
  ↓
ProfileRepository
  ↓
ProfileRepositoryImpl
  ↓
ProfileRemoteDataSource
  ↓
ProfileApi
  ├── MockProfileApi
  └── _ProfileApi（Retrofit generated）
  ↓
ProfileBloc
  ↓
UI
```
