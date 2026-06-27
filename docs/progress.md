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

**狀態：** 🟢 Completed

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

- [x] 未登入顯示尚未登入
- [x] 已登入時 ProfileBloc 呼叫 GetProfileUseCase
- [x] Profile 頁面顯示目前登入用戶名稱
- [x] Profile 錯誤與 loading 狀態正常
- [x] analyze / test 通過
- [x] Git Commit

### Milestone 3-3：Navigation Flow

- [x] Login 成功後切換到 Profile tab
- [x] Logout 成功後回到 Login tab
- [x] tab 切換不破壞 Auth / Session 狀態
- [x] analyze / test 通過
- [x] Git Commit

### Milestone 3-4：Protected Route Flow

- [x] 未登入進 ProtectedRoute 會被 AuthGuard 導回 Login
- [x] 已登入進 ProtectedRoute 會成功進入 ProtectedPage
- [x] ProtectedPage 不依賴 AuthBloc
- [x] analyze / test 通過
- [x] Git Commit

### Milestone 3-5：End-to-End 驗收

- [x] App 啟動 Restore Session
- [x] 未登入 → Login → Profile → Protected → Logout 流程可跑通
- [x] Logout 後 Profile 顯示尚未登入
- [x] Logout 後 ProtectedRoute 會被擋下
- [x] analyze / test 通過
- [ ] build bundle 通過（前次工具安全檢查擋下，未能重跑；Milestone 4 收尾會重新驗證）
- [x] Git Commit

## Definition of Done

- [x] Login 成功
- [x] Profile 顯示登入用戶
- [x] Logout 成功
- [x] Route Guard 生效
- [x] Auto Login 生效
- [x] analyze 通過
- [x] flutter test 通過

---

# Milestone 4：Route Guard 與頁面整理

**狀態：** 🟢 Completed

## 拆分計畫

### Milestone 4-1：ProtectedPage 展示責任整理

- [x] ProtectedPage 不直接讀取 SessionManager
- [x] ProtectedPage 不依賴 DI container
- [x] 登入檢查責任只保留在 AuthGuard
- [x] 補上 ProtectedPage widget test
- [x] analyze 通過
- [x] flutter test 通過
- [x] Git Commit

### Milestone 4-2：Shell / Route 結構驗收

- [x] ShellPage 有 AppBar
- [x] ShellPage 有 BottomNavigationBar
- [x] Login / Profile 是 ShellPage 內層頁面
- [x] AppBar action 可以跳轉 ProtectedPage
- [x] ProtectedPage 有 Route Guard
- [x] 未登入時進入 ProtectedPage 會導回 LoginPage
- [x] analyze / test / build bundle 通過
- [x] Git Commit

## Definition of Done

- [x] ShellPage 有 AppBar
- [x] ShellPage 有 BottomNavigationBar
- [x] Login / Profile nested routes 正確
- [x] AppBar action 可進 ProtectedRoute
- [x] ProtectedRoute 掛上 AuthGuard
- [x] 未登入進 ProtectedRoute 會導回 LoginRoute
- [x] ProtectedPage 只負責展示內容
- [x] analyze 通過
- [x] flutter test 通過
- [x] flutter build bundle 通過

---

# Milestone 5：整理與驗證

**狀態：** 🟢 Completed

## 拆分計畫

### Milestone 5-1：文件整理

- [x] 同步 README 與目前實際架構
- [x] 檢查 `project_context.md`、`progress.md`、`roadmap.md` 是否一致
- [x] 必要時補充 `architecture_decisions.md`（本次無新增架構決策，不需補充）
- [x] 檢查 git diff
- [x] Git Commit

### Milestone 5-2：程式碼整理

- [x] 補齊重要中文註解
- [x] 清理 import
- [x] 檢查命名一致性
- [x] 移除暫時性或冗餘程式碼（若有）
- [x] analyze 通過
- [x] flutter test 通過
- [x] 檢查 git diff
- [x] Git Commit

### Milestone 5-3：最終驗收

- [x] melos bootstrap 通過
- [x] build_runner 通過
- [x] melos run analyze 通過
- [x] flutter test 通過
- [x] flutter build bundle 通過
- [x] 確認 git diff 為預期內容
- [x] Final Commit

## Definition of Done

- [x] 程式碼結構清楚
- [x] 文件符合繁中規範
- [x] MVP 功能可以跑通
- [x] `melos bootstrap` 通過
- [x] `melos run build_runner` 通過
- [x] `melos run analyze` 通過
- [x] `flutter test` 通過
- [x] `flutter build bundle` 通過

---

# Milestone 6：Melos 8 / Pub Workspaces Migration

**狀態：** 🟢 Completed

## 完成項目

- [x] 先執行 `dart run melos clean`
- [x] root `pubspec.yaml` 升級為 Melos 8 + Dart Pub Workspaces 設定
- [x] workspace package 清單移到 root `pubspec.yaml` 的 `workspace:`
- [x] Melos scripts 移到 root `pubspec.yaml` 的 `melos:`
- [x] 各 app / package 加上 `resolution: workspace`
- [x] SDK constraint 升級為 `>=3.8.0 <4.0.0`
- [x] 移除舊版 bootstrap 產生的 `pubspec_overrides.yaml`
- [x] 純 Dart package 測試改用 `flutter_test`
- [x] `build_runner` script 使用 `dart run build_runner build`，並加上 `--order-dependents --concurrency=1`
- [x] `dart run melos bootstrap` 通過
- [x] `dart run melos run build_runner` 通過
- [x] `dart run melos run analyze` 通過
- [x] `dart run melos exec -- flutter test` 通過
- [x] `flutter build bundle` 通過

## 注意事項

- Melos 8 仍保留 `melos.yaml` 作為遷移提示，但實際設定來源是 root `pubspec.yaml`。
- Pub Workspaces 使用單一 dependency resolution，測試依賴需要與 Flutter SDK pinned dependencies 相容。
- 乾淨 workspace 下，多 package 同時跑 `build_runner` 可能造成下游找不到上游 generated files，因此需要依 dependency graph 順序執行。

---

# Milestone 7：Dependency Upgrade

**狀態：** 🟢 Completed

## 背景

目前 `dart pub outdated` 顯示多個核心套件已有新版，但大多需要 major upgrade。

這類升級可能影響：

- generated code
- AutoRoute route generation
- Freezed generated models
- Injectable generated DI
- analyzer / lint 規則
- build_runner 執行流程

因此不應混在一般 code review 或單一模組小修中處理。

## 目前已知升級候選

- `auto_route` 9.x → 11.x
- `auto_route_generator` 9.x → 10.x
- `freezed_annotation` 2.x → 3.x
- `freezed` 2.x → 3.x
- `get_it` 7.x → 9.x
- `injectable` 2.x → 3.x
- `injectable_generator` 2.x → 3.x
- `build_runner` 2.5.x → 2.15.x
- `flutter_lints` 4.x → 6.x
- `lints` 4.x → 6.x

## 原則

- 不更換架構。
- 不更換 Bloc / AutoRoute / Injectable / GetIt。
- 不藉升級做功能重構。
- 優先保持 API 相容與行為相容。
- 每次升級一組高度相關的套件。
- 每組升級後都必須重新產生程式碼並驗證。

## 建議拆分

### Milestone 7-1：Dependency Audit

- [x] 重新執行 `dart pub outdated`。
- [x] 確認哪些套件只有 patch / minor 可升級。
- [x] 確認哪些套件是 major upgrade。
- [x] 閱讀 major upgrade migration notes。
- [x] 決定升級順序。

Audit 結論：

- 現有 constraints 下，`dart pub upgrade` 不會升級任何 dependency。
- 主要可升級項目都需要調整 major constraints。
- `build_runner` 新版已改善 workspace / build cache 行為，適合作為第一組升級。
- Freezed 3 有 breaking change，需搭配 generated code diff 檢查。
- Injectable 3 移除部分 deprecated option，目前專案未使用這些 option，風險中等。
- AutoRoute 10 有 guard / deep link 行為變更，Router stack 應晚於 code generation 與 DI stack。

### Milestone 7-2：Code Generation Stack Upgrade

範圍：

- `build_runner`
- `freezed`
- `freezed_annotation`
- `json_serializable`
- `json_annotation`

完成定義：

- [x] `dart run melos run build_runner` 通過。
- [x] generated files diff 合理。
- [x] `dart run melos run analyze` 通過。
- [x] `dart run melos exec -- flutter test` 通過。

實作紀錄：

- Freezed 3 要求 `@freezed` class 使用 `abstract class` / `sealed class`，本次以最小修改改為 `abstract class`。
- json_serializable 新版要求 package SDK constraint 至少 `>=3.8.0`，因此 workspace SDK baseline 已同步升級。
- build_runner 2.15 應使用 `dart run build_runner build`，舊的 `flutter pub run build_runner` 會產生舊 entrypoint 問題。

### Milestone 7-3：Dependency Injection Stack Upgrade

範圍：

- `get_it`
- `injectable`
- `injectable_generator`

完成定義：

- [x] DI generated files diff 合理。
- [x] App bootstrap 正常。
- [x] `dart run melos run analyze` 通過。
- [x] `dart run melos exec -- flutter test` 通過。
- [x] `flutter build bundle` 通過。

### Milestone 7-4：Router Stack Upgrade

範圍：

- `auto_route`
- `auto_route_generator`

完成定義：

- [x] Route generated files diff 合理。
- [x] AuthGuard 行為不變。
- [x] Login / Profile / Protected flow 測試通過。
- [x] `dart run melos run analyze` 通過。
- [x] `dart run melos exec -- flutter test` 通過。
- [x] `flutter build bundle` 通過。

實作紀錄：

- AutoRoute 新版 `children` API 在測試中已改為直接讀取 `children` list。

### Milestone 7-5：Lint Rules Upgrade

範圍：

- `flutter_lints`
- `lints`

完成定義：

- [x] 新 lint issue 逐一判斷是否合理。
- [x] 只修正有明確收益的 lint。
- [x] 不因 lint 大量改寫架構或命名。
- [x] `dart run melos run analyze` 通過。

實作紀錄：

- 移除 package entrypoint 中不必要的 `library xxx;`。
- 將不必要的多底線 callback 參數改為單底線。

### Milestone 7-6：Final Verification

- [x] `dart run melos bootstrap` 通過。
- [x] `dart run melos run build_runner` 通過。
- [x] `dart run melos run analyze` 通過。
- [x] `dart run melos exec -- flutter test` 通過。
- [x] `flutter build bundle` 通過。
- [x] 更新 README / progress / roadmap。

## Definition of Done

- [x] 所有決定升級的 direct dependencies 已完成升級。
- [x] generated files 已重新產生並檢查。
- [x] MVP flow 行為不變。
- [x] analyze / test / build 全部通過。
- [x] 文件已同步。

## 下一個 Milestone

### Milestone 8：Modernization Review

**狀態：** 🟢 Completed

完成項目：

- [x] Review 升級後是否仍保留舊版相容寫法。
- [x] 評估是否值得採用新版 API / Best Practice。
- [x] 不新增功能、不更換架構、不做大型重構。
- [x] 所有修改都具備明確收益。

Review 結論：

- Freezed：Bloc Event 屬於 union type，已由 `abstract class` 調整為 `sealed class`。
- Freezed：Data model / Entity / State 維持 `abstract class`，避免不必要的語意限制。
- GetIt / Injectable：目前註冊方式可維持現狀，無 deprecated API 必須處理。
- AutoRoute：目前沒有使用 11.0 移除的 named-route APIs 或舊 redirect API，維持現狀。
- Flutter / Dart Best Practice：未發現需要為新版 lint 或官方建議再調整的項目。

驗證結果：

- [x] `dart run melos bootstrap` 通過。
- [x] `dart run melos run build_runner` 通過。
- [x] `dart run melos run analyze` 通過。
- [x] `dart run melos exec -- flutter test` 通過。
- [x] `flutter build bundle` 通過。

---

## 未升級項目

以下項目仍因目前 constraints 或 Flutter SDK pinned dependencies 維持現狀，後續可獨立評估：

- `meta`
- `sqflite`
- `sqflite_common_ffi`
- `sqflite_common_ffi_web`
- `auto_route_generator` 10.6.0
- `injectable_generator` 3.1.0
- 部分 transitive dependencies
