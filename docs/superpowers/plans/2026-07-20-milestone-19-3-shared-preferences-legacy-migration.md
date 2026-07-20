# Milestone 19-3 — SharedPreferences Legacy Migration Implementation Plan

狀態：Implementation plan review passed；可進入Task 1。

日期：2026-07-20。

## 目標

建立Auth-specific `AuthCredentialMigrationCoordinator`，完整實作並測試Secure × Legacy × User decision matrix、migration write/read-back/cleanup順序、partial migration re-entry、identity validation與failure ownership。

19-3只建立可獨立驗證的migration policy與App Composition Root dependency shape；不得提前讓Login、Restore、Refresh、Logout或passive invalidation使用Secure authority。Production credential authority仍只允許在19-4一次切換。

## 非目標

- 不切換default `AuthCredentialStore`；SharedPreferences仍是production authority。
- 不修改Repository、Refresher、AuthBloc或SessionManager runtime flow。
- 不建立persistent migration marker。
- 不新增Generic Migration framework、Generic Secure Store或Generic cleanup framework。
- 不加入OTP、Biometric、Device Binding或額外Native permission。
- 不更新`VERSION`。

## 已拍板Architecture Contract

### 唯一migration owner

```txt
Auth lifecycle owner
  → 取得一次AuthStateMutationCoordinator exclusive ownership
  → 呼叫AuthCredentialMigrationCoordinator.resolveUnlocked()
  → 根據resolution決定Session commit
```

Migration coordinator本身不得依賴或呼叫`AuthStateMutationCoordinator`，也不得修改`SessionManager`。

### Store dependency

```txt
Secure AuthCredentialStore
Legacy AuthLegacyCredentialStore
AuthUserStore
```

19-3 App DI必須注入named `secureAuthCredentialStore`，不能誤用default SharedPreferences `AuthCredentialStore`。

### Resolution contract

新增sealed result，固定區分：

```txt
AuthCredentialMigrationUnauthenticated(diagnostics)
AuthCredentialMigrationResolved(tokens, user, diagnostics)
```

`diagnostics`為immutable list，允許同一次resolution攜帶多個safe diagnostic；不得只保留最後一個cleanup failure。Diagnostic只表達固定operation、severity與safe code，不保存raw error message、payload或Token，且不得把credential放入`toString()`。

只有「Secure已驗證為權威，但Legacy cleanup發生expected local-storage failure」可以用successful resolution加diagnostic表示。Destructive cleanup尚未完成時不得偽裝成成功unauthenticated resolution。

### Failure與cleanup優先權

- Destructive cleanup必須嘗試所有應清除的stores。
- 任一unknown error存在時，完成其他cleanup後重拋最先捕捉的unknown error與原stack。
- 沒有unknown error但存在expected local-storage error時，完成其他cleanup後重拋最先捕捉的expected error與原stack。
- 只有全部destructive cleanup成功時才回傳`AuthCredentialMigrationUnauthenticated`。
- Post-authority Legacy cleanup是唯一例外：expected local-storage failure不阻止`Resolved`，改以cleanup-pending diagnostic表達；unknown error仍重拋。

### Read-back validation contract

- 必須比較`accessToken`、`refreshToken`、`userId`、`accessTokenExpiresAt`與`refreshTokenExpiresAt`全部欄位，不能只比identity。
- read-back `absent`、`corrupted`或完整payload mismatch皆建立固定safe `AppExceptionKind.dataCorruption`，diagnostic code固定為`auth_secure_migration_read_back_invalid`。
- read-back本身拋出的plugin operational failure維持原`AppExceptionKind.localStorage`，不得改寫為corruption。
- validation failure後必須嘗試rollback清除Secure；unknown rollback error優先，其次expected local-storage rollback error，最後才是原始data-corruption validation error。
- 無論哪一個error向外拋出，都不得清除Legacy。

### Authority規則

- Secure present且合法時，Secure優先；Legacy只能cleanup，不得覆寫Secure。
- Secure corrupted時，不得fallback Legacy；清完整Auth state。
- Secure unavailable時直接拋typed local-storage `AppException`；不得讀Legacy並建立Session。
- Secure absent且Legacy完整、User存在且identity一致時，才有migration資格。
- 舊`auth.accessToken`單Token永遠沒有migration資格，只能安全清除。
- Secure write成功後必須read-back驗證成功且payload identity/value一致，才能刪Legacy。
- Secure write或read-back失敗時不得刪Legacy；無法驗證的Secure資料必須嘗試清除。
- Secure已驗證但Legacy cleanup失敗時，Secure仍為權威，resolution可成功；cleanup failure須保留safe diagnostic，下一次由真實store state重試。

## Task 1 — Migration public contract與test harness

**Files**

- Create: `packages/auth/lib/src/data/migration/auth_credential_migration_result.dart`
- Create: `packages/auth/lib/src/data/migration/auth_credential_migration_diagnostic.dart`
- Create: `packages/auth/lib/src/data/migration/auth_credential_migration_coordinator.dart`
- Modify: `packages/auth/lib/auth.dart`
- Create: `packages/auth/test/auth_credential_migration_coordinator_test.dart`

- [x] 先建立failing contract tests。
- [x] 定義sealed resolution與safe diagnostic shape。
- [x] 兩個resolution variant都持有immutable diagnostics list；預設為empty，且可安全承載多個diagnostic。
- [x] Coordinator只接受三個Auth-specific stores，不接受plugin、DI或SessionManager型別。
- [x] 公開方法命名明確表達呼叫方已持有exclusive ownership，例如`resolveUnlocked()`。
- [x] Coordinator不得依賴`AuthStateMutationCoordinator`。
- [x] 驗證所有result / diagnostic `toString()`不含credential sentinel。

Commit：

```bash
git commit -m "feat(auth): 建立credential migration contract"
```

Task 1執行結果：新增兩個sealed resolution variants，兩者皆持有defensive-copy後的immutable diagnostics list；resolved variant持有完整`StoredAuthTokens`與`AuthUser`，但result / diagnostic `toString()`不展開credential或原始error message。`AuthCredentialMigrationDiagnostic`保留typed operation、原始error與stack供後續App adapter明確使用。Coordinator constructor只接受Secure credential、Legacy credential與User三個Auth-specific stores，`resolveUnlocked()` public shape已建立，尚未實作Task 2 decision matrix。RED因所有migration types不存在而失敗；GREEN targeted 4 tests與Auth analyze通過。

Task 1 implementation review：通過。Review補強真正的defensive-copy regression：建構resolution後清空呼叫端原始diagnostics list，resolution內容仍保持不變；並鎖定diagnostic保留原始error與stack identity。Public contract未提前依賴SessionManager、mutation coordinator、plugin或DI，`resolveUnlocked()`尚未接入任何runtime graph。

## Task 2 — Unauthenticated與destructive decision matrix

**Files**

- Modify: `packages/auth/lib/src/data/migration/auth_credential_migration_coordinator.dart`
- Modify: `packages/auth/test/auth_credential_migration_coordinator_test.dart`

- [x] `S absent / L absent / U absent`回傳unauthenticated，不做寫入。
- [x] orphan User會被清除。
- [x] Legacy corrupted會清Legacy；只有orphan User時一併清除。
- [x] Legacy identity mismatch會清Legacy與User。
- [x] Secure present但User absent會清Secure與Legacy。
- [x] Secure與User identity mismatch會清Secure、Legacy與User。
- [x] Secure corrupted時清完整Auth state且不得讀Legacy建立Session。
- [x] 舊單一`auth.accessToken`由Legacy adapter維持corrupted／cleanup語意，不得migration。
- [x] destructive cleanup必須各自嘗試，unknown error優先於expected local-storage error。
- [x] destructive cleanup只有全部成功才回unauthenticated；只要有expected cleanup failure就向外拋出，而不是回成功resolution。
- [x] 多個cleanup failure時固定採unknown優先，其次第一個expected local-storage error，並驗證實際caught stack identity。

Commit：

```bash
git commit -m "feat(auth): 實作migration destructive matrix"
```

Task 2執行結果：完成unauthenticated與destructive matrix。Secure corrupted不讀Legacy便直接清Secure / Legacy / User；Secure present但缺User或identity mismatch時依矩陣清理；Secure absent時處理all absent、orphan User、Legacy corrupted、Legacy缺User與identity mismatch。Destructive cleanup會嘗試所有指定store，只有全部成功才回unauthenticated；多個failure採第一個unknown優先，其次第一個`AppExceptionKind.localStorage`，並以`Error.throwWithStackTrace`保留實際caught stack。Secure valid且User一致與Legacy可migration成功路徑仍由Task 3 / 4實作。Targeted tests增為14項，Auth analyze通過。

Task 2 implementation review：通過。Review補強Secure read unavailable會立即保留原error / caught stack並停止，不讀Legacy、User或執行cleanup；expected destructive cleanup failure也明確驗證實際caught stack identity。Targeted tests增為15項，Auth analyze重新通過。

## Task 3 — Secure authority與Legacy cleanup pending

**Files**

- Modify: `packages/auth/lib/src/data/migration/auth_credential_migration_coordinator.dart`
- Modify: `packages/auth/test/auth_credential_migration_coordinator_test.dart`

- [x] Secure valid且與User一致、Legacy absent時直接resolved。
- [x] Secure valid且Legacy相同時，Secure為權威並清Legacy。
- [x] Secure valid且Legacy不同或corrupted時，仍由Secure resolved，只清Legacy。
- [x] Legacy cleanup成功時不產生diagnostic。
- [x] Legacy cleanup expected failure時仍resolved，回傳safe cleanup-pending diagnostic。
- [x] Legacy cleanup unknown error不得被降級或吞掉，保留error與stack identity。
- [x] 下一次呼叫在Secure valid、Legacy仍存在時會再次嘗試cleanup，不需persistent marker。

Commit：

```bash
git commit -m "feat(auth): 實作Secure authority cleanup policy"
```

Task 3執行結果：Secure credential合法且與User identity一致時成為唯一authority；Legacy absent直接回傳resolved，Legacy present（相同或不同）與corrupted只觸發Legacy cleanup，不清Secure或User，也不重寫Secure。Legacy cleanup成功不產生diagnostic；`AppExceptionKind.localStorage` cleanup failure仍回傳resolved並攜帶`legacyCleanup` safe diagnostic，保留原error與caught stack；unknown cleanup error以原identity / stack重拋。Cleanup pending由Secure、Legacy與User真實store state推導，下一次resolve會再次嘗試Legacy cleanup，無persistent marker。RED為7個Secure authority tests因原`UnimplementedError`失敗；GREEN targeted tests增為22項，Auth analyze通過。

Task 3 implementation review：通過。Review將Legacy matching / different / corrupted案例改為唯一可辨識test名稱；補強Legacy read unavailable會阻止resolved並保留原error / caught stack，且不觸發任何cleanup；re-entry regression改用同一個Coordinator instance連續resolve，正式證明cleanup pending不依賴Coordinator內部mutable state。Targeted tests增為23項，Auth analyze重新通過。

## Task 4 — Legacy migration、read-back validation與partial failure

**Files**

- Modify: `packages/auth/lib/src/data/migration/auth_credential_migration_coordinator.dart`
- Modify: `packages/auth/test/auth_credential_migration_coordinator_test.dart`

- [x] `S absent / L valid / U identity一致`依序write Secure → read-back → validate → clear Legacy → resolved。
- [x] write前後不得修改SessionManager。
- [x] Secure write expected failure保留Legacy且向外拋typed local-storage failure。
- [x] Secure write unknown error保留原error與stack。
- [x] read-back absent、corrupted或payload不一致都視為validation failure。
- [x] payload equality比較Token Pair、userId與兩個expiration metadata全部欄位。
- [x] read-back validation failure建立`AppExceptionKind.dataCorruption`與固定`auth_secure_migration_read_back_invalid` diagnostic code。
- [x] read-back validation failure不得刪Legacy，並嘗試清除無法驗證的Secure寫入。
- [x] read-back operational unavailable不得fallback Legacy或刪Legacy。
- [x] rollback cleanup失敗優先權固定為unknown → expected local-storage →原始validation failure；所有error與stack identity均有tests。
- [x] Secure已驗證後Legacy cleanup expected failure仍resolved並標記cleanup pending。
- [x] partial state可重入：Secure已存在且Legacy仍存在時不重寫Secure，只重試Legacy cleanup。

Commit：

```bash
git commit -m "feat(auth): 完成legacy migration read-back驗證"
```

Task 4執行結果：完成Legacy→Secure migration。只有Secure absent、Legacy valid、User存在且identity一致時才依序write Secure、read-back、比較access / refresh token、userId與兩個expiration欄位，驗證成功後才清Legacy並resolved。Secure write expected / unknown failure均保留Legacy與原error / caught stack；read-back absent、corrupted或任一欄位mismatch建立`AppExceptionKind.dataCorruption`與固定`auth_secure_migration_read_back_invalid` diagnostic code，先嘗試rollback Secure後重拋。Read-back operational failure同樣rollback Secure且不得fallback或刪Legacy。Rollback failure優先於原始validation / operational error，unknown與expected local-storage皆保留identity / stack。Secure已驗證後Legacy cleanup expected failure沿用Task 3 cleanup-pending diagnostic；partial state下一次由Secure authority分支只重試Legacy cleanup，不重寫Secure。RED為10個Task 4 tests停在Legacy migration stub；GREEN targeted tests增為37項，Auth analyze通過。

Task 4 implementation review：發現Secure write可能在底層已完成部分寫入後才回報failure，原實作直接重拋而未清除無法驗證的Secure資料，違反已拍板的write / read-back failure cleanup contract。已修正write expected與unknown failure都先嘗試rollback Secure，再依rollback error優先於原始write error的規則向外拋出；Legacy在所有路徑都保留。Targeted tests增為38項，Auth analyze重新通過。

## Task 5 — App diagnostic adapter與named DI shape

**Files**

- Create: `apps/flutter_architecture/lib/features/auth/data/migration/auth_migration_error_reporter_adapter.dart`
- Modify: `apps/flutter_architecture/lib/app/error_reporting/error_report.dart`
- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Generate: `apps/flutter_architecture/lib/app/di/injection.config.dart`
- Create: `apps/flutter_architecture/test/features/auth/data/migration/auth_migration_error_reporter_adapter_test.dart`
- Create: `apps/flutter_architecture/test/app/di/register_module_auth_migration_test.dart`

- [x] 建立Auth migration cleanup的固定safe reporting operation/context。
- [x] Adapter接受一組diagnostics並逐項上報；不得因只處理單一detail而遺失同次resolution的其他diagnostic。
- [x] Reporter adapter不得包含Token、raw payload、SharedPreferences value、Secure value或plugin message。
- [x] `AuthCredentialMigrationCoordinator`以lazy singleton組裝。
- [x] DI明確使用named `secureAuthCredentialStore`、default Legacy store與User store。
- [x] default `AuthCredentialStore`仍是SharedPreferences。
- [x] Repository與Refresherconstructor graph不得加入migration coordinator，也不得改用Secure store。
- [x] DI tests以不同資料寫入default與named stores，證明production authority沒有提前切換。

Commit：

```bash
git commit -m "refactor(di): 組裝credential migration policy"
```

Task 5執行結果：新增App-owned `AuthMigrationErrorReporterAdapter`，接受整組migration diagnostics並逐項建立`degraded` report，context固定為`authMigration / authMigrationLegacyCleanup`；每項保留原error與caught stack identity，但safe `ErrorReport.toString()`不展開plugin message、Token或storage payload。單一reporter call失敗會被吸收且不阻止後續diagnostic。App DI將`AuthCredentialMigrationCoordinator`與adapter註冊為lazy singleton；Coordinator明確注入named `secureAuthCredentialStore`、default `AuthLegacyCredentialStore`與`AuthUserStore`。Generated graph中Repository與Refresher仍取得default `AuthCredentialStore`，production authority維持SharedPreferences。RED為DI graph尚未產生Coordinator registration；GREEN adapter與DI targeted tests共3項通過，App analyze通過。

Task 5 implementation review：通過。Review補強DI integration regression：在default SharedPreferences credential仍為absent、named Secure store持有credential且User identity一致時，直接呼叫registered Coordinator必須回傳Secure credential；此行為證明Coordinator實際注入named Secure store，而不只依賴generated source inspection。原有Repository restore仍看不到Secure-only credential，後續Repository / Refresher仍只操作default store，production authority未提前切換。Targeted tests共3項重新通過，App analyze重新通過。

## Task 6 — Concurrency contract與19-3 regression gate

**Files**

- Modify: `packages/auth/test/auth_credential_migration_coordinator_test.dart`
- Modify: `docs/audits/milestone_19_planning_review.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/project_context.md`
- Modify: `CHANGELOG.md`
- Modify: this plan

- [ ] 以guard fake證明Coordinator自身不取得`runExclusive`。
- [ ] 測試重入state，不使用migration marker。
- [ ] 測試同一Coordinator不保存跨呼叫mutable authority state。
- [ ] 執行Auth migration targeted tests。
- [ ] 執行App adapter / DI targeted tests。
- [ ] 執行workspace analyze與完整tests，基準不得低於19-2的465項。
- [ ] 執行App `flutter build bundle`，確認尚未切換runtime authority。
- [ ] 進行完整19-3 implementation review。
- [ ] 更新M19-PR01、M19-PR02與M19-PR06 implementation evidence。
- [ ] Review通過後將19-3標記Completed / Reviewed，下一步切換19-4。
- [ ] `VERSION`維持1.2.0。

封存commit：

```bash
git commit -m "docs(auth): 封存 Milestone 19-3 legacy migration"
```

## 19-3 Review Gate

必須全部成立才能進入19-4：

- `AuthCredentialMigrationCoordinator`是唯一migration policy owner。
- Coordinator不依賴DI framework、plugin、SessionManager或mutation coordinator。
- Secure × Legacy × User matrix全部有tests。
- Secure unavailable與corrupted都不fallback Legacy。
- Legacy migration遵守write → read-back → validate → cleanup順序。
- Read-back failure不刪Legacy，無法驗證的Secure資料會嘗試清除。
- Read-back validation使用全部credential metadata，並以固定data-corruption diagnostic表達；plugin unavailable仍保持local-storage failure。
- Destructive cleanup未完整成功時不得回成功unauthenticated resolution。
- Secure verified後Legacy cleanup expected failure不阻止resolution，並留下safe cleanup-pending diagnostic。
- Unknown error與stack identity不被吞掉或降級。
- 不建立persistent migration marker。
- App DI使用named Secure store組裝migration coordinator，但Repository／Refresher仍維持default SharedPreferences authority。
- Workspace analyze、完整tests與App bundle build通過。
- 未加入OTP、Biometric、額外Native設定或VERSION變更。

Gate通過後，下一階段才是：

```txt
Milestone 19-4 — Secure Credential Lifecycle Integration
```

## Plan Review 結論

狀態：Passed。

- `M19-3-PLAN01`：原resolution contract沒有說明diagnostic cardinality，可能在多個cleanup failure時遺失evidence。已固定兩個resolution variants皆攜帶immutable diagnostics list。
- `M19-3-PLAN02`：原destructive cleanup只寫error優先權，沒有說expected failure時是否仍回unauthenticated。已固定只有全部cleanup成功才回成功resolution；expected或unknown failure皆在完成其他cleanup後向外拋出。
- `M19-3-PLAN03`：原read-back failure沒有指定typed exception。已固定validation state failure為`AppExceptionKind.dataCorruption`與safe diagnostic code，plugin operational failure仍維持`localStorage`。
- `M19-3-PLAN04`：原payload一致性只寫identity/value，可能漏掉expiration metadata。已固定比較完整Token Pair、userId與兩個expiration欄位。
- `M19-3-PLAN05`：原rollback cleanup failure沒有優先權。已固定unknown → expected local-storage →原始validation failure，Legacy在所有failure path都不得刪除。
- Named Secure DI與19-4 authority switch邊界維持不變；19-3不修改Repository、Refresher或SessionManager runtime flow。
- 無Open P0 / P1 planning issue。
