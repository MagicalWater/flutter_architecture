# Milestone 18 — Template Baseline Holistic Audit & Release Review

## 狀態

Milestone 狀態：Planning。

目前階段：Phase A — Audit only。

在 Audit Review Gate 通過前：

- 不修改 production code。
- 不進行架構重構。
- 不升級 Template Baseline Version。
- 不發布新的 Template Baseline。

Milestone 18 的完整範圍包含 Audit、經核准的 remediation，以及是否發布新 Template Baseline 的最終 review；但目前只允許進行規劃 review與 audit。

---

## 目標

以目前 `main` 的最終程式碼為準，對 Milestone 1 至 17 累積形成的模板能力進行橫向基線審查。

本次不逐個重播歷史 Milestone，而是從下列能力切面確認：

- Architecture 與 dependency boundary 是否仍一致。
- Runtime critical flows 在組合與競態情境下是否維持正確。
- Persistence、SQLite schema、migration 與跨平台 database factory 是否具備明確契約。
- Android、iOS、Web、Windows、macOS、Linux 的實際 capability 是否被正確描述。
- Test strategy 是否能對應模板能力、風險與平台承諾。
- README、Project Context、ADR、Roadmap、Backlog、CHANGELOG 與 VERSION 是否一致。

Milestone 18 的第一階段輸出是可 review 的 evidence、matrix 與 findings，不預設一定需要 production refactor。

---

## 非目標

- 不重新實作 Milestone 1 至 17。
- 不直接將 `sqflite` 改為 Drift。
- 不為消除少量重複而建立 Generic Mapper、Generic Repository、Generic Cache 或 Generic Pagination framework。
- 不將所有 App feature 提升為 package。
- 不因 audit 發現問題便立即修改 production code。
- 不在 capability 尚未驗證前宣稱六平台完整支援。
- 不將 `flutter build bundle` 視為 Android `appbundle` 驗證。
- 不在 Phase A audit 階段升級 Template Baseline Version。
- 不將純風格偏好自動轉為 remediation。

---

## Milestone 結構

```txt
Phase A — Audit only

18-0 Planning Review
18-1 Architecture & Dependency Audit
18-2 Runtime Critical Flow Audit
18-3 Persistence & Database Audit
18-4 Platform Capability & Build Audit
18-5 Test Capability Matrix
18-6 Documentation & Provisional Baseline Assessment

Audit Review Gate
  findings disposition
  remediation scope
  capability downgrade
  baseline decision

Phase B — Approved work only

18-7 Approved Remediation
18-8 Final Validation, Documentation & Baseline Release
```

18-7 與 18-8 不得在 Audit Review Gate 前開始。

---

## Audit 原則

### 以現況程式碼為準

歷史文件用於理解決策背景，但 observed behavior、dependency graph、runtime path 與 platform capability 必須以目前 `main` 為準。

### Evidence before conclusion

每一項 finding 必須指出具體 evidence，例如：

- 檔案與 symbol。
- import 或 dependency direction。
- runtime call chain。
- schema、migration 或 transaction path。
- test case 與缺少的 scenario。
- platform scaffold、dependency 與實際 build 結果。
- 文件之間的矛盾描述。

不得只依架構偏好提出重構。

### Test evidence throughout audit

Test evidence 必須在 18-1 至 18-4 的各 audit area同步收集，不等到 18-5 才第一次檢查。

每個 runtime或capability scenario至少記錄：

```txt
Expected contract
Production path
Existing test evidence
Coverage gap
Finding
```

18-5 的責任是彙總並評估整體 test strategy，不重新進行所有流程 audit。

### 區分能力層級

平台與功能能力統一使用：

```txt
Supported
  已有必要 scaffold、runtime wiring、測試與可重現 build / runtime 驗證。

Verification pending
  必要 scaffold與dependency存在，但尚未取得指定host、runtime或artifact驗證。

Scaffold only
  已有 platform scaffold，但核心 dependency或runtime flow尚未完成。

Dependency-ready
  Dart / package邊界已有相容設計，但缺少platform scaffold或artifact驗證。

Not supported
  目前缺少必要實作、dependency、scaffold或存在已知不相容。
```

平台 evidence 必須區分：

```txt
Repository evidence
Dependency declaration
Tracked scaffold
Static compatibility
Host-available build
Runtime smoke
External-host verification required
```

不能因目前host無法執行某平台build，便把它直接誤判為Not supported；也不能在缺少artifact或runtime證據時標記為Supported。

### 先完成 findings，再拍板 remediation

同一 audit 子階段的 findings 應先完整盤點，再一起 review。不得看到第一個問題便局部修改，避免在尚未理解全局前製造新的不一致。

### 避免確認偏誤

初始風險假設只用於確保檢查，不作為搜尋邊界。每個 audit area都必須額外執行一次 open-ended scan，記錄不在初始假設中的 findings或明確無問題結論。

---

## Finding 格式

每一項 finding 使用以下欄位：

```txt
ID
Area
Severity
Status
Evidence
Current contract
Observed behavior
Risk
Recommendation
Baseline blocking
Disposition
Disposition rationale
Target phase
Verification required
```

Severity 定義：

```txt
P0 — 資料遺失、安全漏洞或核心流程確定失效，必須立即處理。
P1 — 新 Template Baseline發布前必須處理或明確降級capability。
P2 — 應改善，但不一定阻擋baseline；需有明確disposition。
P3 — 文件、可讀性、維護性或後續演進建議。
```

Finding status：

```txt
Open
Confirmed
Accepted risk
Deferred
Resolved
Not an issue
```

Disposition規則：

```txt
P0
  必須 Resolved。
  未解決時禁止發布 baseline。

P1
  必須 Resolved，
  或明確移除 / 降級相關 capability，
  或經 Audit Review Gate記錄 Accepted risk與理由。

P2 / P3
  必須具有 disposition，但可 Deferred或Not an issue。
```

---

## 固定輸出檔案

Milestone 18 的詳細證據與 findings 不直接堆入 Roadmap。

```txt
docs/audits/milestone_18_holistic_audit.md
  Milestone contract與review gate。

docs/audits/milestone_18/
  18-1_architecture_inventory.md
  18-2_runtime_flows.md
  18-3_persistence_database.md
  18-4_platform_capabilities.md
  18-5_test_matrix.md
  18-6_documentation_baseline.md
  findings.md
  remediation_decision.md
  release_validation.md
```

各檔案應在對應子階段首次需要時建立，不預先建立空白 placeholder。

Roadmap只保存目前階段、重要結論與完成摘要；歷史細節移入audit文件或`docs/archive/`。

---

## Audit 範圍

### 1. Architecture 與 dependency boundary

- App 是否仍是唯一 Composition Root。
- `core`、`api_client`、`auth`、`design_system` 的責任與依賴方向。
- App feature 內 Presentation、Domain、Data 邊界。
- 跨 Feature import、Bloc依賴與navigation contract。
- Package 是否洩漏 `get_it`、`injectable` 或 App-owned implementation。
- Package public export surface、`src` direct usage與過寬 public API。
- Mapper是否表達不同boundary，或存在不必要重複。
- 是否已有過早 abstraction、test-only abstraction或過寬 public API。

### 2. Runtime critical flows

- Bootstrap、AppConfig、database factory、DI、Theme / Locale restore、global error hooks與`runApp`順序。
- Session restore、Login、token / user persistence、runtime Session mutation。
- Concurrent 401、single-flight Refresh、token rotation、safe replay、Session replacement與Logout。
- Profile request、Route Guard與登入狀態同步。
- Catalog Search、debounce、generation、cursor pagination、SWR、Offline Cache、Refresh、Append、cleanup與corruption repair。
- expected Failure、unexpected error、cancellation、protocol violation與reporting ownership。

### 3. Persistence 與 Database

- Schema correctness與latest `onCreate`。
- 所有歷史migration path到latest schema的等價性。
- Referential integrity與foreign key enforcement。
- Transaction atomicity與rollback。
- Query pattern與index suitability。
- Retention、cleanup與Catalog cursor chain / chain revision。
- Auth user、token與preference的敏感度及production adapter揭露。
- Mobile、Desktop、Web database factory初始化。
- 是否存在足以支持改用 Drift的實際痛點；沒有evidence時保留`sqflite`。

### 4. Platform 與 build capability

- Android、iOS、Web、Windows、macOS、Linux是否有tracked scaffold。
- Dependency與plugin是否支援該平台。
- SQLite runtime factory是否完成。
- Host可執行的build命令、runtime smoke與artifact。
- 需由其他host驗證的項目與原因。
- `flutter build bundle`、`flutter build appbundle`、APK、Web與Desktop build的語意差異。
- 以Supported、Verification pending、Scaffold only、Dependency-ready、Not supported建立正式矩陣。

### 5. Test strategy

- Unit、Repository integration、SQLite migration、Bloc、Widget、Golden與跨package tests。
- 彙總18-1至18-4收集的test evidence與coverage gap。
- runtime cross-flow與concurrency scenario coverage。
- 重複、脆弱、只測implementation detail或只為測試存在的API。
- Platform build、Web SQLite browser runtime與尚未支援平台的刻意缺口。

### 6. 文件與版本

- README、Project Context、Architecture Decisions、Roadmap、Backlog、CHANGELOG與VERSION一致性。
- Roadmap是否已混入過多歷史工作日誌，需移至`docs/archive/`。
- Backlog歷史Phase 1規則是否仍被誤解為目前限制。
- Platform capability與build語意是否如實揭露。
- 現有`1.1.0`與Milestone 15至17能力的版本關係。
- Milestone 18 remediation完成後是否發布新的Template Baseline。

---

## 子階段

### Milestone 18-0 — Planning Review

- Review Milestone範圍、Phase、子階段、finding格式、severity與review gate。
- 確認固定輸出檔案與Roadmap邊界。
- 完成純文件planning revision並提交。

完成條件：

- Milestone contract無Audit-only與release scope矛盾。
- Audit Review Gate與18-7 / 18-8進入條件明確。
- 尚未開始production code修改。

### Milestone 18-1 — Architecture & Dependency Audit

- 18-1A：Repository、App、Package與Feature inventory。
- 18-1B：Cross-feature與layer boundary audit。
- 18-1C：DI、Composition Root、public API與abstraction audit。
- 18-1D：Architecture findings整理、severity與baseline blocking評估。

輸出：

- Dependency graph。
- Feature / Package責任矩陣。
- Cross-feature dependency清單。
- DI ownership清單。
- Package export surface清單。
- Mapper / abstraction disposition。
- Architecture findings register。

### Milestone 18-2 — Runtime Critical Flow Audit

- 建立Auth / Session / Refresh / Replay / Logout / Guard狀態與競態矩陣。
- 建立Catalog Search / Pagination / SWR / Cache / Refresh / Append / Repair矩陣。
- 每個scenario同步記錄production path、existing test evidence與coverage gap。
- 找出只有單元流程測試、缺少組合scenario的區域。

### Milestone 18-3 — Persistence & Database Audit

- 驗證schema correctness、migration equivalence、referential integrity、transaction atomicity、query/index、cleanup與敏感資料contract。
- 驗證Mobile、Desktop、Web database factory設計與可取得的runtime evidence。
- 建立`sqflite`保留或後續替換的evidence-based conclusion。

### Milestone 18-4 — Platform Capability & Build Audit

- 建立六平台capability matrix。
- 分別記錄repository、dependency、scaffold、static、host build、runtime與external-host evidence。
- 修正build命令與平台支援描述的語意。

### Milestone 18-5 — Test Capability Matrix

- 彙總18-1至18-4已收集的test evidence。
- 將模板能力映射到unit、integration、SQLite、Bloc、Widget、Golden與platform build。
- 分類完整覆蓋、部分覆蓋、脆弱、重複、缺漏與刻意不支援。

### Milestone 18-6 — Documentation & Provisional Baseline Assessment

#### 18-6A Documentation Consistency Audit

- 盤點主要文件、capability statement、Roadmap歷史與Backlog舊scope。
- 只產出findings與建議，不在Audit Review Gate前進行大規模文件重整。

#### 18-6B Provisional Baseline Assessment

- 評估現有`1.1.0`是否落後。
- 定義新baseline發布條件。
- 提出`PATCH`、`MINOR`、`MAJOR`或不發布的provisional建議。

#### 18-6C Audit Review Gate

進入條件：

- 18-1至18-5完成。
- 18-6A與18-6B完成。
- 所有findings都有severity、evidence與建議disposition。
- 所有P0 / P1都有明確處理建議。
- 尚未修改production code。

Gate輸出：

```txt
Approved remediation list
Accepted-risk list
Deferred list
Not-an-issue list
Capability downgrade list
Baseline release decision
```

只有Approved remediation list可進入18-7。

### Milestone 18-7 — Approved Remediation

- 僅處理Audit Review Gate核准的findings。
- 每個remediation保留原finding ID、targeted verification與review紀錄。
- 不在本階段直接宣告baseline發布完成。

### Milestone 18-8 — Final Validation, Documentation & Baseline Release

- Review 18-7所有實際修改與finding disposition。
- 執行完整regression、host可用platform build與必要artifact驗證。
- 同步README、Project Context、ADR、Roadmap、Backlog、CHANGELOG與VERSION。
- 依Audit Review Gate與最終證據決定是否發布新Template Baseline。
- 完成封存、commit與push。

---

## 初始風險假設

以下只是audit起始假設，不是已確認finding，也不限制open-ended scan：

- 平台支援描述可能高於repo目前tracked scaffold與實際artifact驗證。
- `flutter build bundle`可能被文件讀者誤解為Android `.aab` build。
- Auth / Profile presentation對Shell navigation identity的依賴可能形成反向跨Feature boundary。
- Runtime個別流程測試完整，但跨流程競態仍需集中檢查。
- SQLite foreign key declaration與實際connection enforcement需確認。
- SharedPreferences-based auth persistence需清楚區分template demo adapter與production-secure storage。
- Roadmap累積大量已完成實作日誌，可能需要封存歷史內容。
- `1.1.0`已早於Milestone 15至17能力，但新版本應等Milestone 18 remediation與驗證完成後再決定。

---

## Milestone 18 完成定義

- 18-0至18-6有完整evidence-based輸出與Audit Review Gate決議。
- 所有六個audit area均有findings或明確無問題結論。
- P0全部Resolved；P1依規則Resolved、capability降級或經Gate記錄Accepted risk。
- P2 / P3均有明確disposition。
- Architecture、runtime、database、platform、test與documentation matrix均已落檔。
- 不必要的重構提案已標記為Not an issue或Deferred。
- 18-7只處理Approved remediation list。
- Supported platform與build語意有可重現證據；無法在目前host驗證者被誠實標為Verification pending或其他較低能力層級。
- README、Project Context、ADR、Roadmap、Backlog、CHANGELOG與VERSION一致。
- 18-8完成最終驗證、文件同步、版本決策與封存。
