# Milestone 19-2 Secure Credential Store Adapter Implementation Plan

> **狀態：** Passed；plan review已通過，可開始production implementation。

**Goal:** 在App layer建立可獨立測試的`flutter_secure_storage` credential adapter、typed failure mapping與DI shape，但維持SharedPreferences為19-2 production credential authority。

**Architecture:** `packages/auth`既有`AuthCredentialStore`、`AuthCredentialReadResult`與`StoredAuthTokens`contract不修改plugin邊界。App新增`FlutterSecureAuthCredentialStore`，以named `AuthCredentialStore` binding提供給後續migration coordinator；default `AuthCredentialStore` binding仍指向`SharedPreferencesAuthCredentialStore`。19-2不實作migration、不改Repository / Refresher constructor、不改Login / Restore / Refresh / Logout source of truth。

---

## 19-2 Scope

19-2必須做到：

- `flutter_secure_storage`只加入`apps/flutter_architecture`dependency。
- App layer新增Secure credential adapter。
- Token Pair維持單一logical JSON payload，包含`accessToken`、`refreshToken`、`userId`與expiration metadata。
- Secure read明確區分`absent / present / corrupted`。
- Plugin / platform operational failure映射為`AppExceptionKind.localStorage`，保留原始cause與stack。
- Diagnostic message、exception與`toString()`不得包含raw payload或credential。
- DI建立named secure `AuthCredentialStore` singleton，但default production binding仍為SharedPreferences adapter。
- 完成Android backup設定審查、adapter tests、DI tests與Android artifact build。

19-2不得做到：

- 不切換default `AuthCredentialStore`到Secure adapter。
- 不修改Repository或Refresher persistence authority。
- 不讀取或刪除SharedPreferences legacy credential。
- 不建立`AuthCredentialMigrationCoordinator`。
- 不實作Secure × Legacy × User decision matrix。
- 不建立persistent migration marker。
- 不加入OTP、Biometric、Device Binding或`local_auth`。
- 不建立Generic Secure Store framework。
- 不更新`VERSION`。

---

## 已拍板設計

### 1. Secure payload contract

Secure Store只保存一筆Auth-specific logical payload：

```txt
key: auth.tokens
value: StoredAuthTokens.toJson() encoded JSON string
```

禁止拆成多個secure keys，避免Access Token、Refresh Token、identity與expiration metadata出現partial write state。

### 2. Read taxonomy

```txt
storage.read == null
  → AuthCredentialReadAbsent

storage.read returns valid JSON map
  → AuthCredentialReadPresent

storage.read returns malformed / incomplete logical payload
  → AuthCredentialReadCorrupted

storage API / platform operation throws
  → AppException(kind: localStorage)
```

Corruption是可讀取但payload不符合contract；unavailable是operation無法完成。兩者不得互換。

### 3. Write與clear contract

- `writeCredential()`只執行一次logical payload write。
- `clearCredential()`只刪除Secure credential key，具idempotent語意。
- Plugin operational exception轉成local-storage `AppException`。
- Unknown non-plugin programming error不得被誤分類為absence或corruption。
- Adapter不負責read-back validation；migration write後read-back驗證由19-3 coordinator負責。

### 4. DI authority contract

19-2同時存在兩個`AuthCredentialStore` implementation：

```txt
default AuthCredentialStore
  → SharedPreferencesAuthCredentialStore
  → 19-2 production authority

@Named('secureAuthCredentialStore') AuthCredentialStore
  → FlutterSecureAuthCredentialStore
  → dependency-ready，尚未進入lifecycle
```

Repository與Refresher仍解析default binding。DI test必須證明Secure Store可獨立解析，且default binding沒有改變。

### 5. Android platform contract

- 使用`flutter_secure_storage: ^10.3.1` stable版本與預設Android cryptography options，不啟用biometric mode。
- Android最低SDK明確提升為23，因10.x stable的Android implementation已不支援API 22以下；不得依賴build失敗後才被動發現。
- Android backup policy明確採`android:allowBackup="false"`，避免encrypted payload被還原到沒有原KeyStore key的裝置。這是19-2刻意採用的App-wide安全政策，文件與contract test必須明示其影響，不使用未經驗證的plugin-private路徑做選擇性exclude。
- 不加入`USE_BIOMETRIC`permission。
- compileSdk與targetSdk仍維持Flutter-managed；只有minimum SDK依官方10.x requirement固定為23。
- 19-2 Android evidence為artifact build與manifest contract；實機credential runtime smoke保留19-5。

---

## Task 1：Dependency與Android contract tests

**Files:**

- Modify: `apps/flutter_architecture/pubspec.yaml`
- Modify: `apps/flutter_architecture/android/app/src/main/AndroidManifest.xml`
- Modify: `apps/flutter_architecture/android/app/build.gradle.kts`
- Create: `apps/flutter_architecture/test/app/platform/secure_storage_android_contract_test.dart`

- [x] **Step 1：先寫failing Android contract test**

驗證：

- App dependency精確宣告`flutter_secure_storage: ^10.3.1`。
- Android manifest明確設定`android:allowBackup="false"`。
- Android app minimum SDK固定為23。
- 不加入biometric permission或biometric-specific設定。

- [x] **Step 2：執行failing test**

```bash
cd apps/flutter_architecture
flutter test test/app/platform/secure_storage_android_contract_test.dart
```

Expected：FAIL，因dependency與backup policy尚未加入。

- [x] **Step 3：加入App-only dependency與最小Android設定**

加入`flutter_secure_storage: ^10.3.1`。設定`android:allowBackup="false"`並將App minimum SDK固定為23；不修改package dependency、不加入biometric permission。

- [x] **Step 4：執行dependency resolution與contract test**

```bash
dart pub get
cd apps/flutter_architecture
flutter test test/app/platform/secure_storage_android_contract_test.dart
```

- [x] **Step 5：Commit**

```bash
git commit -m "build(auth): 加入Secure Storage App依賴"
```

Task 1執行結果：先以contract test確認缺少dependency而進入RED；其後App加入`flutter_secure_storage: ^10.3.1`、Android minimum SDK固定為23、manifest設定`android:allowBackup="false"`，且未加入biometric permission。新舊Android contract tests共2項通過，App analyze無問題；`packages/`沒有新增Secure Storage dependency。

Task 1 implementation review：通過。Dependency ownership、minimum SDK、App-wide backup policy與source contract均符合plan；未改動DI或Auth lifecycle。Merged manifest的最終permission evidence留到Task 5 Android artifact review驗證。

---

## Task 2：Secure adapter happy path與typed corruption

**Files:**

- Create: `apps/flutter_architecture/lib/features/auth/data/stores/flutter_secure_auth_credential_store.dart`
- Create: `apps/flutter_architecture/test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart`
- Modify: `apps/flutter_architecture/pubspec.yaml` dev dependency（若測試需要直接實作platform interface fake）

- [x] **Step 1：先寫adapter failing tests**

至少覆蓋：

- absence。
- valid Token Pair round-trip。
- non-JSON。
- JSON非map。
- missing access / refresh token。
- missing或invalid `userId`。
- invalid expiration metadata。
- write只保存一筆logical payload。
- clear idempotent。
- adapter / result diagnostic不包含secret sentinel。

- [x] **Step 2：執行RED**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart
```

- [x] **Step 3：實作最小Secure adapter**

Adapter constructor接受`FlutterSecureStorage`，只依賴public `auth` contracts，不import `package:auth/src/...`。Happy-path可使用`FlutterSecureStorage.setMockInitialValues()`；failure-path若需控制platform result，App test可顯式加入相容的`flutter_secure_storage_platform_interface` dev dependency並安裝test fake，不建立production generic wrapper。

- [x] **Step 4：執行GREEN與analyze**

```bash
flutter test test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart
dart analyze .
```

- [x] **Step 5：Commit**

```bash
git commit -m "feat(auth): 建立Secure credential adapter"
```

Task 2執行結果：新增App-owned `FlutterSecureAuthCredentialStore`，以單一`auth.tokens` JSON payload保存完整Token Pair。Read明確區分absence、valid present與malformed / incomplete corruption；Secure payload要求非空白`userId`，write也會在plugin呼叫前拒絕缺失或空白identity，避免主動寫入下一次必定corrupted的資料。Happy path、round-trip、單key write、absence、8類corruption、invalid write identity、idempotent clear與secret-safe result diagnostics共17項tests通過；plugin failure mapping保留Task 3處理。

Task 2 implementation review：修正write-side必要欄位驗證缺口。`StoredAuthTokens` constructor為legacy相容允許空字串Token，但Secure adapter不得寫入下一次read必定corrupted的payload；現已在plugin呼叫前拒絕空Access / Refresh Token，且validation error不攜帶credential object或secret value。Secure adapter targeted tests增為19項，App analyze與diff check通過；Task 3 plugin failure mapping仍未提前實作。

---

## Task 3：Plugin failure mapping與error identity review

**Files:**

- Modify: `apps/flutter_architecture/lib/features/auth/data/stores/flutter_secure_auth_credential_store.dart`
- Modify: `apps/flutter_architecture/test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart`

- [x] **Step 1：新增failing failure tests**

覆蓋read / write / delete的plugin failure：

- 映射為`AppExceptionKind.localStorage`。
- `cause`保留原始error identity。
- `stackTrace`保留origin stack。
- message與`toString()`不包含raw JSON、access token、refresh token。
- 已是`AppException`時不重複包裝。
- `PlatformException`與`MissingPluginException`視為plugin / platform operational failure並映射為local-storage `AppException`。
- 已是`AppException`時原樣rethrow，不重複包裝。
- 其他unknown programming error保持unexpected，不被降級成local-storage、corruption或absence。

- [x] **Step 2：完成最小failure mapping**

只捕捉明確的Secure Storage operational exception種類；禁止catch-all後統一包成local-storage。Payload decode corruption在typed result內處理，非plugin的`StateError`、`TypeError`等保持原始error與stack。

- [x] **Step 3：執行targeted regression**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart
dart analyze .
```

- [x] **Step 4：Commit**

```bash
git commit -m "fix(auth): 補強Secure Storage錯誤邊界"
```

Task 3執行結果：App test新增`flutter_secure_storage_platform_interface` test-only直接依賴，透過可控platform fake覆蓋read / write / delete。`PlatformException`與`MissingPluginException`會映射為`AppExceptionKind.localStorage`，保留原始cause與origin stack identity；既有`AppException`原樣rethrow，`StateError`與`TypeError`等unknown programming error保持原始error與stack。固定diagnostic message不包含plugin message、raw payload或credential sentinel。Secure adapter targeted tests增為26項，App analyze與diff check通過。

Task 3 implementation review：通過。確認`flutter_secure_storage` 10.3.1公開read / write / delete contract以`PlatformException`表達平台失敗，現有窄範圍mapping沒有catch-all或錯誤降級。Review補強實際caught stack identity、既有`AppException`rethrow stack與read / write / delete固定安全訊息regression；targeted tests與App analyze重新通過。

---

## Task 4：Named DI shape，不切換production authority

**Files:**

- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Generate: `apps/flutter_architecture/lib/app/di/injection.config.dart`
- Create: `apps/flutter_architecture/test/app/di/register_module_secure_auth_store_test.dart`

- [ ] **Step 1：先寫failing DI test**

驗證：

- default `AuthCredentialStore`仍為`SharedPreferencesAuthCredentialStore`。
- named `secureAuthCredentialStore`解析為`FlutterSecureAuthCredentialStore`。
- named Secure Store為lazy singleton。
- Repository與Refresher仍使用default SharedPreferences authority。
- Secure Store寫入不會被現有Repository restore讀取。

- [ ] **Step 2：執行RED**

```bash
cd apps/flutter_architecture
flutter test test/app/di/register_module_secure_auth_store_test.dart
```

- [ ] **Step 3：更新RegisterModule並生成DI**

提供`FlutterSecureStorage`與named Secure `AuthCredentialStore` binding；禁止手動修改generated source。

- [ ] **Step 4：執行generation與DI tests**

```bash
dart run melos run build_runner
cd apps/flutter_architecture
flutter test test/app/di/register_module_secure_auth_store_test.dart
flutter test test/app/di/register_module_auth_persistence_test.dart
```

- [ ] **Step 5：Commit**

```bash
git commit -m "refactor(di): 組裝Secure credential adapter"
```

---

## Task 5：Android artifact與19-2 regression gate

**Files:**

- Modify: `docs/audits/milestone_19_planning_review.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/project_context.md`
- Modify: `CHANGELOG.md`
- Modify: this plan

- [ ] **Step 1：執行targeted tests**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/flutter_secure_auth_credential_store_test.dart
flutter test test/app/di/register_module_secure_auth_store_test.dart
flutter test test/app/platform/secure_storage_android_contract_test.dart
```

- [ ] **Step 2：執行workspace validation**

```bash
cd ../..
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build apk --release
cd ../..
git diff --check
```

Expected：全部通過；既有437 tests不得無理由遺失。

- [ ] **Step 3：進行19-2 implementation review**

Review checklist：

- Secure dependency只存在App。
- Adapter只依賴public Auth contract。
- Single logical payload與typed read taxonomy正確。
- Operational failure沒有降級為absence / corruption。
- Raw credential不進入diagnostic。
- Default authority仍是SharedPreferences。
- Named Secure binding沒有被Repository / Refresher使用。
- 沒有migration、Secure source-of-truth切換、OTP或Biometric行為。
- Android release artifact build通過。

- [ ] **Step 4：同步文件與finding evidence**

只有review通過後才將19-2標記Completed、更新M19-PR03與M19-PR05 evidence，並把下一步切換19-3。`VERSION`維持不變。

- [ ] **Step 5：Commit封存文件**

```bash
git commit -m "docs(auth): 封存 Milestone 19-2 Secure adapter"
```

---

## 19-2 Review Gate

必須全部成立才能進入19-3：

- `flutter_secure_storage`只由App依賴。
- Secure adapter與typed read / failure mapping已有tests。
- Token Pair為單一logical payload。
- Named Secure DI binding可解析且為singleton。
- Default SharedPreferences production authority未改變。
- Repository / Refresher runtime behavior未改變。
- Android backup policy與artifact build通過。
- Workspace analyze與完整tests通過。
- 未加入migration、OTP、Biometric、Native biometric設定或VERSION變更。

Gate通過後，下一階段才是：

```txt
Milestone 19-3 — SharedPreferences Legacy Migration
```

---

## Plan Review 結論

狀態：Passed。

- `M19-2-PLAN01`：原草案只寫`flutter_secure_storage 10.x`，會讓dependency resolution隨時間漂移。已固定為目前stable `^10.3.1`，且不採11.0 prerelease。
- `M19-2-PLAN02`：原草案把minimum SDK調整寫成build失敗後才處理，但10.x已明確要求Android API 23。已改為Task 1的正式Native contract。
- `M19-2-PLAN03`：原草案只要求「安全backup policy」，沒有拍板App-wide disable或選擇性exclude。為避免依賴plugin-private storage path，19-2固定採`android:allowBackup="false"`，並明示這是App-wide安全政策。
- `M19-2-PLAN04`：原failure mapping描述可能導致catch-all，把programming error錯誤降級為local-storage failure。已限制只映射`PlatformException`、`MissingPluginException`與既有`AppException`，其他unknown error保持unexpected。
- `M19-2-PLAN05`：adapter直接接受`FlutterSecureStorage`；測試以plugin提供的mock initial values與platform-interface fake控制，不新增production generic secure-store wrapper。
- Named Secure binding與default SharedPreferences authority的分離成立，19-2不會提前切換Repository / Refresher source of truth。
- 無Open P0 / P1 planning issue。

