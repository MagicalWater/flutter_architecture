# Milestone 19-5 — Security Review、Android Smoke與封存 Design

## 目標

完成Milestone 19 Secure Credential Storage & Migration的最終安全審查、Android release artifact與runtime evidence，確認Login、Restore、Refresh rotation、Legacy migration與Logout cleanup在真實Android runtime使用同一Secure credential authority，且不透過log、exception、reporting或字串輸出洩漏credential。

本階段不新增Auth產品功能；主要產出是可重現的security evidence、Android smoke紀錄、完整regression與Milestone 19封存文件。

## 核准方案

採用「ADB fixture＋既有UI／可控HTTP fixture驗證」。

- 沿用既有`flutter_architecture_m18` Android emulator。
- 使用release APK執行runtime smoke。
- 透過ADB、root-capable emulator與前版release APK建立、檢查或清理測試fixture。
- 一般Login／Restore／Logout可使用既有Mock API；Refresh rotation使用development release＋real API mode＋host-side可控HTTP fixture server。
- 使用既有Login UI、Profile、Protected Route與Logout流程。
- 不新增debug-only頁面、隱藏按鈕、runtime authority flag或測試後門。
- 不修改Secure credential production contract以方便測試。

## Evidence分級

19-5必須區分以下證據，不得互相代替：

1. **Static source evidence**
   - Source scan確認credential不進`toString()`、diagnostic safe context、log message或Failure display。
   - Source與generated DI graph確認只有一個default Secure authority。

2. **Component test evidence**
   - Auth、adapter、migration、DI與sensitive-data regression通過。
   - Expected與unknown error identity、stack與reporting語意維持既有contract。

3. **Artifact evidence**
   - Release APK成功建立。
   - Merged manifest確認實際minSdk、targetSdk、backup policy與permission集合。
   - APK inspection不出現Biometric、Fingerprint、OTP或其他非目標能力。

4. **Android runtime evidence**
   - Release APK可安裝、啟動並保持MainActivity resumed。
   - Login、restart restore、refresh rotation、Legacy migration與Logout cleanup實際執行。
   - Logcat無App fatal error及credential sentinel。

只有第四類可以完整關閉`M19-PR05`的Android runtime evidence要求。

## Android環境

- AVD：`flutter_architecture_m18`。
- Target：既有Android 35 Google APIs x86_64 emulator設定。
- App ID：`com.example.flutterarchitecture`。
- Build mode：release APK。
- Runtime API mode分兩條：一般journey使用development／Mock API；Refresh rotation使用development／`API_MODE=real`，由`adb reverse`連接host-side ephemeral HTTP fixture server。
- HTTP fixture server只屬repo tooling／runtime evidence，不進App production graph，不保存Authorization或request body。

啟動前記錄：

- emulator API level、ABI與device serial。
- `adb root`是否成功；若既有AVD不是root-capable，必須改用Google APIs root-capable AVD，不得以release `run-as`作為替代。
- APK路徑、SHA-256與檔案大小。
- App versionName／versionCode。
- VERSION仍為`1.2.0`，除非最終review另行核准Template Baseline更新。

## ADB fixture原則

ADB只用於準備與觀察測試狀態，不得繞過production Auth orchestration直接製造「成功結果」。

允許：

- `pm clear`建立乾淨安裝狀態。
- 在root-capable emulator上以`adb root`只讀檢查App sandbox中的SharedPreferences、SQLite metadata與非明文Secure Storage backing artifacts；root只用於evidence觀察，不構成rooted-device resistance證明。
- 以原子authority切換前的既有release commit `05b3412`建立predecessor APK，透過該版production Login寫出真實Legacy SharedPreferences＋SQLite User狀態，再以`adb install -r`升級目前release APK並保留App data。
- force-stop／restart驗證process death後Restore。
- 清除logcat並收集指定時間窗內的App logs。

禁止：

- 直接寫入runtime Session memory。
- 直接以ADB寫入SQLite user、Legacy credential或Secure credential後宣稱Login／migration成功。Migration輸入必須由predecessor release APK的production Login產生。
- 解密或輸出Secure Storage raw credential。
- 在文件中保存真實Access Token、Refresh Token、password或Authorization值。

測試fixture使用固定synthetic sentinel，文件只記錄其雜湊或是否存在，不保存完整credential值。

## Runtime smoke流程

### 1. Clean install與Login

1. 清除舊App資料並安裝release APK。
2. 啟動App，確認bootstrap完成且顯示Login。
3. 透過既有Mock Login登入。
4. 確認導向Profile，Protected Route可進入。
5. 確認Legacy SharedPreferences credential key不存在。
6. 確認Secure Storage backing artifacts已建立，但不讀取或輸出raw payload。
7. 確認SQLite single-active-user資料存在且identity與登入user一致。

### 2. Force-stop／restart Restore

1. Force-stop App。
2. 重新啟動release APK。
3. 確認App直接恢復authenticated狀態，不回到Login。
4. 確認Restore使用Secure authority，Legacy credential仍不存在。
5. 確認logcat沒有credential、raw payload或App fatal error。

### 3. Refresh rotation

Refresh smoke必須使用production `AuthRefreshInterceptor → AuthSessionRefresher`路徑，不直接呼叫store adapter。

固定方式：建立development release APK並使用`--dart-define=API_MODE=real`與`--dart-define=API_BASE_URL=http://127.0.0.1:18080`；透過`adb reverse tcp:18080 tcp:18080`連接host-side ephemeral HTTP fixture server。Mock API implementation不經Dio，不能作為Refresh Interceptor runtime evidence。

HTTP fixture server必須提供：

- `POST /auth/login`：回傳synthetic access-v1／refresh-v1與固定user identity。
- 第一次`GET /profile`且Bearer為access-v1：回401。
- `POST /auth/refresh`且refresh token為refresh-v1：回access-v2／refresh-v2。
- replay `GET /profile`且Bearer為access-v2：回200。
- 僅記錄request sequence、status與token fingerprint，不記錄raw Authorization、password、Access Token、Refresh Token或request body。

驗證：

- server request sequence必須精確為Login → Profile 401 → Refresh 200 → Profile replay 200，且refresh endpoint只呼叫一次。
- Secure credential payload已發生rotation，可透過安全metadata、檔案變更或test-known token fingerprint證明，但不輸出token。
- Legacy SharedPreferences credential未重新出現。
- SQLite user identity保持一致。
- runtime Session access token與Secure authority同步。
- rotation完成後force-stop／restart；server保留scenario state並只接受access-v2。重啟後第一次Profile request必須直接200且不得再次呼叫refresh，證明rotated credential已持久化並由Restore重建runtime Session。

不得修改App Mock implementation來製造401，也不得新增UI測試後門、runtime authority flag或release-only分支。若real API release無法連接fixture server，先修正host tooling、`adb reverse`或既有network configuration；只有確認production defect後才能以TDD修改App code並進行獨立implementation review。

### 4. Legacy migration

1. 建立獨立temporary Git worktree並checkout原子authority切換前的`05b3412`。
2. 從該commit建立相同App ID與相同local signing的development release APK。
3. `pm clear`後安裝predecessor APK，透過其production Mock Login建立Legacy SharedPreferences credential與SQLite User。
4. Force-stop predecessor App；以root只讀證據確認Legacy key與User存在，且Secure logical payload尚未建立。
5. 以`adb install -r`安裝目前release APK，保留既有App data。
6. 啟動目前release APK。
7. 確認Restore migration成功並進入authenticated狀態。
8. 確認Legacy credential已刪除。
9. 確認Secure authority backing artifacts存在並可支援再次force-stop／restart Restore。
10. 再次啟動後不得重寫或依賴Legacy credential。

Migration evidence不得以只執行unit test替代。

### 5. Logout destructive cleanup

1. 從authenticated狀態執行既有Logout UI。
2. 確認回到Login。
3. Force-stop／restart後仍保持unauthenticated。
4. 確認Legacy credential不存在。
5. 確認Secure credential logical slot已清除；只記錄read result或backing metadata，不輸出raw值。
6. 確認SQLite Auth User slot已清除。
7. 確認public Catalog Cache仍保留，符合既有Logout persistence contract。

## Security audit範圍

### Credential-bearing types

至少審查：

- Login request／response DTO。
- Refresh request／response DTO。
- `AuthResult`。
- `StoredAuthTokens`。
- `AuthCredentialReadResult`。
- `AuthCredentialMigrationResult`與diagnostics。
- Auth lifecycle diagnostics與cleanup result。
- Bloc event／state。
- AppException、Failure與ErrorReport。

### Output channels

至少審查：

- `toString()`與generated Freezed輸出。
- Debug／ErrorReporter adapters。
- `print`、`debugPrint`、`developer.log`、Dio logger與Bloc observer。
- Exception message、cause、stack與safe context。
- Android logcat。
- Test failure message與golden／snapshot文字。

### Sentinel strategy

使用不可能自然出現的synthetic secret sentinel，驗證以下輸出均不包含它：

- DTO／entity／event／state字串。
- AppException／Failure／diagnostic／ErrorReport字串。
- Debug reporter sink。
- Android runtime logcat。

既有Milestone 17 secret-sentinel tests應延伸至19-1至19-4新增的migration與lifecycle types，不重複建立平行測試framework。

## Error與reporting要求

- Expected local-storage cleanup failure維持degraded diagnostic，不改變合法fallback／Session expiration語意。
- Unknown error不得被reporter吞掉或降級；保留identity與caught stack進unexpected flow。
- Reporter failure採best-effort隔離，不得造成Auth lock重入、App啟動失敗或合法Restore結果改變。
- Runtime smoke期間若發現App fatal、plugin exception、migration retry loop或Session／store不一致，Milestone不得封存，必須回到TDD修正與implementation review。

## 文件與finding closure

完成後同步：

- `README.md`：Android Secure credential runtime capability與限制。
- `docs/project_context.md`：19-5實際artifact、runtime與regression evidence。
- `docs/architecture_decisions.md`：Decision 022 final implementation evidence與能力邊界。
- `docs/roadmap.md`：19-5完成狀態與Milestone 20 gate。
- `docs/backlog.md`：只保留future／deferred security scope。
- `docs/audits/milestone_19_planning_review.md`：以Android runtime evidence關閉`M19-PR05`。
- `CHANGELOG.md`：Milestone 19 final summary。

歷史19-1至19-4文件保留當時正確的階段性authority描述，不回寫成現在狀態。

## 版本規則

19-5開始時`VERSION`維持`1.2.0`。

最終review再判斷：

- 若Secure credential storage與migration被視為現有1.2.0 baseline的完成性安全修正，可維持`1.2.0`。
- 若正式將Secure credential runtime能力作為新的可交付Template Baseline capability，依Semantic Versioning應評估升至下一個MINOR版本。

不得在runtime smoke或security review完成前提前升版。

## 非目標

- OTP。
- Biometric Prompt或`local_auth`。
- Device Binding、hardware attestation或Passkey。
- Root／jailbreak detection。
- 宣稱可防rooted device、runtime memory scraping或server compromise。
- 將Theme、Locale、Catalog Cache或一般preference遷移到Secure Storage。
- 建立永久保留的smoke UI、debug menu或credential inspector。

## 完成定義

Milestone 19-5只有在以下全部成立時才可封存：

- Security source audit與secret sentinel regressions通過。
- Workspace analyze與完整tests不低於19-4的536項。
- Release APK與merged manifest驗證通過。
- Android emulator完成Login、restart Restore、Refresh rotation、Legacy migration與Logout cleanup。
- Runtime logcat與host-side HTTP fixture logs都不包含credential sentinel、raw Authorization或App fatal error。
- `M19-PR05`有Android runtime evidence並正式Closed。
- README、Architecture Decision、Project Context、Roadmap、Backlog與CHANGELOG一致。
- 完整implementation review無Open P0／P1。
- Final review完成版本判斷後才建立Milestone 19封存commit。

