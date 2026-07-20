# Milestone 19-1 Auth Persistence Seam Implementation Plan

Status: Reviewed / Ready for implementation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將 Auth credential、legacy credential 與 user persistence 拆成狹窄、Auth-specific boundary，將 SharedPreferences / SQLite plugin adapter 移至 App layer，並維持既有 Login、Restore、Refresh、Logout runtime behavior 完全等價。

**Architecture:** `packages/auth`只保留純Dart contract、model、repository與refresh orchestration；App layer提供SharedPreferences與SQLite adapter並在唯一Composition Root完成binding。19-1不加入Secure Storage、不切換credential authority、不實作migration policy，只先建立可供19-2至19-4使用的穩定seam。

**Tech Stack:** Dart 3、Flutter、SharedPreferences、sqflite、get_it / injectable、flutter_test、Melos。

---

## 固定範圍與非目標

19-1必須做到：

- `packages/auth`不再直接import或依賴`shared_preferences`、`sqflite`。
- 建立`AuthCredentialStore`、`AuthLegacyCredentialStore`、`AuthUserStore`三個狹窄boundary。
- Credential與Legacy read使用`absent / present / corrupted` typed result。
- App layer提供既有SharedPreferences token persistence與SQLite user persistence adapter。
- Repository與Refresher改依賴新boundary，但本階段仍以SharedPreferences中的`auth.tokens`作production credential authority。
- 舊`auth.accessToken`仍只在read時安全清除，不能恢復Session。
- Login、Restore、Refresh、Logout、latest-intent、single-flight、generation與safe replay行為不變。

19-1不得做到：

- 不加入`flutter_secure_storage`。
- 不建立`AuthCredentialMigrationCoordinator` production implementation。
- 不切換Secure credential authority。
- 不修改Android Native設定。
- 不新增persistent migration marker。
- 不修改OTP、Biometric、navigation或presentation contract。
- 不更新`VERSION`。

---

## 目標檔案結構

### `packages/auth`

```txt
lib/src/data/stores/
  auth_credential_read_result.dart
  auth_credential_store.dart
  auth_legacy_credential_store.dart
  auth_user_store.dart

lib/src/data/repositories/auth_repository_impl.dart
lib/src/refresh/auth_session_refresher.dart
lib/auth.dart
pubspec.yaml
```

### App layer

```txt
apps/flutter_architecture/lib/features/auth/data/stores/
  shared_preferences_auth_credential_store.dart
  shared_preferences_auth_legacy_credential_store.dart
  sqflite_auth_user_store.dart

apps/flutter_architecture/lib/app/di/register_module.dart
```

### Tests

```txt
packages/auth/test/
  auth_credential_read_result_test.dart
  auth_repository_persistence_test.dart
  auth_session_refresher_test.dart

apps/flutter_architecture/test/features/auth/data/stores/
  shared_preferences_auth_credential_store_test.dart
  shared_preferences_auth_legacy_credential_store_test.dart
  sqflite_auth_user_store_test.dart

apps/flutter_architecture/test/features/auth/data/
  auth_single_active_user_persistence_test.dart

apps/flutter_architecture/test/app/di/
  register_module_auth_persistence_test.dart
```

在所有consumer切換完成、exports與tests通過後，刪除：

```txt
packages/auth/lib/src/data/data_sources/auth_local_data_source.dart
packages/auth/lib/src/data/data_sources/auth_local_store.dart
packages/auth/lib/src/data/data_sources/auth_refresh_local_store.dart
packages/auth/lib/src/session/auth_token_storage.dart
```

---

## Task 1：建立 typed credential read contract

**Files:**

- Create: `packages/auth/lib/src/data/stores/auth_credential_read_result.dart`
- Create: `packages/auth/lib/src/data/stores/auth_credential_store.dart`
- Create: `packages/auth/lib/src/data/stores/auth_legacy_credential_store.dart`
- Create: `packages/auth/lib/src/data/stores/auth_user_store.dart`
- Create: `packages/auth/test/auth_credential_read_result_test.dart`
- Modify: `packages/auth/lib/auth.dart`

- [x] **Step 1：先寫typed result contract test**

```dart
const absent = AuthCredentialReadAbsent();
const corrupted = AuthCredentialReadCorrupted();
final present = AuthCredentialReadPresent(tokens);

expect(absent, isA<AuthCredentialReadResult>());
expect(corrupted, isA<AuthCredentialReadResult>());
expect(present.tokens, same(tokens));
expect(present.toString(), isNot(contains(tokens.accessToken)));
expect(present.toString(), isNot(contains(tokens.refreshToken)));
```

- [x] **Step 2：執行failing test**

```bash
dart run melos exec --scope=auth -- flutter test test/auth_credential_read_result_test.dart
```

Expected：FAIL，因新型別尚不存在。

- [x] **Step 3：建立最小contract**

```dart
sealed class AuthCredentialReadResult {
  const AuthCredentialReadResult();
}

final class AuthCredentialReadAbsent extends AuthCredentialReadResult {
  const AuthCredentialReadAbsent();
}

final class AuthCredentialReadPresent extends AuthCredentialReadResult {
  const AuthCredentialReadPresent(this.tokens);

  final StoredAuthTokens tokens;

  @override
  String toString() => 'AuthCredentialReadPresent()';
}

final class AuthCredentialReadCorrupted extends AuthCredentialReadResult {
  const AuthCredentialReadCorrupted();
}
```

Store signatures固定為：

```dart
abstract interface class AuthCredentialStore {
  Future<AuthCredentialReadResult> readCredential();
  Future<void> writeCredential(StoredAuthTokens tokens);
  Future<void> clearCredential();
}

abstract interface class AuthLegacyCredentialStore {
  Future<AuthCredentialReadResult> readLegacyCredential();
  Future<void> clearLegacyCredential();
}

abstract interface class AuthUserStore {
  Future<AuthUser?> readUser();
  Future<void> writeUser(AuthUser user);
  Future<void> clearUser();
}
```

`AuthUserStore`刻意使用公開Domain entity `AuthUser`，不得把`AuthUserModel`暴露給App adapter或迫使App import `package:auth/src/...`。

- [x] **Step 4：執行package test與analyze**

```bash
dart run melos exec --scope=auth -- flutter test test/auth_credential_read_result_test.dart
dart run melos exec --scope=auth -- dart analyze .
```

Expected：PASS。

- [x] **Step 5：Commit**

```bash
git add packages/auth/lib/src/data/stores packages/auth/lib/auth.dart packages/auth/test/auth_credential_read_result_test.dart
git commit -m "refactor(auth): 建立持久化邊界契約"
```

Task 1 implementation review：Passed。

- Public export只包含App adapter必須實作的四個contract；未暴露plugin型別或`AuthUserModel`。
- `sealed` result與三個`final` variant形成封閉typed taxonomy；operational failure仍保留給typed exception boundary。
- `AuthCredentialReadPresent.toString()`固定為不含payload的diagnostic字串，測試同時鎖住Access Token、Refresh Token與`userId`不外洩。
- `AuthUserStore`使用公開Domain `AuthUser`，不迫使App import `package:auth/src/...`。
- Auth package完整52 tests、analyze、format與`git diff --check`均通過；無Open P0 / P1 review finding。

---

## Task 2：建立SharedPreferences credential與legacy adapters

**Files:**

- Create: `apps/flutter_architecture/lib/features/auth/data/stores/shared_preferences_auth_credential_store.dart`
- Create: `apps/flutter_architecture/lib/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart`
- Create: `apps/flutter_architecture/test/features/auth/data/stores/shared_preferences_auth_credential_store_test.dart`
- Create: `apps/flutter_architecture/test/features/auth/data/stores/shared_preferences_auth_legacy_credential_store_test.dart`

- [x] **Step 1：先寫SharedPreferences adapter tests**

Credential adapter覆蓋：absence、合法JSON、非JSON、非Map、缺必要token、非法expiration、write、idempotent clear、plugin false result與unknown error stack preservation。

Legacy adapter覆蓋：合法`auth.tokens`、corrupted payload、只有`auth.accessToken`時回傳absent並清除、同時清除兩個legacy keys與idempotent clear。

- [x] **Step 2：執行failing tests**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/shared_preferences_auth_credential_store_test.dart
flutter test test/features/auth/data/stores/shared_preferences_auth_legacy_credential_store_test.dart
```

Expected：FAIL。

- [x] **Step 3：實作SharedPreferences adapters**

固定規則：

- JSON codec與key常數留在App adapter。
- 只有payload validation failure轉為`AuthCredentialReadCorrupted`。
- `AppException`直接rethrow。
- plugin operational error包成`AppExceptionKind.localStorage`並保留cause / stack。
- exception、log與`toString()`不得包含raw JSON或token。

- [x] **Step 4：執行adapter tests**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/shared_preferences_auth_credential_store_test.dart
flutter test test/features/auth/data/stores/shared_preferences_auth_legacy_credential_store_test.dart
```

Expected：PASS。

- [x] **Step 5：Commit**

```bash
git add apps/flutter_architecture/lib/features/auth/data/stores apps/flutter_architecture/test/features/auth/data/stores
git commit -m "refactor(auth): 將SharedPreferences持久化移至App"
```

Task 2 implementation review：Passed after revision。

- Credential與Legacy adapter維持App-owned plugin boundary，尚未接入DI或改變runtime authority。
- `absent / present / corrupted` taxonomy、single-access-token cleanup、idempotent clear與敏感diagnostic均由15項adapter tests鎖定。
- Review發現`clearLegacyCredential()`原先只保留第一個錯誤，可能讓先發生的expected failure遮蔽後續unknown error；已改為兩個key都嘗試清除，並依Decision 020優先保留unknown error。
- App analyze、format與`git diff --check`通過；無Open P0 / P1 review finding。

---

## Task 3：建立SQLite AuthUser adapter

**Files:**

- Create: `apps/flutter_architecture/lib/features/auth/data/stores/sqflite_auth_user_store.dart`
- Create: `apps/flutter_architecture/test/features/auth/data/stores/sqflite_auth_user_store_test.dart`
- Modify: `apps/flutter_architecture/test/features/auth/data/auth_single_active_user_persistence_test.dart`

- [ ] **Step 1：先寫SQLite adapter tests**

覆蓋：slot不存在、write replace、A後寫B只讀B、clear、SQLite operational failure mapping、model mapping與unknown error不降級成absence。

- [ ] **Step 2：執行failing test**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/sqflite_auth_user_store_test.dart
```

Expected：FAIL。

- [ ] **Step 3：實作`SqfliteAuthUserStore`**

固定使用既有schema：

```dart
static const _table = 'auth_user';
static const _slot = 1;
```

本階段不修改schema、不新增migration。

Adapter直接在App boundary完成SQLite row與公開`AuthUser`之間的mapping；`AuthUserModel`維持`packages/auth`內部實作細節，不成為store contract。

- [ ] **Step 4：更新single-active-user persistence test wiring**

以三個App adapter取代`AuthLocalDataSource`，保留所有既有scenario與assertion。

- [ ] **Step 5：執行SQLite與persistence tests**

```bash
cd apps/flutter_architecture
flutter test test/features/auth/data/stores/sqflite_auth_user_store_test.dart
flutter test test/features/auth/data/auth_single_active_user_persistence_test.dart
```

Expected：PASS。

- [ ] **Step 6：Commit**

```bash
git add apps/flutter_architecture/lib/features/auth/data/stores/sqflite_auth_user_store.dart apps/flutter_architecture/test/features/auth/data/stores/sqflite_auth_user_store_test.dart apps/flutter_architecture/test/features/auth/data/auth_single_active_user_persistence_test.dart
git commit -m "refactor(auth): 將使用者持久化移至App"
```

---

## Task 4：Repository改用新store boundaries

**Files:**

- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`
- Delete after migration: `packages/auth/lib/src/data/data_sources/auth_local_store.dart`

- [ ] **Step 1：先改repository tests為三個fake stores**

19-1 Repository contract：

- Login寫Credential與User store。
- Restore讀Credential與User store。
- corrupted時清credential、legacy、user並回`Success(null)`。
- absence或缺user維持既有cleanup與未登入語意。
- Legacy store在19-1只參與cleanup，不執行migration。
- Logout三個store都嘗試clear；expected / unexpected priority不變。

- [ ] **Step 2：執行failing repository tests**

```bash
dart run melos exec --scope=auth -- flutter test test/auth_repository_persistence_test.dart
```

Expected：FAIL。

- [ ] **Step 3：修改Repository constructor與flow**

```dart
AuthRepositoryImpl(
  AuthRemoteDataSource remoteDataSource,
  AuthCredentialStore credentialStore,
  AuthLegacyCredentialStore legacyCredentialStore,
  AuthUserStore userStore,
  SessionManager sessionManager,
  AuthStateMutationCoordinator mutationCoordinator,
)
```

複合mutation仍只取得一次`runExclusive`；不新增nested lock或migration coordinator。

Repository直接將Domain `AuthUser`交給`AuthUserStore.writeUser()`，Restore取得的也是Domain `AuthUser`；不得新增App對`AuthUserModel`的依賴。

- [ ] **Step 4：執行repository tests與analyze**

```bash
dart run melos exec --scope=auth -- flutter test test/auth_repository_persistence_test.dart
dart run melos exec --scope=auth -- dart analyze .
```

Expected：PASS。

- [ ] **Step 5：Commit**

```bash
git add packages/auth/lib/src/data/repositories/auth_repository_impl.dart packages/auth/test/auth_repository_persistence_test.dart packages/auth/lib/src/data/data_sources/auth_local_store.dart
git commit -m "refactor(auth): 拆分Repository持久化依賴"
```

---

## Task 5：Refresher改用Credential與User stores

**Files:**

- Modify: `packages/auth/lib/src/refresh/auth_session_refresher.dart`
- Modify: `packages/auth/test/auth_session_refresher_test.dart`
- Delete after migration: `packages/auth/lib/src/data/data_sources/auth_refresh_local_store.dart`
- Delete after migration: `packages/auth/lib/src/session/auth_token_storage.dart`

- [ ] **Step 1：先改refresher tests為新store fakes**

鎖定：present才refresh；absent、corrupted、missing userId、identity mismatch、expired refresh token維持expiration語意；rotation persistence-first；passive invalidation清三個store；single-flight與cross-session tests不得減少。

- [ ] **Step 2：執行failing refresher tests**

```bash
dart run melos exec --scope=auth -- flutter test test/auth_session_refresher_test.dart
```

Expected：FAIL。

- [ ] **Step 3：修改Refresher constructor與flow**

```dart
AuthSessionRefresher(
  AuthRefreshRemoteDataSource remoteDataSource,
  AuthCredentialStore credentialStore,
  AuthLegacyCredentialStore legacyCredentialStore,
  AuthUserStore userStore,
  SessionManager sessionManager,
  AuthStateMutationCoordinator mutationCoordinator,
)
```

M19-PR06的non-fatal reporting完整收斂留到19-4，不在19-1混入行為變更。

- [ ] **Step 4：執行refresher tests**

```bash
dart run melos exec --scope=auth -- flutter test test/auth_session_refresher_test.dart
```

Expected：PASS。

- [ ] **Step 5：Commit**

```bash
git add packages/auth/lib/src/refresh/auth_session_refresher.dart packages/auth/test/auth_session_refresher_test.dart packages/auth/lib/src/data/data_sources/auth_refresh_local_store.dart packages/auth/lib/src/session/auth_token_storage.dart
git commit -m "refactor(auth): 拆分Refresh持久化依賴"
```

---

## Task 6：Composition Root與dependency cleanup

**Files:**

- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Generate: `apps/flutter_architecture/lib/app/di/injection.config.dart`
- Create: `apps/flutter_architecture/test/app/di/register_module_auth_persistence_test.dart`
- Modify: `packages/auth/lib/auth.dart`
- Modify: `packages/auth/pubspec.yaml`
- Delete: `packages/auth/lib/src/data/data_sources/auth_local_data_source.dart`

- [ ] **Step 1：先寫DI graph test**

驗證三個store的concrete binding、singleton ownership，以及Repository與Refresher取得相同instances。

- [ ] **Step 2：執行failing DI test**

```bash
cd apps/flutter_architecture
flutter test test/app/di/register_module_auth_persistence_test.dart
```

Expected：FAIL。

- [ ] **Step 3：更新`RegisterModule`**

移除`AuthLocalDataSource`factory，新增三個lazy singleton binding並修改Repository / Refresher factory。

- [ ] **Step 4：移除package plugin dependencies與舊exports**

從`packages/auth/pubspec.yaml`移除`shared_preferences`與`sqflite`；從public export移除舊local data source與store，新增新contracts。

- [ ] **Step 5：執行dependency resolution與generation**

```bash
dart pub get
dart run melos run build_runner
```

Expected：成功更新lockfile與generated DI；禁止手動修改generated source。

- [ ] **Step 6：執行DI與package boundary驗證**

```bash
cd apps/flutter_architecture
flutter test test/app/di/register_module_auth_persistence_test.dart
cd ../..
dart run melos exec --scope=auth -- dart analyze .
git grep -n "package:shared_preferences\|package:sqflite" -- packages/auth
git grep -n "AuthLocalDataSource\|AuthLocalStore\|AuthRefreshLocalStore\|AuthTokenStorage"
```

Expected：`packages/auth`無plugin import；舊型別無production consumer。

- [ ] **Step 7：Commit**

```bash
git add packages/auth apps/flutter_architecture/lib/app/di apps/flutter_architecture/test/app/di pubspec.lock
git commit -m "refactor(di): 完成Auth持久化邊界組裝"
```

---

## Task 7：完整regression、implementation review與文件同步

**Files:**

- Modify: `docs/audits/milestone_19_planning_review.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/project_context.md`
- Modify: `CHANGELOG.md`
- Modify only if public usage changed: `README.md`

- [ ] **Step 1：執行Auth targeted tests**

```bash
dart run melos exec --scope=auth -- flutter test
cd apps/flutter_architecture
flutter test test/features/auth
flutter test test/app/di/register_module_auth_persistence_test.dart
```

- [ ] **Step 2：執行workspace validation**

```bash
cd ../..
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
cd ../..
git diff --check
```

Expected：全部通過；既有410 tests不得無理由減少。

- [ ] **Step 3：進行19-1 implementation review**

Review checklist：

- `packages/auth`無SharedPreferences、sqflite或DI framework dependency。
- 三個store boundary沒有合併成generic local store。
- typed read result沒有把operational failure降級成corrupted或absent。
- App adapter沒有洩漏raw credential。
- Repository與Refresher沒有nested `runExclusive`。
- SharedPreferences仍是19-1 production credential authority。
- 沒有加入migration、Secure Storage、OTP或Biometric行為。
- Login、Restore、Refresh、Logout與concurrency regression維持。

- [ ] **Step 4：同步文件狀態**

只有review通過後才將19-1標記Completed、記錄finding implementation evidence、把下一步切換19-2；`VERSION`維持不變。

- [ ] **Step 5：Commit 19-1封存文件**

```bash
git add docs CHANGELOG.md README.md
git commit -m "docs(auth): 封存 Milestone 19-1 持久化邊界"
```

---

## 19-1 Review Gate

必須全部成立才能進入19-2：

- 新store boundaries與typed read result已有tests。
- SharedPreferences / SQLite adapters已移至App layer。
- `packages/auth`已移除`shared_preferences`與`sqflite`dependency。
- 舊`AuthLocalDataSource`與聚合local-store介面已移除。
- DI graph顯式綁定三個store且使用singleton ownership。
- Login、Restore、Refresh、Logout runtime behavior等價。
- latest-intent、single-flight、session generation與safe replay無退化。
- Analyze、完整tests與App bundle通過。
- 未加入Secure Storage、migration policy、Native設定或VERSION變更。

Gate通過後，下一階段才是：

```txt
Milestone 19-2 — Secure Credential Store Adapter
```

---

## Plan Review 結論

狀態：Passed。

- `M19-1-PLAN01`：原始草案讓`AuthUserStore`暴露`AuthUserModel`，會迫使App依賴package data model或`src`。已修正為公開Domain `AuthUser`，由App SQLite adapter自行完成row mapping。
- `M19-1-PLAN02`：確認19-1的SharedPreferences credential adapter與legacy adapter會暫時讀寫相同`auth.tokens` key；這是為了保持現況authority並預留19-2替換credential adapter，兩者必須分開binding且clear具idempotent語意。
- `M19-1-PLAN03`：確認M19-PR06完整cleanup reporting不納入19-1，避免seam refactor混入runtime behavior change；只保留現有語意並在19-4正式收斂。
- `M19-1-PLAN04`：確認generated DI只能透過build_runner更新，plan未要求手動修改generated source。
- 無Open P0 / P1 planning issue。
- Plan可進入implementation，但必須逐Task執行test-first與commit gate。
