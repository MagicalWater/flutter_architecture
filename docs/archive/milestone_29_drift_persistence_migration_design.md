---
document_type: design-spec
status: archived
authoritative_for:
  - milestone-29-drift-persistence-migration-design
last_reviewed_baseline: 1.10.0
---

# Milestone 29 — Drift Persistence Migration Design

## Decision summary

建立下一個正式 Milestone：

```txt
Milestone 29 — Drift Persistence Migration
```

採用已核准的：

```txt
GO — Option D
一次性整體遷移至 Drift
```

「一次性整體遷移」只描述最終 production baseline：完成 cutover 後，Drift 是 App database implementation、schema version 與 migration contract 的唯一 authority。Milestone 內仍必須拆分 compatibility fixture、schema foundation、historical migration、AuthUser、Catalog、platform opener、CI、cutover 與 final acceptance 等獨立 Tasks；不得發布 sqflite／Drift 長期雙軌 production baseline。

## Baseline facts

Milestone 起點：

| Item | Confirmed state |
|---|---|
| Workspace | `/Users/water/Developer/projects/flutter_architecture` |
| Branch | `main` |
| Upstream | `main` 與 `origin/main` ahead/behind = `0/0` |
| Starting commit | `45a2650 docs(database): 拍板整體遷移至Drift` |
| Worktree | Clean |
| Template Baseline | `1.10.0` |
| Database filename | `flutter_architecture.db` |
| Current schema version | `6` |
| Tables | 3 |
| Explicit indexes | 1 unique index |
| Composite foreign keys | 1，`ON DELETE CASCADE` |
| Current production dependencies | `sqflite ^2.3.3+1`、`sqflite_common_ffi ^2.3.6`、`sqflite_common_ffi_web ^1.1.1` |
| Current Web assets | `web/sqlite3.wasm`、`web/sqflite_sw.js` |
| Direct production sqflite surface | database schema／initializer／DI、AuthUser store、Catalog local data source |

## Goals

- 保留 native 既有 SQLite filename、path、schema、歷史資料與`PRAGMA user_version`語意。
- 將 schema、migration、query、transaction 與 database lifecycle authority完整切換至 Drift。
- 以 v1～v6 isolated database fixtures證明 historical compatibility，而不是只驗證新建 v6 database。
- 保留 AuthUser single-active-row、malformed legacy disposition與typed local-storage exception mapping。
- 保留 Catalog page／item、composite identity、cascade、unique position、chain revision、cursor cycle prevention、orphan cleanup與corruption policy。
- 維持 App 是唯一 Composition Root；reusable package不得依賴 Drift implementation。
- Native與Web使用明確、可測且可替換的 opener policy。
- 預設使用 one-shot query；reactive streams只允許 feature 明確 opt in。
- 將 generated code、schema snapshot、migration verification與change-aware CI納入 repository governance。
- 完成 single-owner cutover，移除 production direct sqflite API、失效 dependencies與舊Web assets。
- 以 Android、iOS及其他平台的明確 acceptance disposition收斂 release claim。

## Non-goals

- 重新評估是否採用 Drift。
- 長期保留 sqflite／Drift雙框架 production baseline。
- 建立 generic database repository、generic DAO framework或跨 feature萬用 persistence port。
- 將 Drift data class、DAO或query builder暴露給`packages/auth`、其他 reusable package、Bloc或Domain。
- 因 Drift 支援 stream 而把 Auth restore或Catalog SWR改成 reactive-first architecture。
- 改變 credential authority；token pair仍由 Flutter Secure Storage持有。
- 重設 Catalog cursor pagination、cache TTL、SWR、logout persistence或connectivity revalidation產品語意。
- 因套件能力直接把Web／Desktop提升為本 repository 的 Supported platform。
- 在本 Milestone導入 SQLCipher、database encryption、cloud sync、backup或multi-process write coordination。

## Package and version strategy

### Accepted package roles

| Package | Responsibility | Final production disposition |
|---|---|---|
| `drift` | Runtime database API、typed schema/query、transactions、migration strategy | Required |
| `drift_dev` | Generator、schema export、migration verification tooling | Required dev dependency |
| `drift_flutter` | Flutter-aware six-platform opener helper與native/Web setup | Required，除非 implementation spike證明 custom opener更能維持既有path且不增加分支 |
| `drift_sqflite` | 從既有 sqflite folder／filename接管的官方 migration bridge | Compatibility harness／temporary bridge only；不得成為 final production executor |
| `sqlite3` | Native／Wasm SQLite runtime，亦為 Drift底層能力 | 由 resolved dependency graph使用；只有 repository直接呼叫其 API 時才宣告 direct dependency |

### Version policy

- Plan建立時以 repository exact Dart／Flutter toolchain重新解析最新相容 stable版本，不使用 floating Git dependency。
- `drift`與`drift_dev`維持同一 compatible release line；若 pub solver需要 patch差異，必須由 lockfile與generation驗證證明相容。
- 起始調查參考版本為 Drift 2.34.x、`drift_flutter` 0.3.x、`drift_sqflite` 2.0.1；這不是永久 pin，實際採用版本由 Implementation Plan鎖定。
- `drift_sqflite`已多年未更新且只支援 Android／iOS／macOS，因此只用於 sqflite compatibility acceptance，不作為跨平台最終架構。
- 升級 Drift major／minor時必須重新執行 generated consistency、schema snapshot與migration suite。

## Target architecture

```txt
App bootstrap
  ↓
App-owned Database Opener
  ↓
AppDatabase (Drift schema + migration authority)
  ├─ AuthUser DAO / adapter
  └─ Catalog cache DAO / data source
       ↓
Existing repository and package contracts
```

### Composition Root

- App仍是唯一 Composition Root。
- DI只注入一個長生命週期`AppDatabase` singleton。
- App負責 opener選擇、database lifecycle、close、diagnostics與platform-specific assets。
- `packages/auth`繼續只依賴`AuthUserStore` abstraction。
- Catalog repository／Domain／Bloc不依賴 Drift；Drift只存在App feature data implementation。
- 不新增「為了隱藏 Drift」的無業務價值 generic database interface；既有 store／data-source seam已足夠。

### Database ownership

建議結構：

```txt
apps/flutter_architecture/lib/app/database/
  app_database.dart
  app_database.g.dart
  connection/
    app_database_opener.dart
    app_database_opener_native.dart
    app_database_opener_web.dart
  schema/
    tables/
    migrations/
  dao/
    auth_user_dao.dart
    catalog_cache_dao.dart
```

實際檔案數可在 Plan依 generator與可讀性調整，但 authority必須保持：

- `AppDatabase.schemaVersion == 6`作為初始 Drift cutover版本。
- current schema definition是唯一 schema owner。
- historical migrations是唯一 version transition owner。
- DAO只封裝 persistence mechanics；Catalog chain business invariant仍由 Catalog local data boundary擁有，不可被 generated manager API隱藏。

## Schema contract

### SQL naming

- SQL table／column／index名稱必須與現有 snake_case逐字一致。
- 禁止因 Dart class命名讓 generator產生不同SQL名稱。
- compatibility harness以`sqlite_master`、PRAGMA與normalized SQL比較，不接受「邏輯類似」取代結構等價。

### AuthUser

```sql
CREATE TABLE auth_user (
  slot INTEGER PRIMARY KEY CHECK (slot = 1),
  id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
)
```

必須保留：

- `slot = 1` check constraint。
- single active row。
- `id` unique且non-null。
- read／write／clear只針對slot 1。
- v5 migration只有legacy table恰有一筆時保留；0筆或多筆皆清空。
- malformed row、constraint violation與database unavailable不得被誤判為「沒有登入使用者」。

### Catalog page

- composite primary key：`query, request_cursor, request_limit`。
- `next_cursor` nullable。
- `updated_at` non-null integer。
- `chain_revision` non-null integer，default 0。

### Catalog item

- composite primary key：page identity + `item_id`。
- composite foreign key指向page identity。
- foreign key必須`ON DELETE CASCADE`。
- page identity + `item_position`維持explicit unique index：`catalog_cache_page_item_position_idx`。
- 所有item payload欄位維持目前nullability。

### Foreign-key policy

- 每個connection在任何 migration或query前啟用`PRAGMA foreign_keys = ON`。
- fixture與runtime smoke必須實際驗證 cascade，不只檢查DDL。
- `foreign_key_check`結果必須為空，除非正在測試 v6 orphan cleanup前置狀態。

## Historical migration contract

Drift cutover不新增 schema version；current version仍為6。v1～v6語意逐步重建：

| Version | Contract |
|---|---|
| v1 | 建立legacy AuthUser schema fixture |
| v2 | 新增Catalog page／item與舊position index語意 |
| v3 | 去除重複position，移除舊index，建立unique position index |
| v4 | 新增`chain_revision INTEGER NOT NULL DEFAULT 0` |
| v5 | AuthUser改為single-active-row，僅單筆legacy資料保留 |
| v6 | 清除foreign-key啟用前遺留orphan item |

### Migration implementation policy

- 不能只呼叫`createAll()`或破壞性重建current schema。
- conditional table／column存在檢查、legacy data disposition與cleanup SQL必須保留。
- migration callback內使用 Drift migrator、`customSelect`與`customStatement`的組合，以可讀且可驗證為優先，不強迫全部改成table DSL。
- 每次 migration在transaction內執行；若底層SQLite限制某DDL transaction行為，Plan必須列出確切處理與回滾證據。
- beforeOpen依序執行 foreign-key enable、schema validation／migration，再允許DAO使用。

## Compatibility fixtures and acceptance harness

Task 29-1先建立完全隔離於 production implementation的fixture與harness。每個version至少包含：

```txt
v1.db
v2.db
v3.db
v4.db
v5.db
v6.db
```

Fixture來源必須由 current sqflite historical contract建立或由可審查的固定SQL生成；不得由新的 Drift schema反向生成，避免同源測試。

每個fixture驗證：

1. Drift可以用相同database file開啟。
2. 升級到schema version 6成功。
3. normalized`sqlite_master`table／index集合一致。
4. columns、type affinity、default、nullability與ordinal一致。
5. primary key shape與順序一致。
6. foreign keys、column mapping、cascade一致。
7. indexes、uniqueness與indexed columns順序一致。
8. check／unique constraints一致。
9. `PRAGMA user_version == 6`。
10. `PRAGMA foreign_key_check`為空。
11. AuthUser資料保留與malformed legacy disposition一致。
12. Catalog page／item資料保留。
13. v3 duplicate position cleanup一致。
14. v4 chain revision default與既有資料值一致。
15. v6 orphan cleanup一致。
16. cursor cycle protection、corruption cleanup與read disposition不變。

Harness必須同時支援：

- 以 current sqflite migration產生expected database。
- 以 Drift migration處理copy database。
- 對兩者輸出 canonical schema/data report再diff。
- failure時保留fixture copy與diagnostic report，但不得輸出credential或敏感payload。

Compatibility gate未通過前，不得修改 production database DI authority。

## AuthUser persistence migration

- 新adapter命名改為 implementation-neutral，例如`DriftAuthUserStore`，並實作既有`auth.AuthUserStore`。
- adapter依賴窄`AuthUserDao`或`AppDatabase`，不得讓`packages/auth`看到Drift type。
- write需維持atomic single-row replacement；若`INSERT OR REPLACE`會觸發與現有不同的delete／cascade語意，改用transaction內delete slot + insert／upsert並以fixture證明等價。
- Drift exception映射為既有typed local-storage`AppException`；constraint violation、open failure、read failure、write failure與unexpected programming error不得混為一類。
- Auth credential lifecycle、migration coordinator、restore ordering、logout與passive invalidation contract不變。

## Catalog Offline Cache migration

### Preserved invariants

- first-page replacement是單一transaction。
- append前驗證predecessor與`next_cursor`鏈結。
- chain revision維持一致且不可被stale write回退。
- cursor cycle不得造成無限讀取或重複page。
- corruption cleanup仍為best-effort且有diagnostic。
- public Catalog cache不因Logout清除。
- expiration、cache-first、SWR與reconnect revalidation authority不變。

### Query policy

- 對單表CRUD與row mapping優先使用typed Drift query。
- 複雜cleanup、schema inspection或能更清楚保留既有語意的SQL可使用`customSelect`／`customStatement`。
- 不以manager API重寫所有邏輯為目標；可審查的transaction與invariant優先。
- item insert可使用batch，但必須在同一transaction內，且不能改變duplicate／constraint failure disposition。

### Corruption policy

- 不可因generated mapping exception把整個cache視為empty而靜默吞錯。
- expected malformed cache可清理並回傳cache miss／degraded result。
- unknown Drift／SQLite error保留stack並透過既有diagnostic boundary上報。
- diagnostic不得包含完整search payload或任何credential。

## One-shot and reactive boundary

- Baseline authority使用`get()`、`getSingleOrNull()`、transaction與explicit repository command。
- AuthUser與Catalog第一版禁止用`watch()`驅動Session或Bloc。
- 未來feature只有在local live view有明確需求、subscription lifecycle與single authority設計完成後，才能opt in reactive stream。
- DAO不得因方便公開stream作為預設API。

## Transaction and isolate policy

### Transactions

- 所有既有atomic write boundary一對一保留。
- transaction callback內不得呼叫使用另一connection的DAO或repository。
- 禁止在transaction內等待network、plugin或unbounded work。
- retry不由 Drift自動擴張；SQLite busy／locked disposition需明確映射與測試。

### Background isolate

- Native final opener預設使用 Drift background connection能力，避免query／mapping阻塞UI isolate。
- compatibility harness需同時驗證 direct native executor與background executor結果一致。
- database singleton與close lifecycle由App bootstrap／DI擁有；不得每個DAO建立自己的isolate。
- integration test與unit test可使用in-memory direct executor以維持determinism，但至少一組runtime test必須走production opener。
- Web使用worker時，worker initialization failure與storage fallback必須可診斷。

## Native opener

### Android and iOS

- 必須開啟現有 sqflite database folder中的`flutter_architecture.db`，不得採`drift_flutter`預設的`<name>.sqlite`造成新檔。
- path由App-owned opener明確組合並以fixture／runtime smoke驗證。
- cutover release第一次開啟時由Drift讀取既有`user_version`與執行必要migration。

### Windows, macOS and Linux

- final opener使用Drift native／`sqlite3`路徑，不使用`sqflite_common_ffi` global factory。
- database path規則必須明確；對尚未發佈的dependency-ready平台可採App documents path，但不得與Android／iOS既有path相容要求混淆。
- Windows、macOS、Linux各至少需build或host-side opener smoke disposition；是否提升Supported由獨立platform policy決定。

## Web opener and storage migration

Web必須被視為獨立migration問題，不能因SQLite file format相容而推論browser storage相容。

### Required investigation

- 確認現有`sqflite_common_ffi_web`使用的browser database name、IndexedDB database／store名稱與worker protocol。
- 確認 Drift Wasm opener的storage selection、database name、IndexedDB／OPFS backend與cross-tab worker需求。
- 在相同browser profile建立舊版資料，再用cutover build驗證是否可讀。

### Accepted disposition hierarchy

1. **Preferred — in-place import**：可可靠讀出舊storage並匯入Drift database，完成後留下migration marker。
2. **Acceptable — explicit reset**：若 repository從未宣稱Web Supported且無正式production distribution，可清楚聲明既有experimental Web cache/auth user local data會reset；token credential仍依其自身storage contract處理。
3. **Unsupported upgrade**：只有browser storage API限制導致無法安全辨識／遷移時才能採用，且必須提供明確文件、diagnostic與manual cleanup route。

不得在沒有runtime evidence時聲稱automatic preservation。

### Web assets

- Drift final setup預期使用與resolved `sqlite3` major相容的`sqlite3.wasm`及`drift_worker.js`。
- 舊`sqflite_sw.js`只有在所有Web migration／rollback acceptance完成後才能移除。
- CI必須檢查required assets存在、版本相容且未保留失效worker引用。

## Generated code and schema governance

- `app_database.g.dart`等generated file不得手改。
- root既有 build_runner workflow必須包含 Drift generation。
- repository保留generated source並以clean generation diff作為CI gate。
- 匯出versioned schema snapshots至tracked test fixture directory。
- migration test驗證每個historical snapshot到latest schema。
- schema或DAO source變更若沒有同步generated output，change-aware CI必須fail。
- CI classifier必須把`.drift`、Drift table／DAO source、build config、schema snapshots、Wasm／worker assets與pubspec變更分類為database／source critical path。
- docs-only change不得無理由觸發Drift generation，但unknown path維持fail-safe full matrix。

## Exception mapping and diagnostics

- open／migration failure是bootstrap-critical database failure，不可降級成空DB。
- expected SQLite／Drift operational error轉為既有typed local-storage failure。
- constraint violation需保留安全operation context，例如table、operation kind、schema version；不得附row payload。
- migration diagnostic包含oldVersion、newVersion、step、fixture id／platform與sanitized SQLite code。
- unknown programming error不被包成一般cache miss或unauthenticated。
- Web storage fallback、worker failure與database reset disposition必須可觀測，但不加入user credential。

## Rollout, cutover and rollback

### Rollout phases

1. 建立v1～v6fixture與sqflite expected harness。
2. 加入Drift foundation與migration bridge，但不改production DI。
3. 完成Drift schema／migration／DAO並在tests使用。
4. 完成AuthUser與Catalog parity。
5. 完成native／Web opener acceptance。
6. 單一commit切換production DI到`AppDatabase`。
7. full regression與platform runtime acceptance。
8. 移除sqflite authority、dependencies與舊assets。

### Cutover gate

production cutover前必須：

- v1～v6 fixtures全部pass。
- AuthUser與Catalog parity全部pass。
- native同檔開啟與Web disposition完成。
- generated clean diff pass。
- Open P0 = 0。
- Open P1 without disposition = 0。

### Rollback

- cutover release前可回退到最後sqflite commit／artifact，因production baseline尚未發布。
- cutover若保持schema version 6且未改DDL，舊sqflite binary應可重新開啟native database；必須以rollback fixture實測，不能只依理論判定。
- 若實作中需要升到schema version 7或改變資料格式，必須先修訂本Spec並建立雙向data disposition；未核准前不得進行。
- Web rollback取決於storage migration strategy，必須個別驗證。

## Documentation and authority cutover

Milestone完成時需同步：

- 新增／更新 canonical ADR，將 App database authority由sqflite改為Drift。
- `docs/adr/README.md`索引與supersession關係。
- root README、App README、Auth／Catalog README與database guide。
- `AGENTS.md`移除sqflite setup，加入Drift generation與Web assets操作。
- `docs/project_context.md`technology map與platform persistence描述。
- `docs/roadmap.md`、`docs/roadmap/active.md`、Milestone index、CHANGELOG與VERSION。
- feasibility audit保留為historical planning evidence，不改寫成current authority。

## Validation and platform acceptance matrix

| Area | Required evidence |
|---|---|
| Schema | fresh v6 create、normalized sqlite_master、PRAGMA、constraints |
| Historical | v1～v6 upgrade、data preservation、cleanup、rollback |
| AuthUser | single row、malformed legacy、read/write/clear、exception mapping |
| Catalog | replace、append、transaction rollback、revision、cycle、corruption、logout persistence |
| DI/bootstrap | singleton open、close、failure propagation、generated registration |
| Android | representative build + production opener runtime smoke |
| iOS | unsigned Simulator build + production opener runtime smoke |
| macOS | native opener smoke或明確blocked evidence |
| Windows | build／host opener smoke或明確environment disposition |
| Linux | build／host opener smoke或明確environment disposition |
| Web | build、Wasm/worker load、storage migration/reset disposition、runtime smoke |
| CI | pub get、build_runner、generated diff、docs check、analyze、all tests、change-aware classification |

Platform classification規則不變：Drift套件支援六平台，不等於本 repository已取得六平台Supported claim。

## Proposed Task decomposition

### Design and planning

- Design Spec — 本文件與完整Task review。
- Implementation Plan — exact files、commands、commit boundary與acceptance sequencing。

### Implementation

```txt
Task 29-1 — Historical Database Fixtures and Compatibility Harness
Task 29-2 — Drift Schema and Database Foundation
Task 29-3 — Historical Migration Contract
Task 29-4 — AuthUser Persistence Migration
Task 29-5 — Catalog Offline Cache Migration
Task 29-6 — Cross-platform Database Openers and Web Storage Disposition
Task 29-7 — Generated Code, Schema Snapshot and CI Governance
Task 29-8 — Production Single-owner Cutover and sqflite Authority Removal
Task 29-9 — Platform Runtime and Full Regression Validation
Task 29-10 — Holistic Final Review, Release and Post-release Validation
```

Plan可在不省略必要scope的前提下微調檔案與Task邊界；不得合併到無法獨立review，也不得把Web、historical fixture或authority removal延後到Milestone外。

## Acceptance criteria

Milestone 29只有在以下全部成立時才完成：

1. Drift是唯一App database authority。
2. production source不再直接import或呼叫sqflite API。
3. 不存在兩套schema version owner或長期雙framework executor。
4. Native既有`flutter_architecture.db`可被Drift同檔開啟。
5. v1～v6 fixtures升級與schema/data parity全部通過。
6. AuthUser與Catalog所有既有invariant保持。
7. Web既有storage有實測migration、explicit reset或unsupported-upgrade disposition。
8. Android／iOS runtime evidence完成；Desktop／Web有符合platform policy的明確matrix結果。
9. generated code、schema snapshots與change-aware CI穩定。
10. sqflite dependencies、global factory initializer與失效Web assets依核准時機移除。
11. ADR、current snapshot、README、roadmap、CHANGELOG與VERSION同步。
12. Open P0 = 0；Open P1 without disposition = 0。
13. Milestone holistic review、release commit、push與post-release validation完成。

## Blocking conditions

以下任一項未有可接受修正或disposition時，禁止production cutover：

- historical fixture data loss或schema mismatch。
- AuthUser lifecycle或Catalog chain invariant regression。
- Native無法同檔開啟且只能建立新DB。
- Web既有storage相容性未知且沒有reset／unsupported disposition。
- generated source無法deterministic重建。
- migration／rollback可能造成不可逆資料破壞。
- 必須發布長期sqflite／Drift雙authority才能運作。

## Final design disposition

```txt
Design status: ACCEPTED
Direction: Option D one-shot full migration
Starting schema version: 6
Final database authority: Drift
drift_sqflite: temporary compatibility bridge only
Default query authority: one-shot
Reactive streams: explicit opt-in only
Production cutover before fixtures: prohibited
Open P0: 0
Open P1 without disposition: 0
Next Task: Milestone 29 Implementation Plan
```
