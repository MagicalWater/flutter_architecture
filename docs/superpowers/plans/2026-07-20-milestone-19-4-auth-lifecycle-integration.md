# Milestone 19-4 — Auth Lifecycle Integration Implementation Plan

狀態：Passed；implementation plan review已通過。

## Goal

將Milestone 19-1至19-3已完成的Auth persistence seam、Secure adapter與migration policy正式整合進Login、Restore、Refresh、Logout與passive invalidation lifecycle，並在單一可驗證切換點將production credential authority由SharedPreferences改為Secure Storage。

Milestone 19-4完成後：

```txt
Login / Restore / Refresh / Logout / Passive invalidation
  → Secure AuthCredentialStore
  → Legacy cleanup只作migration / compatibility cleanup
  → SQLite AuthUserStore
  → SessionManager commit永遠在必要persistence成功之後
```

## Non-goals

- 不加入OTP。
- 不加入Biometric Prompt、Device Binding、Passkey或hardware attestation。
- 不新增persistent migration marker。
- 不改變API contract、DTO或Mock登入行為。
- 不更換`AuthStateMutationCoordinator`或建立可重入lock。
- 不在`packages/auth`加入Flutter plugin、GetIt或Injectable依賴。
- 不修改VERSION；維持`1.2.0`。
- Android runtime smoke與release artifact security review保留給19-5。

## Approved Runtime Contract

### Single authority switch

19-4不得出現半套authority：

```txt
Login寫Secure
Restore讀SharedPreferences
Refresh寫SharedPreferences
```

正式DI切換必須在Repository與Refresher都已完成Secure lifecycle tests後一次完成：

```txt
default AuthCredentialStore
  SharedPreferences  →  Secure
```

Legacy SharedPreferences adapter仍以`AuthLegacyCredentialStore`存在，只負責migration與cleanup。

### Exclusive ownership

- Repository public lifecycle entry與Refresher既有entry負責取得`runExclusive`。
- `AuthCredentialMigrationCoordinator.resolveUnlocked()`只在已持有ownership時呼叫。
- 所有內部cleanup helper採`...Unlocked`語意，不得nested `runExclusive`。
- Session commit前必須再次驗證latest-intent或session generation。

### Diagnostic ownership

Migration與lifecycle cleanup diagnostic必須由Auth lifecycle owner逐項交給App-owned reporter adapter。

為維持package純Dart boundary，`packages/auth`新增Auth-specific lifecycle diagnostic與狹窄sink contract；App adapter實作該contract。Diagnostic必須能區分migration Legacy cleanup、Secure cleanup、Legacy cleanup與User cleanup，並只保存operation、原error與caught stack，不暴露`ErrorReport`、Crashlytics或plugin型別。

Reporter failure不得改變Restore結果，也不得阻止後續diagnostic。

Reporter不得在持有Auth mutation ownership時呼叫。Lifecycle owner應在exclusive section內完成store resolution、latest-intent / generation驗證與Session commit，將immutable diagnostics帶出lock後再逐項report，避免外部reporting I/O延長或重入Auth lock。

### Transitional implementation boundary

Task 2至Task 5可以完成Secure lifecycle production code與targeted tests，但App production graph在Task 6前必須維持既有SharedPreferences authority，且不得選用新Secure lifecycle path。

若Repository或Refresher constructor shape需要提前演進，必須使用明確的transitional constructor / collaborator，讓App DI仍選擇舊path；Task 6一次切換App graph後立即移除transitional legacy path。不得以optional dependency、runtime flag或nullable migration coordinator維持雙重production behavior。

### Cleanup priority

Interactive destructive cleanup與passive invalidation都必須嘗試Secure、Legacy與User三個stores。

優先權：

```txt
unknown / unexpected error
  → expected AppExceptionKind.localStorage
  → success
```

- Interactive Login compensation / Logout：expected cleanup failure可回Failure，但runtime Session不得恢復。
- Passive invalidation：expected cleanup failure不得阻止Session expiration；必須non-fatal report。
- Unknown error不得空catch吞掉，必須保留error與stack交給既有reporting boundary。

## Task 1 — Lifecycle diagnostic sink與shared cleanup policy

**Files**

- Add: `packages/auth/lib/src/data/lifecycle/auth_lifecycle_diagnostic.dart`
- Add: `packages/auth/lib/src/data/lifecycle/auth_lifecycle_diagnostic_sink.dart`
- Modify: `packages/auth/lib/auth.dart`
- Add/Modify: Auth lifecycle cleanup helper files under `packages/auth/lib/src/data/`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`
- Modify: `packages/auth/test/auth_session_refresher_test.dart`
- Modify: `apps/flutter_architecture/lib/features/auth/data/migration/auth_migration_error_reporter_adapter.dart`
- Modify: adapter tests

**Contract**

- [x] Package新增Auth-specific lifecycle diagnostic與單一狹窄sink abstraction。
- [x] Diagnostic operation至少區分migration Legacy cleanup、Secure cleanup、Legacy cleanup與User cleanup。
- [x] App adapter實作sink並逐項上報fixed safe context；不得把raw plugin message或credential payload放入context。
- [x] 建立Auth-specific cleanup accumulator/helper，統一Secure / Legacy / User全部嘗試與error priority。
- [x] Helper不取得mutation lock、不修改SessionManager、不依賴App reporter。
- [x] Interactive與passive caller可明確選擇rethrow或report policy，不使用空catch。
- [x] Error與caught stack identity均有tests。

建議commit：

```bash
git commit -m "refactor(auth): 建立lifecycle cleanup與diagnostic boundary"
```

Task 1執行結果：新增純Dart `AuthLifecycleDiagnostic`、四種封閉operation與`AuthLifecycleDiagnosticSink`；既有migration result與Coordinator也收斂到同一diagnostic taxonomy，不再保留平行的migration-only diagnostic型別。App reporter adapter正式實作sink，逐項映射migration Legacy、Secure、Legacy與User cleanup safe context，保留原error / caught stack且reporter failure不阻止後續項目。新增`AuthLifecycleCleanupPolicy.clearAllUnlocked()`，固定依序嘗試Secure、Legacy與User三個stores，回傳immutable diagnostics；`AuthLifecycleCleanupResult`提供interactive `throwIfFailed()`與passive `throwIfUnexpected()`，unknown優先於expected `localStorage`，不取得lock、不修改SessionManager、不依賴App reporter。RED為新contract不存在；GREEN package targeted 5項、App adapter 2項與兩側analyze通過。Repository與Refresher尚未改用新policy，留待Task 2至5逐步整合。

Task 1 implementation review：發現Coordinator仍產生舊`AuthCredentialMigrationDiagnostic`，而新sink只接受`AuthLifecycleDiagnostic`，會迫使Task 2建立臨時轉換並形成雙重taxonomy。已將migration result與Coordinator正式切換為`AuthLifecycleDiagnosticOperation.migrationLegacyCleanup`，移除舊型別與public export，讓Restore可直接把immutable diagnostics交給sink。

## Task 2 — Restore整合migration resolution

**Files**

- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`
- Add/Modify: transitional Secure lifecycle collaborator或明確constructor path
- Modify: package tests；App DI不得在本Task切換到新path

**Contract**

- [x] Restore在單一`runExclusive`內呼叫`resolveUnlocked()`。
- [x] `AuthCredentialMigrationUnauthenticated`清runtime Session並回`Success(null)`。
- [x] `AuthCredentialMigrationResolved`在lock內驗證operation仍current並建立Session；immutable diagnostics帶出lock後才逐項report。
- [x] Reporter failure不阻止合法restore，且reporting不發生在mutation lock內。
- [x] Secure unavailable、migration write/read-back failure映射typed local-storage／data-corruption Failure，不fallback Legacy Session。
- [x] Unknown error保留原error與stack。
- [x] Restore不再自行重複實作Secure / Legacy / User decision matrix。
- [x] 同一exclusive section內不nested lock。
- [x] App production DI仍選擇舊SharedPreferences restore path；新Secure restore path只由targeted tests驗證，待Task 6原子啟用。

建議commit：

```bash
git commit -m "feat(auth): 整合restore credential migration"
```

Task 2執行結果：`AuthRepositoryImpl`新增非nullable transitional `secureLifecycle` constructor，透過private restore resolver strategy整合`AuthCredentialMigrationCoordinator.resolveUnlocked()`；既有default constructor仍使用Legacy resolver，App DI與production SharedPreferences restore authority未切換。Migration resolution與latest-intent check、Session commit都位於同一exclusive section；resolved / unauthenticated diagnostics以immutable outcome帶出lock後才交給sink，reporter failure不改變合法restore。`localStorage`與`dataCorruption`均映射Restore Failure，unknown error保留identity，較新Logout可使blocked migration restore superseded。RED為secureLifecycle constructor缺失及dataCorruption仍被重拋；GREEN新migration restore 6項、既有Repository與Coordinator targeted合計64項，Auth analyze通過。

Task 2 implementation review：通過。Review發現初版為導入strategy將原本public `const AuthRepositoryImpl`改成factory，造成不必要的package API退化。Dart const initializer不能以constructor參數建立內嵌strategy，因此最終shape保留原default generative const constructor；named `secureLifecycle` factory明確redirect到同library私有Secure subclass。Default class固定Legacy restore，Secure subclass以nonnullable Migration Coordinator與diagnostic sink覆寫restore/report boundary，不使用nullable dependency或runtime authority flag。新增source contract regression鎖定constructor shape。Restore reporting仍在lock外，latest-intent / Session commit仍在同一exclusive section；targeted tests與analyze通過。

## Task 3 — Login Secure persistence與compensation

**Files**

- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`

**Contract**

- [x] 新Secure lifecycle path只寫其注入的Secure credential authority，不寫Legacy credential。
- [x] 寫入順序固定為Secure credential → User → Session commit。
- [x] 任一必要persistence失敗都不得建立Session。
- [x] User write failure或latest-intent superseded時嘗試清Secure、Legacy與User。
- [x] Compensation全部stores都嘗試，unknown優先於expected local-storage error。
- [x] Compensation必須受operation ownership保護；較舊Login不得以blind clear清除或覆寫較新Login已commit的state。
- [x] Double Login、Login + Logout、account switch與existing latest-intent tests維持通過。
- [x] App production DI在Task 6前仍選擇舊path；不得因本Task讓Login先於Restore / Refresh切換authority。

建議commit：

```bash
git commit -m "feat(auth): 切換login至Secure credential persistence"
```

Task 3執行結果：Secure lifecycle subclass覆寫Login persistence hook，固定在caller-owned exclusive section內依序寫入Secure credential與SQLite User，最後才由Repository commit runtime Session；Legacy store從不接收write。任一persistence或superseded failure都使用Task 1 `AuthLifecycleCleanupPolicy`依序嘗試清Secure、Legacy與User，再清runtime Session；cleanup unknown error優先於原始expected persistence failure。Secure path專屬tests覆蓋寫入順序、User write補償、unknown cleanup priority與Double Login反向完成，證明較舊Login不會blind clear較新已commit state。App production DI仍使用default Legacy constructor，未切換authority。

Task 3 implementation review：通過。Review發現初版會讓expected cleanup failure覆蓋原始unknown persistence error，且superseded compensation會無條件清除runtime Session。已明確收斂優先權：unknown cleanup最高；其後superseded control flow與原始unknown persistence error；只有原始expected local-storage failure時，expected cleanup failure才可成為primary。Superseded compensation仍清Secure／Legacy／User，但不清除不屬於舊Login的runtime Session。新增原始unknown對expected cleanup與mid-persistence superseded兩項regression。

## Task 4 — Refresh Secure rotation與passive invalidation

**Files**

- Modify: `packages/auth/lib/src/refresh/auth_session_refresher.dart`
- Modify: `packages/auth/test/auth_session_refresher_test.dart`

**Contract**

- [ ] 新Secure lifecycle path只從其注入的Secure credential authority讀取完整Token Pair。
- [ ] Rotation只寫同一注入authority，維持persistence-first後才更新Session access token。
- [ ] Refresh前驗證stored userId、SQLite User與runtime Session一致。
- [ ] Invalid refresh、credential corruption／absence與identity mismatch觸發passive invalidation。
- [ ] Passive invalidation嘗試清Secure、Legacy與User，再清runtime Session。
- [ ] Expected cleanup failure不阻止Session expired語意；先清runtime Session，再於lock外逐項non-fatal report。
- [ ] Unknown cleanup error也必須先完成runtime Session expiration，再保留identity / stack進既有unexpected reporting flow。
- [ ] Concurrent 401 single-flight、generation、cross-session與safe replay regression不得退化。
- [ ] App production DI在Task 6前仍選擇舊Refresher path。

建議commit：

```bash
git commit -m "feat(auth): 切換refresh與passive invalidation至Secure"
```

## Task 5 — Logout destructive cleanup

**Files**

- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`
- Modify: App reporting tests if passive / interactive context需要區分

**Contract**

- [ ] Logout在單一exclusive section內分別嘗試清Secure、Legacy與User。
- [ ] Runtime Session無論cleanup結果都必須清除；較新lifecycle已接管時不得清其Session。
- [ ] 所有cleanup都嘗試完成後才依unknown → expected local-storage優先權向外表達。
- [ ] Expected cleanup failure映射Logout Failure，但不得恢復Session。
- [ ] Unknown error保留error / stack。
- [ ] Logout與較新Login交錯的latest-intent regression不得退化。
- [ ] App production DI在Task 6前仍選擇舊Repository path；本Task不得單獨完成authority switch。

建議commit：

```bash
git commit -m "refactor(auth): 收斂Secure logout cleanup policy"
```

## Task 6 — Atomic DI authority switch

**Files**

- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Regenerate: `apps/flutter_architecture/lib/app/di/injection.config.dart`
- Modify: DI integration tests
- Modify: SharedPreferences / Secure store integration tests

**Contract**

- [ ] Default `AuthCredentialStore`改綁Secure adapter。
- [ ] 移除只為19-2 / 19-3過渡使用的named Secure requirement，或將named binding收斂為無重複authority的明確shape。
- [ ] Repository、Refresher與Migration Coordinator取得同一Secure singleton instance。
- [ ] `AuthLegacyCredentialStore`仍綁SharedPreferences legacy adapter。
- [ ] Legacy資料可由Restore migration一次升級；Login與Refresh不再寫SharedPreferences credential。
- [ ] DI tests以不同Secure／Legacy資料證明authority已完整切換，沒有半套graph。
- [ ] App graph切換後移除Task 2至Task 5的transitional legacy constructor / collaborator path；不得留下optional dependency或runtime authority flag。
- [ ] Generated code只由build_runner產生。

建議commit：

```bash
git commit -m "refactor(di): 原子切換Auth credential authority"
```

## Task 7 — 19-4 regression與implementation review gate

**Files**

- Modify: `docs/audits/milestone_19_planning_review.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/project_context.md`
- Modify: `CHANGELOG.md`
- Modify: this plan

- [ ] Auth Repository targeted tests通過。
- [ ] Auth Refresher targeted tests通過。
- [ ] Migration、adapter與DI targeted tests通過。
- [ ] latest-intent、single-flight、generation、cross-session、safe replay全部通過。
- [ ] Workspace analyze通過。
- [ ] Workspace完整tests不得低於19-3的506項。
- [ ] App `flutter build bundle`通過。
- [ ] Source / generated graph scan確認Repository、Refresher、Migration共用Secure authority。
- [ ] 完整19-4 implementation review無Open P0 / P1。
- [ ] 更新M19-PR01、M19-PR02與M19-PR06並完整關閉；M19-PR05留至19-5 runtime evidence。
- [ ] VERSION維持1.2.0。

封存commit：

```bash
git commit -m "docs(auth): 封存 Milestone 19-4 lifecycle integration"
```

## 19-4 Review Gate

必須全部成立才能進入19-5：

- Login、Restore、Refresh、Logout與passive invalidation全部使用Secure credential authority。
- Legacy SharedPreferences只剩migration / cleanup責任。
- Restore migration與Session commit位於同一exclusive ownership，Coordinator不nested lock。
- Login與Refresh維持persistence-first，不建立partial runtime Session。
- Destructive與passive cleanup都嘗試Secure、Legacy與User，沒有空catch吞unknown error。
- Expected cleanup failure的interactive／passive語意一致且有reporting evidence。
- latest-intent、single-flight、generation、cross-session與safe replay無退化。
- App DI一次性完成authority switch，沒有default / named雙重production authority。
- Workspace analyze、完整tests與App bundle通過。
- 未加入OTP、Biometric、Device Binding、額外Native permission或VERSION變更。

## Plan Review 結論

狀態：Passed。

- `M19-4-PLAN01`：原diagnostic sink只接受`AuthCredentialMigrationDiagnostic`，無法表達Secure與User cleanup failure。已改為Auth-specific lifecycle diagnostic，operation至少涵蓋migration Legacy、Secure、Legacy與User cleanup。
- `M19-4-PLAN02`：原Restore契約要求在mutation lock內先report diagnostics，可能讓App reporter I/O延長或重入Auth lock。已固定lock內只做resolution、current check與Session commit，immutable diagnostics帶出lock後才report。
- `M19-4-PLAN03`：原Task 2至Task 5會修改Repository / Refresher production behavior，但authority switch延至Task 6，可能形成Restore、Login與Refresh使用不同authority的中間graph。已新增transitional implementation boundary：App DI在Task 6前不得選用新Secure lifecycle path，Task 6一次切換後立即移除legacy transitional path。
- `M19-4-PLAN04`：原Login compensation只要求清三個stores，未限制較舊operation不得blind clear較新Login state。已要求compensation受operation ownership保護，並以反向完成與account switch tests證明舊operation不能清除新state。
- `M19-4-PLAN05`：原passive invalidation對unknown cleanup error只寫重拋，未固定runtime Session expiration先後。已固定expected與unknown cleanup failure都先完成Session expiration；expected在lock外report，unknown保留identity / stack進unexpected flow。
- 無Open P0 / P1 planning issue；可以進入Task 1 implementation。

