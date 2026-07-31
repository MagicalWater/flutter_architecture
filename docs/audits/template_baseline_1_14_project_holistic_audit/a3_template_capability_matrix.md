---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-capability-matrix
last_reviewed_baseline: 1.14.0
---

# A3 — Template Capability Inventory and Classification

## Classification Rule

本Matrix只使用accepted Design定義的六種分類：正式可用、Reference implementation、需要產品接入、Dependency-ready、Deferred、Explicitly not planned。

分類判斷同時要求contract、production／reference path、primary tests、build／runtime evidence、adopter action與non-goals。存在dependency或範例不等於Supported。

## Capability Matrix

| Capability | Classification | Contract owner | Production／reference path | Primary test owner | Build／runtime evidence | Adopter action required | Known limitations／non-goals | Finding IDs |
|---|---|---|---|---|---|---|---|---|
| Authentication | Reference implementation | ADR-005／Auth README | `packages/auth`＋App Auth adapters／UI | Auth package＋App Auth tests | Android／iOS release-SHA regression | 替換endpoint、backend identity、copy與policy | 不等於產品帳號系統或compliance完成 | F-A2-01 |
| Refresh Token | Reference implementation | ADR-015／API client README | Auth refresher、401 interceptor、credential rotation | Auth＋API client tests | Package／App regression、platform builds | 對接server refresh semantics與token policy | 不保證任意backend replay／revocation model | F-A2-01 |
| OTP Step-Up | Reference implementation | ADR-022／Auth README | Login union、Verify／Resend、OTP UI／navigation | Auth OTP＋App navigation tests | Android／iOS regression | 提供server challenge、delivery、rate limit與localized policy | 不防SIM-swap、phishing，不保證SMS delivery | — |
| Biometric Local Unlock | 正式可用 | ADR-022／App Auth README | App-owned `local_auth` adapter、unlock gate | Auth abstraction＋App local unlock tests | Android runtime evidence；iOS static／simulator boundary | 產品決定enablement、copy、fallback與device acceptance | 只證明user presence；不是server auth或Device Binding | — |
| Secure Credential Storage | 正式可用 | ADR-022 | `flutter_secure_storage` App adapter＋migration coordinator | Auth migration／store／cleanup tests | Android／iOS platform regression | 產品確認threat model、Keychain／Keystore policy | 不抵禦root、runtime memory、server compromise | — |
| Networking／HTTP | 正式可用 | ADR-013 | Retrofit APIs、Dio factory／interceptors、typed transport mapping | API client tests＋App DI tests | Android／iOS builds | 設定HTTPS endpoint、timeouts、headers與backend contract | 不內建所有外部系統或generic gateway | F-A2-01 |
| Pagination | Reference implementation | ADR-016 | Catalog cursor pagination | Catalog repository／Bloc／API tests | App regression | 替換domain DTO、cursor contract與UI copy | 不是通用pagination framework承諾 | — |
| Search | Reference implementation | ADR-016／017 | Catalog query generation、debounce／cancellation | Catalog Bloc／repository tests | App regression | 接入產品search domain與ranking semantics | 不包含server search quality或analytics | — |
| Offline Cache | Reference implementation | ADR-017 | Catalog SWR、Drift cache、fallback／diagnostics | Catalog data／database tests | App regression | 定義產品TTL、privacy、logout與storage policy | 不代表全App offline-first或sync engine | — |
| Connectivity | 正式可用 | ADR-027 | App controller、`connectivity_plus` adapter、offline scope | App connectivity＋Catalog reconnect tests | Android／iOS post-release evidence | 產品決定哪些feature opt-in revalidation | Network state不等於backend reachability | — |
| Drift Persistence | 正式可用 | ADR-010 | Single AppDatabase、AuthUser／Catalog DAOs、platform opener | Database migration／DAO／feature integration tests | Android／iOS builds；Web assets tracked | 新產品依schema／migration規則擴充table | Web仍是dependency-ready；historical sqflite只作oracle | — |
| Localization | 正式可用 | App／Feature README | Flutter localization、Feature failure localization | App widget／localization tests | Platform builds | 新增產品語系、copy與翻譯流程 | 範例copy不代表產品法務／UX核准 | — |
| Design System | Reference implementation | Design System README | Reusable tokens／components＋sample screens | Package／golden／App widget tests | Android／iOS golden authority | 套用產品brand、accessibility與visual QA | 不是完整產品品牌系統 | — |
| Exception／Failure | 正式可用 | ADR-020 | Core typed contracts、boundary-local mapping | Core／Auth／API／Catalog tests | Full regression | 依新operation增加狹窄mapping與copy | 禁止catch-all generic mapper | — |
| Observability | 需要產品接入 | ADR-026 | Provider-neutral reporter＋Firebase Crashlytics reference adapter | Core／App observability＋CI contracts | Android／iOS controlled event historical evidence | 提供Firebase config、privacy／retention、collection與symbol upload policy | Default collection off；reference adapter不等於產品privacy完成 | — |
| Android | 正式可用 | ADR-023／025／026 | Tracked runner、flavors、release verification scripts | Native／CI／App tests | Runtime smoke、managed artifact、post-release validation | 替換identifier、endpoint、signing與Store account | Production APK仍verification signing；distribution deferred | — |
| iOS | 正式可用 | ADR-024～026 | Tracked runner、schemes、Keychain／Face ID、build scripts | Native／CI／App tests | Simulator runtime、unsigned builds、managed evidence | 替換bundle identity、provider config、signing與device acceptance | 不含physical-device biometric、IPA／TestFlight／App Store | — |
| Web | Dependency-ready | ADR-010／platform claim | Drift Wasm／worker assets、conditional opener | Static／database contract tests | 無tracked Web runner或release runtime evidence | 建立runner、驗證plugin support、storage reset與deployment | 不得宣稱Supported | — |
| Windows | Dependency-ready | Platform claim | Conditional desktop dependencies／manual tooling | Package／static tests | 無tracked App runner／release runtime | 建立runner、plugin matrix、artifact與runtime smoke | 不得宣稱Supported | — |
| macOS | Dependency-ready | Platform claim | macOS用作CI host／golden authority，但無tracked App runner | Golden／static tests | Host evidence不等於macOS App evidence | 建立App runner、plugin／sandbox／runtime evidence | 不得由iOS host能力推導Supported | — |
| Linux | Dependency-ready | Platform claim | Conditional dependencies | Static package tests | 無tracked runner／artifact／runtime | 建立runner、native dependency與runtime smoke | 不得宣稱Supported | — |
| CI/CD Foundation | 正式可用 | ADR-023＋CI guide | Change classifier、GitHub workflows、manual／self-hosted／github-hosted modes | Python CI contracts | 1.14.0 self-hosted CI／Android／iOS evidence | Operator維護trusted runner、variables與artifact root | 不含production publishing；Branch Protection僅建議 | — |
| Testing Governance | 正式可用 | Testing Governance Guide | Inventory、owner、historical boundary、Tier 1～5、deletion manifest | Python inventory tests＋all repository tests | Milestone 30 closure＋current validation | 新測試遵守owner／replacement evidence | 不以test count或LOC作唯一品質指標 | — |
| Development Workflow Governance | 正式可用 | Governing Skill＋workflow guide | Requirement Decision、Level 0～5、雙層Task與Skill registry | Docs／Skill pressure tests | Milestone 31 recovery／post-release evidence | 每項新工作先分類並遵守gate | 不替代人類產品決策或runtime evidence | — |
| Template Product Identity Adoption | 需要產品接入 | ADR-025＋adoption Skill／Guide | Manifest-first Android／iOS／environment projection | Skill／docs／native contract tests | Clean-checkout behavioral evidence | 提供產品名稱、identifier、API domain與安全material外部配置 | 不允許把keystore／private key寫入repository | — |

## High-Risk Evidence Review

### Auth／OTP／Secure Storage

Contract、package implementation、App adapters與focused tests完整。其可採用性仍以reference backend與明確threat boundary為前提；沒有把OTP或Biometric描述成Device Binding。

### Drift

Current production owner為single AppDatabase；Auth與Catalog current integration走Drift。sqflite只存在historical fixtures／rollback oracle，production grep為0。

### Observability

Provider-neutral contract與Firebase reference adapter均存在，且曾完成controlled ingestion／symbolication。因採用者仍必須提供provider config、privacy、retention與collection決策，所以主分類是「需要產品接入」，不是「正式可用的產品監控」。

### CI／Platform

Android與iOS具tracked runner、build及runtime evidence，可在揭露限制下列為正式可用。Web／Desktop只有dependency或host能力，全部維持Dependency-ready。

## Claim Consistency Review

- Root README與Project Context對Android／iOS Supported、Web／Desktop Dependency-ready的claim一致。
- Security non-goals一致揭露Device Binding／Passkey不在baseline。
- Production signing、physical-device acceptance與Store distribution均沒有被描述為已完成。
- Firebase adapter沒有被描述成預設已啟用的產品privacy方案。
- 沒有使用`mostly ready`、`partial supported`或其他未核准分類。

## Findings Disposition

A3沒有新增finding。`F-A2-01`只影響Networking／Auth的package transport boundary，不降低current capability主分類；若後續重用Auth package於非Dio transport，風險才會上升。

## Task Disposition

```txt
Capabilities classified: 25
High-risk rows fully checked: Auth, Drift, Observability, CI, Android, iOS
New findings: 0
Open P0: 0
Open P1 without disposition: 0
Task A3: ACCEPTED
```
