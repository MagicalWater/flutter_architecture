---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-security-platform-claim-evidence
last_reviewed_baseline: 1.14.0
---

# A5 — Security and Platform Claim Audit

## Scope and Claim Rule

本Task對照ADR-022～026、tracked Android／iOS／Web configuration、A3 capability matrix、A4 runtime matrix與Milestone 25／27／32 evidence，審查安全能力、威脅邊界與平台分類。

`Supported`只表示repository在明確揭露的範圍內具tracked runner、build／runtime與維護證據；不自動等於physical-device、production signing、Store distribution、產品privacy或所有plugin能力均已完成。

## Security Capability and Threat Boundary Matrix

| Capability／Threat | Repository evidence | Current claim | Explicit boundary | Disposition |
|---|---|---|---|---|
| Credential-at-rest | App-owned `flutter_secure_storage` adapter、read-back migration、corruption／cleanup tests | 正式可用的credential-at-rest hardening | 不防root／jailbreak、runtime memory extraction、server compromise或已外洩credential | Claim precise |
| Server OTP | Server-issued challenge、typed Verify／Resend、Session commit gate | Reference step-up authentication | Client不保證SMS provider delivery、SIM-swap、phishing、provider compromise或產品rate-limit policy | Claim precise |
| Local biometric user presence | App-owned `local_auth` adapter、cold-start gate、resume grace、fail-closed paths | Android正式可用；iOS有Simulator／static evidence且physical device deferred | 不是server authentication、不保存biometric template、不是cryptographic Device Binding | Claim precise |
| Device Binding | 無key pair、server registration、challenge或signature verification | Deferred／not in baseline | 不能由secure storage或biometric presence推導 | Claim precise |
| Passkey | 無WebAuthn／FIDO credential lifecycle、relying-party或platform registration | Deferred／not in baseline | 不能由OTP、local_auth或Keychain dependency推導 | Claim precise |
| Root／jailbreak | 無integrity attestation或tamper resistance contract | Non-goal | Secure storage不宣稱抵抗已受控OS | Claim precise |
| Runtime memory | 無memory hardening／anti-debug guarantee | Non-goal | Token在執行期間仍可能存在於process memory | Claim precise |
| Server compromise | Client template不控制backend trust boundary | Non-goal | Client security不能補償server credential／database compromise | Claim precise |
| SIM-swap／phishing | OTP只表達server challenge state machine | Non-goal | 不把SMS OTP稱為phishing-resistant authentication | Claim precise |
| Sensitive diagnostics | Typed allowlist、credential／OTP sentinel tests、safe context | 正式可用的redaction contract | 不允許raw body、headers、token、PII或free-form context | Claim precise |
| Provider privacy／retention | ADR-026 collection switch、anonymous-by-default、Firebase reference adapter | 需要產品接入 | Template預設remote collection off；adopter需決定consent、retention、deletion、opt-out與法規責任 | Claim precise |

## Platform Claim Matrix

| Platform | Tracked scaffold | Dependency support | Static contract | Host build | Runtime smoke | Physical device | Signing | Distribution | Current classification | Finding IDs |
|---|---|---|---|---|---|---|---|---|---|---|
| Android | Present；19 tracked files | Required plugins與native flavors | CI／native identity／security contractsfresh通過 | Self-hosted Android workflow run `30561753236` success at release SHA `f4f6a8e` | Existing runtime smoke與Milestone 32 managed evidence | 不作所有裝置／OEM保證；本Audit未新增physical-device run | Repository verification signing only | Play Store／production release deferred | Supported | — |
| iOS | Present；58 tracked files | CocoaPods、Keychain、LocalAuthentication、Firebase Apple SDK | CI／native／Face ID／Keychain／configuration contractsfresh通過 | Self-hosted iOS workflow run `30561753276` success at release SHA `f4f6a8e`；unsigned Simulator／generic-device verification | Simulator runtime、storage／security smoke與macOS golden evidence | Explicitly deferred；Milestone 25 Task 25-9未連接實體iPhone | Development Team unset；unsigned verification | IPA／TestFlight／App Store deferred | Supported with explicit physical-device／distribution disposition | — |
| Web | Present；3 tracked files | Drift Wasm／worker assets與conditional opener | Web asset hash、explicit reset policy tests | 無tracked Web build gate作current release authority | 無tracked deployment runtime smoke | N/A | N/A | 無deployment commitment | Dependency-ready | — |
| Windows | Absent；0 tracked files | Conditional Dart／native dependencies可解析 | Package-level static contracts only | Windows是manual CI host，不是Windows App build evidence | 無App runtime evidence | 未驗證 | 未定義 | 未定義 | Dependency-ready | — |
| macOS | Absent；0 tracked files | Darwin dependencies與Mac CI host存在 | iOS golden／host contracts，不是macOS App contract | Mac執行CI、Android與iOS，不代表macOS App build | 無tracked macOS App runtime | 未驗證 | 未定義 | Mac App Store未定義 | Dependency-ready | — |
| Linux | Absent；0 tracked files | Conditional dependencies可解析 | Package-level static contracts only | 無tracked Linux App build | 無runtime evidence | 未驗證 | 未定義 | 未定義 | Dependency-ready | — |

## Exact Release and Runtime Evidence

Milestone 32 post-release validation鎖定：

```txt
Baseline: 1.14.0
Release SHA: f4f6a8e76eebe13be2e039db72c6e27a9c1df380
CI run: 30561753255 / success
Android run: 30561753236 / success
iOS run: 30561753276 / success
Observability Acceptance: 30561753104 / expected skipped on ordinary push
Runner: water-mac-flutter-architecture
Execution mode: self-hosted
Managed jobs: 7 / all evidence_status=complete
Release evidence: 305 files / 503,786,801 bytes
```

Current source在release SHA後只有Milestone 32 closure／roadmap文件與本Audit evidence；沒有production、native configuration或workflow變更使上述platform evidence失效。因此A5重用exact release evidence，不建立不必要的Android／iOS rebuild blocker。

## Current GitHub Storage Read-only Validation

2026-07-31於已登入的existing GitHub CLI session執行唯一允許的`inventory` command；沒有建立manifest、沒有delete，也沒有讀取或保存新token。

```txt
Repository: MagicalWater/flutter_architecture
Collected at: 2026-07-31T14:29:10Z
Inventory SHA-256: 47dd3e1bf801d91cd733285c18d6e8cf731583b7f614123a65457177bb017283
Artifacts: 0 objects / 0 bytes
Caches: 0 objects / 0 bytes
Total: 0 objects / 0 bytes
```

Current inventory與Milestone 32 release前後的0／0結果一致，證明一般self-hosted release validation沒有重新增加GitHub artifact storage。

## Observability Claim Review

- `ErrorReporter`與event routing是provider-neutral contract。
- Firebase Crashlytics只存在App／native integration scope，不污染Feature／Package。
- Controlled event、symbolication與release identity已有historical acceptance evidence。
- Ordinary main push的Observability Acceptance保持expected skipped，避免未經明確gate送出controlled event。
- Template預設collection off；存在provider adapter／config hook不等於adopter已完成privacy、consent、retention或production activation。
- Analytics、APM、session replay與generic remote logging仍是明確non-goal。

## Product Identity and Signing Boundary

- Default identifier、display name與example endpoint仍是template placeholder。
- Adoption必須從manifest／adoption Skill開始，同步Android、iOS與Dart environment mapping。
- Repository禁止保存Android keystore password、Apple private key、certificate、provisioning profile、provider secret或service account material。
- Android production configuration輸出仍是verification artifact；iOS production `.app`仍是unsigned verification build。
- Product account、signing credential、protected environment與Store publishing需由未來產品工作獨立治理。

## Overclaim／Underclaim Review

### Confirmed overclaims

None。

### Confirmed underclaims

None。Web／Desktop雖有dependency與部分static assets，但缺tracked runner／runtime／artifact維護承諾，維持Dependency-ready是正確保守分類。

### Not-an-issue dispositions

- iOS沒有physical-device evidence，但ADR-024允許在明確揭露device／distribution disposition下維持Supported；current README與Project Context均有揭露。
- Android／iOS Supported不代表signed、Store-ready或所有產品provider已啟用。
- Mac是trusted CI host與iOS golden authority，不等於macOS App Supported。
- Web scaffold存在不等於Web Supported。
- Firebase controlled event evidence不等於production privacy完成。

## Fresh Static Validation

```txt
Tracked scaffold: Android present / iOS present / Web present
Tracked scaffold: Windows absent / macOS absent / Linux absent
Tracked files: Android 19 / iOS 58 / Web 3 / Desktop 0
Repository CI static contracts: 202 tests passed
Documentation contracts: 19 tests passed
GitHub storage inventory: 0 objects / 0 bytes
```

最初兩次scaffold批次因Windows `cmd`／PowerShell條件組合錯誤只產生partial output；改用逐項`Test-Path`後取得完整結果。這是audit command composition recovery，不是platform failure。

## Whole-Task Review

- 安全能力與威脅模型逐項分離，沒有使用「安全登入」模糊合併。
- Platform matrix分開tracked scaffold、build、runtime、physical device、signing與distribution。
- Exact current release SHA與remote run evidence仍對應current native／workflow source。
- 沒有要求Apple／Google account、keystore、provider secret或physical device補證明。
- 沒有執行GitHub storage manifest／delete。
- 沒有新增P0／P1或claim finding。

## Task Disposition

```txt
Security／threat rows reviewed: 11
Platforms reviewed: 6
Current GitHub storage: 0 objects / 0 bytes
New findings: 0
Open P0: 0
Open P1 without disposition: 0
Task A5: ACCEPTED
```
