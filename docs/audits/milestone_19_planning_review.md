# Milestone 19 Planning Review

狀態：Completed。

Review 範圍：Milestone 19-0 Scope、Threat Model、Architecture Contract、Persistence Seam、Migration Ownership、Failure Taxonomy、Concurrency Contract與驗證要求。

本 Review 只審查與修訂文件，不修改 production code、dependency、Native 設定、generated files或 VERSION。

---

## 現況 Evidence

目前 `packages/auth` 的 credential persistence 具有下列特性：

- `AuthLocalDataSource` 同時持有 `SharedPreferences`與SQLite `Database`，並同時實作Repository、Refresh與Token Storage所需介面。
- `auth.tokens`以JSON保存完整Token Pair；`auth.accessToken`只保存舊單一Access Token。
- `AuthRepositoryImpl`將Login、Restore與Logout的複合mutation放入`AuthStateMutationCoordinator.runExclusive`。
- `AuthSessionRefresher`在remote refresh前後分段使用相同coordinator，rotation採persistence-first。
- `AuthStateMutationCoordinator.runExclusive`是不可重入的序列queue；在exclusive action內再次等待`runExclusive`會形成self-deadlock。
- 現有`readTokens()`使用nullable表示absence、`CorruptedAuthTokensException`表示corruption、`AppExceptionKind.localStorage`表示expected operational failure。
- 現有best-effort cleanup會吞掉cleanup error，因此Milestone 19必須重新定義哪些路徑可忽略、哪些路徑應回傳Failure或non-fatal report。

---

## Threat Model

### 需要保護的資產

- Access Token。
- Refresh Token。
- Token對應的`userId`與expiration metadata。
- Legacy SharedPreferences credential cleanup狀態。

`AuthUser`不是credential，仍保存在SQLite；但其`id`是Session identity validation的一部分。

### Milestone 19提供的保護

- Credential不再以明文JSON保存在一般SharedPreferences。
- 降低一般檔案擷取、未受保護App資料備份或低權限診斷工具直接取得Token Pair的風險。
- Credential read、write、rotation、migration與cleanup經由單一Auth-specific boundary協調。
- Secure、Legacy與SQLite User identity不一致時不猜測、不建立runtime Session。

### 不在保護範圍

- 已root、已被完整控制或已解鎖且遭惡意程式注入的裝置。
- Runtime process memory、debugger、screen capture或輸入側錄。
- Server、TLS termination、API credential issuer或帳號本身遭入侵。
- Cryptographic Device Binding、hardware-backed key attestation、Passkey與biometric user presence。
- iOS及其他非Android平台runtime secure-storage保證。

因此Milestone 19不得將Secure Storage描述為「Token絕對無法被取得」，而應描述為credential-at-rest hardening。

---

## Approved Architecture Contract

### 1. Store boundaries

`packages/auth`建立三個Auth-specific狹窄boundary：

```txt
AuthCredentialStore
  readCredential
  writeCredential
  clearCredential

AuthLegacyCredentialStore
  readLegacyCredential
  clearLegacyCredential

AuthUserStore
  readUser
  writeUser
  clearUser
```

`AuthCredentialStore`由App layer的Secure Storage adapter實作；`AuthLegacyCredentialStore`由SharedPreferences adapter實作；`AuthUserStore`由SQLite adapter實作。

不得建立Generic Secure Store、Generic Key-Value Store或讓package public contract暴露plugin型別。

### 2. Credential read taxonomy

Credential與Legacy read使用sealed typed result，不再只靠nullable與例外混合表意：

```txt
AuthCredentialReadResult
  absent
  present(StoredAuthTokens)
  corrupted
```

規則：

- `absent`是正常狀態。
- payload存在但格式、必要欄位或內容驗證失敗時回傳`corrupted`。
- plugin unavailable、I/O failure、key invalidated或其他expected operational failure拋出typed local-storage `AppException`。
- programming error、平台契約外錯誤與其他unknown error保留原error與stack重拋。
- `clear`在資料本來不存在時仍視為成功，必須具備idempotent語意。

### 3. Migration owner

新增Auth-specific `AuthCredentialMigrationCoordinator`作為唯一migration policy owner。

它只負責在呼叫方已持有`AuthStateMutationCoordinator` exclusive ownership時執行：

```txt
inspect Secure + Legacy + User
  → decide authority
  → write Secure when eligible
  → read-back validate
  → cleanup Legacy
  → return resolved credential state
```

Migration coordinator本身不得呼叫`runExclusive`，也不得修改`SessionManager`。Lifecycle owner負責取得一次exclusive ownership、呼叫migration，再決定runtime Session commit。

### 4. No persistent migration marker

Milestone 19第一版不新增persistent migration marker。

理由：

- Secure、Legacy與User三個store的實際狀態已足以推導migration phase。
- Secure已成功且Legacy仍存在，本身就是`legacyCleanupPending`。
- 另加marker會形成第四個非原子store，增加marker與實際credential狀態不一致的故障模式。
- Migration必須可由真實資料狀態重入，不依賴「曾經執行過」的旗標。

未來只有在真實runtime evidence證明無法由store state推導時，才另開Decision評估marker。

### 5. Exclusive ownership與禁止巢狀lock

所有跨Secure、Legacy、User與SessionManager的複合mutation必須只取得一次`AuthStateMutationCoordinator.runExclusive`。

禁止：

```txt
runExclusive
  → migration coordinator
    → runExclusive
```

因目前coordinator不是reentrant lock，上述流程會self-deadlock。

Repository、Refresher與passive invalidation應提供清楚的`...Unlocked`內部helper，在已持有exclusive ownership時使用；公開入口才負責取得lock。

### 6. Production authority切換

19-1只拆boundary且保持現況行為；19-2只建立Secure adapter與測試；19-3完成migration policy與matrix tests。

Production credential authority只在19-4一次切換：

- Login直接寫Secure credential，成功後寫User；任一步失敗都不得建立Session。
- Restore在同一exclusive section內執行migration resolution，再建立Session。
- Refresh讀寫Secure credential，rotation維持persistence-first。
- Logout與passive invalidation嘗試清除Secure、Legacy與User。

不得出現Login已寫Secure、Restore仍讀Legacy或Refresh仍寫SharedPreferences的半套狀態。

---

## Secure × Legacy × User Decision Matrix

縮寫：`S`=Secure、`L`=Legacy完整Token Pair、`U`=SQLite User。

| S | L | U | 決策 |
|---|---|---|---|
| absent | absent | absent | 未登入；不做額外寫入。 |
| absent | absent | present | 清除orphan User；維持未登入。 |
| absent | valid且identity一致 | present | 寫Secure、read-back驗證、清Legacy；成功後可restore。 |
| absent | valid但identity不一致 | present | 清Legacy與User；維持未登入。 |
| absent | corrupted | 任意 | 清Legacy；若只有orphan User則一併清除；維持未登入。 |
| valid且與U一致 | absent | present | Secure為權威；可restore。 |
| valid且與U一致 | valid且相同 | present | Secure為權威；清Legacy；可restore。 |
| valid且與U一致 | valid但不同或corrupted | present | Secure為權威；只清Legacy；可restore。 |
| valid | 任意 | absent | 無法證明完整Session；清Secure與Legacy；維持未登入。 |
| valid但與U不一致 | 任意 | present | 清Secure、Legacy與User；維持未登入。 |
| corrupted | 任意 | 任意 | Secure不可使用；不得由Legacy覆蓋一個存在但損壞的Secure state；清完整Auth state並維持未登入。 |

補充規則：

- 舊`auth.accessToken`永遠不具有migration資格，只清除。
- Secure read operational failure時不得讀Legacy並建立Session，避免把Secure暫時不可用誤判為Secure不存在。
- Secure write成功但read-back validation失敗時，不刪Legacy，並清除無法驗證的Secure寫入。
- Secure已驗證且Legacy cleanup失敗時，Secure仍為權威；本次restore可繼續，但cleanup failure必須non-fatal report並在下一次Auth lifecycle重試。

---

## Cleanup與Reporting Contract

### Interactive Login / Restore

- Credential或User必要寫入失敗：不建立Session，回傳typed Failure。
- Migration前置Secure read unavailable：不fallback Legacy，回傳typed Failure。
- 已驗證Secure credential後只有Legacy cleanup失敗：允許restore，進行non-fatal report，後續重試cleanup。

### Interactive Logout

- Runtime Session必須清除，即使任一storage cleanup失敗。
- Secure、Legacy與User三者都必須各自嘗試清除。
- Unknown error優先於expected local-storage error重拋。
- 若只有expected cleanup error，Logout回傳Failure，但不得恢復runtime Session。

### Passive Session Invalidation

- Runtime Session必須清除。
- Secure、Legacy與User cleanup都必須嘗試。
- Expected cleanup failure不得阻止Session expiration語意，但要由單一owner non-fatal report。
- Unknown error不得被空catch吞掉；必須保留原error與stack交給既有reporting boundary。

Diagnostic不得包含Token、raw payload、SharedPreferences value、Secure Storage value、Authorization、Cookie或credential-bearing error message。

---

## Findings與Disposition

### M19-PR01 — Migration缺少唯一owner

- Severity：P1。
- Status：Disposition approved；待19-3 / 19-4 implementation與tests關閉。
- Risk：Repository、Refresher與adapter各自判斷migration會造成重複政策、authority不一致與競態。
- Disposition：由`AuthCredentialMigrationCoordinator`作唯一policy owner；Lifecycle owner取得exclusive ownership。
- Target：19-3 / 19-4。

### M19-PR02 — Mutation coordinator不可重入

- Severity：P1。
- Status：19-1 implementation evidence complete；待19-3 / 19-4完整關閉。
- Risk：migration或cleanup helper在exclusive action中再次等待`runExclusive`會self-deadlock。
- Disposition：明確禁止nested lock；使用已持有ownership的`...Unlocked` helper。
- Target：19-1 / 19-3 / 19-4。
- 19-1 Evidence：Repository與Refresher複合mutation只取得一次`runExclusive`，cleanup使用既有ownership下的helper；concurrency、latest-intent、single-flight與cross-session tests通過。

### M19-PR03 — Absence、corruption與unavailable taxonomy不足

- Severity：P1。
- Status：Closed；19-1與19-2 implementation evidence complete。
- Risk：把Secure unavailable當成absence會錯誤fallback Legacy並建立Session。
- Disposition：採sealed read result；operational unavailable仍拋typed AppException。
- Target：19-1 / 19-2。
- 19-1 Evidence：`AuthCredentialReadAbsent / Present / Corrupted`已成為公開sealed taxonomy；SharedPreferences adapter只將payload validation映射為corrupted，plugin operational failure維持`AppExceptionKind.localStorage`並保留cause與stack。
- 19-2 Evidence：Secure adapter沿用相同sealed taxonomy；不存在payload回傳absent，malformed / incomplete payload回傳corrupted，`PlatformException`與`MissingPluginException`拋出typed local-storage `AppException`。Tests確認cause、stored stack與實際caught stack identity，unknown `StateError` / `TypeError`不被降級。

### M19-PR04 — Persistent marker增加第四個非原子狀態

- Severity：P2。
- Status：Not an issue after revision。
- Risk：marker與實際credential stores漂移，反而使migration不可重入。
- Disposition：Milestone 19不建立persistent marker，以真實store state推導。

### M19-PR05 — Threat model與Secure Storage能力可能被過度宣稱

- Severity：P1。
- Status：19-2 implementation evidence complete；待19-5 Android runtime evidence完整關閉。
- Risk：將at-rest hardening誤述為rooted device、runtime memory或server compromise防護。
- Disposition：固定保護範圍、非目標與Android-only runtime evidence。
- Target：19-2 / 19-5。
- 19-2 Evidence：Secure Storage能力只描述為credential at-rest hardening；未宣稱可防rooted device、runtime memory或server compromise。Android App固定Secure Storage最低API 23下限、全面停用backup；release APK與merged manifest通過，實際minSdk 24、targetSdk 36，未加入Biometric / Fingerprint permission。

### M19-PR06 — Cleanup failure ownership不足

- Severity：P1。
- Status：Disposition approved；待19-3 / 19-4 implementation與tests關閉。
- Risk：沿用空catch會吞掉Secure cleanup failure與unknown error，且不同flow可能產生不同Session語意。
- Disposition：區分interactive、passive與post-migration cleanup；固定return、report與rethrow規則。
- Target：19-3 / 19-4。

---

## Planning Review Gate 結論

Milestone 19-0 Planning Review通過。

- 無Open P0 finding。
- 六項planning finding皆已取得明確disposition。
- 所有P1 finding均已取得approved disposition，但仍保持implementation pending，必須以對應production change、tests與runtime evidence正式關閉。
- Secure Storage dependency尚未加入。
- Production code、Native設定與VERSION尚未修改。
- 下一個正式階段為Milestone 19-1 Auth Persistence Seam。

19-1不得提前加入`flutter_secure_storage`或改變runtime authority；它只建立新boundary、搬移既有SharedPreferences / SQLite adapter ownership並維持行為等價。

## 19-1 Implementation Review Update

Milestone 19-1已完成並通過implementation review。

- 三個Auth-specific store contracts與typed read taxonomy已建立。
- SharedPreferences / SQLite adapters與plugin dependency已移至App；`packages/auth`保持純Dart orchestration boundary。
- 舊`AuthLocalDataSource`、`AuthLocalStore`、`AuthRefreshLocalStore`與`AuthTokenStorage`已移除。
- Repository與Refresher由App Composition Root取得相同lazy singleton stores。
- SharedPreferences仍是19-1 credential authority；未加入Secure adapter、migration policy、Native設定或VERSION變更。
- Workspace analyze、437項完整tests與App bundle build通過。

下一步為Milestone 19-2；M19-PR03須待Secure adapter實作後完整關閉，其他跨階段finding依原Target持續追蹤。

## 19-2 Implementation Review Update

Milestone 19-2已完成並通過implementation review。

- `flutter_secure_storage: ^10.3.1`只由App依賴；`packages/auth`沒有新增Flutter plugin或DI framework依賴。
- App-owned Secure adapter使用單一Token Pair payload，並維持absent / present / corrupted / unavailable四種不同語意。
- Plugin operational failure只窄範圍映射`PlatformException`與`MissingPluginException`；既有`AppException`與unknown error identity / stack保持不變。
- Named Secure store與底層plugin為lazy singleton；default SharedPreferences store仍由Repository與Refresher使用。
- Android release build發現並修正Flutter upgrader會覆寫literal minSdk的問題；最終採`maxOf(flutter.minSdkVersion, 23)`，release manifest實際minSdk 24、targetSdk 36、backup disabled且無Biometric permission。
- Workspace analyze、465項完整tests與release APK build通過；未加入migration、OTP、Biometric runtime或VERSION變更。

M19-PR03已關閉；M19-PR05完成19-2 evidence，保留至19-5 runtime evidence後完整關閉。下一步為Milestone 19-3。
