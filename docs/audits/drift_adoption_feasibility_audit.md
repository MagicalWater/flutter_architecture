---
document_type: planning-review
status: proposed
authoritative_for:
  - drift-adoption-feasibility-evidence
last_reviewed_baseline: 1.10.0
---

# Drift Adoption Feasibility Audit

## 1. Audit scope

本文件評估 Template Baseline 1.10.0 是否應將目前的 sqflite persistence architecture 遷移至 Drift。

本次只做 capability inventory、repository-specific feasibility analysis 與 disposition；沒有修改 production persistence implementation、沒有新增 Drift dependency，也沒有建立 Milestone 29。

評估依據：

- repository current source、schema、tests、DI、platform initializer 與既有 audit／ADR。
- 2026-07-24 查核的 Drift、drift_flutter、sqflite、sqflite_common_ffi、sqflite_common_ffi_web 與 sqlite3 官方文件／pub.dev metadata。
- 通用 Enterprise Architecture Template 的重用性、AI-assisted development、型別安全、migration reliability、跨平台支援與 maintenance burden。

## 2. Workspace and baseline confirmation

| Item | Confirmed state |
|---|---|
| Workspace | `/Users/water/Developer/projects/flutter_architecture` |
| Branch | `main` |
| Remote sync | `HEAD`、`origin/main`、`origin/HEAD` 均為 `ecccd0f` |
| Worktree | Clean |
| Baseline | `1.10.0` |
| Current database file | `flutter_architecture.db` |
| Schema version | `6` |
| Production database dependencies | `sqflite ^2.3.3+1`、`sqflite_common_ffi ^2.3.6`、`sqflite_common_ffi_web ^1.1.1` |
| Drift dependencies | None |

## 3. Current persistence capability inventory

### 3.1 Lifecycle and Composition Root

- App 是唯一 Composition Root。
- `bootstrap.dart` 先依 conditional import 初始化 platform database factory。
- Android／iOS 使用 sqflite 原生 implementation。
- Windows／macOS／Linux 由 `sqflite_common_ffi` 設定全域 `databaseFactoryFfi`。
- Web 由 `sqflite_common_ffi_web` 設定 `databaseFactoryFfiWeb`。
- `RegisterModule.database` 是唯一 production open boundary：以 `getDatabasesPath()` 與固定 filename 開啟 DB，套用 schema version、`onConfigure`、`onCreate`、`onUpgrade`，再把同一個 `Database` singleton 注入 Auth 與 Catalog。

此設計的優點是 platform implementation 與 reusable package 隔離，缺點是 App feature data source 仍直接綁定 sqflite `Database`／`DatabaseExecutor` API。

### 3.2 Schema ownership

`AppDatabaseSchema` 是目前 schema 與 migration 的唯一 production owner。共有三張 table、一個 explicit index：

1. `auth_user`
   - single active row：`slot INTEGER PRIMARY KEY CHECK (slot = 1)`。
   - `id TEXT NOT NULL UNIQUE`。
   - `name TEXT NOT NULL`。
2. `catalog_cache_page`
   - composite primary key：`query, request_cursor, request_limit`。
   - 保存 `next_cursor`、`updated_at`、`chain_revision`。
3. `catalog_cache_page_item`
   - composite primary key：page identity + `item_id`。
   - composite foreign key 指向 page，`ON DELETE CASCADE`。
4. `catalog_cache_page_item_position_idx`
   - page identity + `item_position` 的 unique index。

`PRAGMA foreign_keys = ON` 在每次 open 的 `onConfigure` 執行。

### 3.3 Migration history

目前 schema version 6：

- v1：AuthUser。
- v2：Catalog cache tables。
- v3：清除重複 position 並將舊 index 升為 unique index。
- v4：加入 `chain_revision`。
- v5：AuthUser 轉為 single-active-row；只有舊表恰有一筆資料時保留，其他情況安全清空。
- v6：清除 foreign-key 啟用前可能留下的 orphan item。

Migration 寫法具備 idempotent／defensive elements，例如 sqlite_master、`PRAGMA table_info`、`DROP INDEX IF EXISTS`、orphan cleanup，但不是 declarative schema snapshot system。

### 3.4 AuthUser persistence

- `packages/auth` 只定義 `AuthUserStore` abstraction，不依賴 sqflite。
- App adapter `SqfliteAuthUserStore` 直接接收 `Database`。
- read／write／clear 都以 slot 1 操作。
- sqflite `DatabaseException` 會轉為 typed local-storage `AppException`。
- credential token authority 不在 SQLite；token pair 位於 Flutter Secure Storage。

因此 Auth package boundary 已隔離良好，但 App adapter implementation 仍與 sqflite API 綁定。

### 3.5 Catalog Offline Cache

- `CatalogLocalDataSource` 直接依賴 `Database`。
- 使用 explicit query、transaction、composite identity、chain revision 與 corruption cleanup。
- first-page replacement、append linked validation、cursor cycle prevention 與 lazy cleanup 是 imperative domain-specific transaction logic。
- entity／domain mapping 位於 feature data layer，沒有把 sqflite row map直接洩漏到 Repository 或 Bloc。
- Catalog cache 是 public cache，Logout 不清除。

這是目前 sqflite coupling 最大、也最可能從 typed SQL／generated row mapping 得益的區域；但它的主要複雜度來自 cursor-chain correctness，而不是 CRUD boilerplate。

### 3.6 Transactions, batch, index, foreign key and concurrency

- Catalog write／cleanup 使用 sqflite transaction。
- 現有 production source未使用 batch；item insert 在 transaction 內逐筆執行。
- 使用 composite PK、composite FK、cascade delete 與 unique position index。
- Auth write使用 `ConflictAlgorithm.replace`。
- Catalog 也使用 replace，但另外顯式刪除 child rows以維持 replacement semantics。
- concurrency correctness主要由 transaction + chain revision + repository／Bloc request generation管理，不依賴 reactive database stream。

### 3.7 Tests and evidence

主要 coverage：

- DB open、DI resolution、foreign key enforcement。
- v5 → v6 orphan cleanup。
- v1／v4 AuthUser historical migration、single-active-row invariant與 malformed legacy state disposition。
- v1／v2／v3 Catalog historical migration、index replacement、chain revision。
- AuthUser adapter read／write／clear與 database failure mapping。
- Catalog read／write／replace／append linking／cycle／corruption／expiration／logout persistence。
- Repository cache-first、SWR 與 degradation behavior。

目前 evidence 主要是 in-memory／temporary SQLite tests及 Android／iOS build/runtime paths。Windows、macOS、Linux、Web仍是 dependency-ready，沒有 tracked runner runtime acceptance。

### 3.8 Direct sqflite dependency surface

Production direct dependencies集中於：

- `app_database_schema.dart`
- `database_initializer_io.dart`
- `database_initializer_web.dart`
- `register_module.dart`
- `sqflite_auth_user_store.dart`
- `catalog_local_data_source.dart`

另有 generated DI file與多個 tests使用 `Database`／`databaseFactoryFfi`。

結論：domain／repository contract大致隔離，但 persistence implementation boundary尚未抽成 App-level database port。遷移不會影響 Bloc／UseCase public API，卻會重寫 schema owner、DI database type、兩個 adapters及大量 database-focused tests。

## 4. Official package capability findings

### 4.1 sqflite family

- sqflite官方支援 Android、iOS、macOS，transactions、batches及 mobile background-thread execution。
- Linux／Windows／Dart VM由 `sqflite_common_ffi` 提供；新版本以 sqlite3 3.x／native build hooks改善 Windows native library setup。
- Web由 `sqflite_common_ffi_web` 提供 persistence、worker與Wasm，但官方 README 仍明確標示 experimental、slow、not fully tested、存在 bugs與部分功能限制。

### 4.2 Drift family

- Drift是 Dart-first reactive relational persistence library，支援 Android、iOS、Linux、macOS、Web、Windows。
- `drift_flutter` 提供六平台共用 opener；native可指定 database path，Web使用 Drift Wasm storage selection。
- Drift提供 typed tables／queries、SQL static analysis、generated data classes、migration APIs、schema export與migration testing工具。
- Drift可透過自訂 native path開啟既有 SQLite file；SQLite file format本身相容，但 table／column name、constraints、schema version與migration callback必須由 repository精確對齊。
- Drift reactive query是 opt-in；可以只使用 one-shot `get()`／transaction，不必把 stream帶入 Repository／Bloc。
- Drift native opener可使用 background isolate；這會改善 UI isolate isolation，但也增加 connection lifecycle、debugging與test setup的概念成本。

## 5. Repository-specific sqflite vs Drift

| Dimension | Current sqflite | Drift in this repository |
|---|---|---|
| Architecture consistency | 已符合 App-owned Composition Root | 可維持，但必須避免 Drift class進入 reusable packages |
| Type safety | row map與cast靠 runtime tests | table／row／query大幅提升 compile-time safety |
| SQL static validation | 無 | 明顯改善 raw SQL與schema reference |
| Schema ownership | 單一手寫 schema file，直觀 | generated schema + migration contract，authority更強但更重 |
| Migration safety | 已有實測歷史 migration | 可加 schema snapshots與step-by-step validation，但轉換本身有風險 |
| Existing DB compatibility | 已證實 | 技術上可保留同一 file；需 exact schema contract spike確認 |
| Reactive queries | 無；符合 explicit refresh authority | 對 AuthUser與目前 Catalog flow價值低，預設啟用反而複雜 |
| Testing | FFI in-memory簡單、現有coverage成熟 | typed test DB與migration tooling較強，但需重寫大量fixtures |
| Cross-platform library capability | mobile穩定；desktop需`ffi` factory；Web implementation官方仍標示experimental | Android、iOS、Windows、macOS、Linux、Web均為正式支援平台，並提供跨平台opener；Web仍受瀏覽器storage／worker能力限制 |
| Repository verification status | Android／iOS已有tracked runtime evidence；其他平台僅dependency-ready | 採用後仍需補repository runtime evidence，但這是模板驗證工作，不是Drift平台能力缺口 |
| Background isolate | mobile plugin自行處理；desktop語意不同 | Drift可統一 isolate strategy，但增加 lifecycle責任 |
| Generated code | 無DB generated code | 增加 `drift_dev`、build_runner輸出與generated consistency gate |
| Build／CI cost | 低 | 增加 code generation、cache invalidation與generated diff checks |
| Debugging | SQL與row map直接 | generated stack、query expression與isolate messaging需學習 |
| AI error protection | SQL typo／column cast容易漏到runtime | schema／query compile-time feedback明顯較佳 |
| Template learning cost | Flutter開發者普遍易懂 | adopters需理解 table DSL、companions、migration、streams、generation |
| Template scalability | 目前範例規模易讀，但採用者擴充後需自行承擔manual SQL與migration治理 | 可把typed schema、SQL validation與migration tooling作為模板預設能力，價值不能以目前示範table數量衡量 |
| Rollback | 現況無migration成本 | 一旦 Drift migration發布，rollback需雙向 schema／data strategy |

## 6. Option analysis

### Option A — Maintain sqflite

優點：

- 零production migration risk。
- 保留成熟的 migration、Auth lifecycle與Catalog correctness tests。
- 不增加 generated source、build time、native dependency與學習成本。
- 目前範例schema小，短期manual schema ownership仍可控。

缺點：

- SQL／column／row mapping錯誤仍主要在runtime發現。
- Desktop／Web平台分工與initializer branch持續存在。
- Web仍依 experimental implementation。
- schema snapshot／migration consistency需自行維護。

風險：本repository是提供未來專案擴充的模板，而不是只服務目前三張示範table；若以current sample size決定baseline，會低估採用者在中大型專案中的typed schema、SQL validation與migration tooling需求。

### Option B — Drift only for new feature opt-in

優點：新feature可試用typed persistence而不碰現有data。

缺點／風險：

- 同一App同時存在兩套DB framework、兩種migration authority、兩套testing與error semantics。
- 若使用同一SQLite file，schema version ownership衝突；若使用不同file，backup／cleanup／diagnostic更複雜。
- 對通用模板會形成「選哪套都可以」但缺乏單一推薦路徑的治理負擔。

Disposition：不建議作為正式baseline策略。只適合 isolated spike，不適合作為長期雙軌production architecture。

### Option C — SQLite-file-compatible gradual Drift migration

優點：

- 可先用 Drift custom query／existing schema接管單一table或DAO。
- 可保留 database file與data。
- 降低一次重寫所有query的風險。

缺點／風險：

- sqflite與Drift同時開啟同一file時有connection、transaction與schema ownership風險。
- migration期間兩套 API、exception、test fixture並存。
- 「漸進」不等於容易回滾；任何 schema version owner切換都必須是明確 cutover。

Disposition：只有在正式決定遷移後才合理；應以 phase-by-phase source conversion、single database owner cutover完成，而不是長期雙框架共存。

### Option D — One-shot full migration

優點：完成後架構單一、generated schema與typed query收益完整。

缺點／風險：

- 同時重寫open lifecycle、schema、migration、Auth adapter、Catalog complex transactions、tests與platform setup。
- 最難區分 framework migration bug與原有cursor-chain business invariant regression。
- 現有production surface較小，反而可能使現在成為一次性切換成本最低的時間點；但仍需先用歷史fixture驗證相容性。
- rollback與existing DB acceptance要求最高。

Disposition：不能再僅以current table數量否決。若isolated spike證明歷史database相容、schema等價與CI成本可接受，應與Option C一起進入正式方案比較。

## 7. Special verification results

### Existing SQLite file

Confirmed at capability level：Drift native可指定現有DB path並開啟SQLite file，不要求專有file format。

Not repository-runtime-confirmed：尚未以本repository v1–v6 fixture執行 Drift opener、schema validation與write/read round-trip。因此不能宣稱無風險直接切換。

### Schema expressiveness

AuthUser與Catalog schema均可由Drift table／custom SQL表達，包括 composite PK、composite FK、check、unique index、default與cascade delete。

需要特別驗證的細節：

- generated table／column名稱必須與現有snake_case完全一致。
- `slot = 1` check與single-row replacement semantics。
- composite foreign key與unique position index的generated SQL等價性。
- `ConflictAlgorithm.replace`對parent／child與cascade的實際行為。

### Migration contract conversion

現有v1–v6 imperative migration可轉為 Drift `MigrationStrategy`／step-by-step migration，但不能只把current schema declarative化；歷史cleanup、conditional table detection與malformed-state disposition必須保留。

### Mapper／DAO simplification

- AuthUser：可明顯減少row cast與table／column string。
- Catalog：可減少row parsing與部分CRUD boilerplate。
- 但 cursor-chain traversal、generation check、cycle prevention、corruption policy與SWR authority不會因Drift消失。

整體判定：Drift會消除一部分mechanical risk，但不會簡化Catalog最重要的domain-specific complexity。

### Web and desktop

- Drift本身正式支援Android、iOS、Windows、macOS、Linux與Web；`drift_flutter`提供依目前平台選擇native或Web implementation的共用opener。
- Repository目前把Web／Desktop列為dependency-ready，只代表尚未建立tracked runner與runtime acceptance，不能解讀為Drift不支援這些平台。
- 採用Drift不會自動讓repository取得Supported宣稱，因為該宣稱仍需要本專案自己的build／runtime evidence；但Drift的六平台一致API與正式Web路徑，確實是模板層級的實質優勢。
- 現有`sqflite_common_ffi_web`官方仍明列experimental、slow、not fully tested與bugs；相較之下，Drift Web有正式platform documentation、browser compatibility matrix與storage fallback說明。這項差異應提高Drift的採用權重，而不是等到Web先被本repository標為Supported後才評估。

### Reactive query and Bloc authority

目前Auth restore與Catalog refresh authority都是explicit command／repository result。導入Drift stream沒有明確產品需求，可能導致：

- DB change stream與remote refresh completion形成雙authority。
- Bloc event ordering與SWR presentation更難推理。
- Logout／relogin／query generation需新增stream subscription lifecycle。

因此即使未來採用Drift，baseline也應預設one-shot query；只有真正需要local live view的feature才opt in stream。

## 8. Confirmed findings

1. 現有persistence範例規模小、schema owner單一、migration已有實際歷史coverage；但table數量只描述目前template sample，不能代表採用者最終專案規模。
2. Reusable `auth` package沒有依賴sqflite；主要coupling位於App Composition Root與兩個App feature adapters。
3. Drift可在技術上保留同一SQLite file，並能表達目前schema。
4. Drift對typed query、SQL validation、generated row mapping與migration tooling有真實價值。
5. Drift reactive query對目前Auth／Catalog flow沒有已證實價值。
6. Drift不會消除Catalog cursor-chain的核心複雜度。
7. 現有sqflite Web implementation仍由官方標示experimental；Drift正式支援六平台，且跨平台setup與database API較一致。
8. 目前沒有足夠repository runtime evidence證明v1–v6 data可零風險切換。
9. 先前以「目前只有3 tables」判定收益不足不成立；對模板應評估未來中大型專案的預設路徑，而現有surface較小也可能代表現在是遷移成本最低的時點。

## 9. Assumptions and unverified items

- 未執行 isolated Drift spike。
- 未以真實／fixture v1–v6 database file進行Drift open與schema diff。
- 未量測Drift code generation與CI wall-clock增加量。
- 未在Windows／Linux／Web執行兩方案runtime comparison。
- 未驗證Drift 2.34.x與repository exact Flutter／Dart toolchain的完整dependency resolution。
- 未驗證Web從`sqflite_common_ffi_web` IndexedDB naming／storage轉移至Drift Wasm storage的data migration；兩者不能僅因底層皆為SQLite就假設browser persistence直接相容。

以上事項會直接影響正式go／no-go，尤其是existing database compatibility、Web storage transition與generated／CI成本。未完成isolated spike前，不應宣告migration no-go，也不應宣告production migration go。

## 10. Recommendation

修正後的正式建議：

```text
先撤回原本的D／NO-GO結論。
進入isolated Drift compatibility spike，再於Option C與Option D之間做正式選擇。
```

在spike完成以前，production implementation仍維持Option A，且不得建立長期雙framework production path；但這只是調查期間的暫時狀態，不是最終adoption disposition。

理由：

- 本repository是中大型Flutter專案模板，不能以目前示範schema規模推論未來採用者的database複雜度。
- Drift的typed schema、SQL static validation、migration tooling與六平台一致API，均是template-level能力，而不只是目前Auth／Catalog兩個feature的局部收益。
- Drift正式支援Web與Desktop；repository尚未對這些平台建立runtime evidence，只影響本模板的support claim，不減損套件能力與架構價值。
- 現有surface較小，可能使現在成為切換成本最低、最容易建立完整historical fixture acceptance的時間點。
- reactive query不是現有架構需求。
- 是否採Option C或D，必須由v1–v6 file compatibility、schema equivalence、Web storage disposition及CI成本的isolated spike決定。

## 11. Not recommended

- 不建議Option B長期雙軌：會建立兩套schema authority與adopter ambiguity。
- 不再預先排除Option D；目前surface小可能讓一次性cutover比長期漸進雙軌更安全。
- 不建議現在以「Drift較熱門」或download數作為Milestone promotion依據。
- 不建議為預防未來遷移而先建立generic database abstraction；目前domain store／repository boundary已足以隔離business layer。

## 12. Re-evaluation triggers

下列項目不再是「未來才重新評估」的門檻，而是本次spike與最終方案比較應納入的決策因素：

1. 預期採用者的table、relation、join與migration複雜度，而不是目前sample table count。
2. SQL／column mapping／migration defect開始逃過tests並進入runtime。
3. 出現需要complex join、aggregate、full-text search或大量dynamic query的正式feature。
4. 出現真正需要local reactive view／multi-screen live database state的feature。
5. Drift與sqflite在Web／Desktop的runtime、storage、worker與deployment差異；不要求repository先提升為Supported才有評估價值。
6. 需要統一background isolate database execution，現有platform差異造成可量測問題。
7. CI可接受新增generated schema consistency gate，且build time成本已量測。
8. 可先完成isolated spike，證明v1–v6 file compatibility、schema equivalence、migration fixture與rollback策略。
9. 新專案採用者回饋顯示manual SQL學習／錯誤成本高於Drift generated workflow。

## 13. Future spike entry and exit criteria

下一步應建立與production source隔離的spike，不直接切換dependency authority。

必驗項目：

- 複製v1、v2、v3、v4、v5、v6 fixtures。
- Drift以相同filename／path開啟並升級至current schema。
- `sqlite_master`、`PRAGMA table_info`、`foreign_key_list`、index與`user_version`最終一致。
- Auth single-row、Catalog chain、orphan cleanup與corruption semantics全部通過。
- Android、iOS、macOS、Windows、Linux、Web至少完成dependency／runtime matrix；Supported claim另依repository platform policy判定。
- 量測generation、analyze、test、representative build時間。
- 明確single-owner cutover與rollback procedure。

退出條件：任何歷史fixture data loss、schema mismatch、Web storage incompatibility未有disposition、或CI成本未被接受，均回到sqflite baseline。

## 14. Severity and revised disposition

```text
Open P0: 0
Open P1 without disposition: 1
P1: Drift compatibility spike尚未完成，無法做最終Option C／D判定
Migration Milestone: PENDING SPIKE RESULT
Production Drift dependency: NO
Final disposition: PRIOR NO-GO WITHDRAWN
Current production baseline during audit: Maintain sqflite temporarily
Next disposition: Execute isolated compatibility spike, then decide gradual or one-shot migration
```

原NO-GO把目前sample schema規模當成template adoption的主要成本／收益依據，並把repository support classification與Drift library platform support混為一談，因此結論無效。本文件降回proposed，待isolated spike完成後重新審查並關閉P1。

## 15. External references checked on 2026-07-24

- Drift documentation: `https://drift.simonbinder.eu/`
- Drift package: `https://pub.dev/packages/drift`
- drift_flutter package: `https://pub.dev/packages/drift_flutter`
- sqflite package: `https://pub.dev/packages/sqflite`
- sqflite_common_ffi package: `https://pub.dev/packages/sqflite_common_ffi`
- sqflite_common_ffi_web package: `https://pub.dev/packages/sqflite_common_ffi_web`
- sqlite3 package: `https://pub.dev/packages/sqlite3`
