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
3eb1121 feat(mvp): initialize enterprise architecture template
```

---

# Milestone 2A：Authentication Infrastructure

**狀態：** ⏳ Not Started

## 預計完成項目

- AuthRepository 完整底層流程
- Mock Login API
- Mock Profile API
- Token Storage
- SQLite Profile Storage
- Dio Authorization Header Interceptor
- Session Restore Infrastructure

## Definition of Done

- [ ] AuthRepository 可以登入並回傳 AuthResult
- [ ] Token 存入 SharedPreferences
- [ ] User / Profile 存入 SQLite
- [ ] Profile API 自動帶 Header
- [ ] Restore Session 可以從本地資料還原登入狀態
- [ ] flutter analyze = 0
- [ ] flutter test 全部通過

---

# Milestone 2B：Authentication Flow

**狀態：** ⏳ Not Started

## 預計完成項目

- Login Button 串接 AuthBloc
- 登入成功後切換到 Profile tab
- Profile 頁面顯示目前登入用戶名稱
- 未登入時 Profile 顯示尚未登入
- ProtectedPage Route Guard
- 未登入進 ProtectedPage 時導回 LoginPage

## Definition of Done

- [ ] Login 成功
- [ ] Profile 顯示登入用戶
- [ ] Logout 成功
- [ ] Route Guard 生效
- [ ] Auto Login 生效
- [ ] flutter analyze = 0
- [ ] flutter test 全部通過
