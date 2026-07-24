---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-30-test-suite-audit-rationalization-governance-design
last_reviewed_baseline: 1.11.0
---

# Milestone 30 — Test Suite Audit, Rationalization & Governance Design

## Decision summary

建立下一個正式 Milestone：

```txt
Milestone 30 — Test Suite Audit, Rationalization & Governance
```

採用有界的 repository-wide test rationalization。目標不是追求較少測試，而是建立可稽核的 coverage ownership、production／historical boundary、刪除與替代證據、執行層級與長期治理，再依證據進行受控精簡。

## Confirmed baseline

| Item | Confirmed state |
|---|---|
| Workspace | `/Users/water/Developer/projects/flutter_architecture` |
| Branch | `main` |
| Starting commit | `03819c0 docs(database): 完成Milestone 29發布後閉合` |
| Worktree | Clean |
| Template Baseline | `1.11.0` |
| Tracked test files | 134 |
| Test LOC | 23,066 |
| Dart／Flutter test files | 119 |
| Dart／Flutter static cases | 659 |
| Python contract files | 15 |
| Python static cases | 110 |
| App runtime test result | 467 tests passed |
| Full Flutter workspace wall time | 約20.54秒 |
| CI Python contract wall time | 約0.38秒 |
| Documentation checker wall time | 約0.07秒 |

## Problem statement

目前測試已形成有效防線，但存在下列結構性問題：

- Auth與Catalog測試規模集中，部分檔案超過700～1,100行且混合多個責任。
- 一般feature測試仍直接使用historical sqflite adapter，與Drift production authority不一致。
- 同一business invariant可能在DAO、data source、repository、Bloc與widget多層重複驗證，但各層責任尚未明文化。
- Drift與sqflite測試同時存在，尚未完整區分current production contract與historical migration／rollback oracle。
- Theme、Locale、SharedPreferences與Auth cleanup tests存在相似fixture與failure matrix。
- CI／Platform Python contracts對同一workflow片段、classifier與execution mode有重複string assertion。
- 部分historical tooling看似測試，但不在正式matrix且缺乏明確執行authority。
- Repository沒有正式test inventory、coverage owner、execution tier與deletion manifest。

## Goals

- 為所有tracked tests建立可重現inventory、taxonomy與coverage owner。
- 明確區分business invariant、architecture boundary、implementation contract、migration compatibility、regression、platform、CI、visual與historical-only coverage。
- 將一般Auth／Catalog production integration切回production Drift path或明確fake contract，不再意外依賴historical sqflite implementation。
- 保留sqflite historical migration、rollback、fixture integrity與schema equivalence oracle。
- 為每個Keep、Reduce、Rewrite、Merge、Delete與Archive disposition提供理由、replacement coverage與validation。
- 降低跨層重複、錯誤implementation coupling與重複fixture維護成本。
- 只在真正穩定且可讀的重複存在時抽取shared fixture；禁止建立通用test framework作為目標本身。
- 建立fast regression、full regression、change-aware platform、historical compatibility與manual external acceptance等execution tier。
- 維持Auth session、credential security、Catalog concurrency、migration與platform regression coverage。
- 建立長期test governance authority與新增／刪除／分層規則。

## Non-goals

- 不以test file、case或LOC下降比例作為唯一成功標準。
- 不設定機械式單檔LOC上限。
- 不全面重寫test suite。
- 不建立generic preference contract、generic repository contract或跨domain test DSL。
- 不因名稱包含`sqflite`就刪除historical migration與rollback harness。
- 不改變production business behavior、architecture dependency direction或App Composition Root。
- 不降低Auth安全、Catalog concurrency、database migration、generated consistency與platform contract gate。
- 不因目前full Flutter tests約20秒就把快速deterministic tests移到nightly。
- 不導入第三方coverage SaaS、mutation testing平台或新的CI供應商。
- 不處理physical-device、Store distribution或外部服務的新acceptance scope。

## Test taxonomy

每個測試至少有一個primary category，必要時可有secondary tags：

| Category | Definition | Typical owner |
|---|---|---|
| Business invariant | 產品／安全／concurrency不可破壞的語意 | Domain、Repository或orchestrator最近責任層 |
| Architecture boundary | dependency direction、Composition Root、package isolation | App composition／package contract |
| Implementation contract | adapter、DAO、serializer或provider-specific behavior | 該implementation本身 |
| Migration compatibility | historical schema／data升級與rollback | Database migration harness |
| Regression | 過去具體bug且仍有重現價值 | 最接近bug根因的owner |
| Platform | native scaffold、plugin、runner與artifact contract | App platform boundary |
| CI | classifier、workflow、execution mode與generated gate | CI tooling |
| Visual | golden、layout、localization與accessibility rendering | Design System／Widget |
| Historical-only | 不代表current production，只支援fixture、oracle或recovery | Historical tooling |

## Coverage ownership rules

### Primary-owner principle

每個invariant必須有一個主要coverage owner。其他層只能驗證該層新增的責任，不得重複整套情境。

```txt
Persistence mechanics
→ DAO／adapter

Cache／fallback／mapping policy
→ Repository／data source

Generation、cancellation、latest-intent
→ Bloc／coordinator

Rendering、interaction、accessibility
→ Widget
```

相同測試名稱或情境不必然代表重複；只有在failure signal、責任與replacement coverage相同時才可Reduce或Merge。

### Auth ownership

- Credential migration authority resolution由`AuthCredentialMigrationCoordinator`擁有。
- Login／logout persistence與latest-intent由Auth repository擁有。
- Refresh single-flight、rotation persistence-first與session invalidation由session refresher擁有。
- Request replay eligibility與401 coordination由API client interceptor擁有。
- Flutter Secure Storage exception mapping與redaction由App adapter擁有。
- Local unlock lifecycle與presentation各自只驗證自身新增責任。

### Catalog ownership

- Table、transaction、cascade、page replacement與chain persistence mechanics由Drift DAO／local boundary擁有。
- Fresh／stale／retain、remote fallback與emission ordering由Repository擁有。
- Debounce、generation、append／refresh／reconnect cancellation由Bloc擁有。
- Loading、empty、cached、append與non-blocking failure呈現由Widget擁有。

### Preference ownership

Theme、Locale與local unlock可以共用簡單recording fixture，但各自保留具名domain tests。不同fallback、安全或diagnostic語意不得被generic contract隱藏。

## Production and historical boundary

### Current production authority

- App database：Drift `AppDatabase`。
- AuthUser persistence：Drift-backed production adapter。
- Catalog cache：Drift-backed production DAO／data source。
- sqflite與`sqflite_common_ffi`只可存在於dev dependency、historical fixture與rollback harness。

### Historical harness policy

以下coverage必須保留：

- v1～v6 checked-in SQLite fixture integrity。
- historical sqflite expected migration oracle。
- Drift historical migration equivalence。
- rollback compatibility。
- schema、index、foreign key、sentinel data與`user_version`驗證。

Historical classes必須以路徑、命名與文件明確表達非production owner。一般feature tests不得因setup方便直接依賴historical DAO；若要驗證contract，使用明確fake；若要驗證current persistence integration，使用Drift path。

## Disposition contract

每個測試檔或case群必須獲得以下其中一種disposition：

| Disposition | Required evidence |
|---|---|
| Keep | owner、risk與保留理由 |
| Reduce | 哪些cases重複、保留哪個failure signal |
| Rewrite | 新owner／fixture、前後coverage mapping |
| Merge | 被合併責任相同且結果仍可定位 |
| Delete | 明確失效原因、replacement test與validation |
| Archive as fixture/tooling | historical用途、正確執行方式與matrix disposition |

禁止只有「過期」、「重複」、「檔案太大」或「測試太多」等無replacement證據的刪除理由。

## Large-file policy

大型測試檔只在混合不同責任、不同fixture lifecycle或不同failure domain時拆分。不得只為降低行數拆檔。

候選責任切分：

- `auth_credential_migration_coordinator_test.dart`：authority resolution、cleanup diagnostics、legacy migration transaction。
- `auth_refresh_interceptor_test.dart`：single-flight／identity、replay eligibility、replay payload與failure handling。
- `auth_repository_persistence_test.dart`：login generation、restore、logout cleanup。
- `auth_session_refresher_test.dart`：refresh success、invalidation matrix、concurrency／stale completion。
- `catalog_bloc_test.dart`：initial／query、append、refresh、reconnect。
- `catalog_repository_cache_test.dart`：initial cache policy、append／revision、fallback／diagnostics。
- `catalog_local_data_source_test.dart`：page contract、corruption cleanup、migration-specific cases。

## Shared fixture policy

允許：

- Typed test data builders。
- Fake clock。
- Recording credential／user stores。
- Drift in-memory database setup。
- Workflow file loader／focused parser helper。
- Simple widget pump helper。

禁止：

- 以複雜泛型隱藏domain language。
- 一個helper同時斷言多層business behavior。
- 跨Auth、Catalog、Theme與Locale建立萬用storage contract。
- 讓測試必須閱讀helper internals才能理解scenario。

## Execution tiers

### Tier 1 — Fast deterministic regression

- Dart／Flutter unit與widget tests。
- Python CI與documentation contracts。
- 相關source change預設執行。

### Tier 2 — Full repository regression

- 全workspace Flutter tests。
- docs check、analyze、generated consistency。
- release、classifier、dependency或test governance變更執行。

### Tier 3 — Change-aware platform verification

- Android／iOS representative build。
- native、dependency、database-critical、platform或release path觸發。

### Tier 4 — Historical compatibility

- v1～v6 migration、rollback、fixture integrity與schema reports。
- database／fixture／migration／schema tooling變更必須執行；release仍納入full gate。

### Tier 5 — Manual external acceptance

- Firebase ingestion、physical device或外部服務驗證。
- 不得用來替代Tier 1～4 deterministic coverage。

目前不建立nightly-only unit test tier。若未來單一suite成本顯著增加，必須以量測證據重新設計。

## Inventory and deletion manifest

Repository應建立可重現inventory tooling與managed report，至少輸出：

```txt
path
suite
file type
LOC
static case count
primary category
coverage owner
production／historical classification
execution tier
disposition
replacement／notes
```

受控cleanup另維護deletion／merge manifest，逐項記錄old coverage、reason、replacement owner、replacement test與validation。Inventory是current治理工具；phase review保存當次evidence，不把逐case歷史流水帳塞入Roadmap。

## Documentation authority

- 本Spec擁有Milestone 30 design與scope。
- Implementation Plan擁有執行順序、檔案與validation gate。
- `docs/guides/testing_governance.md`將成為完成後的current test governance authority。
- `docs/audits/milestone_30/`保存inventory baseline、phase findings、deletion manifest與review evidence。
- `docs/roadmap/active.md`只路由active milestone與next action。
- `docs/project_context.md`只摘要current capability，不保存測試數流水帳。

## Task decomposition

```txt
Task 30-0 — Design Spec
Task 30-1 — Implementation Plan
Task 30-2 — Test Inventory, Ownership and Baseline
Task 30-3 — Historical and Persistence Boundary Audit
Task 30-4 — Auth Test Rationalization
Task 30-5 — Catalog Test Rationalization
Task 30-6 — Shared Fixtures and Focused Contract Extraction
Task 30-7 — Platform, CI, Documentation and Generated Contract Audit
Task 30-8 — Execution Matrix and Cost Optimization
Task 30-9 — Controlled Cleanup and Deletion Manifest
Task 30-10 — Governance and Adoption Documentation
Task 30-11 — Holistic Regression and Final Review
```

每個Task依兩層Task治理模型獨立完成focused review、findings、修正、re-review、whole-task review、documentation authority check、validation、P0／P1 gate與commit，通過後直接進入下一Task。

## Acceptance criteria

- 134個baseline test files全部有inventory與primary owner。
- 所有historical sqflite references有明確Keep／Rewrite／Archive disposition。
- 一般Auth／Catalog production integration不再意外以historical sqflite作current implementation。
- 每個Delete／Merge都有replacement coverage與review evidence。
- 核心Auth、Catalog、migration、platform與CI invariant matrix在前後可比較且沒有coverage hole。
- Full Flutter regression、Python contracts、docs check、analyze與generated consistency通過。
- Change-aware routing維持fail-safe且不因優化產生漏跑。
- 新治理文件有單一authority，未在多份文件複製完整規則。
- Open P0 = 0。
- Open P1 without disposition = 0。

## Release policy

Milestone 30主要改變測試與治理，不預設改變production runtime。若只移除錯誤綁定、重構tests與新增治理，採PATCH release；若實作過程發現並修正會改變公開模板能力或runtime behavior，需在final review重新判定版本級別。

