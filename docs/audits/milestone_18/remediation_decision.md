# Milestone 18 — Audit Review Gate Decision

## 狀態

Audit Review Gate：Approved。

Phase A audit已完成。18-7只可處理本文件列入Approved remediation list的項目；未列入者不得順帶擴張scope。

本文件只保存Finding ID的Gate disposition、理由、target phase與verification要求。Finding內容仍以`findings.md`為唯一Single Source of Truth。

---

## 1. Gate summary

```txt
Approved remediation   7 findings
Accepted risk          0 findings
Deferred               2 findings（final documentation）
Not an issue           0 findings
Capability downgrade   5 platforms
Supported target       Android only
Baseline release       Do not release now
Provisional candidate  1.2.0 MINOR
```

Gate未接受任何P1 correctness risk。Auth ordering、persisted identity與architecture boundary必須進入18-7修正。

平台scope採最小可交付策略：Android是本次唯一Supported target。iOS、Web、Windows、macOS與Linux維持Dependency-ready，不在18-7建立runner，也不得在README宣稱Supported。

---

## 2. Approved remediation list

### M18-A01 — ShellPage跨Feature直接依賴AuthBloc

**Disposition：** Approved remediation

**Target phase：** 18-7

**Decision：** 將Auth restore / startup ownership移至App-owned bootstrap或composition boundary，Shell不得直接import或dispatch AuthBloc event。

**Verification：** Cross-feature import scan、Auth restore startup regression、Shell startup與完整App tests。

---

### M18-A02 — Auth與Profile Presentation反向依賴ShellTab

**Disposition：** Approved remediation

**Target phase：** 18-7

**Decision：** 由App-owned navigation composition負責Login成功與Logout成功到Shell destination的映射；Auth與Profile Presentation不得依賴ShellTab或tab index identity。

**Verification：** Login success tab transition、Profile logout tab transition、router mapping、Shell navigation regression與cross-feature import scan。

---

### M18-R01 — Auth lifecycle command缺少跨operation latest-intent ordering

**Disposition：** Approved remediation

**Target phase：** 18-7

**Decision：** 建立Auth lifecycle latest-intent contract：新Login使舊Login失效；Logout立即使所有舊Restore / Login失效；過期operation不得commit persistence、Session或UI。

實作可採operation generation / latest-intent guard或等價最小方案，但不得只在不同event handler各自加入`sequential()`。

**Verification：** Double Login反向完成、Login + Logout反向完成、Restore + Login UI ordering，以及Auth、Session與persistence regression。

---

### M18-P01 — auth_user多列造成token-user identity mismatch

**Disposition：** Approved remediation

**Target phase：** 18-7

**Decision：** 建立single-active-user persistence contract，必須同時處理future writes、existing multi-row rows與restore token-user identity validation。只加入`ORDER BY`不構成修正。

**Verification：** Sequential不同user login、Double Login與restart restore、existing database含多個`auth_user` rows、migration或restore-time cleanup、Logout與正常single-user restore regression。

---

### M18-P02 — Catalog foreign key未在production connection啟用

**Disposition：** Approved remediation

**Target phase：** 18-7

**Decision：** 啟用production connection foreign-key enforcement，並明確處理upgrade前existing orphan rows。不得只加入`PRAGMA foreign_keys = ON`而忽略既有不一致資料。

**Verification：** Fresh install與upgrade connection的`PRAGMA foreign_keys = 1`、cascade、orphan insert rejection、existing orphan cleanup或明確rejection contract，以及Catalog完整regression。

---

### M18-C01 — 缺少tracked Flutter platform scaffold

**Disposition：** Approved remediation + capability downgrade

**Target phase：** 18-7 implementation；18-8 final validation

**Decision：**

```txt
Android  Supported target
iOS      Dependency-ready
Web      Dependency-ready
Windows  Dependency-ready
macOS    Dependency-ready
Linux    Dependency-ready
```

18-7只建立tracked Android scaffold與必要native baseline，不建立其他五平台runner。Android只有在18-8取得release artifact與runtime smoke後才能正式標記Supported；若驗證失敗則降為Verification pending或Scaffold only，且不得發布高於證據的claim。

**Verification：** Tracked Android scaffold、application ID、min SDK、manifest與network permission、plugin registration、sqflite、SharedPreferences、path_provider初始化、release APK或AAB，以及bootstrap、Mock login、navigation、Catalog、Theme / Locale、restart restore與logout smoke。

---

### M18-D01 — README企業模板定位未揭露無可執行platform project

**Disposition：** Approved remediation，與M18-C01共用同一platform disposition

**Target phase：** 18-8

**Decision：** README首頁、Quick Start、`flutter run`與platform matrix必須以Android Supported target及其他平台Dependency-ready為準。若Android最終驗證未達Supported，README必須同步降級，不得保留可直接執行的暗示。

**Verification：** README首頁與capability matrix一致、Quick Start命令可在承諾host / device執行、未承諾平台明確標示Dependency-ready與前置生成責任。

---

## 3. Deferred list

### M18-D02 — 早期Web scaffold / runtime evidence terminology

**Disposition：** Deferred to final documentation

**Target phase：** 18-8

**Rationale：** 最終platform capability需先由18-7與18-8 evidence確定。Current authoritative documents與Decision 014補充current evidence clarification；歷史CHANGELOG與archive原則上保留，不全面改寫。

**Verification：** README、Project Context、Roadmap current summary與ADR clarification使用一致的component / scaffold / artifact / runtime terminology。

---

### M18-D03 — Backlog混列已完成與未完成能力

**Disposition：** Deferred to final documentation

**Target phase：** 18-8

**Rationale：** 不影響runtime或18-7 production remediation。Final documentation時整理為Future ideas、Deferred commitments與explicitly not planned，completed items移至Roadmap、Project Context或archive。

**Verification：** Backlog不再把已完成能力列為future work。

---

## 4. Accepted-risk list

無。所有P1均核准修正或platform capability降級，沒有以Accepted risk放行。

---

## 5. Not-an-issue list

無。Phase A沒有正式finding在Gate被判定為Not an issue。

---

## 6. Capability downgrade list

下列平台維持Dependency-ready，不進入18-7 runner或artifact scope：

```txt
iOS
Web
Windows
macOS
Linux
```

這不是宣告永久不支援，而是本次Template Baseline不承諾application support。未來可另開Milestone逐平台提升能力。

Android為唯一Supported target候選；在18-8驗證完成前仍不得視為已Supported。

---

## 7. 18-7 approved work order

```txt
18-7A  Auth lifecycle latest-intent ordering（M18-R01）
18-7B  Auth single-active-user persistence（M18-P01）
18-7C  Catalog foreign-key enforcement（M18-P02）
18-7D  App / Feature boundary remediation（M18-A01、M18-A02）
18-7E  Android platform scaffold與application smoke foundation（M18-C01）
```

每個子階段需獨立review與targeted regression。不得因Android scaffold加入Native Flavor、Firebase、Crashlytics、CI/CD或其他五平台runner。

### 18-7A implementation progress

18-7A已完成並通過review，`M18-R01`正式Resolved。`AuthStateMutationCoordinator`提供lifecycle generation lease；restore、login與logout開始時取得operation，較新的command會使舊operation失效。外部權威Session clear也會invalidate舊operation。Repository在remote completion、persistence mutation與runtime Session commit前驗證lease；被取代時丟出`AuthLifecycleOperationSuperseded` control flow，AuthBloc靜默忽略舊結果，不轉成Failure或覆蓋較新UI。

Logout在進入exclusive cleanup前可被取代；cleanup一旦開始會完整執行user與token cleanup，但只有current Logout可清runtime Session。Regression涵蓋Double Login、Login + Logout、Restore + Login UI ordering、external Session clear，以及Logout cleanup與較新Login交錯。Workspace五個package analyze與389項tests全數通過。下一步為18-7B Auth single-active-user persistence。

### 18-7B reviewed outcome

18-7B已完成並通過review，`M18-P01`正式Resolved。SQLite schema升至version 5，`auth_user`改為固定`slot = 1`的single-active-user record；future writes以同一slot replace，schema直接拒絕非法slot與額外active row。v4 upgrade若只有一列則保留row structure，但legacy token因缺少identity binding仍會在首次restore安全登出；若存在multi-row則直接清空。

`StoredAuthTokens`新增stable `userId`，login與refresh rotation均持續保存identity。Restore與Refresh都只接受token `userId`與persisted / runtime user一致的資料；legacy或mismatch token不會呼叫refresh remote，並清除token、user與runtime Session。Regression涵蓋Sequential Login A → B → restart restore B、existing multi-row + token upgrade後restore cleanup及schema constraint。五個workspace package analyze與400項tests全數通過。下一步為18-7C Catalog foreign-key enforcement。

### 18-7C implementation progress

18-7C已完成實作，尚待review。App-owned database open configuration新增`AppDatabaseSchema.onConfigure`，production DI在每次開啟SQLite connection時啟用`PRAGMA foreign_keys = ON`。Schema升至version 6，v5以前upgrade會清除沒有對應parent page的既有Catalog item rows。

Regression涵蓋fresh connection pragma、parent delete cascade、orphan insert rejection、v5 existing orphan cleanup、`foreign_key_check`與Mock / Real DI graph實際connection。Workspace五個package analyze與402項tests全數通過。`M18-P02`仍待18-7C review後才可改為Resolved。

---

## 8. Baseline release decision

```txt
Current baseline         1.1.0
Release now              No
Provisional candidate    1.2.0 MINOR
Final decision           18-8
```

1.2.0只是provisional candidate。只有在approved remediation、完整regression、Android artifact / runtime evidence與final documentation完成後，18-8才可決定發布。

若Android未達Supported、P1未Resolved或文件能力高於證據，則維持1.1.0並記錄不發布理由。

---

## 9. Gate conclusion

Audit Review Gate通過。Phase A結束，允許進入18-7 Approved Remediation，但只限本文件列出的scope。

Production code、tests與Android scaffold可從18-7開始修改；VERSION仍維持1.1.0，直到18-8 final decision。
