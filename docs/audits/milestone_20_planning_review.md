# Milestone 20-0 OTP Contract、Threat Model與State Machine Planning Review

狀態：Reviewed / Closed；Planning Gate Approved。

Review 範圍：Auth API、DTO、Retrofit contract、`AuthRepositoryImpl`、`AuthBloc`、Login UI、Navigation、`SessionManager`、`AuthStateMutationCoordinator`、Refresh single-flight / generation、Protected Route、Auth navigation coordinator、Mock / Real API selector、Secure credential lifecycle與latest-intent ordering。

本 Review 只修改規劃文件，不修改 production code、dependency、Native 設定、generated files或 VERSION。

---

## 1. Current Evidence

| Boundary | Evidence | Milestone 20 impact |
|---|---|---|
| Auth HTTP contract | `AuthApi.login()`只回傳`LoginResponseDto`；DTO固定包含Access Token、Refresh Token與User。 | 必須改為typed login union，另增Verify與Resend contract。 |
| Repository | `AuthRepositoryImpl.login()`在remote成功後立即mapping、寫Secure credential、寫SQLite User並建立Session。 | 只有authenticated result可進既有persistence-first commit；challenge result不得碰store或Session。 |
| Domain | `AuthResult`目前固定包含Token Pair與User。 | 拆為`AuthLoginResult.authenticated`與`AuthLoginResult.otpChallenge`。 |
| Bloc | `AuthState`以`user != null`表示authenticated，只有restore/login/logout failure operation。 | 新增明確OTP challenge state與login / verify / resend operation identity；不得以nullable token或布林組合表達。 |
| Lifecycle ordering | `AuthStateMutationCoordinator`提供monotonic lifecycle generation與exclusive queue。 | Password Login、Verify、Resend、Logout、Restore、external clear必須共用同一Auth intent ordering；不能另建Generic state machine framework。 |
| Session | `SessionManager`只有authenticated或null，generation於set / clear遞增。 | OTP pending維持null；Verify成功才建立新generation Session。 |
| Guard / navigation | Protected Route依賴`SessionManager`；Auth navigation依authenticated transition。 | OTP pending自然不可進Protected Route；App-owned coordinator新增challenge navigation，不把Guard改成依Bloc。 |
| Refresh | Refresh依Session identity / generation與single-flight。 | OTP pending沒有Session，因此沒有refresh；Verify成功後才進既有refresh lifecycle。 |
| Mock | `MockAuthApi`無狀態，login固定回token。 | 改為可注入clock、具challenge registry與attempt / resend狀態的Auth-specific Stateful Mock。 |
| Real API | Retrofit與Mock共用`AuthApi` abstraction，由App selector決定implementation。 | Real API只遵守HTTP contract，不加入SMS provider SDK或provider-specific型別。 |
| Secret lifecycle | credential model已禁用欄位型`toString()`；Secure lifecycle與safe diagnostics已建立。 | Password、OTP code、token、raw challenge payload、完整destination均不得進failure、diagnostic、log或`toString()`。 |

---

## 2. Threat Model

### Assets

- Account password與OTP code。
- Server-issued `challengeId`、challenge expiration、attempt budget與replacement identity。
- Verify成功後簽發的Access Token、Refresh Token與User identity。
- 使用者最新Auth intent與目前active challenge。

### Protected properties

- Password login只可產生authenticated或OTP challenge其中之一。
- OTP完成前不得保存credential、寫入AuthUser、建立runtime Session或通過Protected Route。
- 舊Login、Verify、Resend response不得覆蓋較新的Auth intent或active challenge。
- Challenge replacement後，predecessor challenge與其所有in-flight response均不可再commit。
- OTP code不得在Client持久化、diagnostic、exception message、analytics或一般log中出現。
- Masked destination只能顯示Server提供的safe display value；Client不得自行從完整電話或Email推導遮罩。

### Attacker / failure capabilities considered

- 重放舊Verify或Resend response。
- 並行點擊Verify / Resend、快速切換帳號、Logout或重新Login。
- 猜測OTP、超過attempt limit、使用過期或被替換的challenge。
- Transport timeout造成Client不知道Server是否已驗證或替換challenge。
- Backend回傳malformed union、credential與challenge同時存在、缺少必要欄位或不前進的replacement。
- Debug log、Bloc tooling、error reporter或test failure輸出敏感資料。

### Explicit non-goals

- Biometric、Device Binding、Passkey、TOTP enrollment、Recovery Codes。
- Firebase Auth、SMS / Email provider SDK、Client端發送OTP。
- 防止已控制裝置、runtime memory擷取、keylogger、Server compromise、SIM swap或信箱遭入侵。
- Generic Authentication State Machine、Generic Challenge framework或Generic Navigation Service。

---

## 3. Approved Typed API Contract

### Password Login

```txt
POST /auth/login
request: account + password
response:
  authenticated(credentials + user)
  | otpChallenge(challenge)
```

JSON採明確discriminator，例如`resultType: authenticated | otpChallenge`。不得以nullable `accessToken`、`challengeId`組合推斷variant；未知type或variant欄位缺失視為protocol violation。

### OTP Verify

```txt
POST /auth/otp/verify
request: challengeId + code
response: authenticated(credentials + user)
```

Verify成功是唯一可簽發並commit credential的OTP boundary。若產品未來需要二次challenge，必須另開Decision；Milestone 20第一版Verify success不得再回challenge。

Verify失敗不得只靠HTTP status表達。Backend error envelope至少要能以stable code區分：

```txt
invalidCode(attemptsRemaining?)
challengeExpired
tooManyAttempts
challengeInvalidated
temporaryUnavailable
```

`invalidCode`若Server提供新的`attemptsRemaining`，Client必須以該值更新active challenge；若未提供則保留unknown，不自行遞減猜測。Error envelope不得回傳OTP code、完整destination或raw challenge資料。

### OTP Resend

```txt
POST /auth/otp/resend
request: challengeId
response: otpChallenge(replacement challenge)
```

Resend成功永遠回傳完整replacement challenge；不得只回`cooldownSeconds`並讓Client保留舊challenge identity。replacement必須有新的`challengeId`；舊challenge立即失效。

Resend cooldown failure必須提供authoritative `retryAt`或等價absolute UTC timestamp；Client不得只依本地倒數推算Server cooldown authority。

### Challenge DTO required fields

```txt
challengeId: opaque non-empty string
expiresAt: absolute UTC timestamp
maskedDestination: server-provided safe display string
resendAvailableAt: absolute UTC timestamp
attemptsRemaining: positive integer or null when server intentionally withholds it
```

Client以absolute timestamp判斷顯示與本地pre-check，但Server永遠是expiration、cooldown與attempt authority。

---

## 4. Domain Contract

```txt
AuthLoginResult
  authenticated(AuthAuthenticatedResult)
  otpChallenge(OtpChallenge)

AuthAuthenticatedResult
  accessToken
  refreshToken
  user

OtpChallenge
  challengeId
  expiresAt
  maskedDestination
  resendAvailableAt
  attemptsRemaining
```

`OtpChallenge`不包含account、password、OTP code、完整destination或provider identity。Domain model禁止欄位型`toString()`。

Repository拆為三個Auth-specific行為：

```txt
login(account, password) -> Result<AuthLoginResult>
verifyOtp(challengeId, code) -> Result<AuthAuthenticatedResult>
resendOtp(challengeId) -> Result<OtpChallenge>
```

對應UseCase為`LoginUseCase`、`VerifyOtpUseCase`、`ResendOtpUseCase`；不建立大型`AuthUseCase`。

---

## 5. OTP State Machine

### Stable presentation states

```txt
unauthenticated
passwordSubmitting
otpRequired(activeChallenge)
otpVerifying(activeChallenge)
otpResending(activeChallenge)
authenticated(user)
```

Failure不是獨立authentication authority。Password、Verify與Resend failure附著於相應未登入或active challenge state；任何OTP state的`SessionManager.currentSession`均必須為null。

`AuthState`必須能在不保存OTP code的前提下保存下列presentation資料：active challenge、目前operation、operation-specific failure與Server回傳的challenge metadata更新。OTP code只存在輸入controller／event參數與單次request生命週期，不進Bloc state。

### Legal transitions

| From | Event / result | To |
|---|---|---|
| unauthenticated | Login submitted | passwordSubmitting |
| passwordSubmitting | authenticated | authenticated |
| passwordSubmitting | otpChallenge | otpRequired(new challenge) |
| passwordSubmitting | failure | unauthenticated + login failure |
| otpRequired | Verify submitted | otpVerifying(same challenge) |
| otpVerifying | authenticated | authenticated |
| otpVerifying | invalid code | otpRequired(same challenge identity, authoritative attempts metadata if supplied) |
| otpVerifying | expired / too many attempts / challenge replaced | unauthenticated或terminal challenge surface；active challenge清除 |
| otpRequired | Resend submitted且cooldown已到 | otpResending(same challenge) |
| otpResending | replacement challenge | otpRequired(replacement) |
| otpResending | cooldown / temporary failure | otpRequired(original challenge) |
| 任意未登入或OTP state | newer Login / account switch | passwordSubmitting；舊challenge立即由Client失去authority |
| 任意state | Logout / authoritative Session clear | unauthenticated；active challenge清除 |

禁止transition：OTP pending → Session restore、OTP pending → refresh、resend success保留舊challengeId、Verify success後先emit authenticated再保存credential。

---

## 6. Credential and Session Commit Boundary

唯一commit helper接受`AuthAuthenticatedResult`，並在caller-owned single exclusive section內執行：

```txt
operation current check
  → write Secure credential
  → operation current check
  → write SQLite AuthUser
  → operation current check
  → SessionManager.setAuthenticated
```

Password Login authenticated與OTP Verify authenticated共用此helper。任何寫入失敗、operation superseded或identity validation failure都不得建立Session，並沿用Milestone 19 compensation / cleanup policy。

OTP Verify的authenticated commit不得只依Bloc收到response後再判斷challenge是否仍active，因為那時Repository可能已完成credential與Session commit。Repository開始Verify時必須取得同一`AuthStateMutationCoordinator` lifecycle operation；任何較新的Resend、Verify、Login、Logout或Restore都會使該operation失效。Repository在進入authenticated commit helper前及每個commit步驟間檢查operation current。Bloc的active challenge identity檢查只負責防止stale UI metadata更新，不是credential commit的唯一安全線。

Challenge result只更新Bloc / presentation state；不得進`AuthCredentialStore`、`AuthUserStore`或`SessionManager`。

---

## 7. Expiration、Cooldown、Attempts and Replacement

- `expiresAt <= now`：Client禁止送出新的Verify，顯示expired；Server仍對競態中的request做最終判定。
- `resendAvailableAt > now`：Client禁用Resend並顯示remaining duration；Server仍可回typed cooldown failure與authoritative retry time。
- Invalid code不得自動清除challenge，除非Server回too-many-attempts、expired或invalidated。
- `attemptsRemaining`若Server未提供則UI不得自行猜測固定上限。
- Resend成功必須替換完整challenge；舊challenge、舊cooldown、舊attempt budget與所有舊Verify response立即失效。
- Transport timeout不代表Verify或Resend未在Server生效。Client不得自行建立credential或合成replacement；只能重試、重新Login或依Server後續結果收斂。

---

## 8. Latest-intent and Concurrency Contract

`AuthStateMutationCoordinator`繼續作為Auth lifecycle latest-intent與commit serialization owner；Milestone 20不建立第二套generation framework。

每個Login、Verify、Resend、Logout、Restore都取得新的lifecycle operation。Repository authenticated commit以operation generation作為權威安全線；Bloc另以request challenge identity對照active challenge，防止舊invalid-code、cooldown或replacement metadata覆蓋目前UI。

| Race | Required result |
|---|---|
| Login A → Login B，A晚回 | A不得建立challenge、credential、User、Session或覆蓋B UI。 |
| Verify C1 → Resend C1，Resend先回C2 | C1 Verify晚回即使authenticated也不得commit。使用者需對C2重新Verify。 |
| Resend C1重複點擊 | 只允許目前operation回傳的replacement成為active；其他response stale。 |
| Verify C1重複點擊 | latest intent wins；較舊response不得更新attempt或建立Session。 |
| OTP pending → Login不同帳號 | active challenge立即清除；舊Verify / Resend皆stale。 |
| OTP pending → Logout / external clear | active challenge清除；舊response不得復活流程。 |
| Verify success與401 refresh | 不會並存；Verify commit Session後才可能產生authenticated request與refresh。 |

不在mutation lock內等待UI timer或執行diagnostic reporter。Network call在lock外；只有persistence / Session commit進exclusive section。

`SessionManager`在OTP pending本來就是null，因此不能只依「session stream從authenticated變null」才清除challenge。AuthBloc對authoritative external clear必須有明確event／coordinator signal，或將現有session-clear listener擴張為OTP operation也會失效；不得假設null→null一定會產生足以清理OTP state的transition。

---

## 9. Failure Taxonomy and Leakage Rules

新增Auth OTP-specific stable failure identity，但沿用`AppException` → `Failure`架構：

```txt
otpInvalidCode
otpChallengeExpired
otpTooManyAttempts
otpResendCooldown(retryAt)
otpChallengeInvalidated
otpProtocolViolation
```

OTP failure identity需要承載狹窄、safe且可供state transition使用的metadata：

```txt
otpInvalidCode(attemptsRemaining?)
otpResendCooldown(retryAt)
```

不得把這些欄位塞進自由文字message，也不得讓Presentation解析backend message。

- 401不能一律映射invalid credential；依endpoint與backend code區分password invalid、OTP invalid與challenge invalidated。
- Timeout、connection、429、5xx維持temporary / transport failure，不清除既有active challenge，除非Server response明確宣告invalidated。
- Malformed union、credential + challenge混合、空challengeId、非UTC / 無法解析timestamp、replacement未更換identity為protocol violation。
- Safe diagnostic只允許operation enum、endpoint category、HTTP status、backend code、diagnostic code、challenge lifecycle category與boolean flags。
- 禁止記錄password、OTP code、token、Authorization、raw request / response body、raw challengeId、完整destination、Secure payload或Freezed欄位型`toString()`。

---

## 10. Mock and Real API Boundary

Stateful Mock必須以Auth-specific in-memory challenge registry實作，支援可注入clock與deterministic fixtures：

- 一組帳號直接authenticated。
- 一組帳號要求OTP。
- 正確code、錯誤code、expiration、too many attempts。
- cooldown與Resend replacement。
- predecessor challenge invalidation。
- controllable delayed Login / Verify / Resend，供stale response tests。

Mock code只存在test / development fixture，不代表production secret；仍不得由model `toString()`輸出。

Real Retrofit contract只定義endpoint、DTO與transport mapping。App selector維持Mock / Real選擇，不加入Firebase Auth、Twilio、AWS SNS或任何SMS provider SDK。

---

## 11. Planning Findings

| ID | Severity | Risk | Evidence | Disposition | Target phase |
|---|---|---|---|---|---|
| M20-PR01 | P1 | 現有Login DTO / Domain只能表達立即簽發credential，若直接加nullable challenge會產生非法混合state。 | `LoginResponseDto`與`AuthResult`固定包含Token Pair。 | Approved：使用discriminated typed union。 | 20-1 / 20-2 |
| M20-PR02 | P1 | Repository目前remote成功即保存credential與建立Session，challenge response可能誤進commit path。 | `AuthRepositoryImpl.login()`固定呼叫`_persistLoginUnlocked`。 | Approved：只有`AuthAuthenticatedResult`可進共用commit helper。 | 20-2 |
| M20-PR03 | P1 | Bloc只有user / loading二態，無法安全表達active challenge與Verify / Resend競態。 | `AuthState.isAuthenticated => user != null`。 | Approved：建立Auth-specific explicit state machine與challenge identity guard。 | 20-3 |
| M20-PR04 | P1 | Resend replacement與舊Verify response可能交錯，僅靠目前request completion順序會讓predecessor重新建立Session。 | 既有generation只涵蓋restore / login / logout語意，尚無challenge identity validation。 | Approved：所有Auth intents共用generation，另驗證active challenge identity。 | 20-3 |
| M20-PR05 | P2 | Stateless Mock無法驗證expiration、attempt、cooldown與replacement。 | `MockAuthApi.login()`固定回token。 | Approved：Stateful deterministic Mock，不建立generic mock server。 | 20-1 |
| M20-PR06 | P2 | 現有Failure operation沒有Verify / Resend分類，401可能被錯誤顯示為一般帳密錯誤。 | Auth failure localization只區分restore / login / logout。 | Approved：新增OTP-specific failure identity與surface mapping。 | 20-2 / 20-4 |
| M20-PR07 | P2 | OTP code或raw challenge資料可能透過generated `toString()`、error message或reporter洩漏。 | Milestone 17 / 19已對credential建立sentinel contract，但新DTO尚不存在。 | Approved：所有敏感request / response model禁用欄位型`toString()`並加入sentinel tests。 | 20-1 / 20-5 |
| M20-PR08 | P2 | Navigation若直接依AuthBloc或把OTP視為authenticated，會破壞App-owned coordinator與Guard boundary。 | Guard依SessionManager，navigation由App coordinator擁有。 | Approved：Guard不變；App coordinator新增challenge route mapping。 | 20-4 |
| M20-PR09 | P1 | 若Verify authenticated response只在Bloc端檢查active challenge，Repository可能已先保存credential並建立Session。 | Repository目前在回傳Domain success前完成persistence / Session commit。 | Approved：Verify在Repository開始時取得lifecycle operation，commit前與各步驟間檢查generation；Bloc identity guard只保護UI metadata。 | 20-2 / 20-3 |
| M20-PR10 | P1 | Invalid code與Resend cooldown若只映射一般Failure，無法安全更新attempts與authoritative retry時間。 | 現有`Failure`沒有OTP transition metadata。 | Approved：建立typed OTP failure details，Presentation不得解析message。 | 20-1 / 20-2 / 20-3 |
| M20-PR11 | P2 | OTP pending時Session已是null，現有session listener可能無法藉authenticated→null transition清除challenge。 | `AuthBloc`目前只在`session == null && (isAuthenticated || isLoading)`時加入sessionCleared。 | Approved：20-3明確擴張authoritative clear contract並加入null→null OTP regression。 | 20-3 |

Planning Gate結論：無Open P0；所有P1均有明確approved disposition與target phase。文件review已補正authenticated commit authority、typed failure metadata與OTP pending external-clear缺口。20-1可開始，但不得跨階段提前加入UI或改變VERSION。

---

## 12. Formal Sub-phases and Acceptance Criteria

### 20-1 API、DTO、Mapper foundation與Stateful Mock

- Typed Login union、Verify / Resend request與response DTO。
- Retrofit contract與generated code。
- DTO validation / protocol mapping。
- Typed backend error envelope與invalid-code / cooldown metadata contract。
- Stateful deterministic Mock與selector regression。
- Secret sentinel、serialization與endpoint tests。

### 20-2 Domain、Repository、UseCase與credential boundary

- Domain login union與`OtpChallenge`。
- `VerifyOtpUseCase`、`ResendOtpUseCase`。
- authenticated-only共用persistence / Session commit helper。
- Verify lifecycle operation必須在Repository commit前阻擋較舊challenge成功結果。
- OTP failure taxonomy與transport / backend mapping。
- Repository tests證明challenge path零credential、零User、零Session mutation。

### 20-3 Bloc concurrency與latest challenge ordering

- Explicit OTP state machine與events。
- Login / Verify / Resend / account-switch latest-intent ordering。
- active challenge identity guard、replacement與terminal failure transitions。
- authoritative external clear在Session原本為null時仍能清除OTP state。
- Timer只負責presentation countdown，不成為Server authority。

### 20-4 OTP UI、Navigation與Protected Route

- OTP route / page、masked destination、code input、verify、resend countdown與localized failure。
- App-owned Auth navigation coordinator映射challenge與authenticated transitions。
- Guard仍只依SessionManager；OTP pending Protected Route regression。
- Accessibility、large text、narrow viewport與Theme / Locale coverage。

### 20-5 Security Review、Regression與封存

- Secret / diagnostic / `toString()` audit。
- Login、Verify、Resend、Restore、Logout、Refresh、account switch與navigation完整regression。
- Mock full journey與Real API contract evidence。
- Android artifact / runtime smoke範圍由20-5 review決定；不宣稱SMS delivery provider。
- 同步文件並於final review才判斷Template Baseline版本。

---

## 13. Approved Implementation Order

```txt
20-1 typed wire contract + Stateful Mock
  ↓
20-2 domain / repository / authenticated commit boundary
  ↓
20-3 Bloc state machine / concurrency
  ↓
20-4 UI / navigation / guard integration
  ↓
20-5 security / regression / documentation / baseline decision
```

20-0完成後停止，不直接開始20-1。

---

## 14. Final Document Review Closure

Final document review已完成，範圍涵蓋Planning Review、Implementation Plan、Architecture Decision、Roadmap、Project Context與CHANGELOG。

Review結論：

- 11項planning findings數量、severity、disposition與target phase一致；無殘留「8項findings」描述。
- Repository lifecycle generation是credential、User與Session副作用的唯一stale-response authority；Bloc active challenge identity只保護presentation metadata與state transition，不反向補償已發生的Repository commit。
- `invalidCode(attemptsRemaining?)`與`resendCooldown(retryAt)`使用typed metadata，不解析free-form message。
- OTP pending時即使`SessionManager`原本為null，authoritative external clear仍必須使operation失效並清除active challenge。
- 20-1至20-5的implementation順序與scope一致，沒有提前加入UI、SMS provider SDK、Native設定或VERSION變更。
- Planning findings在implementation evidence完成前維持approved disposition，不在20-0誤標為implementation Closed。

Milestone 20-0 document review正式Closed。下一步只允許在獨立工作中開始20-1；本次不開始production implementation。
