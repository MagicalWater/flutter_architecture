---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-critical-runtime-data-flow-evidence
last_reviewed_baseline: 1.14.0
---

# A4 — Critical Runtime, Data and Integration Flow Audit

## Scope and Evidence Rule

本Task以current production source、A2／A3 matrix、Milestone 19～21與27～30 bounded evidence，以及fresh focused tests審查Auth、Catalog、Persistence、Failure／Observability關鍵流程。

Test count只代表執行範圍，不等於coverage充分。每個結論都需有明確contract owner、production path與scenario-specific test owner。

## Auth Runtime Scenario Matrix

| Scenario | Expected contract | Production path | Current test evidence | Coverage disposition | Finding |
|---|---|---|---|---|---|
| Login authenticated | Credential與AuthUser完成persistence後才commit runtime Session | Login UI／Bloc → LoginUseCase → AuthRepository → secure credential／Drift AuthUser → SessionManager | Auth repository secure login、App Auth Bloc／navigation | Covered；包含補償與unknown error identity | — |
| OTP challenge | Challenge不得寫credential、AuthUser或Session；UI進入typed pending state | Auth API → Login union → AuthRepository → AuthBloc／OTP coordinator | Auth OTP domain／repository／Bloc／navigation | Covered | — |
| OTP Verify | Verify成功是唯一從challenge進入authenticated的路徑 | OTP UI → Verify use case → Repository → persistence-first commit | Auth repository OTP、App OTP Bloc／page | Covered；包含stale completion | — |
| OTP Resend replacement | Replacement challenge使predecessor失效並保留cooldown／expiry語意 | Resend API → AuthRepository → AuthBloc | Mock OTP state machine、repository／Bloc tests | Covered | — |
| Restore | 只有secure credential與AuthUser identity一致才restore | Bootstrap／AuthBloc → RestoreUseCase → migration coordinator／stores → SessionManager | Migration restore、single-active-user、AuthBloc restore | Covered | — |
| Logout | 清除credential、AuthUser、local unlock preference與Session；較新login不得被舊cleanup破壞 | LogoutUseCase → lifecycle cleanup policy → App adapters／SessionManager | Auth lifecycle／persistence、App local unlock integration | Covered | — |
| Invalid refresh cleanup | 401／403 terminal refresh結果清理舊session，不把temporary failure當invalid credential | AuthRefreshInterceptor → AuthSessionRefresher → typed refresh result／cleanup | Auth refresher、API interceptor tests | Covered；transport type coupling另由F-A2-01擁有 | F-A2-01 |
| Temporary refresh | Network、429與5xx不得清除Session，request依policy結束 | Interceptor → AuthSessionRefresher → temporary result | Auth refresher／secure lifecycle tests | Covered | F-A2-01 |
| Concurrent 401 | 同一generation共用single-flight refresh，避免多次rotation | AuthRefreshInterceptor＋AuthRefresher coordination | API interceptor concurrency tests | Covered | — |
| Safe replay | 只有明確`requiresAuth`且body可安全重建的request可replay | Request metadata → interceptor replay path | API interceptor tests | Covered；不宣稱任意stream／upload安全replay | — |
| Relogin／account switch stale completion | 較舊login、verify、restore或cleanup不得覆蓋較新generation | AuthRepository mutation generation＋AuthBloc generation | Double login、account switch、stale verify／restore／logout tests | Covered | — |
| Secure credential migration | SharedPreferences legacy只在exclusive section遷移；read-back成功後才清除legacy | Migration coordinator → secure store／legacy store／Drift AuthUser | 154個Auth package tests中的migration matrix＋App adapters | Covered；historical legacy path仍可執行 | — |
| Corruption | Corrupted secure／legacy payload走typed result與bounded cleanup；unknown error原樣保留 | Store adapters → migration／cleanup policy | Secure／legacy store corruption tests | Covered | — |
| Local unlock cold start | Preference enabled時先完成local user presence，未通過不得讀credential／restore | Bootstrap coordinator → local presence verifier → RestoreUseCase | Local unlock lifecycle／page／settings tests | Covered；只證明user presence | — |
| Local unlock resume grace | Resume只在既定grace／lifecycle條件重新鎖定，避免無界自動restore | App lifecycle coordinator → lock authority／SessionManager | App local unlock lifecycle coordinator tests | Covered；physical-device UX仍屬A5 claim boundary | — |

## Catalog and Connectivity Scenario Matrix

| Scenario | Expected contract | Production path | Current test evidence | Coverage disposition | Finding |
|---|---|---|---|---|---|
| Initial cache hit | Fresh cache可直接顯示；source identity與freshness明確 | CatalogBloc → SearchUseCase → Repository → LocalDataSource／Drift | Repository cache、Bloc、view tests | Covered | — |
| Initial cache miss | 走remote並原子寫入page／items | Repository → RemoteDataSource → mapper → LocalDataSource | Data layer／local data source tests | Covered | — |
| Stale SWR | 先顯示stale snapshot並non-blocking revalidate；failure保留cache | Repository stream → Bloc revalidating state | Repository cache＋Bloc stale tests | Covered | — |
| Refresh replacement | Manual refresh整批替換第一頁與chain metadata；失敗保留現有items | Bloc generation → Repository remote-first replacement | Bloc refresh／local first-page replacement tests | Covered | — |
| Append retained cache／remote fallback | Append保留既有items，remote failure可使用符合identity的bounded cache | Bloc load-more → Repository append policy | Repository cache＋Bloc append tests | Covered | — |
| Revision CAS | 舊chain revision不得覆蓋新query／refresh結果 | LocalDataSource／DAO transaction＋revision | Local data source revision corruption／CAS tests | Covered | — |
| Cursor cycle | Self-loop、cycle或non-advancing cursor是protocol failure，不污染chain | Mapper／Repository／Bloc protocol guard | Data layer、local source、Bloc cycle tests | Covered | — |
| Query generation | 舊query、舊generation與舊append結果不得覆蓋新搜尋 | CatalogBloc cancellation＋generation | Bloc query switching／stale completion tests | Covered | — |
| Reconnect dedupe | 只有已載入資料的Feature opt-in revalidate；重複signal不得重入 | ConnectivityController → Scope → CatalogBloc | Connectivity banner／Catalog reconnect tests | Covered；network state不等於backend reachability | — |
| Non-blocking failure | Cache write／revalidation failure不得丟失remote success或既有items | Repository degraded policy → ErrorReporter | Repository／Bloc degraded tests | Covered | — |
| Logout cache preservation | Public Catalog cache在Auth logout後保留；Auth state需清除 | Auth cleanup與Catalog database owners分離 | Catalog logout persistence tests | Covered；若未來資料改為user-private需新Requirement Decision | — |

## Persistence and Historical Boundary Matrix

| Scenario | Expected contract | Current owner／path | Fresh evidence | Disposition |
|---|---|---|---|---|
| Fresh schema | Current Drift schema包含canonical tables、checks與indexes | Single AppDatabase／generated schema | `drift_fresh_schema_test` passed | Covered |
| v1～v6 migration | 每個tracked historical fixture原子升至canonical v6 | Drift migration strategy＋historical fixtures | 6 Drift migration cases passed | Covered |
| Migration failure | 不留下partial schema且不推進`user_version` | Drift transaction boundary | Failure rollback case passed | Covered |
| Rollback compatibility | Drift升級後historical sqflite oracle仍可讀取與維持constraints | Test-only historical harness | v1～v5 rollback cases passed | Historical compatibility covered |
| Foreign keys | Fresh與upgrade path啟用FK、清orphan並執行cascade | AppDatabase open／migration hooks | Foreign-key tests passed | Covered |
| Single AppDatabase | AuthUser與Catalog DAO共用App-owned lifecycle | App Composition Root | DI、database與feature integration tests | Covered |
| AuthUser single-row | Login B取代Login A；restart只restore目前identity | DriftAuthUserStore | Single-active-user tests passed | Covered |
| Catalog chain invariants | Page identity、position uniqueness、revision、cursor與cascade一致 | Catalog DAO／LocalDataSource | Local source＋database tests passed | Covered |
| Web explicit reset | Web schema upgrade不假稱自動保留，使用明確reset policy | Web opener／storage policy | Web asset／storage policy tests passed | Covered for Dependency-ready claim |
| Historical sqflite boundary | sqflite只存在fixture、migration、rollback oracle，不是production owner | `test/support`與historical tests | Production grep為0；inventory tests passed | Correctly historical-only |

## Failure and Observability Scenario Matrix

| Scenario | Expected contract | Current path | Test evidence | Disposition |
|---|---|---|---|---|
| Expected Failure | 只有known `AppException`映射typed Failure | DataSource／Repository boundary | Core、Auth、Catalog、API tests | Covered |
| Unknown identity／stack | Programming／system error原樣rethrow，保留stack | Boundary-local catches＋Bloc cleanup/rethrow | Auth、Catalog、transport mapper tests | Covered |
| Cancellation | Query switch／dispose是control flow，不產生user Failure | Bloc subscription lifecycle | Catalog cancellation tests | Covered |
| Protocol violation | Malformed DTO、cursor、OTP metadata形成typed protocol identity | Mapper／RemoteDataSource／Repository | OTP／Catalog protocol tests | Covered |
| Degraded reporting | Cache、preference、migration diagnostic可non-fatal report且不阻斷主成功 | ErrorReporter adapters | Migration reporter／Catalog degraded tests | Covered |
| Sensitive redaction | Credential、OTP、payload不進`toString`、diagnostic或safe context | Sensitive models／events／reporter adapters | Package與App sentinel tests | Covered |
| Provider failure isolation | Crashlytics／reporter adapter failure不得改變產品flow或遞迴失敗 | Composite／Firebase reference adapter | App observability／reporter tests與Milestone 27 evidence | Covered |

## Fresh Validation Results

```txt
Auth package: 154 tests passed
API client package: 55 tests passed
App Auth／App auth／Navigation: 126 tests passed
Catalog／Connectivity: 138 tests passed
App database: 37 tests passed
Test inventory unit tests: 4 tests passed
Generated consistency verification: passed
Generated verification final checks: 2 tests passed
```

`verify_generated.sh`在Windows重新產生檔案時留下LF／CRLF工作樹狀態，但：

- Script明確回報`Generated files are consistent with source`。
- `git diff --ignore-space-at-eol --exit-code`為0。
- Staged content diff為0。
- 只還原generated檔案的checkout換行副作用後，工作樹恢復clean。

Build runner對兩個OTP request DTO輸出「必須提供`toJson()`」的Retrofit責任提示；current generated DTO確實具有serialization path，API／OTP tests與generated consistency均通過，因此不建立runtime finding。若未來generator升級把提示提升為failure，再由dependency upgrade工作重新分類。

## Coverage Gap Disposition

- Physical-device biometric UX、production provider activation、signed distribution不屬A4 runtime contract，轉由A5 security／platform claim審查。
- Web persistence只支援Dependency-ready static contract與explicit reset，不宣稱tracked Web runtime。
- `F-A2-01`是package transport ownership erosion；fresh runtime matrix沒有顯示terminal cleanup、temporary refresh或OTP mapping故障，因此維持P2。
- 沒有因focused suite通過而推導未執行的physical-device、Store或real backend結果。

## Whole-Task Review

- 每一要求scenario都有contract、production path與test owner。
- Current／historical persistence boundary清楚，沒有把historical sqflite當production debt刪除。
- Fresh tests沒有P0／P1 failure。
- Generated consistency沒有content drift。
- 沒有修改source、tests、fixtures、generated files或platform contract。

## Task Disposition

```txt
Auth scenarios reviewed: 15
Catalog／Connectivity scenarios reviewed: 11
Persistence scenarios reviewed: 10
Failure／Observability scenarios reviewed: 7
New findings: 0
Open P0: 0
Open P1 without disposition: 0
Task A4: ACCEPTED
```
