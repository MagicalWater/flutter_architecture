# Milestone 19-5 — Security Review、Android Smoke與封存 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完成Milestone 19的credential安全審查、Android release runtime evidence、Legacy upgrade migration、Refresh rotation與最終文件封存，並只在證據完整後關閉`M19-PR05`與判斷Template Baseline版本。

**Architecture:** 不新增App測試後門或runtime authority選項。Security evidence由既有Dart tests延伸；Refresh runtime使用development release＋real API mode＋host-side deterministic HTTPS fixture server，root-capable emulator暫時安裝test-only local CA而不修改App production trust policy；Legacy migration使用`05b3412` predecessor release的production Login建立真實舊資料，再以相同App ID升級目前release。ADB只負責安裝、force-stop、root只讀觀察、logcat、temporary CA與port reverse，不直接手工製造成功狀態。

**Tech Stack:** Dart 3、Flutter、flutter_test、Python 3 standard library、OpenSSL 3、PowerShell 5.1、Android SDK／ADB、Android 35 Google APIs x86_64 emulator、Gradle、Melos、Git worktree。

---

## File map

- Create: `tools/milestone_19_5/auth_fixture_server.py`
  - Host-side deterministic HTTPS Login／401／Refresh／Replay server。
  - 只輸出sequence、status與SHA-256 fingerprint，不輸出raw credential或request body。
- Create: `tools/milestone_19_5/test_auth_fixture_server.py`
  - 使用Python standard library驗證server state machine、單次refresh、secret-safe logs與restart profile contract。
- Create: `tools/milestone_19_5/android_smoke.ps1`
  - 啟動／確認AVD、`adb root`、artifact metadata、install、port reverse、force-stop、root只讀查核與log收集。
  - 不直接修改App sandbox credential或SQLite。
- Create: `docs/audits/milestone_19/19-5_security_android_smoke.md`
  - 記錄static、component、artifact、runtime四層evidence與命令輸出摘要。
- Modify: `packages/auth/test/auth_credential_read_result_test.dart`
  - 補齊`StoredAuthTokens`與credential read union的secret sentinel輸出契約。
- Modify: `packages/auth/test/auth_credential_migration_coordinator_test.dart`
  - 擴充migration result／diagnostic secret regression。
- Modify: `packages/auth/test/auth_lifecycle_cleanup_policy_test.dart`
  - 擴充cleanup diagnostic與error message secret regression。
- Modify: `apps/flutter_architecture/test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart`
  - 鎖定adapter error／result輸出不包含credential sentinel。
- Modify: `apps/flutter_architecture/test/features/auth/data/migration/auth_migration_error_reporter_adapter_test.dart`
  - 鎖定safe report context與reporter sink不輸出credential-bearing message。
- Modify: `README.md`
- Modify: `VERSION`（只在Task 8 final review核准升版時）
- Modify: `CHANGELOG.md`
- Modify: `docs/project_context.md`
- Modify: `docs/architecture_decisions.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/backlog.md`
- Modify: `docs/audits/milestone_19_planning_review.md`

---

### Task 1：Security surface inventory與secret regression

**Files:**
- Modify: `packages/auth/test/auth_credential_read_result_test.dart`
- Modify: `packages/auth/test/auth_credential_migration_coordinator_test.dart`
- Modify: `packages/auth/test/auth_lifecycle_cleanup_policy_test.dart`
- Modify: `apps/flutter_architecture/test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart`
- Modify: `apps/flutter_architecture/test/features/auth/data/migration/auth_migration_error_reporter_adapter_test.dart`
- Create: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [x] **Step 1：盤點credential-bearing output surface**

Run:

```bash
rg -n "toString\(|print\(|debugPrint\(|developer\.log|LogInterceptor|BlocObserver|Authorization|accessToken|refreshToken|password|raw payload|cause:" packages apps/flutter_architecture/lib
```

Expected:

- 產出待審清單。
- Production log／reporting不得直接展開credential-bearing object。
- 任何新發現先記入audit文件，不立即以猜測修改production code。

- [x] **Step 2：先寫失敗的統一sentinel regressions**

使用固定sentinel：

```dart
const accessSentinel = 'M19_ACCESS_SECRET_7f4a';
const refreshSentinel = 'M19_REFRESH_SECRET_2c91';
const passwordSentinel = 'M19_PASSWORD_SECRET_11de';
const pluginSentinel = 'M19_PLUGIN_SECRET_a63b';
```

每個credential-bearing value至少驗證：

```dart
final text = value.toString();
expect(text, isNot(contains(accessSentinel)));
expect(text, isNot(contains(refreshSentinel)));
expect(text, isNot(contains(passwordSentinel)));
expect(text, isNot(contains(pluginSentinel)));
```

涵蓋：

- `StoredAuthTokens`。
- `AuthCredentialReadPresent`。
- `AuthCredentialMigrationResolved / Unauthenticated`。
- `AuthLifecycleDiagnostic`。
- Secure adapter mapped `AppException`。
- `AuthMigrationErrorReporterAdapter`建立的`ErrorReport`與debug sink文字。

- [x] **Step 3：執行targeted tests確認RED或既有契約已完整**

Run:

```bash
cd packages/auth && flutter test test/auth_credential_read_result_test.dart test/auth_credential_migration_coordinator_test.dart test/auth_lifecycle_cleanup_policy_test.dart
cd ../../apps/flutter_architecture && flutter test test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart test/features/auth/data/migration/auth_migration_error_reporter_adapter_test.dart
```

Expected:

- 若任何credential出現在字串中，測試FAIL並精確指出type。
- 若全部已安全，新增測試仍應PASS並形成19-5明確evidence。

- [x] **Step 4：只修正已證實的production leakage**

允許修正方式：

- Freezed type加入或維持`toStringOverride: false`。
- 自訂`toString()`只輸出runtime type、operation與safe enum。
- Error message移除raw plugin message／credential payload。

禁止：

- 丟失原始error identity或stack。
- 將unknown error降級為expected Failure。
- 建立平行的redaction framework。

- [x] **Step 5：重跑targeted tests與analyze**

Run:

```bash
cd packages/auth && flutter test test/auth_credential_read_result_test.dart test/auth_credential_migration_coordinator_test.dart test/auth_lifecycle_cleanup_policy_test.dart
cd ../../apps/flutter_architecture && flutter test test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart test/features/auth/data/migration/auth_migration_error_reporter_adapter_test.dart
cd ../.. && dart run melos run analyze
```

Expected: PASS；五個workspace package analyze無issue。

- [x] **Step 6：記錄Task 1 evidence並commit**

```bash
git add packages/auth/test apps/flutter_architecture/test/features/auth/data docs/audits/milestone_19/19-5_security_android_smoke.md
git commit -m "test(auth): 補強Milestone 19 credential安全回歸"
```

- [x] **Step 7：進行Task 1 implementation review**

Review gate：

- 沒有credential sentinel進入任何一般字串輸出。
- Error identity／stack與Decision 020語意未退化。
- 無新增跨package redaction abstraction。

Task 1執行結果：新增統一Access／Refresh／Password／Plugin sentinels，覆蓋`StoredAuthTokens`、credential read union、migration result、lifecycle diagnostic、cleanup result、Secure adapter mapped `AppException`與App `ErrorReport`／safe context。Auth targeted 51項、App targeted 31項與五個workspace package analyze全數通過。新增regressions直接GREEN，確認既有production output已secret-safe，因此未修改production code；error identity、caught stack與Decision 020語意保持不變。

Task 1 implementation review：通過。Source inventory未發現production Token Pair、Authorization、password或raw payload直接輸出；沒有新增redaction framework、package dependency或runtime behavior change。

---

### Task 2：建立secret-safe deterministic HTTP fixture server

**Files:**
- Create: `tools/milestone_19_5/auth_fixture_server.py`
- Create: `tools/milestone_19_5/test_auth_fixture_server.py`

- [x] **Step 1：先寫server state machine tests**

測試必須覆蓋：

```python
def test_login_profile_401_refresh_replay_sequence(): ...
def test_refresh_is_called_once(): ...
def test_restart_profile_accepts_access_v2_without_refresh(): ...
def test_logs_never_include_raw_credentials_or_request_body(): ...
def test_wrong_refresh_token_returns_401_without_logging_value(): ...
```

固定state：

```python
ACCESS_V1 = "m19-access-v1"
REFRESH_V1 = "m19-refresh-v1"
ACCESS_V2 = "m19-access-v2"
REFRESH_V2 = "m19-refresh-v2"
USER_ID = "user-001"
```

Log event只允許：

```python
{
    "sequence": 1,
    "method": "GET",
    "path": "/profile",
    "status": 401,
    "credential_fingerprint": "<sha256-prefix>"
}
```

- [x] **Step 2：執行tests確認RED**

Run:

```bash
python -m unittest discover -s tools/milestone_19_5 -p "test_*.py" -v
```

Expected: FAIL，因server module尚未存在。

- [x] **Step 3：實作最小HTTP fixture server**

使用Python standard library：

```python
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
```

Endpoints：

- `POST /auth/login` → v1 Token Pair＋User。
- 第一次`GET /profile`＋access-v1 → 401。
- `POST /auth/refresh`＋refresh-v1 → v2 Token Pair。
- `GET /profile`＋access-v2 → 200。
- `GET /evidence` → 僅回傳sequence、count與fingerprint，不回raw credential。
- `POST /reset` → 清空state，僅供host orchestration使用。

Server不得print headers、body、exception repr或raw token。

- [x] **Step 4：執行server tests確認GREEN**

Run:

```bash
python -m unittest discover -s tools/milestone_19_5 -p "test_*.py" -v
```

Expected: 全部PASS。

- [x] **Step 5：執行secret scan**

Run:

```bash
rg -n "print\(.*Authorization|print\(.*password|print\(.*access|print\(.*refresh|request\.headers|request body" tools/milestone_19_5
```

Expected: 無不安全輸出。

- [x] **Step 6：commit**

```bash
git add tools/milestone_19_5
git commit -m "test(auth): 新增Android refresh fixture server"
```

- [x] **Step 7：進行Task 2 implementation review**

Review gate：

- Server state machine與production Retrofit JSON contract一致。
- Refresh只允許一次。
- Evidence endpoint不洩漏credential。
- Tool不進App dependency graph。

Task 2執行結果：先建立6項Python state machine tests，RED因`auth_fixture_server`不存在而正確失敗；GREEN新增Python standard library HTTPS fixture server，固定Login → Profile 401 → Refresh → Replay 200、單次refresh與restart access-v2 contract。Evidence只保存sequence、method、path、status及SHA-256前16碼fingerprint，停用HTTP預設request log，不保存headers、body或raw credential。6項unittest、`py_compile`、secret scan與diff check通過；未修改App或package production source。Task 2 implementation review通過，無Open P0／P1。

---

### Task 3：建立Android smoke orchestration與artifact gate

**Files:**
- Create: `tools/milestone_19_5/android_smoke.ps1`
- Modify: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [x] **Step 1：建立PowerShell參數與fail-fast checks**

Script parameters：

```powershell
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Avd = "flutter_architecture_m18",
  [string]$PackageId = "com.example.flutterarchitecture",
  [int]$FixturePort = 18443,
  [string]$EvidenceDir = "build/milestone_19_5_evidence"
)
```

必須fail fast檢查：

- `flutter`、`adb`、`python`、`openssl`、`git`存在。
- AVD存在且device boot完成。
- `adb root`成功；若失敗，停止並要求root-capable Google APIs AVD。
- `adb remount`成功，且temporary CA安裝前後都有可驗證cleanup path。
- App ID與release APK存在。
- Evidence directory不在Git tracked source內。

- [x] **Step 2：加入artifact metadata收集**

收集：

```txt
device serial
API level
ABI
AVD name
APK path
SHA-256
file size
versionName
versionCode
merged manifest path
minSdk
targetSdk
allowBackup
permissions
```

不得複製APK或credential payload進docs。

- [x] **Step 3：加入只讀sandbox evidence helpers**

只允許：

- 列出SharedPreferences filenames與key names。
- SQLite執行`SELECT slot, id, name FROM auth_user`。
- 檢查Secure Storage backing artifact是否存在／mtime／size。
- 搜尋Legacy key是否存在。

不得輸出：

- `auth.tokens` value。
- Secure Storage XML／DB raw value。
- Authorization、Access Token、Refresh Token、password。

- [x] **Step 4：加入temporary CA lifecycle helpers**

工具需以host-side openssl或Python產生一次性local CA與`localhost` server certificate，將CA certificate hash命名後推入emulator system trust store：

```txt
/system/etc/security/cacerts/<subject_hash>.0
```

要求：

- 只在`$PSCmdlet.ShouldProcess(...)`為true時執行。
- 安裝前記錄原始system CA檔案集合。
- smoke結束時移除該CA並重啟adbd；若cleanup失敗，整個Task失敗並要求wipe AVD。
- 不修改App manifest、network security config或Dio certificate callback。

- [x] **Step 5：加入logcat gate**

Script在每個journey前執行：

```powershell
adb logcat -c
```

每個journey後保存限定App process／Flutter tag的log，並掃描：

```txt
M19_ACCESS_SECRET
M19_REFRESH_SECRET
M19_PASSWORD_SECRET
Authorization:
Bearer m19-
FATAL EXCEPTION
```

任何命中均使Task失敗。

每個主要UI狀態還需收集：

- `adb shell dumpsys activity activities`中的resumed Activity。
- `adb shell uiautomator dump`產生的UI hierarchy。
- Login、authenticated、restart restored與logout後畫面的PNG screenshot及SHA-256。

Screenshot與UI dump只保存於untracked evidence directory；輸入password前或完成登入後才允許截圖，不得保存含明文password、Token或Authorization的畫面／hierarchy。

- [x] **Step 6：執行PowerShell parser／dry-run檢查**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/milestone_19_5/android_smoke.ps1 -WhatIf
```

Expected:

- 只檢查工具與列出將執行步驟。
- 不啟動server、不安裝APK、不修改device data。

- [x] **Step 7：commit**

```bash
git add tools/milestone_19_5/android_smoke.ps1 docs/audits/milestone_19/19-5_security_android_smoke.md
git commit -m "test(android): 建立Milestone 19 runtime smoke工具"
```

- [x] **Step 8：進行Task 3 implementation review**

Review gate：

- Script沒有直接寫入credential或SQLite。
- Release sandbox observation只依賴root-capable emulator。
- Evidence logs不包含secret。
- `-WhatIf`不產生side effect。
- Temporary CA一定有cleanup evidence；App production trust policy未改動。
- UI evidence可對應Login、authenticated、restored與unauthenticated狀態，且不含secret。

Task 3執行結果：新增Windows PowerShell 5.1相容的`android_smoke.ps1`，具`SupportsShouldProcess`與Plan／Prepare／Artifact／Install／ClearData／Launch／ForceStop／CaptureUi／InspectSandbox／Logcat／CA lifecycle／ReversePort actions。Parser、預設dry-run與`CreateCa -WhatIf`均通過且無side effect；實際短效CA chain與localhost SAN驗證通過；既有release APK metadata helper成功取得SHA-256、size、App ID、versionCode／versionName、minSdk 24與targetSdk 36。Static review未發現credential、SQLite或Session寫入helper，也未加入cleartext／certificate bypass；Task 3 implementation review通過，無Open P0／P1。

---

### Task 4：Current release Login、Restore與Logout runtime smoke

**Files:**
- Modify: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [x] **Step 1：啟動AVD並確認root capability**

Run:

```bash
flutter emulators --launch flutter_architecture_m18
adb wait-for-device
adb root
adb shell getprop sys.boot_completed
adb shell getprop ro.build.version.sdk
adb shell getprop ro.product.cpu.abi
```

Expected:

- `sys.boot_completed=1`。
- API 35、x86_64或實際記錄值。
- `adb root`成功。

- [x] **Step 2：建立current development release APK（Mock mode）**

Run:

```bash
cd apps/flutter_architecture
flutter build apk --release -t lib/main_development.dart --dart-define=API_MODE=mock
```

Expected: `build/app/outputs/flutter-apk/app-release.apk`建立成功。

- [x] **Step 3：執行clean install與Login journey**

流程：

- `pm clear`／install current release。
- UI Login。
- Profile與Protected Route成功。
- Legacy key不存在。
- Secure backing artifact存在。
- `auth_user`只有slot 1且identity為`user-001`。
- 保存Login完成後的UI hierarchy、screenshot hash與resumed Activity evidence。

- [x] **Step 4：執行force-stop／restart Restore**

流程：

- force-stop。
- restart。
- 直接進authenticated destination。
- Legacy key仍不存在。
- logcat無fatal／secret。
- 保存restart後的UI hierarchy、screenshot hash與resumed Activity evidence。

- [x] **Step 5：執行Logout cleanup**

流程：

- 先開Catalog建立public cache evidence。
- UI Logout。
- 回Login。
- Secure logical slot清除。
- Legacy key不存在。
- `auth_user`為空。
- Catalog cache tables仍有資料。
- force-stop／restart仍unauthenticated。
- 保存Logout後與restart後Login畫面的UI hierarchy、screenshot hash與resumed Activity evidence。

- [x] **Step 6：更新audit evidence並commit**

文件只記錄：

- 命令與exit status。
- device／artifact metadata。
- key存在／不存在。
- row count與safe identity。
- logcat scan結果。

```bash
git add docs/audits/milestone_19/19-5_security_android_smoke.md
git commit -m "test(android): 驗證Secure login restore與logout"
```

- [x] **Step 7：進行Task 4 implementation review**

Review gate：Login／Restore／Logout均由release App production orchestration完成，ADB沒有直接建立Session或credential。

Task 4執行結果：在`flutter_architecture_m18`（API 35、x86_64、root adbd）建立Mock mode development release APK並完成clean install。既有UI Login後Profile顯示`Water Magical`，Legacy keys不存在、Secure backing artifact存在、`auth_user`為`1|user-001|Water Magical`；force-stop／restart後直接恢復authenticated Profile。Catalog先建立1頁／12項public cache，Logout後回Login、`auth_user`清空且Legacy keys仍不存在，Catalog cache保持1頁／12項；再次restart仍unauthenticated。UI／Activity／screenshot hash／sandbox／logcat evidence均保存於untracked build directory，logcat gate無secret或fatal。執行中修正Task 3 SQLite helper的Windows quoting缺陷，維持只讀safe欄位查詢。Task 4 implementation review通過，無Open P0／P1。

---

### Task 5：Real API Refresh rotation與restart persistence smoke

**Files:**
- Modify: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [ ] **Step 1：啟動fixture server並reset state**

Run:

```bash
python tools/milestone_19_5/auth_fixture_server.py --host 127.0.0.1 --port 18443 --cert build/milestone_19_5_evidence/localhost.crt --key build/milestone_19_5_evidence/localhost.key --evidence build/milestone_19_5_evidence/fixture.jsonl
```

Expected: server啟動，不輸出raw credential。

- [ ] **Step 2：建立real API development release APK**

Run:

```bash
cd apps/flutter_architecture
flutter build apk --release -t lib/main_development.dart --dart-define=API_MODE=real --dart-define=API_BASE_URL=https://localhost:18443
adb reverse tcp:18443 tcp:18443
```

Expected: release APK建立成功，reverse rule存在。

- [ ] **Step 3：執行Login與401／Refresh／Replay**

UI執行Login並進Profile。

Fixture sequence必須精確為：

```txt
POST /auth/login       200
GET  /profile          401
POST /auth/refresh     200
GET  /profile replay   200
```

Assertions：

- Refresh endpoint只呼叫一次。
- Legacy key不存在。
- User identity不變。
- App保持authenticated。

- [ ] **Step 4：驗證rotated credential已持久化**

流程：

- Force-stop App。
- Fixture server保留只接受access-v2的state。
- Restart App。
- Restore後第一次Profile直接200。
- 不得再次呼叫`/auth/refresh`。

這是rotation persistence的必要evidence；mtime／size只能作輔助，不能單獨判定成功。

- [ ] **Step 5：掃描App與server logs**

Expected：

- Temporary CA存在於smoke期間，完成後已移除或AVD已wipe。
- 無raw Authorization。
- 無Access／Refresh Token。
- 無password／request body。
- 無App fatal。

- [ ] **Step 6：更新audit evidence並commit**

```bash
git add docs/audits/milestone_19/19-5_security_android_smoke.md
git commit -m "test(android): 驗證refresh rotation與restart restore"
```

- [ ] **Step 7：進行Task 5 implementation review**

Review gate：

- 實際經過Dio interceptor與AuthSessionRefresher。
- Replay只有一次。
- Restart後直接使用rotated credential。
- Host tooling沒有洩漏secret。

---

### Task 6：Predecessor release upgrade與Legacy migration smoke

**Files:**
- Modify: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [ ] **Step 1：建立temporary predecessor worktree**

Run:

```bash
git worktree add ../devspace-sandbox-m19-predecessor 05b3412
```

Expected: detached worktree建立，不修改main checkout。

- [ ] **Step 2：從`05b3412`建立相同App ID／signing的release APK**

Run in predecessor worktree:

```bash
cd apps/flutter_architecture
flutter pub get
flutter build apk --release -t lib/main_development.dart --dart-define=API_MODE=mock
```

Expected: predecessor APK建立成功，package ID為`com.example.flutterarchitecture`。

同時以`apksigner verify --print-certs`確認predecessor與current APK certificate SHA-256相同；若不同，不得使用`adb install -r`宣稱upgrade evidence。

- [ ] **Step 3：以predecessor production Login建立真實Legacy資料**

流程：

- `pm clear`。
- 安裝predecessor APK。
- UI Mock Login。
- Force-stop。
- Root只讀確認`auth.tokens` key與`auth_user` slot 1存在。
- Secure Storage current logical payload尚未建立。

不得手工寫XML或SQLite。

- [ ] **Step 4：升級安裝current release並執行Restore migration**

Run:

```bash
adb install -r <current-release-apk>
```

Expected：保留App data且安裝成功。

啟動後：

- 直接authenticated。
- Legacy key已刪除。
- Secure backing artifact建立。
- User identity保持`user-001`。

- [ ] **Step 5：再次force-stop／restart證明Secure authority接管**

Expected：

- 仍authenticated。
- Legacy key沒有重新出現。
- 不依賴predecessor APK或migration marker。
- logcat無retry loop、plugin failure、secret或fatal。

- [ ] **Step 6：移除temporary worktree**

Run:

```bash
git worktree remove ../devspace-sandbox-m19-predecessor
```

Expected: worktree乾淨移除。

- [ ] **Step 7：更新audit evidence並commit**

```bash
git add docs/audits/milestone_19/19-5_security_android_smoke.md
git commit -m "test(android): 驗證Legacy credential升級migration"
```

- [ ] **Step 8：進行Task 6 implementation review**

Review gate：fixture由舊版production Login產生；current release只透過production Restore migration處理；ADB未手工建立成功結果。

---

### Task 7：完整regression、artifact與security gate

**Files:**
- Modify: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [ ] **Step 1：dependency與generation gate**

Run:

```bash
dart pub get
dart run melos run build_runner
git diff --exit-code -- '*.g.dart' '*.freezed.dart' '*injection.config.dart'
```

Expected: dependency與generation成功；generated source與預期一致。

- [ ] **Step 2：workspace analyze與完整tests**

Run:

```bash
dart run melos run analyze
dart run melos exec -- flutter test
python -m unittest discover -s tools/milestone_19_5 -p "test_*.py" -v
```

Expected：

- 五個package analyze通過。
- 完整Flutter tests不少於536項。
- Python fixture tests全數通過。

- [ ] **Step 3：release artifact與manifest gate**

Run:

```bash
cd apps/flutter_architecture
flutter build apk --release -t lib/main_development.dart --dart-define=API_MODE=mock
```

檢查：

- APK SHA-256／size。
- merged manifest實際minSdk／targetSdk。
- `android:allowBackup="false"`。
- permission只包含既有必要權限。
- 無`USE_BIOMETRIC`、`USE_FINGERPRINT`、OTP、Device Binding或Passkey dependency／permission。

- [ ] **Step 4：source與generated DI scan**

Run:

```bash
rg -n "secureAuthCredentialStore|secureLifecycle|SharedPreferencesAuthCredentialStore\(" apps/flutter_architecture/lib packages/auth/lib
rg -n "AuthCredentialStore|AuthCredentialMigrationCoordinator|AuthSessionRefresher|AuthRepositoryImpl" apps/flutter_architecture/lib/app/di/injection.config.dart
```

Expected：

- Production只有default Secure `AuthCredentialStore`。
- Repository、Refresher、Migration Coordinator共用該binding。
- Legacy adapter只負責migration／cleanup。

- [ ] **Step 5：完整security scan**

Run:

```bash
rg -n "print\(|debugPrint\(|developer\.log|LogInterceptor|Authorization|Cookie|raw payload|accessToken|refreshToken|password" packages apps/flutter_architecture/lib tools/milestone_19_5
```

逐項分類：

- Legitimate model／serialization usage。
- Test-only sentinel。
- Unsafe output（必須修正後重跑Task 1 review）。

- [ ] **Step 6：更新regression evidence並commit**

```bash
git add docs/audits/milestone_19/19-5_security_android_smoke.md
git commit -m "test(auth): 完成Milestone 19 security regression gate"
```

- [ ] **Step 7：進行Task 7 implementation review**

Review gate：無Open P0／P1；所有runtime evidence可重現；test count未退化；artifact claim不超過實際證據。

---

### Task 8：Finding closure、版本判斷與Milestone 19封存

**Files:**
- Modify: `README.md`
- Modify: `VERSION`（僅核准升版時）
- Modify: `CHANGELOG.md`
- Modify: `docs/project_context.md`
- Modify: `docs/architecture_decisions.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/backlog.md`
- Modify: `docs/audits/milestone_19_planning_review.md`
- Modify: `docs/audits/milestone_19/19-5_security_android_smoke.md`

- [ ] **Step 1：以runtime evidence關閉`M19-PR05`**

Finding更新必須包含：

- Android release artifact metadata。
- Root-capable emulator環境。
- Login／Restore／Refresh／Migration／Logout runtime evidence。
- Logcat與host logs無secret。
- 能力只描述為credential-at-rest hardening。
- 明確不防rooted device、runtime memory或server compromise。

- [ ] **Step 2：進行版本判斷**

判斷規則：

- 若Milestone 19被正式列為新的可交付Template能力，更新`VERSION`至下一個MINOR，並新增對應CHANGELOG release section。
- 若只補完1.2.0既有安全承諾，維持`1.2.0`，只更新`Unreleased`與文件。

不得因「Milestone完成」本身自動升版；需記錄review理由。

- [ ] **Step 3：同步所有文件**

必須一致表達：

- Android為唯一Supported target。
- Secure Storage只保存credential；User仍在SQLite；Legacy SharedPreferences只供migration／cleanup。
- Runtime evidence已完成。
- OTP、Biometric、Device Binding、Passkey仍是後續Milestone。
- Milestone 20只有在19正式封存後才可開始。

- [ ] **Step 4：文件一致性scan**

Run:

```bash
rg -n "19-5|M19-PR05|SharedPreferences authority|Secure authority|下一步|VERSION|OTP|Biometric" README.md CHANGELOG.md VERSION docs
git diff --check
```

Expected：

- 現況文件無互相矛盾。
- 歷史19-1至19-4紀錄維持當時正確描述。
- 無Open P0／P1。

- [ ] **Step 5：最終完整驗證**

Run:

```bash
dart pub get
dart run melos run analyze
dart run melos exec -- flutter test
python -m unittest discover -s tools/milestone_19_5 -p "test_*.py" -v
cd apps/flutter_architecture && flutter build apk --release -t lib/main_development.dart --dart-define=API_MODE=mock
```

Expected：全部PASS，Flutter tests不少於536項。

- [ ] **Step 6：進行Milestone 19 final implementation review**

Final gate：

- `M19-PR01`至`M19-PR06`全部Closed或依正式scope有明確非阻塞disposition。
- 無Open P0／P1。
- Runtime evidence可重現且未使用測試後門。
- Security claim不超過at-rest hardening。
- 版本判斷有明確理由。

- [ ] **Step 7：建立封存commit並推送**

若升版：

```bash
git add README.md VERSION CHANGELOG.md docs
git commit -m "docs(release): 封存Milestone 19並發布新基線"
git push origin main
```

若維持1.2.0：

```bash
git add README.md CHANGELOG.md docs
git commit -m "docs(auth): 封存Milestone 19安全儲存與migration"
git push origin main
```

---

## Plan review checklist

- [ ] 每個runtime成功結果都由release App production flow產生。
- [ ] ADB沒有直接寫入credential、User或Session。
- [ ] Refresh使用real API mode與Dio interceptor，不使用Mock shortcut。
- [ ] Rotation persistence以force-stop／restart＋access-v2直接成功驗證。
- [ ] Migration fixture由`05b3412` predecessor production Login產生。
- [ ] Root只用於test environment evidence，不形成安全能力宣稱。
- [ ] Host server與PowerShell tooling不輸出credential。
- [ ] Refresh HTTPS使用temporary test CA，App manifest／Dio trust policy不為smoke弱化。
- [ ] 每個Task有獨立implementation review。
- [ ] 最終版本判斷只在完整runtime與security gate後進行。

