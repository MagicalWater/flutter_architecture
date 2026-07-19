# Milestone 18-5 — Test Capability Matrix

## 狀態

Reviewed / Closed；尚未進入remediation。

本文件彙總18-1至18-4已收集的test evidence，將模板能力映射至unit、repository、Bloc、SQLite、Widget、Golden、integration與platform build。所有正式finding的唯一Single Source of Truth為`docs/audits/milestone_18/findings.md`。

---

## 1. Regression inventory

Audit host：Windows，Flutter 3.41.6 stable，Dart 3.11.4。

Tracked test files：53。

```txt
apps/flutter_architecture  38 files
packages                   15 files
```

完整workspace命令：

```txt
dart run melos exec --concurrency=1 -- "flutter test"
```

結果：5個workspace packages全部通過，共382個test cases。

```txt
api_client             43
auth                   42
core                    4
design_system          43
flutter_architecture  250
total                 382
```

Repository包含1個Design System gallery golden fixture；沒有`integration_test/`、`test_driver/`或tracked CI workflow。

---

## 2. Coverage classification

本階段使用：

```txt
Complete for declared component contract
  目前明確宣告的component / package contract，其主要正常、failure與重要edge paths均有直接evidence；不代表application runner、device、browser或process-level journey已完成。

Partial
  核心contract有測試，但仍缺跨層、跨process或特定scenario。

Fragile
  主要依賴implementation detail、單一host或間接證據。

Duplicate
  多層測試重複同一contract，收益低於維護成本。

Missing
  已承諾能力沒有對應test evidence。

Intentionally unsupported / deferred
  capability尚未承諾，或已由Roadmap明確Deferred。
```

---

## 3. Capability matrix

| Capability | Unit / component | Repository / SQLite | Bloc / stream | Widget / golden | Integration / platform | Assessment |
|---|---|---|---|---|---|---|
| Config與Mock / Real DI | config parsing與selector | DI graph建立 | N/A | App smoke | 無platform runner | Partial |
| Exception / Failure | mapper、Result、sensitive `toString` | expected / unknown propagation | Bloc observer與loading cleanup | localized failure surfaces | global hook component tests，無real runner | Complete at component level |
| Bootstrap | fatal guard、hook installer、Theme / Locale restore | DI dependencies分別驗證 | N/A | App smoke | 無完整production `bootstrap()` orchestration test | Partial |
| Auth login / restore / logout | repository compensation與typed failure | split-store fake boundary | 個別AuthBloc flows | Login UI與callback | 無跨Bloc / persistence full journey | Partial；`M18-R01`、`M18-P01` |
| Concurrent 401 / refresh / replay | request eligibility與metadata | token rotation / invalidation | single-flight與session generation | N/A | Dio adapter component integration；無application runner integration | Complete for package / adapter contract |
| Profile / Guard | mapper與repository | Session identity checks | stale response、account switch | Profile states | Guard tests存在，無完整expiration navigation journey | Partial |
| Catalog initial / SWR | mapper與repository policy | SQLite page round-trip、cache fallback | debounce、switching、generation | loading / error / empty / content | 無page→repository offline journey | Strong partial |
| Catalog refresh / append | repository chain policy | transaction、rollback、migration、revision、corruption | exhaust、cancellation、late result、cursor cycle | refresh lifecycle | 無real app offline runtime | Complete for repository / Bloc / SQLite component contract |
| Theme / Locale | codec、store、controller、resolution | SharedPreferences adapters | serialized writes | selector runtime switching、render matrix | bootstrap分別測試，無platform persistence smoke | Strong partial |
| Design System | tokens、registry、ThemeData contract | N/A | N/A | primitive、state surfaces、accessibility、1 golden | golden只在目前host render | Complete for declared component contract |
| Platform capability | conditional initializer static design | Windows-host FFI component tests | N/A | N/A | 六平台均無artifact / runtime tests | Missing for application platform support；`M18-C01` |

---

## 4. Strong coverage areas

### Refresh與Replay

並行401 single-flight、舊Session隔離、token rotation、invalid / temporary refresh、request replay eligibility、unsafe body與second 401均有直接測試。這是目前最完整的跨package runtime contract之一。

### Catalog persistence與concurrency

LocalDataSource、Repository與Bloc分層涵蓋transaction rollback、stale-while-revalidate、query switch cancellation、Refresh / Append ordering、cursor cycle、chain revision、migration與corruption cleanup。雖缺少real application journey，但component correctness evidence強。

### Failure與reporting

Expected operational failure、unexpected error、reporter failure isolation、Flutter / Platform hooks、Bloc deduplication、non-fatal degraded reporting與sensitive diagnostic contract均有direct tests。

### UI與Design System

主要頁面涵蓋state surface、narrow viewport、large text、Theme matrix與English / `zh_TW` runtime switching；Design System另有單一gallery golden，用於視覺baseline而非建立大型golden suite。

---

## 5. Coverage gaps mapped to findings

### Shell startup ownership

- 缺少防止Shell再次跨Feature import AuthBloc的architecture regression，以及startup ownership調整後的Shell / Auth restore組合測試。
- 對應`M18-A01`。

### Architecture navigation boundaries

- Login成功切Profile tab與Profile logout切Login tab缺少跨feature integration test。
- 對應`M18-A02`，不建立新的test-only finding。

### Auth lifecycle ordering

- 缺double Login反向完成、Login + Logout反向完成與Restore + Login transient ordering tests。
- 對應`M18-R01`。

### Auth persisted identity

- 缺不同user sequential login後restart restore、existing multi-row upgrade / cleanup與identity validation tests。
- 對應`M18-P01`。

### SQLite connection contract

- 缺fresh schema snapshot、production-style foreign key pragma、cascade、orphan rejection與existing orphan handling tests。
- 對應`M18-P02`。

### Platform application capability

- 目前六平台都缺tracked runner、artifact build、plugin registration與runtime smoke。
- 對應`M18-C01`，不是單純增加`integration_test`即可解決。Gate列為Supported target的平台必須補artifact與runtime verification；維持Dependency-ready的平台不要求application tests，但文件不得宣稱Supported。

### Bootstrap orchestration

- 缺少單一測試驗證完整production `bootstrap()`順序、hook installation、DI、preference restore與`runApp`條件。
- 此缺口維持Partial，不建立formal finding：各子契約與source ordering已有直接evidence，尚未發現observed correctness defect。
- 若Gate承諾可執行platform baseline，應納入18-7或18-8的application smoke verification。

### Catalog offline application journey

- 缺少Page → Bloc → Repository → SQLite cache → offline fallback的完整application journey。
- 此為application matrix gap，不代表已確認新的Catalog correctness defect；是否補測取決於`M18-C01`的正式平台scope。

---

## 6. Cross-layer integration assessment

目前多數測試是高品質component integration：使用real SQLite FFI、real Bloc stream、real widget tree或Dio adapter，但沒有可執行platform runner，所以不存在真正的device / browser application integration test。這些component integration evidence不得外推為plugin registration、application lifecycle或platform runtime evidence。

Phase B若建立正式承諾平台，最低journey應包含：

```txt
App bootstrap
  → Mock login
  → guarded/profile navigation
  → Catalog load / refresh
  → Theme / Locale mutation
  → restart restore
  → logout
```

這個journey不能取代現有精細component tests；它負責驗證Composition Root、plugin registration、persistence path與navigation組合。

---

## 7. Golden strategy

目前只有Design System gallery golden，搭配大量semantic/widget matrix。對模板現階段而言屬刻意的最小golden策略：

- 避免每個feature建立高維度Theme × Locale × viewport golden。
- 以Widget assertions驗證interaction、semantics與layout。
- 以單一gallery fixture鎖定primitive與page-state視覺baseline。

未發現需要建立正式finding的golden缺口。若Phase B新增platform runner，可再評估字型、renderer與host差異，不應直接複製完整screen golden matrix。

---

## 8. CI / automation

Repository沒有tracked CI workflow，但Roadmap與Backlog已明確將Milestone 11 CI/CD標記為Deferred。README提供canonical workspace test command，且本次手動完整regression可重現通過。

因此CI absence分類為Intentionally deferred，不建立Milestone 18 finding。若Audit Review Gate決定新baseline必須具備automatic verification，應重新開啟Milestone 11或納入18-7 approved remediation，而不是假設目前已有CI capability。

---

## 9. Duplication與fragility scan

- Theme / Locale、Design System與feature widgets有部分render matrix重疊，但各自鎖定不同ownership boundary，未形成明顯低價值duplicate suite。
- App tests大量使用Flutter test host；這是component evidence，不可外推為platform runtime。
- Golden依賴目前host renderer，應維持單一fixture並在未來CI固定host，不擴張成大量脆弱goldens。
- 沒有以coverage percentage作為品質代理；本階段以risk-to-evidence mapping評估。

---

## 10. 18-5 conclusion

現有test foundation成熟，完整workspace regression為382 tests全數通過。主要優勢是critical concurrency、persistence與failure boundaries有直接evidence；主要缺口是既有findings對應的Auth ordering / identity、foreign key connection contract，以及完全缺少platform application artifact與runtime journey。

本階段沒有新增正式finding。Auth、architecture、persistence與platform缺口由`M18-A01`、`M18-A02`、`M18-R01`、`M18-P01`、`M18-P02`與`M18-C01`承載；Bootstrap orchestration與Catalog offline full journey屬未觀察到production defect的application matrix gaps，待正式平台scope決定是否納入18-7 / 18-8；CI/CD則屬明確Deferred。

本階段只完成audit、review與落檔，不修改production或test code。下一步為18-6 Documentation & Provisional Baseline Assessment。
