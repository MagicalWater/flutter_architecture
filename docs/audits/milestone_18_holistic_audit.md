# Milestone 18 — Template Baseline Holistic Audit

## 狀態

Planning / Audit only。

本 Milestone 目前只進行盤點、驗證與 findings 整理。未經 review 與拍板前，不修改 production code、不進行架構重構，也不發布新的 Template Baseline。

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

Milestone 18 的輸出首先是可 review 的 evidence 與 findings，不預設一定需要 production refactor。

---

## 非目標

- 不重新實作 Milestone 1 至 17。
- 不直接將 `sqflite` 改為 Drift。
- 不為消除少量重複而建立 Generic Mapper、Generic Repository、Generic Cache 或 Generic Pagination framework。
- 不將所有 App feature 提升為 package。
- 不因 audit 發現問題便立即修改 production code。
- 不在 capability 尚未驗證前宣稱六平台完整支援。
- 不將 `flutter build bundle` 視為 Android `appbundle` 驗證。
- 不在 audit 階段升級 Template Baseline Version。

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

### 區分能力層級

平台與功能能力統一使用：

```txt
Supported
  已有必要 scaffold、runtime wiring、測試與可重現 build 驗證。

Scaffold only
  已有 platform scaffold，但核心 dependency 或 runtime flow 尚未完成驗證。

Dependency-ready
  Dart / package 邊界已有相容設計，但缺少 platform scaffold 或實際 artifact 驗證。

Not supported
  目前缺少必要實作、dependency、scaffold 或存在已知不相容。
```

### 先完成 findings，再拍板 remediation

同一 audit 子階段的 findings 應先完整盤點，再一起 review。不得看到第一個問題便局部修改，避免在尚未理解全局前製造新的不一致。

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
```

Severity 定義：

```txt
P0 — 資料遺失、安全漏洞或核心流程確定失效，必須立即處理。
P1 — 新 Template Baseline 發布前必須處理或明確降級 capability。
P2 — 應改善，但不一定阻擋 baseline；需有明確 disposition。
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

---

## Audit 範圍

### 1. Architecture 與 dependency boundary

- App 是否仍是唯一 Composition Root。
- `core`、`api_client`、`auth`、`design_system` 的責任與依賴方向。
- App feature 內 Presentation、Domain、Data 邊界。
- 跨 Feature import、Bloc 依賴與 navigation contract。
- Package 是否洩漏 `get_it`、`injectable` 或 App-owned implementation。
- Mapper 是否表達不同 boundary，或存在不必要重複。
- 是否已有過早 abstraction、test-only abstraction 或過寬 public API。

### 2. Runtime critical flows

- Bootstrap、AppConfig、database factory、DI、Theme / Locale restore、global error hooks 與 `runApp` 順序。
- Session restore、Login、token / user persistence、runtime Session mutation。
- Concurrent 401、single-flight Refresh、token rotation、safe replay、Session replacement與 Logout。
- Profile request、Route Guard與登入狀態同步。
- Catalog Search、debounce、generation、cursor pagination、SWR、Offline Cache、Refresh、Append、cleanup與 corruption repair。
- expected Failure、unexpected error、cancellation、protocol violation與 reporting ownership。

### 3. Persistence 與 Database

- `sqflite` / SQLite schema與 latest `onCreate`。
- 所有歷史 migration path到 latest schema的等價性。
- transaction atomicity與 rollback。
- index、foreign key enforcement與 cleanup。
- Catalog cache identity、cursor chain與 chain revision。
- Auth user、token與 preference的敏感度及 production adapter揭露。
- Mobile、Desktop、Web database factory初始化。
- 是否存在足以支持改用 Drift的實際痛點；沒有 evidence時保留 `sqflite`。

### 4. Platform 與 build capability

- Android、iOS、Web、Windows、macOS、Linux 是否有 tracked scaffold。
- Dependency與 plugin是否支援該平台。
- SQLite runtime factory是否完成。
- 實際可執行的 build命令與 artifact。
- `flutter build bundle`、`flutter build appbundle`、APK、Web與 Desktop build的語意差異。
- 以 Supported、Scaffold only、Dependency-ready、Not supported建立正式矩陣。

### 5. Test strategy

- Unit、Repository integration、SQLite migration、Bloc、Widget、Golden與跨 package tests。
- 能力對應測試矩陣。
- runtime cross-flow與 concurrency scenario coverage。
- 重複、脆弱、只測 implementation detail或只為測試存在的 API。
- Platform build、Web SQLite browser runtime與尚未支援平台的刻意缺口。

### 6. 文件與版本

- README、Project Context、Architecture Decisions、Roadmap、Backlog、CHANGELOG與 VERSION一致性。
- Roadmap是否已混入過多歷史工作日誌，需移至 `docs/archive/`。
- Backlog歷史 Phase 1規則是否仍被誤解為目前限制。
- Platform capability與 build語意是否如實揭露。
- Milestone 18 remediation完成後是否發布新的 Template Baseline。

---

## 子階段

### Milestone 18-1 — Repository Inventory & Boundary Audit

- 18-1A：Repository、App、Package與Feature inventory。
- 18-1B：Cross-feature與layer boundary audit。
- 18-1C：DI、Composition Root與abstraction audit。
- 18-1D：Architecture findings整理、severity與baseline blocking評估。

輸出：

- Dependency graph。
- Feature / Package責任矩陣。
- Cross-feature dependency清單。
- DI ownership清單。
- Mapper / abstraction disposition。
- Architecture findings register。

### Milestone 18-2 — Runtime Critical Flow Audit

- 建立 Auth / Session / Refresh / Replay / Logout / Guard狀態與競態矩陣。
- 建立 Catalog Search / Pagination / SWR / Cache / Refresh / Append / Repair矩陣。
- 找出只有單元流程測試、缺少組合 scenario的區域。

### Milestone 18-3 — Persistence & Database Audit

- 驗證 schema、migration、transaction、index、foreign key、cleanup與敏感資料 contract。
- 建立 `sqflite`保留或後續替換的 evidence-based conclusion。

### Milestone 18-4 — Platform Capability & Build Audit

- 建立六平台 capability matrix。
- 實際驗證可用的 scaffold、dependency、runtime與 build artifact。
- 修正 build命令與平台支援描述的語意。

### Milestone 18-5 — Test Capability Matrix

- 將模板能力映射到 unit、integration、SQLite、Bloc、Widget、Golden與platform build。
- 分類完整覆蓋、部分覆蓋、脆弱、重複、缺漏與刻意不支援。

### Milestone 18-6 — Documentation & Baseline Decision

- 統一主要文件與 capability statement。
- 決定 Roadmap歷史封存方式。
- 決定 findings remediation scope與下一個 Template Baseline版本。

### Milestone 18-7 — Approved Remediation & Release Validation

僅處理經 review 拍板的 findings：

- 修正 baseline blocking問題。
- 補必要 regression與build驗證。
- 同步文件與版本。
- 完成最終 release validation、封存與提交。

---

## 初始風險假設

以下只是 audit 起始假設，不是已確認 finding：

- 平台支援描述可能高於 repo目前 tracked scaffold與實際 artifact驗證。
- `flutter build bundle` 可能被文件讀者誤解為 Android `.aab` build。
- Auth / Profile presentation對 Shell navigation identity的依賴可能形成反向跨 Feature boundary。
- Runtime個別流程測試完整，但跨流程競態仍需集中檢查。
- SQLite foreign key declaration與實際 connection enforcement需確認。
- SharedPreferences-based auth persistence需清楚區分 template demo adapter與 production-secure storage。
- Roadmap累積大量已完成實作日誌，可能需要封存歷史內容。
- `1.1.0` 已早於 Milestone 15至17能力，但新版本應等 Milestone 18 remediation與驗證完成後再決定。

---

## Milestone 18 完成定義

- 所有六個 audit area均有 evidence-based findings或明確無問題結論。
- P0 / P1 findings均已 resolved、accepted risk或透過 capability降級處理。
- Architecture、runtime、database、platform、test與documentation matrix均已落檔。
- 不必要的重構提案已標記為 Not an issue或Deferred。
- Supported platform與build語意有可重現證據。
- README、Project Context、ADR、Roadmap、Backlog、CHANGELOG與 VERSION一致。
- 經 review決定是否發布新的 Template Baseline，並完成對應驗證與封存。
