# Conversation Rules

本文件定義本專案與 ChatGPT 協作時的工作規範。

目的：避免重要決策只留在聊天紀錄中，讓專案文件成為 Single Source of Truth。

---

## Rule 1：先討論，再拍板，再實作

架構問題不要直接寫程式。

流程應該是：

```txt
討論
  ↓
拍板
  ↓
更新文件
  ↓
實作
  ↓
驗證
  ↓
Commit
```

---

## Rule 2：Architecture 改變先更新 Decision

如果討論結果會影響架構，例如：

- Feature 邊界
- Package 邊界
- Dependency direction
- Route Guard 依賴
- Session 管理方式
- Storage 策略

必須先更新：

```txt
docs/architecture_decisions.md
```

再修改程式。

---

## Rule 3：Milestone 改變先更新 Roadmap / Progress

如果目前工作順序改變，或新增 / 拆分 Milestone，必須同步更新：

```txt
docs/roadmap.md
docs/progress.md
```

避免文件和實際進度不同步。

---

## Rule 4：Progress 是目前進度依據

任何新對話或新工作開始前，先閱讀：

```txt
docs/progress.md
```

目前要做什麼，以 progress.md 為準。

---

## Rule 5：README 永遠保持最新

README 是第一次接觸專案的人會看的入口。

如果新增：

- 啟動方式
- 驗證方式
- 平台限制
- 重要依賴
- 文件導覽

必須同步更新 README。

---

## Rule 6：文件與註解使用繁體中文

預設使用繁體中文。

技術名詞保留英文。

例如：

```txt
Clean Architecture
Feature First
Repository
UseCase
Bloc
Route Guard
Dependency Injection
```

不要強行翻譯成生硬中文。

---

## Rule 7：不要跨 Feature 直接依賴 Bloc

原則：

```txt
自己的 Page
  ↓
自己的 Bloc
```

避免：

```txt
ProfilePage
  ↓
AuthBloc
```

跨 feature 溝通應透過：

- SessionManager
- Repository Interface
- UseCase
- Domain abstraction

---

## Rule 8：Route Guard 不依賴 Presentation Detail

AuthGuard 不應依賴 AuthBloc。

應依賴更小且更穩定的能力：

```txt
SessionManager / AuthSessionReader
```

Route Guard 只需要知道是否可進入頁面，不需要知道登入 UI 狀態。

---

## Rule 9：UseCase 粒度以業務行為為單位

推薦：

```txt
LoginUseCase
LogoutUseCase
RestoreSessionUseCase
GetProfileUseCase
```

避免：

```txt
AuthUseCase
ProfileUseCase
UserUseCase
```

原因：過大的 UseCase 容易變成 service class，職責不清楚。

---

## Rule 10：每個 Milestone 都必須驗證

每個 Milestone 收尾至少執行：

```bash
dart run melos bootstrap
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

如果有 Web 平台：

```bash
cd apps/flutter_architecture
flutter build web
```

---

## Rule 11：Commit 前更新 Progress

Commit 前確認：

- progress.md 已更新。
- roadmap.md 如有變更也已更新。
- architecture_decisions.md 如有架構決策也已更新。
- README 如有使用方式變更也已更新。

---

## Rule 12：新的 ChatGPT 對話恢復流程

新的對話第一步請閱讀：

```txt
README.md
docs/project_context.md
docs/architecture_decisions.md
docs/progress.md
docs/roadmap.md
docs/conversation_rules.md
```

閱讀完成後，依照 progress.md 的目前 Milestone 繼續開發。

不要依賴舊聊天紀錄作為唯一上下文。
