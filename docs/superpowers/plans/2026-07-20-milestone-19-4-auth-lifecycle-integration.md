# Milestone 19-4 — Auth Lifecycle Integration Implementation Plan

狀態：Draft，待implementation plan review。

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

Migration cleanup diagnostic必須由Auth lifecycle owner逐項交給App-owned reporter adapter。

為維持package純Dart boundary，`packages/auth`新增狹窄diagnostic sink contract；App adapter實作該contract。Contract只接受`AuthCredentialMigrationDiagnostic`，不暴露`ErrorReport`、Crashlytics或plugin型別。

Reporter failure不得改變Restore結果，也不得阻止後續diagnostic。

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

- Add: `packages/auth/lib/src/data/migration/auth_credential_migration_diagnostic_sink.dart`
- Modify: `packages/auth/lib/auth.dart`
- Add/Modify: Auth lifecycle cleanup helper files under `packages/auth/lib/src/data/`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`
- Modify: `packages/auth/test/auth_session_refresher_test.dart`
- Modify: `apps/flutter_architecture/lib/features/auth/data/migration/auth_migration_error_reporter_adapter.dart`
- Modify: adapter tests

**Contract**

- [ ] Package新增單一狹窄migration diagnostic sink abstraction。
- [ ] App adapter實作sink並逐項上報fixed safe context。
- [ ] 建立Auth-specific cleanup accumulator/helper，統一Secure / Legacy / User全部嘗試與error priority。
- [ ] Helper不取得mutation lock、不修改SessionManager、不依賴App reporter。
- [ ] Interactive與passive caller可明確選擇rethrow或report policy，不使用空catch。
- [ ] Error與caught stack identity均有tests。

建議commit：

```bash
git commit -m "refactor(auth): 建立lifecycle cleanup與diagnostic boundary"
```

## Task 2 — Restore整合migration resolution

**Files**

- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`
- Modify: App DI source / generated graph tests as needed

**Contract**

- [ ] Restore在單一`runExclusive`內呼叫`resolveUnlocked()`。
- [ ] `AuthCredentialMigrationUnauthenticated`清runtime Session並回`Success(null)`。
- [ ] `AuthCredentialMigrationResolved`先逐項report diagnostics，再驗證operation仍current，最後才建立Session。
- [ ] Reporter failure不阻止合法restore。
- [ ] Secure unavailable、migration write/read-back failure映射typed local-storage／data-corruption Failure，不fallback Legacy Session。
- [ ] Unknown error保留原error與stack。
- [ ] Restore不再自行重複實作Secure / Legacy / User decision matrix。
- [ ] 同一exclusive section內不nested lock。

建議commit：

```bash
git commit -m "feat(auth): 整合restore credential migration"
```

## Task 3 — Login Secure persistence與compensation

**Files**

- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/test/auth_repository_persistence_test.dart`

**Contract**

- [ ] Login只寫Secure credential，不寫Legacy credential。
- [ ] 寫入順序固定為Secure credential → User → Session commit。
- [ ] 任一必要persistence失敗都不得建立Session。
- [ ] User write failure或latest-intent superseded時嘗試清Secure、Legacy與User。
- [ ] Compensation全部stores都嘗試，unknown優先於expected local-storage error。
- [ ] 較舊Login不得清除或覆寫較新Login已commit的state。
- [ ] Double Login、Login + Logout、account switch與existing latest-intent tests維持通過。

建議commit：

```bash
git commit -m "feat(auth): 切換login至Secure credential persistence"
```

## Task 4 — Refresh Secure rotation與passive invalidation

**Files**

- Modify: `packages/auth/lib/src/refresh/auth_session_refresher.dart`
- Modify: `packages/auth/test/auth_session_refresher_test.dart`

**Contract**

- [ ] Refresh只從Secure credential讀取完整Token Pair。
- [ ] Rotation只寫Secure credential，維持persistence-first後才更新Session access token。
- [ ] Refresh前驗證stored userId、SQLite User與runtime Session一致。
- [ ] Invalid refresh、credential corruption／absence與identity mismatch觸發passive invalidation。
- [ ] Passive invalidation嘗試清Secure、Legacy與User，再清runtime Session。
- [ ] Expected cleanup failure不阻止Session expired語意，逐項non-fatal report。
- [ ] Unknown cleanup error保留identity / stack並進既有unexpected reporting flow。
- [ ] Concurrent 401 single-flight、generation、cross-session與safe replay regression不得退化。

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

