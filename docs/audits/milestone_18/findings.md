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

**Status：** Resolved

**Baseline blocking：** No，已於18-7A完成remediation與review verification。

**Disposition：** Resolved in 18-7A

**Target phase：** Completed

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

18-7A採用`AuthStateMutationCoordinator` lifecycle generation lease。較新的restore / login / logout會使舊operation失效；外部權威Session clear亦會invalidate舊operation。Repository在remote completion、persistence與runtime Session commit boundary驗證lease，superseded維持control flow，不轉Failure或覆蓋較新Bloc state。

Logout在進入exclusive cleanup前可被取代；一旦cleanup開始，仍會完整執行user與token cleanup，但只有current Logout可以清除runtime Session，完成後若已被較新operation取代則回傳superseded control flow。

Verification涵蓋Double Login反向完成、Login + Logout反向完成、Restore + Login transient UI ordering、external Session clear invalidation，以及Logout cleanup與較新Login交錯。Workspace五個package analyze與389項tests全數通過。

---

## M18-P01 — auth_user多列造成token-user identity mismatch

**Area：** Persistence / Auth Identity Consistency

**Severity：** P1

**Status：** Confirmed

**Baseline blocking：** Yes，除非在Audit Review Gate修正auth user single-record / identity contract或明確降級Auth persistence capability。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** 不同user sequential login、double login、正常single-user restore、既有multi-row database upgrade / restore、row count異常cleanup、logout與migration regression。

### Evidence

`auth_user`以`id`為primary key，因此可同時保存多個不同user。`saveUser()`使用replace，只替換同ID row；`readUser()`則對整張table執行`limit: 1`，沒有order或token user identity條件。

Token pair保存在單一SharedPreferences key，payload沒有user ID。不同帳號登入後，SQLite可能保留多個user row；後續restore可把目前token pair與任意舊user配對。

### Current contract

Persisted token、persisted user與runtime Session必須代表同一auth identity。模板目前只支援單一active Session，不宣告multi-account persistence。

### Observed behavior

Sequential account switch即可觸發：先登入User A，再登入User B，token key被B覆蓋，但`auth_user`同時保留A與B；restart後`readUser(limit: 1)`結果沒有identity保證。

### Risk

- Session userId可能與access / refresh token實際subject不同。
- Profile、Guard與diagnostic context可能使用錯誤user identity。
- 問題可跨restart持續，且不依賴並行event。

### Recommendation

Audit Review Gate應拍板最小single-active-user persistence contract，例如在保存新user前transactionally清空table，或使用固定single-row identity；若token payload可安全保存stable user ID，也可在restore時做explicit match。

Remediation必須同時處理future writes與existing persisted rows。既有資料若出現multi-row或無法證明token-user identity，restore應安全清理或拒絕建立Session。只加入`ORDER BY`只能穩定選row，不能證明identity，因此不構成有效修正。

不建議為此建立multi-account framework。

### Disposition rationale

目前先保留Pending。這是可造成auth identity錯配的baseline correctness問題，Phase A不修改production code。

---

## M18-P02 — Catalog foreign key未在production connection啟用

**Area：** Persistence / SQLite Constraint Enforcement

**Severity：** P2

**Status：** Confirmed

**Baseline blocking：** No，但發布新baseline前必須有明確disposition。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** Production-style openDatabase pragma test、fresh install與upgrade connection、parent delete cascade、orphan child insert rejection、既有orphan cleanup / rejection與Catalog regression。

### Evidence

`catalog_cache_page_item`宣告composite foreign key與`ON DELETE CASCADE`，但App的`openDatabase()`沒有`onConfigure`執行`PRAGMA foreign_keys = ON`。

### Current contract

Schema宣告的referential integrity應在production database connection實際生效，或文件與DDL不應暗示依賴未啟用的constraint。

### Observed behavior

現有Catalog DataSource會手動先刪items再刪page，因此已知流程通常不依賴cascade；但新的直接parent delete、migration或maintenance path可能留下orphan item。

### Risk

- Schema與runtime行為不一致。
- 未來維護者可能依賴`ON DELETE CASCADE`，卻得到orphan rows。
- Tests沒有驗證production connection的foreign key pragma。

### Recommendation

在App-owneddatabase connection configuration明確啟用foreign keys，並加入production-style pragma與cascade regression；或若刻意不使用foreign key enforcement，移除DDL中的誤導性constraint並維持manual cleanup contract。

若選擇啟用foreign key，必須另外處理upgrade前已存在的orphan rows；`PRAGMA foreign_keys = ON`不會自動修復既有資料。可透過migration cleanup、`foreign_key_check`驗證或明確拒絕不一致database，但需保留可測試的contract。

### Disposition rationale

目前先保留Pending。現有production paths有manual cleanup，故severity為P2而非P1。

---

## M18-C01 — 缺少tracked Flutter platform scaffold

**Area：** Platform Capability / Build Artifact

**Severity：** P1

**Status：** Confirmed

**Baseline blocking：** Yes，除非在Audit Review Gate建立並驗證至少正式承諾的平台scaffold，或明確將Template Baseline降級為不含可執行platform project的Dart / architecture starter。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** 逐平台disposition、tracked scaffold inventory、對應host release artifact build、必要native configuration、plugin / database / SharedPreferences initialization、bootstrap與核心runtime smoke。

### Evidence

`apps/flutter_architecture`沒有`android/`、`ios/`、`windows/`、`macos/`、`linux/`或完整`web/`runner scaffold。`.metadata`亦不存在，但只作為repository inventory輔助證據；真正阻擋artifact的是runner與platform build configuration缺失。Web只tracked `sqflite_sw.js`與`sqlite3.wasm`。

Windows host實測：

```txt
flutter build bundle --release
  success，但只屬framework / Dart bundle compilation evidence

flutter build web --release
  This project is not configured for the web.

flutter build windows --release
  No Windows desktop project configured.
```

### Current contract

Platform capability必須由tracked scaffold、必要native configuration、artifact build與runtime evidence支持；`flutter build bundle`不得當作Android、Web或Desktop artifact驗證。

### Observed behavior

App的Dart code、plugin dependencies與conditional database factory具跨平台設計，但沒有任何platform runner可直接build或run。六平台目前全部只能分類為Dependency-ready。

### Risk

- 使用者clone模板後不能直接建立APK、AAB、Web output或Desktop executable。
- Native manifest、identifier、permissions、entitlements與deployment target沒有baseline contract。
- Flutter/plugin compatibility只能由Dart tests推論，沒有application artifact證據。
- `flutter build bundle`成功容易被誤認為Android build已通過。

### Recommendation

Audit Review Gate應逐平台拍板Template Baseline disposition，例如Supported target、Verification pending target、維持Dependency-ready或Not supported。對承諾的平台建立tracked scaffold、固定必要native configuration並取得artifact / runtime evidence；不承諾的平台維持較低能力分類並在README與capability matrix明示。

單純執行`flutter create . --platforms ...`最多只取得Scaffold only，不能直接標記Supported。每個平台仍需獨立驗證dependency resolution、generated code、release artifact、identifier / permissions / entitlements / deployment target、plugin registration、database factory、SharedPreferences、bootstrap / routing、Theme / Locale restore、Mock API核心流程與runtime smoke。

### Disposition rationale

目前先保留Pending。這是baseline capability問題而非單一native設定bug，Phase A不得執行`flutter create`修改repository。

---

## M18-D01 — README企業模板定位未揭露無可執行platform project

**Area：** Documentation / Product Positioning

**Severity：** P1

**Status：** Confirmed

**Baseline blocking：** Yes，除非建立並驗證正式承諾的平台，或明確將模板定位降級為不含可執行platform project的Dart / architecture starter。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-7 candidate

**Verification required：** README首頁、Quick Start與run instructions、platform capability matrix、tracked scaffold及artifact evidence一致；`M18-C01`與本finding使用同一份platform disposition。

### Evidence

README將repository描述為「可直接作為企業專案起點的Flutter Enterprise Template」，並提供一般`flutter run`命令；但App沒有任何完整platform runner，clone後無法直接build或run application。Web段落雖說明可自行執行`flutter create`，首頁與一般run instructions沒有同步揭露整體capability只有Dependency-ready。

### Current contract

Current product positioning必須清楚區分architecture starter、tracked runnable application與Supported platform，不得要求讀者從歷史段落推導重要限制。

### Observed behavior

Architecture、Dart application layer與component tests成熟，但repository缺少所有platform projects。README的第一印象高於實際可直接使用的application capability。

### Risk

- 使用者可能預期clone後可直接`flutter run`或建立artifact。
- Enterprise template定位可能被誤解為已有native baseline、identifier、permissions與plugin runtime驗證。
- README與`M18-C01` capability matrix不一致。

### Recommendation

Gate應先拍板正式平台集合，並讓`M18-C01`與本finding共用同一份platform disposition。若建立平台，README需列出Supported / pending / Dependency-ready矩陣、必要host與可直接執行的實際命令；若不建立平台，首頁需明確定位為Dart / architecture starter，把platform generation列為Quick Start前置步驟，並提醒`flutter create`可能產生或覆蓋platform files。

文件降級不能取代`M18-R01`與`M18-P01`等Auth correctness remediation。

### Disposition rationale

目前先保留Pending。這是current baseline positioning問題，應與`M18-C01`一起處理。

---

## M18-D02 — 早期文件將Web dependency preparation描述為完整scaffold或runtime成果

**Area：** Documentation / Platform Evidence Terminology

**Severity：** P2

**Status：** Confirmed

**Baseline blocking：** No，但發布新baseline前必須有明確disposition。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-8 candidate

**Verification required：** Current README、ADR、Project Context與Roadmap使用一致的scaffold / component / artifact / runtime terminology。

### Evidence

Decision 014寫「目前只有Dart / Flutter Web scaffold」，但tracked Web只有SQLite service worker與WASM assets，沒有完整runner。Milestone 2C部分歷史語意描述Web不再白畫面，但沒有browser application runtime evidence。

### Current contract

Platform evidence必須區分dependency preparation、tracked scaffold、framework compilation、artifact build與runtime smoke。

### Observed behavior

Conditional database factory與Web assets已完成，但較早文件的「Web scaffold」與runtime完成語意超過實際evidence。

### Risk

- 後續讀者可能把Web assets誤認為完整Web platform project。
- 歷史build文字可能被誤認為platform artifact或browser smoke。
- Platform capability review容易重複產生錯誤假設。

### Recommendation

保留歷史決策背景。Current README、Project Context、Roadmap current summary與baseline release notes使用Web dependency preparation / SQLite assets與framework compilation terminology；Accepted ADR可補充current evidence clarification。Archive、historical CHANGELOG與舊Milestone紀錄原則上不全面重寫。

### Disposition rationale

目前先保留Pending。這是文件準確性與evidence taxonomy問題，不代表SQLite implementation失效。

---

## M18-D03 — Backlog混列已完成與未完成能力

**Area：** Documentation / Planning Hygiene

**Severity：** P3

**Status：** Confirmed

**Baseline blocking：** No。

**Disposition：** Pending Audit Review Gate

**Target phase：** 18-8 candidate

**Verification required：** Backlog只保留future / deferred scope，completed items移至Roadmap、Project Context或archive。

### Evidence

Backlog的「第二階段可以考慮」仍列出ADR、完整Unit / Bloc / Repository Test範例與Localizations；其中前兩者已有實作，Localization已由Milestone 16完成但仍與future items混列。文件也保留多個已完成Milestone於「已排入正式Roadmap」區段。

### Current contract

Backlog應表達尚未承諾或Deferred的future scope，已完成工作由Roadmap、Project Context與archive保存。

### Observed behavior

讀者必須依括號註解與其他文件判斷項目是否仍待辦，Backlog不再是可靠的未完成清單。

### Risk

- 新對話或維護者可能重複規劃已完成能力。
- Future scope優先級被歷史項目稀釋。

### Recommendation

將Backlog整理為Future ideas、Deferred commitments與explicitly not planned；移除或移轉completed項目，不需要建立複雜issue tracker格式。

### Disposition rationale

目前先保留Pending。屬低風險文件維護問題，可在final documentation同步時處理。
