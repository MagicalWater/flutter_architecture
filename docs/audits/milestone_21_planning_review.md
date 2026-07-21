# Milestone 21-0 Biometric-gated Local Session Unlock Planning Review

狀態：Reviewed / Closed；Planning Gate Approved。

Review 範圍：Auth restore、Secure credential lifecycle、`AuthRepositoryImpl`、`SessionManager`、`AuthStateMutationCoordinator`、`AuthBloc`、Auth navigation coordinator、Protected Route Guard、Refresh single-flight、App bootstrap / lifecycle、DI、Android runner與Native configuration。

本 Review 只修改規劃文件，不修改 production code、dependency、Native 設定、generated files或 VERSION。

---

## 1. Current Evidence

| Boundary | Current evidence | Milestone 21 impact |
|---|---|---|
| Restore authority | `AuthRepositoryImpl.restoreSession()`在migration resolution成功後直接呼叫`SessionManager.setAuthenticated()`。 | Biometric gate必須位於credential read / restore commit之前；不可先建立Session再以UI遮罩。 |
| Secure credential | App-owned `FlutterSecureAuthCredentialStore`是production credential authority；SQLite只保存公開`AuthUser`。 | Gate只控制既有credential的本機使用權，不搬移或重新簽發credential。 |
| Session | `SessionManager`只有authenticated或null；Guard、Dio token provider、Profile與navigation皆依此authority。 | Locked階段必須保持null，才能自然阻擋Guard、Dio與跨feature consumer。 |
| Auth lifecycle ordering | `AuthStateMutationCoordinator`提供monotonic lifecycle generation與exclusive mutation queue。 | Unlock、restore、logout、login、OTP與external clear必須共用既有ordering，不建立第二套security generation。 |
| AuthBloc | Startup `AuthStarted`直接執行restore；presentation已含OTP state machine。 | Startup需先解析local-unlock policy，再決定直接restore、等待unlock或安全維持unauthenticated。 |
| Navigation | App-owned `AuthNavigationCoordinator`目前映射Login / OTP / Profile，啟動後立即dispatch restore。 | 新增locked destination與unlock orchestration仍由App composition layer持有；Auth feature不得直接操作Router。 |
| Route Guard | `AuthGuard`只讀`SessionManager.isAuthenticated`。 | Guard不需知道Biometric；locked自然拒絕Protected Route。 |
| Refresh | `AuthSessionRefresher`只在已有Session時取得credential並refresh。 | Locked沒有Session，因此不得refresh；unlock後restore建立Session才可進既有refresh流程。 |
| App lifecycle | `ArchitectureApp`目前沒有`WidgetsBindingObserver`型security lifecycle owner。 | Resume re-lock政策需由App-owned coordinator明確持有，不塞進Page或AuthBloc timer。 |
| Android runner | `MainActivity`目前繼承`FlutterActivity`；manifest只有INTERNET permission。 | `local_auth` Android整合預期需`FlutterFragmentActivity`與Biometric permission / theme contract，必須在21-5驗證實際merged manifest與runtime。 |
| Platform scope | Android是唯一Supported runtime target；其他平台Dependency-ready。 | Adapter必須可測且對unsupported platform有typed result，但不宣稱iOS或desktop runtime support。 |

---

## 2. Threat Model

### Assets

- Secure Store中的Access Token、Refresh Token與credential identity。
- SQLite中的公開`AuthUser` identity。
- 已由Server建立、仍可被restore的既有Session資格。
- 使用者是否啟用local unlock的本機政策。
- Unlock prompt結果、目前App lifecycle與最新Auth intent。

### Protected properties

- App啟動時，在local unlock成功前不得讀出可供Session commit的credential，也不得建立runtime Session。
- Biometric success只代表本機user presence，不代表新的Server Login、OTP Verify或credential issuance。
- Cancel、negative button、temporary lockout、permanent lockout、no hardware、not enrolled與plugin operational failure不得被當成success或absence。
- Logout必須清除Session與credential，並安全清除local unlock preference；不可留下「已啟用但無credential」的幽靈政策。
- Disable local unlock不得刪除Server Session或credential；它只改變未來restore是否需要local gate。
- 舊prompt completion不得在較新的Logout、Login、OTP、Disable或App lifecycle決策後重新觸發restore。
- 不保存、傳輸或記錄指紋、臉部template、raw plugin error、prompt輸入或platform biometric type。

### Attacker / failure capabilities considered

- 未授權者取得已解鎖或重新啟動的裝置並啟動App。
- 在prompt顯示期間將App切至背景、返回、重複觸發prompt或快速取消。
- 在prompt pending時執行Logout、重新Login、OTP流程或清除credential。
- 裝置在啟用後移除所有biometric enrollment、暫時／永久lockout，或plugin回傳operational error。
- Process death發生於enable、disable、prompt或restore期間。
- Secure credential存在但unlock preference損壞、讀取失敗或版本未知。
- Debug log、error reporter、Bloc tooling或test output洩漏安全狀態細節。

### Explicit non-goals

- Cryptographic Device Binding、Android Keystore key attestation、Secure Enclave key pair與server signature challenge。
- Passkey、TOTP、Firebase Auth、Root / Jailbreak detection。
- 將local unlock視為第二因素或Server authentication proof。
- 防止rooted device、runtime memory擷取、accessibility malware、screen overlay或server compromise。
- iOS Face ID / Touch ID runtime、Web、Windows、macOS或Linux biometric runner。

---

## 3. Authority Boundary

```txt
Server authentication authority
  Password Login / OTP Verify / Refresh
  → 簽發或更新credential

Local user-presence authority
  local_auth prompt
  → 只允許本次本機restore繼續

Credential authority
  AuthCredentialStore
  → 保存既有Token Pair

Runtime authentication authority
  SessionManager
  → Guard / Dio / Profile / Navigation唯一登入判定
```

Biometric adapter不得直接讀credential、寫Session、操作Router或改變OTP challenge。它只回傳狹窄的local user-presence result。

App-owned startup unlock coordinator負責：

1. 讀取local unlock preference。
2. 判斷是否需要prompt。
3. 取得最新lifecycle operation。
4. 成功後才dispatch gated restore。
5. 對cancel / unavailable / failure決定presentation state，不自行合成Session。

`AuthRepositoryImpl`仍是credential、User與Session restore commit owner；但21-3必須提供「已通過local gate後才可呼叫」的狹窄restore入口或ticket contract，避免任何caller繞過gate。

---

## 4. Approved Policy Model

Biometric capability與使用者政策必須分離：

```txt
LocalUnlockPreference
  disabled
  enabled(versioned metadata)

LocalUserPresenceCapability
  available
  noHardware
  notEnrolled
  unsupportedPlatform
  temporarilyUnavailable
```

第一版政策：

- 預設`disabled`，既有1.4.0使用者升級後不會突然被鎖住。
- Enable只能在目前已有authenticated Session且prompt成功後保存；單純偵測到hardware不可自動啟用。
- Disable需由目前authenticated使用者主動操作；第一版不再要求一次額外prompt，因為這不是Server security setting。產品若要更嚴格需另開Decision。
- Enabled但credential已不存在時，restore結果為unauthenticated，並best-effort清除stale preference。
- Enabled但not enrolled / no hardware / unsupported時，不得fallback成自動restore；維持locked並提供「重新登入」安全出口。重新登入走Server auth，成功後可讓使用者重新設定local unlock。
- Cancel / negative button維持locked，不清credential、不建立Session，可再次嘗試或選擇重新登入。
- Temporary lockout維持locked並顯示typed retry guidance；permanent lockout視為unavailable，提供重新登入出口。
- Preference corruption或operational read failure不得靜默當disabled而繞過gate。Corruption採fail-closed：若Secure credential存在或無法安全證明absence，維持locked並要求重新登入；unknown programming error原樣上拋。

Preference保存於App-owned一般preference storage，只保存`enabled`與schema version，不保存biometric type、enrollment identity、prompt result或credential資料。

---

## 5. State Machine

### Stable App authentication-access states

```txt
bootstrapping
unauthenticated
localUnlockRequired
localUnlockPrompting
restoringAfterUnlock
otpRequired
authenticated
```

`localUnlockRequired`與`localUnlockPrompting`都不是authenticated；`SessionManager.currentSession`必須為null。

### Legal transitions

| From | Event / result | To |
|---|---|---|
| bootstrapping | preference disabled | restoringAfterUnlock（直接restore） |
| bootstrapping | preference enabled | localUnlockRequired |
| localUnlockRequired | retry unlock | localUnlockPrompting |
| localUnlockPrompting | success | restoringAfterUnlock |
| localUnlockPrompting | cancel / negative | localUnlockRequired |
| localUnlockPrompting | temporary lockout | localUnlockRequired + typed failure |
| localUnlockPrompting | unavailable / permanent lockout | localUnlockRequired + re-login action |
| restoringAfterUnlock | valid credential + user | authenticated |
| restoringAfterUnlock | no valid credential | unauthenticated；stale preference cleanup |
| 任意locked state | choose re-login | unauthenticated；invalidate pending prompt / restore |
| authenticated | enable local unlock + prompt success | authenticated + preference enabled |
| authenticated | disable local unlock | authenticated + preference disabled |
| 任意state | logout / authoritative clear | unauthenticated；preference cleanup policy執行 |

禁止transition：prompt success直接`SessionManager.setAuthenticated`、locked state觸發refresh、cancel後fallback自動restore、background中的舊prompt completion建立Session。

---

## 6. Startup、Resume and Re-lock Policy

### Cold start / process restart

- Enabled時每次process start都必須重新unlock。
- App在prompt前不執行credential restore，不建立Session。
- Prompt只由App-owned coordinator序列化，任何時間最多一個active prompt。

### Background / resume

第一版採明確grace period，而不是每次短暫system dialog都立刻re-lock：

- App進入background時記錄monotonic timestamp，不立即清除credential。
- 超過可注入的5分鐘grace period後resume，若local unlock enabled且目前Session存在，先清除runtime Session並要求unlock，再透過既有restore重建Session。
- grace period內resume維持目前Session，不重複prompt。
- Screen off、process death或OS reclaim仍由cold-start規則保護。
- Prompt自身造成的lifecycle抖動不得觸發第二個prompt或清除其operation。

Grace period是local access policy，不是token expiration或Server session TTL；未來產品可改為更短，但第一版需可注入以供deterministic tests。

---

## 7. Local User Presence Contract

`packages/auth`新增純Dart狹窄contract：

```txt
LocalUserPresenceVerifier
  getCapability()
  verify(reason)

LocalUserPresenceResult
  verified
  cancelled
  temporarilyLockedOut
  permanentlyLockedOut
  unavailable(reason)
```

規則：

- Contract不暴露`BiometricType`、`LocalAuthException`、Android error code或plugin class。
- App adapter使用`local_auth`，只允許biometric驗證，不允許device credential fallback；否則Milestone名稱與security claim會失真。
- Prompt reason由App localization提供；package contract只接收已localized安全字串或App adapter內建surface mapping，不讓Domain依賴l10n。
- `stickyAuth`、`persistAcrossBackgrounding`等plugin option必須在21-1 review依實際版本API固定，不憑印象設定。
- Unknown plugin / programming error保留error與caught stack，交由既有ErrorReporter boundary處理；不得降級成cancelled。

---

## 8. Failure Taxonomy

沿用`AppException` / `Failure`架構，新增Auth local-unlock狹窄identity：

```txt
localUnlockCancelled
localUnlockNotAvailable
localUnlockNotEnrolled
localUnlockTemporaryLockout
localUnlockPermanentLockout
localUnlockPreferenceCorrupted
localUnlockPreferenceUnavailable
localUnlockOperationalFailure
```

分類規則：

- Cancel / negative button是expected user outcome，不上報為unexpected。
- No hardware、not enrolled與unsupported platform是capability outcome，不是storage absence。
- Temporary / permanent lockout保留獨立identity，不解析plugin message。
- Preference storage expected failure映射localStorage；corrupted payload映射dataCorruption；unknown error原樣拋出。
- Safe diagnostic只允許operation enum、capability category、lifecycle phase、preference enabled flag與是否有runtime Session；禁止raw biometric type list、plugin message、credential、userId或prompt reason全文。

---

## 9. Concurrency and Latest-intent Contract

- Unlock attempt開始時取得App presentation generation與Auth lifecycle operation。
- Prompt在mutation lock外執行；成功後進入restore前再次確認兩者仍current。
- Logout、Login、OTP、Disable、re-login escape、resume re-lock與external Session clear都會invalidate pending unlock / restore。
- 重複tap unlock採single active prompt；後續tap不建立平行plugin call。
- App background若由prompt本身造成，不得將該prompt判為stale；真正使用者離開App則按adapter lifecycle result與coordinator generation收斂。
- Repository仍負責restore persistence / Session commit的operation checks；UI generation只保護locked surface metadata。

---

## 10. Planning Findings

| ID | Severity | Risk | Evidence | Disposition | Target phase |
|---|---|---|---|---|---|
| M21-PR01 | P0 | 現有startup直接restore並建立Session；若只在UI上加prompt，Guard、Dio與Profile可在unlock前取得authenticated authority。 | `ArchitectureApp`啟動即dispatch`AuthStarted`；Repository直接`setAuthenticated()`。 | Approved：建立App-owned pre-restore gate，locked階段Session維持null。 | 21-3 / 21-4 |
| M21-PR02 | P1 | Capability可用不等於使用者已啟用；若混為一談，升級後可能突然鎖住既有使用者。 | 目前沒有local unlock preference。 | Approved：versioned preference，default disabled；enable需authenticated + successful prompt。 | 21-2 |
| M21-PR03 | P1 | Enabled後移除enrollment或hardware unavailable時，fallback自動restore會繞過既有政策。 | 目前restore沒有capability gate。 | Approved：fail-closed locked + re-login escape，不自動restore。 | 21-1 / 21-3 / 21-4 |
| M21-PR04 | P1 | 舊prompt success可能晚於Logout、account switch或resume re-lock並重新建立Session。 | 現有latest-intent只涵蓋Auth repository operations，尚無prompt owner。 | Approved：App generation + shared Auth lifecycle operation；Repository仍做pre-commit guard。 | 21-3 / 21-4 |
| M21-PR05 | P1 | `SessionManager`只有authenticated/null，若新增獨立「locked session」進SessionManager會污染Guard與refresh authority。 | Guard與token provider直接依SessionManager。 | Approved：locked是App/Auth presentation state，SessionManager維持null，不擴張成credential-known state。 | 21-3 / 21-4 |
| M21-PR06 | P1 | Preference corruption若當disabled處理，可能繞過原本已啟用的gate。 | Theme / Locale corruption可fallback，但Auth access policy風險不同。 | Approved：security preference corruption fail-closed；提供re-login，不靜默disable。 | 21-2 / 21-3 |
| M21-PR07 | P2 | 每次resume立即prompt會被system picker與prompt lifecycle抖動反覆觸發；完全不re-lock又降低本機保護。 | App目前沒有security lifecycle coordinator。 | Approved：可注入5分鐘grace period、single prompt與prompt-owned lifecycle suppression。 | 21-4 |
| M21-PR08 | P1 | Logout若保留enabled preference，下一次無credential啟動可能停在無意義locked畫面。 | Logout目前只清Secure、Legacy、User與Session。 | Approved：Logout納入preference cleanup；無credential restore也best-effort清stale policy。 | 21-2 / 21-3 |
| M21-PR09 | P2 | Adapter若暴露plugin exception / biometric type，會破壞package與平台邊界。 | Decision 022要求`local_auth`只在App。 | Approved：純Dart typed capability / result；App adapter完成mapping。 | 21-1 |
| M21-PR10 | P1 | Android `local_auth`通常需要FragmentActivity與Native contract；只加dependency可能compile通過但runtime失敗。 | MainActivity目前是`FlutterActivity`，manifest無Biometric permission。 | Approved：21-5才修改Native，驗證merged manifest、release artifact與API 35 runtime。 | 21-5 |
| M21-PR11 | P2 | Enable操作若只寫preference而未先驗證prompt，可能把不可用裝置鎖入enabled狀態。 | 目前無workflow。 | Approved：capability check + successful prompt + serialized preference write；write失敗不宣稱enabled。 | 21-2 |
| M21-PR12 | P2 | local auth取消、lockout或not-enrolled若映射一般login failure，UI與reporting會錯誤。 | 現有Auth failure taxonomy只有Server / persistence / OTP。 | Approved：typed local unlock failure與feature-local localization。 | 21-1 / 21-4 |

Planning Gate結論：M21-PR01為P0且已取得明確approved design disposition；在21-3 implementation evidence完成前不得視為Closed。無未處理P0 / P1規劃缺口。21-1可於獨立工作開始，但不得跨階段啟用production gate、修改Native或更新VERSION。

---

## 11. Formal Sub-phases

### 21-1 Local User Presence Contract與App Adapter

- 純Dart capability / verification contract與typed result。
- App-only `local_auth` dependency與adapter，但不接production startup flow。
- Plugin exception、cancel、lockout、not-enrolled、unsupported mapping。
- Adapter unit tests、secret / diagnostic boundary與DI named binding。

### 21-2 Enable / Disable Policy與Persistence

- Versioned local unlock preference、codec、store與typed read taxonomy。
- Authenticated-only enable workflow：capability → prompt → serialized write。
- Disable workflow、Logout cleanup與stale preference cleanup contract。
- Corruption fail-closed、write/read failure與concurrency regression。

### 21-3 Gated Restore與Session Authority

- App-owned startup gate與狹窄gated restore contract。
- Locked階段Session null；success後才允許Repository restore。
- Unlock / Login / OTP / Logout / external clear共用latest-intent ordering。
- Guard、Dio、Refresh、Profile與navigation在locked時不得取得authority。

### 21-4 Unlock UI、Navigation與Lifecycle Concurrency

- Unlock route / surface、retry、re-login escape與localized typed failure。
- App navigation新增locked destination，不讓Route Guard依AuthBloc。
- Resume grace period、single prompt、background / prompt lifecycle競態。
- Accessibility、large text、narrow viewport、Theme / Locale與widget regression。

### 21-5 Android Native、Security Review與封存

- Android runner / manifest / theme依實際`local_auth`版本完成Native configuration。
- Release artifact、merged manifest、API 35 emulator capability / prompt runtime smoke。
- Full Auth / OTP / Restore / Refresh / Logout / navigation regression與secret audit。
- 跨文件同步、findings reconciliation與final baseline decision；只有判定形成新baseline才修改VERSION。

---

## 12. Approved Implementation Order

```txt
21-1 typed local user-presence boundary + isolated App adapter
  ↓
21-2 preference / enable-disable policy
  ↓
21-3 pre-restore gate / Session authority
  ↓
21-4 UI / navigation / lifecycle concurrency
  ↓
21-5 Android runtime / security / regression / baseline decision
```

21-0完成後停止，不直接開始21-1。

---

## 13. Cross-document Consistency Review

Final document review已涵蓋本Planning Review、詳細implementation plan、Decision 022、Roadmap、Project Context、Backlog與CHANGELOG。

結論：

- 所有文件一致將Biometric定義為local user-presence gate，不是Server Login、OTP authority或Device Binding。
- M21-PR01至M21-PR12的severity、disposition與target phase一致；P0只有pre-restore Session exposure，已由21-3明確承接。
- Locked階段一律維持`SessionManager == null`；沒有文件提出先restore再遮罩或新增「locked authenticated Session」。
- Capability與preference分離，default disabled；not-enrolled / unavailable不得fallback自動restore。
- Resume採可注入5分鐘grace period；cold start每次重新unlock。此政策屬local access，不改Server token TTL。
- `local_auth`只在App layer；Android Native修改延後21-5，其他平台不提升runtime support。
- VERSION維持1.4.0；Planning Gate不預先承諾下一版本號。

Milestone 21-0 document review正式Closed。下一步只允許在獨立工作開始21-1；本次不開始production implementation。
