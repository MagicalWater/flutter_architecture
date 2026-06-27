# 專案開發進度

本文件用來追蹤目前開發進度。

> roadmap.md 負責規劃未來。
>
> progress.md 負責記錄目前做到哪裡。

---

# Milestone 1：Project Skeleton（MVP）

**狀態：** 🟢 Completed

## 完成項目

- [x] Monorepo（Melos）
- [x] apps / packages 結構
- [x] Clean Architecture + Feature First 骨架
- [x] flutter_bloc
- [x] flutter_hooks
- [x] hooked_bloc
- [x] auto_route
- [x] get_it + injectable
- [x] freezed + json_serializable
- [x] Dio Mock API
- [x] SharedPreferences
- [x] SQLite
- [x] Smoke Test
- [x] build_runner 通過
- [x] flutter analyze = 0
- [x] flutter build bundle 通過

## Definition of Done

- [x] 專案可以正常解析依賴
- [x] Melos bootstrap 通過
- [x] Melos scripts 全部通過
- [x] Code Generation 正常
- [x] 靜態分析無錯誤
- [x] flutter test 全部通過
- [x] flutter build bundle 通過
- [x] 第一個 Git Commit

## 驗證命令

已通過：

```bash
dart pub get
dart run melos bootstrap
dart run melos run get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

## Git Commit

已建立：

```txt
8ed9095 feat(mvp): initialize enterprise architecture template
```

---

# Milestone 2A：Auth Package 邊界重構

**狀態：** 🟢 Completed

## 完成項目

- [x] 將 Auth 的 domain / data 從 app feature 移動到 `packages/auth`
- [x] App 的 auth feature 只保留 presentation layer
- [x] AuthBloc 改依賴 `packages/auth` 的 UseCase
- [x] AuthRepository / UseCase / DataSource / Model 整理到 auth package
- [x] 保留 LoginPage / AuthBloc / AuthEvent / AuthState 在 app

## Definition of Done

- [x] Auth 的 domain / data 不再放在 app feature 內
- [x] app 只保留 Auth 的 presentation layer
- [x] AuthBloc 依賴 `packages/auth` 的 UseCase
- [x] package export 邊界清楚
- [x] `melos run analyze` 通過
- [x] `flutter test` 通過

---

# Milestone 2B：SessionManager 與跨 Feature 登入狀態

**狀態：** 🟢 Completed

## 完成項目

- [x] 建立或整理 SessionManager / AuthSessionReader
- [x] AuthGuard 改為依賴 SessionManager，不再依賴 AuthBloc
- [x] ProfilePage 不再直接讀 AuthBloc
- [x] ProfileBloc 透過 SessionManager 判斷登入狀態
- [x] 登入成功後更新 SessionManager
- [x] 登出後清除 SessionManager
- [x] ProtectedPage 不再直接讀 AuthBloc

## Definition of Done

- [x] AuthGuard 不 import AuthBloc
- [x] ProfilePage 不 import AuthBloc
- [x] UI 只依賴自己 feature 的 Bloc
- [x] 跨 feature 登入狀態統一透過 SessionManager 或 domain abstraction 取得
- [x] analyze 通過
- [x] flutter test / dart test 通過

---

# Milestone 2C：跨平台 SQLite 初始化

**狀態：** 🟢 Completed

## 已完成項目

- [x] Desktop 加入 sqflite_common_ffi 初始化
- [x] Web 加入 sqflite_common_ffi_web 初始化
- [x] main.dart 移除直接 `dart:io` import
- [x] 使用條件匯入隔離平台差異
- [x] `melos run analyze` 通過
- [x] `flutter test` 通過
- [x] `flutter build bundle` 通過

## 收尾紀錄

- [x] README 補充 Web setup：`dart run sqflite_common_ffi_web:setup`
- [x] 已確認 app 目前只有 sqflite web binary，尚未建立完整 Flutter Web 平台 scaffold；`flutter build web` 需待執行 `flutter create . --platforms web` 後再驗證
- [x] Git Commit

## Definition of Done

- [x] Flutter Web 不再因 sqflite databaseFactory 未初始化而白畫面
- [x] Desktop 不再因 sqflite databaseFactory 未初始化而錯誤
- [x] `melos run analyze` 通過
- [x] `flutter test` 通過
- [x] README 補充 Web setup
- [x] Git Commit

---

# Milestone 3：Auth + Profile Flow

**狀態：** 🟡 In Progress

## 拆分計畫

### Milestone 3-1：Login Flow

- [x] LoginPage 按鈕觸發 AuthBloc
- [x] AuthBloc 呼叫 LoginUseCase
- [x] LoginUseCase 經由 AuthRepository 完成 Remote + Local 流程
- [x] 登入成功後更新 SessionManager
- [x] AuthBloc state 正確呈現 loading / success / failure
- [x] analyze / test 通過
- [x] Git Commit

### Milestone 3-2：Profile Flow

- [ ] 未登入顯示尚未登入
- [ ] 已登入時 ProfileBloc 呼叫 GetProfileUseCase
- [ ] Profile 頁面顯示目前登入用戶名稱
- [ ] Profile 錯誤與 loading 狀態正常
- [ ] analyze / test 通過
- [ ] Git Commit

### Milestone 3-3：Navigation Flow

- [ ] Login 成功後切換到 Profile tab
- [ ] Logout 成功後回到 Login tab
- [ ] tab 切換不破壞 Auth / Session 狀態
- [ ] analyze / test 通過
- [ ] Git Commit

### Milestone 3-4：Protected Route Flow

- [ ] 未登入進 ProtectedRoute 會被 AuthGuard 導回 Login
- [ ] 已登入進 ProtectedRoute 會成功進入 ProtectedPage
- [ ] ProtectedPage 不依賴 AuthBloc
- [ ] analyze / test 通過
- [ ] Git Commit

### Milestone 3-5：End-to-End 驗收

- [ ] App 啟動 Restore Session
- [ ] 未登入 → Login → Profile → Protected → Logout 流程可跑通
- [ ] Logout 後 Profile 顯示尚未登入
- [ ] Logout 後 ProtectedRoute 會被擋下
- [ ] analyze / test / build bundle 通過
- [ ] Git Commit

## Definition of Done

- [ ] Login 成功
- [ ] Profile 顯示登入用戶
- [ ] Logout 成功
- [ ] Route Guard 生效
- [ ] Auto Login 生效
- [ ] `melos run analyze` 通過
- [ ] `flutter test` 通過
