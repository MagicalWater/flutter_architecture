# Milestone 18-2 — Runtime Critical Flow Audit

## 狀態

Completed audit；尚未進入 remediation。

本文件保存runtime contract、production path、existing test evidence、coverage gap與分析。所有正式finding的唯一Single Source of Truth為`docs/audits/milestone_18/findings.md`。

---

## 1. Audit方法

本階段依Milestone 18 contract，對每個critical flow記錄：

```txt
Expected contract
Production path
Existing test evidence
Coverage gap
Finding
```

本次檢查：Bootstrap、Auth restore / login / logout、Concurrent 401 / Refresh / Replay、Profile / Guard、Catalog Search / SWR / Refresh / Append / Cache，以及Failure / reporting ownership。

---

## 2. Bootstrap flow

### Expected contract

- Flutter binding先初始化。
- Global uncaught hooks與Bloc observer在其他async initialization前安裝。
- Database factory在DI建立Database前初始化。
- AppConfig先建立，再組裝DI graph。
- Theme與Locale restore完成後才`runApp`。
- Bootstrap failure以fatal上報並保留原始error / stack identity。

### Production path

```txt
runBootstrapGuarded
  ↓
WidgetsFlutterBinding.ensureInitialized
  ↓
AppUncaughtErrorHooks.install
  ↓
Bloc.observer = AppBlocObserver
  ↓
initializeDatabaseFactory
  ↓
AppConfigFactory.fromEnvironment
  ↓
configureDependencies
  ↓
restoreThemeController
  ↓
restoreLocaleController
  ↓
runApp
```

`runBootstrapGuarded`將bootstrap error以fatal上報，再以原error與stack重新拋出。

### Existing test evidence

- Bootstrap fatal guard、identity preservation、reporter failure與deduplication。
- Flutter / Platform hooks、既有handler delegation、dispose與重複install。
- Bloc unexpected error reporting。
- Mock / Real DI graph建立。
- Theme / Locale restore、typed fallback、unknown error與reporter failure。

### Coverage gap

- 沒有單一整合測試直接驗證完整`bootstrap()`順序與`runApp`進入條件。
- Database factory跨平台runtime驗證留到18-3與18-4。

### Finding

Production順序與各子契約一致。現有缺口先於18-5彙總，不建立18-2 runtime finding。

---

## 3. Auth restore、login與logout

### Expected contract

- Restore、login、logout、refresh對persistence與runtime Session的複合修改必須序列化。
- Login只有在token與user均保存成功後才建立runtime Session。
- Restore缺少或損壞任一必要auth state時清理殘留並視為未登入。
- Logout即使local cleanup部分失敗，仍清除runtime Session。
- Unexpected error不得降級為expected Failure。
- 較舊operation不得覆蓋較新的使用者意圖。

### Production path

`AuthRepositoryImpl`透過單一`AuthStateMutationCoordinator`序列化Login persistence commit、Restore local read / cleanup與Logout cleanup。

Login remote request在進入mutation lock前執行。AuthBloc的`AuthStarted`、`AuthLoginRequested`與`AuthLogoutRequested`沒有指定event transformer，依Bloc預設行為可並行處理。

### Existing test evidence

- Login persistence補償清理。
- Restore corrupted tokens與known / unexpected storage failure。
- Logout兩段cleanup、error優先順序與runtime Session清除。
- AuthBloc個別restore、login、logout及Session cleared同步。

### Coverage gap

- 沒有Restore + Login交錯測試。
- 沒有雙Login不同帳號反向完成測試。
- 沒有Login + Logout反向完成測試。

### Finding

`M18-R01`：AuthBloc lifecycle events可並行完成，缺少operation identity或明確event ordering；較舊restore / login結果可能覆蓋較新操作的UI與persisted Session。

---

## 4. Concurrent 401、Refresh與Replay

`AuthSessionRefresher`以`generation + userId + failedAccessToken`綁定in-flight refresh。Token read、rotated pair save、Session update與invalidation均透過`AuthStateMutationCoordinator`協調，remote response commit前再次驗證generation與userId。

`AuthRefreshInterceptor`在refresh前、refresh後與replay前驗證Session snapshot；只允許HTTP 401、`requiresAuth`、`allowAuthReplay`、未retry且非FormData / Stream / streaming / progress flow的request。

Tests已覆蓋並行401 single-flight、new / old Session隔離、logout / relogin、token rotation failure、invalid / temporary / malformed response、second 401、account switch、request metadata preservation與不安全body禁止replay。

結論：Refresh與Replay contract具備強production guard與完整test evidence；未建立新finding。

---

## 5. Profile與Route Guard

`ProfileBloc`在request前保存current Session，response後比較`generation + userId`。Session clear會移除Profile UI；若clear event處理前已建立新Session，會重新request。`AuthGuard`直接依賴`SessionManager`。

Tests已覆蓋Session expiration、舊response、account switch、clear後立即relogin，以及Guard未登入 / 已登入 / expiration。

Login成功切Profile tab與Profile logout切Login tab的integration coverage仍缺少，已於18-1與`M18-A02`記錄。

結論：Profile與Guard runtime identity處理一致；不建立新finding。

---

## 6. Catalog initial、SWR與query switching

`CatalogBloc`使用`debounceTime + distinct + switchMap`、`_searchGeneration`與query雙重guard，並可取消first-page subscription。Stale cache後stream未提供revalidation result即關閉會視為protocol violation。

Repository initial policy為Fresh cache直接完成、Stale cache先emit再remote、Cache miss / expired走remote。

Tests已覆蓋debounce、normalized distinct、query switching、same-query generation、subscription cancellation、fresh / stale / future timestamp、remote success / failure與unexpected stream closure。

結論：Initial與SWR contract完整；不建立新finding。

---

## 7. Catalog Refresh、Append與cursor chain

Refresh與Append使用`exhaustMap`；`_SingleSnapshotRequest`要求exactly one emission。Refresh增加generation並取消first-page / append；Append完成時重新比較generation、query與requested cursor。`_consumedAppendCursors`阻止cursor循環。

Repository與LocalDataSource包含non-advancing cursor guard、第一頁chain reset、linked chain revision compare-and-replace與corruption cleanup。

Tests已覆蓋single-flight、merge / retry、Refresh取消Append、Query switch cancellation、empty / multiple emission、cursor cycle、late old append、same cursor reuse、chain revision corruption與transaction rollback。

結論：Refresh、Append與cursor chain具備強競態guard；不建立新finding。

---

## 8. Failure與reporting ownership

Expected operational failure透過`Result / Failure`回到UI；unexpected error與protocol violation保留identity並進framework/global reporting。Catalog known localStorage failure可降級，但先送diagnostic sink；reporting failure不改變原流程。

Tests已覆蓋Repository unknown error、Bloc loading cleanup、Catalog diagnostic safe context，以及Bootstrap / Bloc / Flutter / Platform reporting severity與deduplication。

結論：Failure與reporting ownership符合Milestone 17 contract；不建立新finding。

---

## 9. Open-ended scan

另檢查Bloc event concurrency、Session generation、late response commit、stream cancellation、exactly-one emission、reporter failure與cache fallback typed identity。

新增唯一正式runtime finding為`M18-R01`。沒有發現P0問題。

---

## 10. 18-2 conclusion

整體runtime foundation成熟。正式finding：

```txt
M18-R01 — AuthBloc restore、login與logout事件缺少明確ordering，較舊operation可能覆蓋較新使用者意圖
```

本階段只完成audit與落檔，不修改production code。Finding需等18-6C Audit Review Gate統一決定remediation。
