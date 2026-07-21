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
