# Milestone 19-5 Security Review與Android Smoke Evidence

## Task 1 — Security surface inventory與secret regression

### Scope

本階段只審查credential-bearing output surface，不修改Auth runtime authority、migration、refresh或cleanup語意。

盤點範圍：

- `StoredAuthTokens`與`AuthCredentialReadResult`。
- `AuthCredentialMigrationResult`與`AuthLifecycleDiagnostic`。
- `AuthLifecycleCleanupResult`。
- Secure Storage adapter mapped `AppException`。
- `AuthMigrationErrorReporterAdapter`建立的`ErrorReport`與safe context。
- Production `print`、`debugPrint`、`developer.log`、Dio logger與Bloc observer使用點。

### Unified sentinels

Task 1使用以下固定synthetic sentinels建立一致回歸證據：

```txt
M19_ACCESS_SECRET_7f4a
M19_REFRESH_SECRET_2c91
M19_PASSWORD_SECRET_11de
M19_PLUGIN_SECRET_a63b
```

測試只驗證一般字串輸出不包含sentinel；原始error identity與caught stack仍依Decision 020保留於typed欄位，不將unknown error降級。

### Initial source inventory

- Production Auth model與migration／lifecycle result已有自訂或Object預設的secret-safe `toString()`。
- `ErrorReport.toString()`只輸出error runtime type、severity與typed context，不展開error或stack。
- `DebugErrorReporter`不呼叫`error.toString()`。
- 未發現production `LogInterceptor`、Authorization header、Token Pair或password被直接輸出。
- 既有測試已有分散的secret regressions；Task 1新增統一sentinel覆蓋19-1至19-4新增surface。

### Verification

執行結果：

- Auth targeted：51項通過。
- App Secure adapter／reporter targeted：31項通過。
- 五個workspace package analyze全數通過。
- `dart format`無額外修改。

新增統一sentinel regressions全部直接通過，表示既有production `toString()`、mapped `AppException`與`ErrorReport`已符合secret-safe契約，不需要修改production code。

Task 1 implementation review：通過。

- `StoredAuthTokens`、credential read result、migration result、lifecycle diagnostic、cleanup result、Secure adapter mapped error與App report context均不展開sentinel。
- 原始error identity與caught stack仍保留於typed欄位；沒有將unknown error降級。
- 沒有新增平行redaction framework或跨package dependency。
- Production source scan未發現Token Pair、Authorization、password或raw payload直接輸出。

## Task 3 — Android smoke orchestration與artifact gate

新增`tools/milestone_19_5/android_smoke.ps1`，以Windows PowerShell 5.1可執行語法提供AVD／root檢查、artifact metadata、install／clear／launch／force-stop、UI evidence、root-only只讀sandbox查核、temporary CA lifecycle、`adb reverse`與logcat gate。

所有會修改host或device的操作都經`SupportsShouldProcess`／`ShouldProcess`。工具沒有credential、SharedPreferences value、SQLite User或Session寫入helper，也不修改App manifest、network security config或Dio trust policy。

驗證結果：

- PowerShell parser通過。
- 預設`-WhatIf`與`CreateCa -WhatIf`均無side effect。
- 實際短效CA與localhost certificate建立成功；`openssl verify`通過，SAN包含`DNS:localhost`與`IP Address:127.0.0.1`。
- Artifact helper成功解析既有release APK：App ID `com.example.flutterarchitecture`、versionCode 1、versionName 0.1.0、minSdk 24、targetSdk 36，並產出SHA-256與size。
- Script static scan未發現credential／SQLite寫入、cleartext bypass、`badCertificateCallback`或network security override。
- Temporary evidence驗證後已清除，未進Git。

Task 3 implementation review：通過。

- `-WhatIf`沒有host／device side effect。
- Release sandbox inspection只允許root-capable emulator的只讀metadata與safe row查核。
- UI、sandbox與logcat evidence都有secret sentinel gate。
- Temporary CA具create／install／remove流程；cleanup失敗要求wipe AVD。
- App production trust policy與runtime Auth contract未修改。

## Task 2 — Secret-safe deterministic HTTP fixture server

### Scope

新增repo-owned host tooling，只用來提供Android release runtime的deterministic Login／401／Refresh／Replay契約，不進App dependency graph，也不修改Mock API或production Auth code。

檔案：

- `tools/milestone_19_5/auth_fixture_server.py`
- `tools/milestone_19_5/test_auth_fixture_server.py`

### State machine

固定流程：

```txt
POST /auth/login       → access-v1 / refresh-v1
GET  /profile + v1     → 401
POST /auth/refresh     → access-v2 / refresh-v2
GET  /profile + v2     → 200
```

- Refresh只允許成功一次；後續相同refresh credential回401。
- Restart evidence保留server state，access-v2可直接取得Profile且不新增refresh call。
- `/reset`只清除host state與evidence，不接觸App資料。
- HTTPS certificate與temporary CA由Task 3 orchestration建立；server本身要求明確傳入`--cert`與`--key`。

### Secret-safe evidence

Evidence event只包含：

```txt
sequence
method
path
status
credential_fingerprint（SHA-256前16碼，可選）
```

不記錄：

- Raw Authorization header。
- Access Token／Refresh Token。
- Password。
- Request body。
- Exception repr或HTTP server預設request log。

### Verification

- TDD RED：server module不存在，unittest因`ModuleNotFoundError`失敗。
- GREEN：6項Python state machine tests全數通過。
- `python -m py_compile`通過。
- Secret scan只命中必要的parser／test fixture使用點，沒有unsafe print或raw evidence輸出。
- `git diff --check`通過。

Task 2 implementation review：通過。

- Login、Refresh與Profile JSON欄位和現有Retrofit DTO contract一致。
- Refresh只成功一次，restart後access-v2可直接使用。
- Evidence endpoint與JSONL檔案只暴露safe metadata與fingerprint。
- `BaseHTTPRequestHandler.log_message()`已停用，避免預設request line輸出。
- Tooling沒有App、Flutter或package dependency，亦未修改production source。

## Task 4 — Current release Login、Restore與Logout runtime smoke

### Environment與artifact

- AVD：`flutter_architecture_m18`。
- Device serial：`emulator-5554`。
- Android API：35。
- ABI：x86_64。
- `adb root`：成功；root只用於test environment evidence。
- APK：development release、`API_MODE=mock`。
- APK SHA-256：`5477bdef4d51a042a4ad13c14e03bf9553c10be1274da006fb1b68f399d4d476`。
- APK size：58,927,329 bytes。
- App artifact versionName／versionCode：`0.1.0`／`1`。
- Merged manifest：minSdk 24、targetSdk 36、`allowBackup=false`。

### Login與Secure authority

- Clean install後顯示Login頁，預設帳號存在且password欄位保持遮罩。
- 透過既有UI Login後顯示Profile，current user為`Water Magical`。
- Legacy SharedPreferences keys `auth.tokens`／`auth.accessToken`均不存在。
- Secure Storage backing artifact `FlutterSecureStorage.xml`存在。
- SQLite `auth_user`為single-active row：`1|user-001|Water Magical`。
- Authenticated UI hierarchy、screenshot hash與resumed Activity evidence已保存於untracked evidence directory。

### Force-stop／restart Restore

- Force-stop後重新啟動release APK，App直接恢復Profile authenticated狀態。
- Restore後Legacy keys仍不存在。
- Secure Storage backing artifact與`auth_user` identity保持一致。
- Restore UI hierarchy、screenshot hash、Activity及logcat evidence已保存。

### Logout destructive cleanup與public cache persistence

- 先開啟Catalog，建立public cache：`catalog_cache_page=1`、`catalog_cache_page_item=12`。
- 透過既有Profile UI執行Logout後回到Login頁。
- Logout後`auth_user=0`，Legacy keys不存在；Secure Storage backing file仍可存在，但logical credential已清除，檔案大小由1,500 bytes降為1,144 bytes。
- Catalog cache在Logout後仍保持1頁／12項，符合既有public persistence contract。
- 再次force-stop／restart後仍停留Login，`auth_user`保持空、Legacy keys仍不存在。
- Logout與restart後UI hierarchy、screenshot hash、Activity、sandbox與logcat evidence已保存。

### Task 4 implementation review

- Login、Restore與Logout成功結果均由release App production orchestration產生。
- ADB只負責安裝、點擊既有UI、force-stop／launch、只讀sandbox與evidence收集，沒有直接建立Session、credential或User。
- 每次`CollectLogcat`均通過secret／fatal gate，沒有credential sentinel或App fatal。
- Task 4執行期間發現Task 3 SQLite helper的Windows quoting缺陷；已改為先由ADB只讀取得`.db`路徑，再以quoted `sqlite3` command查詢safe欄位，未增加任何寫入能力。
- 無Open P0／P1 runtime finding。

## Task 5 — Real API Refresh rotation與restart persistence smoke

### Environment與transport

- 使用同一`flutter_architecture_m18` AVD，以`-writable-system -no-snapshot`啟動後完成`adb root`、disable-verity、overlayfs與`adb remount`。
- Temporary local CA安裝至emulator system trust store；App manifest、network security config與Dio trust policy均未修改。
- Host fixture以`https://localhost:18443`運行，並透過`adb reverse tcp:18443 tcp:18443`連線。
- Current APK為development release、`API_MODE=real`。

### Runtime發現與修正

首次runtime sequence為Login 200 → Profile 401 → Refresh 401。Safe shape診斷顯示Refresh request長度37、沒有`Content-Type`且不是JSON；內容未被記錄。

根因是`RefreshTokenRequestDto`沒有明確宣告public `toJson()` contract，導致Retrofit generated client將DTO物件直接交給Dio，實際request body沒有形成JSON Map。新增API client regression後先得到`adapter.body == null`的RED結果，再補上`toJson()`宣告並重新執行build_runner。

修正後generated client會執行：

```txt
request.toJson()
→ {'refreshToken': '<credential>'}
```

Fixture server也補上chunked request body decoder及對應Python test，避免host tooling因Transfer-Encoding差異誤判；evidence仍不保存request body。

### Refresh rotation evidence

最終fixture sequence：

```txt
1 POST /auth/login    200
2 GET  /profile       401  access-v1 fingerprint
3 POST /auth/refresh  200  refresh-v1 fingerprint
4 GET  /profile       200  access-v2 fingerprint
```

- App完成Login後保持authenticated並顯示Profile／`Water Magical`。
- Refresh endpoint只成功一次。
- Replay使用與後續restart相同的access-v2 fingerprint。
- Legacy keys不存在；Secure backing artifact存在。
- SQLite `auth_user`保持`1|user-001|Water Magical`。

### Restart persistence evidence

Force-stop／restart後fixture只新增：

```txt
5 GET /profile 200 access-v2 fingerprint
```

- 沒有第二次`POST /auth/refresh`。
- Restart後直接顯示authenticated Profile。
- Secure backing artifact size與`auth_user` identity維持一致。
- 這項evidence證明rotated Token Pair已持久化，且Restore後runtime Session直接使用rotated access token。

### Secret與environment cleanup gate

- App UI、sandbox、logcat與host fixture evidence掃描無raw Access Token、Refresh Token、Authorization、password、request body或`FATAL EXCEPTION`。
- Fixture evidence只保存sequence、method、path、status與SHA-256前16碼fingerprint。
- Temporary CA移除後，system CA filename集合與安裝前完全一致。
- Host fixture server已停止。

### Task 5 implementation review

- 實際經過real Dio client、`AuthRefreshInterceptor`、`AuthSessionRefresher`與request replay。
- Rotation與restart persistence均由release App production flow證明。
- 修正有API client regression、generated source與runtime evidence共同保護。
- Host tooling沒有保存raw credential。
- Temporary CA lifecycle完整cleanup，App production trust policy未弱化。
- 無Open P0／P1；runtime發現的Refresh JSON P1已在本Task關閉。
