# Milestone 18 Findings

本文件是Milestone 18所有正式finding的唯一Single Source of Truth。

各audit子階段文件保存inventory、matrix、evidence與分析，並以Finding ID引用本文件；不得複製完整finding內容。

---

## M18-A01 — ShellPage跨Feature直接依賴AuthBloc

**Area：** Architecture / Cross-feature Presentation Boundary

**Severity：** P1

**Status：** Confirmed

**Baseline blocking：** Yes，除非在Audit Review Gate明確修正、降級既有architecture claim或記錄Accepted risk。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** Architecture import scan、Shell startup behavior regression、完整App tests。

### Evidence

`apps/flutter_architecture/lib/features/shell/presentation/pages/shell_page.dart`直接import：

```dart
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
```

並於ShellPage內取得AuthBloc及送出startup event：

```dart
final authBloc = useBloc<AuthBloc>();
authBloc.add(const AuthEvent.started());
```

`AGENTS.md`與`docs/conversation_rules.md`均明確規定不要跨Feature直接依賴Bloc。

### Current contract

跨Feature狀態與協調應透過SessionManager、Repository Interface、UseCase或domain abstraction；Page原則上只依賴自己的Bloc。

### Observed behavior

Shell feature直接知道Auth feature的Presentation Bloc與Auth startup event，並擁有觸發restore flow的責任。

### Risk

- Shell navigation implementation與Auth Presentation lifecycle耦合。
- 未來替換Auth state management或調整startup ownership時需修改Shell feature。
- 模板實作與其明文architecture rule不一致，會誤導使用者。

### Recommendation

Audit Review Gate應選擇並拍板其中一種最小方案：

1. 將Auth restore / startup ownership提升到App bootstrap或App-owned coordinator，Shell不直接操作AuthBloc。
2. 若Shell確實是App orchestration owner，則建立App-owned明確contract並修訂「Page只依賴自己的Bloc」規則，但不得只為保留現況而模糊化規則。

不建議建立Generic AppCoordinator framework。

### Disposition rationale

目前先保留Pending。問題已確認，但依Milestone 18 contract，在18-6C前不得修改production code。

---

## M18-A02 — Auth與Profile Presentation反向依賴ShellTab

**Area：** Architecture / Navigation Boundary

**Severity：** P2

**Status：** Confirmed

**Baseline blocking：** No，但發布新baseline前必須有明確disposition。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** Login success tab transition、Profile logout tab transition、router mapping與Shell navigation regression。

### Evidence

下列feature page直接importShell presentation identity：

```txt
features/auth/presentation/pages/login_page.dart
  → features/shell/presentation/shell_tab.dart

features/profile/presentation/pages/profile_page.dart
  → features/shell/presentation/shell_tab.dart
```

Login成功後：

```dart
context.tabsRouter.setActiveIndex(ShellTab.profile.index);
```

Profile logout成功後：

```dart
context.tabsRouter.setActiveIndex(ShellTab.login.index);
```

### Current contract

Shell擁有tab ordering與navigation chrome。Auth與Profile應表達「登入成功」或「登出成功」結果，不應擁有Shell tab implementation identity。

### Observed behavior

Auth與Profile Presentation知道Shell有哪些tab及其index mapping。Feature結果與App navigation implementation直接耦合。

### Risk

- Shell tab重排、移除或改成非tab navigation時需要修改Auth與Profile頁面。
- Feature presentation不能在不同App shell中直接重用。
- 現有測試只鎖定router child mapping與ShellScaffold callback，沒有直接覆蓋兩個跨feature transition。

### Recommendation

由App-owned navigation boundary負責結果到destination的映射，例如：

- Page對外發出成功callback，由route / shell composition傳入navigation action。
- 使用App-owned typed navigation intent，而不是讓feature importShellTab。
- 若AutoRoute可由route name表達，仍應避免feature知道tab index ordering。

不建議建立Generic Navigation Service。

### Disposition rationale

目前先保留Pending。這是明確耦合但未造成核心流程失效，適合在Audit Review Gate與M18-A01一起決定最小remediation。

---

## M18-R01 — Auth lifecycle command缺少跨operation latest-intent ordering

**Area：** Runtime / Auth State Mutation Ordering

**Severity：** P1

**Status：** Confirmed

**Baseline blocking：** Yes，除非在Audit Review Gate修正、明確限制可接受的event concurrency contract，或記錄Accepted risk。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** Double Login、Login + Logout反向完成測試；Restore + Login UI ordering測試；Auth、Session與persistence regression。

### Evidence

`AuthBloc`註冊`AuthStarted`、`AuthLoginRequested`與`AuthLogoutRequested`時皆未指定跨operation ordering contract。Handlers在await後直接emit結果，沒有operation generation、request identity或latest-operation guard。

`AuthRepositoryImpl.login()`的remote request在`AuthStateMutationCoordinator.runExclusive()`之前執行。Coordinator只序列化完成後的persistence / Session mutation，不保證較新的使用者意圖最後commit。

### Current contract

較舊login response不得在較新的login / logout意圖後覆蓋UI、persistence或runtime Session。Logout必須使所有較舊login operation失效。

### Observed behavior

已確認情境：Login A先開始，Login B後開始但先完成並commit Session B；Login A較晚完成後仍可commit Session A。另一情境是Login remote尚未完成，Logout先清除Session，舊Login之後仍可重新commit Session。

Restore + Login目前只確認為UI ordering / transient-state coverage gap；Repository mutation queue使Restore通常先進入local mutation，因此尚無足夠evidence宣稱Restore會在較新Login commit後覆蓋最終persisted Session。

### Risk

- 雙login或account switch可能得到與最後操作不同的帳號。
- 較晚完成的舊login可能在logout後重新建立Session。
- 各次commit內部一致，但跨operation ordering不符合使用者意圖。
- 現有測試未覆蓋Bloc lifecycle交錯。

### Recommendation

Audit Review Gate應拍板最小contract：新Login使舊Login失效，Logout立即使所有舊Restore / Login失效，舊operation不得commit persistence、Session或UI。

優先比較：

- operation generation / latest-intent guard。
- App-owned Auth command coordinator。
- 單一AuthLifecycleEvent bucket搭配明確transformer。

不能只在不同event type各自加`sequential()`便假設已有跨event type全域ordering；單純strict sequential也可能讓Logout等待慢速Login完成。

不可只依靠UI loading button避免重複event。不建議建立Generic Operation Coordinator framework。

### Disposition rationale

目前先保留Pending。依Milestone 18 contract，在18-6C前不得修改production code。
