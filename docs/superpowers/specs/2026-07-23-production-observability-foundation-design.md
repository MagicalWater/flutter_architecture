---
document_type: design-spec
status: accepted
authoritative_for:
  - production-observability-foundation-design
last_reviewed_baseline: 1.8.0
---

# Production Observability Foundation Design

## Decision summary

建立新的正式 Milestone：

```txt
Milestone 27 — Production Observability Foundation
```

架構採兩層策略：

```txt
App-owned provider-neutral observability contract
  ↓
Single reference adapter: Firebase Crashlytics
```

不在 reusable package 依賴 Firebase SDK，不讓 Feature／Package直接呼叫 provider API，也不在同一Milestone導入Sentry或第二個production provider。

## Goals

- 將既有`ErrorReporter`提升為可支援production provider的穩定App-owned boundary。
- 明確定義fatal、unexpected與degraded事件如何route至production provider。
- 建立release、version、build、environment與commit identity contract。
- 建立anonymous-by-default、PII deny-by-default的context policy。
- 建立provider初始化、outage、slow reporting與recursive failure保護。
- 建立Android mapping／symbol與iOS dSYM upload的CI contract。
- 提供Firebase Crashlytics單一reference adapter與可替換seam。
- 保持Debug、staging與production behavior可預測且可測試。
- 提供adopter-facing configuration、secret與verification文件。

## Non-goals

- Analytics與business event tracking。
- Feature Flags、Remote Config或A/B testing。
- Performance APM、distributed tracing、session replay。
- 通用remote logging backend或完整log aggregation平台。
- 同時支援Firebase Crashlytics與Sentry production adapter。
- Production signing、AAB／IPA、TestFlight、Play Store或App Store publishing。
- Store release health、full SRE dashboard、alert routing或on-call process。
- Network reachability、request queue、offline mutation或connectivity UI state。

## Architecture boundaries

### Composition root

App仍是唯一Composition Root：

```txt
bootstrap
  ↓
resolve environment + release identity
  ↓
initialize provider adapter best effort
  ↓
compose ErrorReporter
  ↓
install Flutter / Platform / Bloc boundaries
  ↓
runApp
```

Reusable package只保留Exception／Failure contract。Feature可以透過App提供的窄diagnostic sink上報特定degraded operation，但不得知道provider或SDK。

### Contract placement

Production reporting contract維持在App boundary，而不是移到`packages/core`。原因：

- provider初始化依賴Flutter binding與native platform config。
- environment、release identity與consent由App持有。
- reusable package不應取得global reporter或SDK dependency。

既有`ErrorReporter`可演進但不擴張成任意Map、任意breadcrumb或全域logger。

## Event model

### Stable classification

沿用既有severity：

| Severity | Meaning | Default provider route |
|---|---|---|
| `fatal` | App startup或root uncaught path，可能終止當前execution | fatal／crash-compatible record |
| `unexpected` | 未預期 programming／system error，保留identity與stack | non-fatal exception record |
| `degraded` | 已分類、非阻斷但值得診斷的operation failure | filtered non-fatal record |

不得把所有`Failure`上報。Expected operational Failure只有在ADR-020已允許的protocol violation、重要degraded-mode或明確診斷入口才report。

### Source routing

- Bootstrap fatal：初始化失敗後best effort上報，保留原error與stack rethrow。
- Flutter framework：`unexpected`，不因framework來源自動升級fatal。
- Platform/root isolate uncaught：`fatal`。
- Bloc unhandled：`unexpected`，由deduplicator避免後續Platform重複上報。
- Cache／preference／migration：只有已分類safe diagnostic進`degraded`或`unexpected`。

### Duplicate ownership

現有`ErrorReportDeduplicator`只負責同一event-loop turn內的App boundary重複抑制。Provider grouping、event fingerprint與server-side aggregation不是其責任。

Milestone不得把deduplicator改成長時間全域cache，也不得依error message或stack字串模糊去重。

## Safe context design

### Allowlist only

保留封閉typed context，不允許呼叫方提交任意`Map<String, Object?>`。

可新增的production-safe metadata只限：

- source與operation enum。
- environment。
- release version與build number。
- commit SHA（存在時）。
- platform與native configuration identity。
- session generation或`hasSession`等非識別性狀態。
- sanitized route template、HTTP method、status、backend code等ADR-020已允許欄位。

### Prohibited data

Provider adapter必須明確拒絕或根本不接收：

- password、OTP、PIN、token、Authorization、Cookie。
- raw request／response body與完整headers。
- email、phone、name、address等直接PII。
- raw user id、account id、device id、advertising id。
- cursor、search query、free-form Bloc state與event payload。

### User and session context

第一版不設定provider user identifier。只允許anonymous session facts，例如`hasSession`與session generation；generation不得可逆推出account或token。

若未來產品需要user correlation，必須另立privacy review與ADR adjustment，採不可逆且rotatable identifier，不能在Milestone 27偷偷加入。

## Release identity

新增App-owned immutable `ReleaseIdentity`，至少包含：

```txt
environment
version
buildNumber
commitSha? 
platform
nativeConfiguration
```

來源優先順序：

- Version／build number：platform package metadata或build-time define，實作時選擇單一authority並測試一致性。
- Environment：現有`AppEnvironment`與native mismatch guard。
- Commit SHA：CI注入；local build可缺省並標示`local`或不設定，不得假造SHA。
- Native configuration：Android flavor／iOS scheme-build configuration的已驗證mapping。

Production adapter初始化前必須先得到可驗證的environment；release identity缺少非關鍵欄位時可降級，但environment mismatch仍維持fail-fast。

## Provider strategy

### Recommended reference adapter

選擇Firebase Crashlytics作為第一個且唯一reference adapter。

理由：

- 本Milestone核心是crash與handled exception foundation，而非APM平台。
- Flutter、Android與iOS的reference path較聚焦。
- mapping／dSYM與native crash pipeline能形成具體CI evidence。
- 容易示範App-owned adapter如何隔離vendor SDK。

### Replacement cost

未來替換Sentry時，應只替換：

- provider初始化器。
- `ErrorReporter` adapter。
- provider native config與CI upload step。
- adopter config guide。

不應改動Feature、Package、Exception／Failure mapping、Bloc或Flutter／Platform capture boundaries。

### Provider-neutral-only rejection

只做抽象無法驗證native configuration、symbol upload、offline queue、provider outage與release event，因此不足以稱為Production Observability Foundation。

## Initialization and failure semantics

### Startup ordering

Provider初始化需要Flutter binding時，必須在安裝remote adapter前完成最小binding初始化。Bootstrap fatal guard不得依賴一個尚未成功初始化的provider。

推薦兩階段composition：

1. 立即建立永不拋出的local fallback reporter。
2. Best effort初始化production provider並建立composite／switching reporter。

初始化失敗：

- 不阻止App啟動，除非失敗代表既有environment mismatch或安全contract破壞。
- 只使用local safe diagnostic記錄provider unavailable，不遞迴呼叫同一失敗provider。
- 不無限重試，不在startup等待長時間network。

### Slow provider and outage

- `report()`維持同步best-effort API或以adapter內部fire-and-forget queue處理；呼叫方不得await remote delivery。
- Provider SDK queue與offline buffering由SDK持有，App不自行建立持久化crash queue。
- Adapter不得在report path執行network request、database write或無界重試。
- Provider callback或adapter內部錯誤不得重新送入同一reporter。

### Shutdown

Flutter mobile process沒有可靠通用shutdown callback。Milestone不宣稱保證flush。若provider有非阻斷flush API，只可在可測且不延遲正常exit的邊界使用；否則依SDK queue contract。

## Sampling and rate limiting

Fatal與unexpected第一版不在App側random sampling；保留完整事件以利foundation驗證。

Degraded事件必須有有界rate policy：

- 依source＋operation在process內限制burst。
- 不把原始error message納入key。
- 超限事件可drop並增加安全count，不遞迴上報drop本身。

Provider後台sampling與retention由adopter設定並在guide揭露，不由Feature決定。

## Breadcrumb strategy

第一版只允許封閉的system breadcrumbs，不提供Feature任意文字API。

可納入：

- App startup phase。
- authentication lifecycle phase，不含account或token。
- navigation route template，不含query／argument。
- connectivity state僅在未來Connectivity foundation提供typed authority後接入。

因此Milestone 27可先定義breadcrumb interface與startup/navigation minimal set；網路可用性、offline queue與request retry breadcrumbs defer。

## Environment behavior matrix

| Environment | Reporter | Remote collection | Verification |
|---|---|---|---|
| Development | Debug reporter；reference adapter預設關閉 | Off by default | unit／local manual opt-in |
| Staging | Debug + production adapter | On with staging environment tag | non-fatal test event與symbol check |
| Production | production adapter + non-recursive local fallback | On according toadopter privacy policy | release configuration與upload gate |
| Test | recording／fake／noop | Off | deterministic contract tests |

Debug build不得因配置檔存在就自動送production project。Staging與production必須使用可區分的provider project或environment/release routing，且文件不得把同一後台混成無法辨識的資料流。

## Consent, privacy and retention

- Template提供collection switch contract與adopter hook，不自行聲稱符合任何特定司法管轄區。
- 預設anonymous，不設定user id，不收集PII。
- Adopter必須在privacy policy揭露provider、資料類型、retention與opt-out方式。
- 若產品需要opt-in consent，provider initialization／collection enablement必須受App-owned preference控制。
- Provider dashboard retention、data deletion與region是產品採用責任，guide要明列，不硬編碼在Feature。

## Android and iOS release integration

### Android

Milestone應建立：

- development／staging／production對應的provider config projection。
- Gradle plugin與Crashlytics dependency只留在App Android runner。
- R8／ProGuard mapping upload contract。
- Flutter split-debug-info是否採用的明確決策；未採用時不得宣稱Dart obfuscation symbol support。
- CI verification確認production configuration存在、upload step可被安全觸發且secret缺失時行為明確。

目前production APK使用debug verification signing，仍可驗證build wiring與mapping task；不能宣稱Play Store release已完成。

### iOS

Milestone應建立：

- 各environment config與Runner build phase的受控整合。
- dSYM upload script／CLI contract。
- unsigned generic device production build的dSYM存在性驗證。
- CI只使用provider upload credential，不需要Apple signing secret。

目前沒有IPA、TestFlight與App Store distribution，因此可完成dSYM生成與upload tooling evidence，但Store archive／bitcode後處理等distribution-specific驗證defer。

## CI and secrets

GitHub Actions新增的secret與config必須：

- 不提交private service credential。
- 使用environment-scoped secret或repository secret，名稱由guide擁有。
- Pull Request from fork不得取得secret；workflow需能安全skip upload但仍完成build／static contract validation。
- Main push或manual verification可在有secret時執行reference upload test。
- Provider outage不得讓一般quality／unit tests失敗；release upload gate可以依Milestone明確決定為blocking或manual evidence。

建議第一版：

- build與config validation為blocking。
- 真正remote event與symbol upload使用manual／main-only acceptance，不放在fork PR。
- 沒有secret時明確標示not executed，不偽裝成verified。

## Testability

### Contract tests

- severity／source／operation routing。
- release identity conversion。
- safe context allowlist與sensitive data rejection。
- adapter failure、recursive callback與slow provider isolation。
- degraded rate limiting。
- collection enabled／disabled behavior。
- development／staging／production composition。

### Native and CI tests

- Android config/flavor mapping。
- iOS config/scheme/build configuration mapping。
- mapping／dSYM artifact existence。
- upload command dry-run或fake endpoint contract。
- main-only remote test event evidence。

### Runtime acceptance

- Staging handled non-fatal event可在provider console定位到正確release與environment。
- Android／iOS至少各一個symbolicated test stack evidence。
- Reporter失敗不改變App startup與原始error propagation。
- 敏感資料fixture不出現在event context、logs或artifact。

## Proposed task split

### Task 0 — Planning review and ADR

- 核准Milestone scope。
- 新增Production Observability ADR。
- 確認ADR-020只需related link與必要措辭校準，不重寫其error分類authority。

### Task 1 — Release identity and provider-neutral contracts

- `ReleaseIdentity`。
- Collection policy。
- Adapter lifecycle與environment composition contract。
- Focused unit tests。

### Task 2 — Reporting routing hardening

- Fatal／unexpected／degraded provider mapping。
- Recursive failure guard。
- Degraded rate limiting。
- Minimal typed breadcrumbs。

### Task 3 — Firebase Crashlytics reference adapter

- App-owned adapter與SDK seam。
- Development／staging／production composition。
- Collection enablement與safe metadata conversion。

### Task 4 — Android native and symbol pipeline

- Gradle／config wiring。
- Mapping／symbol artifact與upload verification。
- Focused native contract tests。

### Task 5 — iOS native and dSYM pipeline

- Xcode config／build phase wiring。
- dSYM artifact與upload verification。
- Unsigned production verification boundary。

### Task 6 — CI, secrets and remote acceptance

- Safe PR behavior。
- Main/manual secret-backed remote event validation。
- Android／iOS symbolicated evidence。

### Task 7 — Privacy, adopter guide and holistic review

- Privacy／retention／consent adoption guide。
- App／Core README與roadmap synchronization。
- Full regression、final review與Milestone closure。

## Deferred to Connectivity and Offline State Foundation

以下能力不屬於Milestone 27：

- OS／network reachability authority。
- Online、offline、limited、unknown等connectivity state model。
- Request retry／backoff與offline mutation queue。
- Cache synchronization、pending action與reconnect orchestration。
- Connectivity UI surfaces。
- Connectivity state breadcrumbs與network transition diagnostics。
- Provider upload queue是否因network狀態主動pause／resume；第一版依SDK自身offline buffering。

Milestone 27只保留未來可接入typed connectivity breadcrumb的窄extension point，不先實作connectivity foundation。

## Acceptance criteria

- 新ADR被接受且不與ADR-020 authority重疊。
- Reusable package與Feature沒有provider SDK dependency或direct call。
- App可依environment組裝Debug、Test與單一Crashlytics production adapter。
- Fatal／unexpected／degraded routing有明確測試。
- Release identity至少包含environment、version、build與可選commit SHA。
- Anonymous-by-default；沒有raw user id、token、OTP、Authorization、payload或完整response body。
- Provider初始化、report、outage或recursive failure不造成App crash或阻塞startup。
- Android mapping與iOS dSYM具本地／CI可重現artifact evidence。
- Staging remote event可確認release、environment與symbolication。
- Debug build預設不送remote production data。
- CI secrets與fork PR behavior已文件化並測試。
- Adopter guide涵蓋provider project、config、privacy、retention、consent、secret與verification。
- Open P0／P1 findings = 0。

## Design recommendation

Production Observability Foundation值得成為目前下一個正式Milestone。它建立在既有ErrorReporter、ADR-020、native environment與CI基礎上，範圍有界且能產出真正production evidence。

推薦provider策略為provider-neutral contract加Firebase Crashlytics單一reference adapter。Sentry保留為未來替換／第二reference候選，不在本Milestone同步導入。
