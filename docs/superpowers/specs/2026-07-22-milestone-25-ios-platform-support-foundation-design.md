---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-25-ios-platform-support-foundation-design
last_reviewed_baseline: 1.6.1
---

# Milestone 25 — iOS Platform Support Foundation Design

## Status

Proposed / Planning Review。

本文件保存 Milestone 25 經討論核准後的正式設計候選。進入 implementation plan 前，必須先完成文件自我 review、planning review 與 findings disposition。

本階段不得執行 `flutter create`、建立 `ios/`、修改 Xcode project、加入 iOS CI、commit 或 push。

## Current Baseline

```txt
Template Baseline: 1.6.1
Branch: main
Local HEAD: be37533 docs(release): 發布 1.6.1 CI 相容性修正
Git status: main ahead of origin/main by 1 commit; working tree clean
Current supported platform: Android
iOS classification: Dependency-ready
```

`be37533` 尚未 push；未經明確指示不得 push。

## Goal

建立最小、可維護且不含 production distribution 責任的 tracked iOS runner，完成 iOS Simulator build、核心 runtime smoke、Keychain／SharedPreferences／SQLite／`local_auth` integration、macOS golden authority 與 GitHub-hosted iOS build validation，並以可重現 evidence 區分 build、simulator、device 與 Supported classification。

## Problem Statement

目前 Flutter App 只有：

```txt
android/
web/
lib/
test/
```

沒有 tracked `ios/` runner，因此：

```bash
flutter build ios --simulator -t lib/main.dart
```

只會得到：

```txt
Application not configured for iOS
```

現有 Dart source、packages 與 conditional platform implementation 對 iOS 具 dependency readiness，但 dependency 或 adapter 存在不代表 executable application support。Milestone 25 必須補齊 native runner、platform configuration、artifact build、runtime plugin evidence 與維護契約，才能改變平台 claim。

## Design Principles

1. App 維持唯一 Composition Root；reusable packages 不直接依賴 Apple plugin implementation。
2. Tracked runner、native configuration、build evidence 與 runtime evidence必須同時存在，不能只靠 dependency claim。
3. iOS scaffold 必須以固定 Flutter toolchain可重現生成，且不得覆蓋既有 Android、Web、Dart、generated source或專案metadata。
4. 第一版採 YAGNI：只建立單一 template identity、單一 Runner target與必要 plugin configuration。
5. Production signing、Store distribution與正式產品identity保持獨立後續initiative。
6. Simulator、physical device與distribution evidence不得互相冒充。
7. Android既有Supported contract與CI evidence不得因新增iOS而退化。

## Current Compatibility Audit

### Reusable packages

以下 packages 沒有 native plugin ownership，也沒有發現 iOS-specific architecture blocker：

```txt
packages/api_client
packages/auth
packages/core
packages/design_system
```

- `packages/api_client`：Dart network、serialization與refresh boundary。
- `packages/auth`：Dart Auth domain、data contract、Session與local user-presence abstraction。
- `packages/core`：Dart exception、failure、result與reporting contract。
- `packages/design_system`：Flutter presentation package，不依賴native plugin。

Native integration集中於 `apps/flutter_architecture`，符合App唯一Composition Root與ADR-012。

### Resolved plugin set

目前 lockfile與package config解析出的關鍵版本：

| Capability | App dependency | Darwin implementation | Minimum iOS | Swift Package manifest |
|---|---|---|---:|---|
| Biometric user presence | `local_auth 3.0.2` | `local_auth_darwin 2.0.3` | 13.0 | 有 |
| Secure credential | `flutter_secure_storage 10.3.1` | `flutter_secure_storage_darwin 0.3.2` | 12.0 | 有 |
| Preferences | `shared_preferences 2.5.5` | `shared_preferences_foundation 2.5.6` | 13.0 | 有 |
| SQLite | `sqflite 2.4.2+1` | `sqflite_darwin 2.4.2` | 12.0 | 有 |
| Path provider | `path_provider 2.1.6` | `path_provider_foundation 2.6.0` | plugin-defined | 無 |

因此最低合理 deployment target 為 iOS 13.0。

## Native Dependency Manager Decision

### Current ecosystem direction

Flutter自3.44起預設使用Swift Package Manager管理iOS與macOS native dependencies；CocoaPods進入maintenance mode。Flutter仍會對尚未支援Swift Package Manager的plugin回退至CocoaPods，且官方要求plugin在過渡期同時支援Swift Package Manager與CocoaPods。

### Current repository constraint

本repository的exact Flutter authority是：

```txt
Flutter 3.41.6
Dart 3.11.4
```

Flutter 3.41.6早於Flutter 3.44的Swift Package Manager預設切換。本次resolved plugin set中，`path_provider_foundation 2.6.0`亦未提供`Package.swift`。

因此 Milestone 25 不得宣稱純Swift Package Manager integration，也不應把Flutter 3.44+ toolchain upgrade偷偷混入iOS scaffold工作。

### Decision

Milestone 25採用以下contract：

```txt
Primary executable integration for baseline 1.6.1 toolchain:
  CocoaPods-compatible Flutter 3.41.6 iOS scaffold

Swift Package Manager posture:
  readiness audited
  supported plugin manifests recorded
  no pure-SPM claim
  no forced migration in Milestone 25
```

理由：

1. iOS platform foundation與Flutter major toolchain migration應分開review、rollback與release。
2. Flutter 3.41.6 generated runner與plugin tooling仍以CocoaPods-compatible integration為可重現authority。
3. 目前至少一個resolved Darwin plugin缺少Swift Package manifest，純SPM不能由現有dependency graph證明。
4. 即使後續升級至Flutter 3.44+，Flutter仍可能對不支援SPM的plugin採hybrid fallback；因此不能把「啟用SPM」等同「完全移除CocoaPods」。

### Future migration gate

後續Swift Package Manager migration必須獨立滿足：

```txt
Flutter exact toolchain >= 3.44
all required Darwin plugins audited for Package.swift
fallback plugin disposition recorded
generated Xcode integration reviewed
Package.resolved authority defined
CI cache and resolution contract defined
CocoaPods removal proven safe rather than assumed
```

若Milestone 25 implementation開始前專案另行核准Flutter toolchain升級，必須重新review本節與全部generated scaffold assumptions，不得直接沿用本spec的CocoaPods contract。

## Plugin Boundary Design

### `local_auth`

現有App-owned boundary：

```txt
PluginLocalAuthGateway
  → LocalAuthUserPresenceVerifier
  → packages/auth LocalUserPresenceVerifier
```

必須維持：

```txt
biometricOnly: true
sensitiveTransaction: true
persistAcrossBackgrounding: false
```

iOS runner必須加入非placeholder的`NSFaceIDUsageDescription`。建議文字：

```txt
使用 Face ID 驗證目前使用者，以解鎖本機已登入的工作階段。
```

此文字不得暗示Face ID是server authentication、付款驗證、Device Binding或biometric data storage。

### `flutter_secure_storage`

Credential authority維持：

```txt
Auth Token Pair
  → FlutterSecureStorage
  → Apple Keychain implementation on iOS
```

第一版不新增：

- App Groups。
- iCloud Keychain sync。
- Generic Secure Store abstraction。
- Biometry-bound Keychain item。
- Secure Enclave key pair。
- Device Binding。

Runner必須依resolved plugin contract配置必要Keychain entitlements，並以runtime restart smoke證明write、read與delete，不得只以mock unit test或`write()`未throw作為成功證據。

### `shared_preferences`

iOS integration延續既有用途：

- Theme preference。
- Locale preference。
- Local unlock preference。
- Legacy credential migration與cleanup。

不需要額外permission或entitlement。Runtime smoke必須區分Preferences container persistence與Keychain lifecycle，不能假設兩者在uninstall／reinstall後有相同行為。

### `sqflite`

既有platform boundary維持：

```txt
Android / iOS
  → native sqflite

Windows / macOS / Linux
  → sqflite_common_ffi

Web
  → sqflite_common_ffi_web
```

iOS不呼叫`sqfliteFfiInit()`。Simulator runtime必須驗證fresh schema、schema version、foreign keys、single-active-user persistence、Catalog cache與Logout preservation contract。

### App lifecycle

現有`WidgetsBindingObserver`會把`inactive`、`hidden`與`paused`視為background boundary，並在`resumed`觸發local unlock lifecycle reconciliation。

iOS biometric prompt本身可能產生`inactive → resumed`序列，因此必須驗證：

```txt
prompt開始
→ App inactive
→ prompt完成
→ App resumed
→ 不重複發出第二個prompt
```

同時驗證真實background、五分鐘grace period與超過grace後重新驗證。

## Scaffold Generation Strategy

### Rejected approaches

不得在production checkout直接執行：

```bash
flutter create .
flutter create . --platforms=android,ios,web
```

不得完全手工建立Xcode project，避免遺漏Flutter build phases、generated plugin integration、xcconfig與project metadata。

### Selected approach

採用temporary generation與逐檔引入：

```txt
固定Flutter 3.41.6
→ 在repository外或ignored temporary directory建立同型Flutter app
→ 只生成ios platform
→ 保存生成命令與generated manifest
→ 比對既有App metadata與root files
→ 只引入經review的ios/
→ 在真正App執行pub resolution、native dependency resolution與build
```

Implementation plan必須列出確切generation command、`--org`、project name與Flutter revision。任何generated root metadata差異都需單獨review，不得順手覆蓋。

## Toolchain Contract

### iOS deployment target

```txt
iOS minimum deployment target: 13.0
```

此值必須在Xcode project、Podfile與resolved native dependencies一致。

### Xcode

```txt
Local validated Xcode: 26.6
CI Xcode: explicit GitHub-hosted image/toolchain, recorded from actual run
```

不得假設`macos-latest`永遠等於本機Xcode 26.6。Local與CI evidence必須分開記錄。

### Swift

App採Flutter 3.41.6 generated default Swift language setting；目前最高plugin floor為Swift 5.5。不啟用Swift 6 strict concurrency，也不新增native Swift業務模組。

### CocoaPods

```txt
Local validated CocoaPods: 1.16.2
Podfile platform: ios, '13.0'
Pods/: not tracked
Podfile.lock: tracked native resolution authority
```

CI優先執行可重現的普通dependency resolution；不得每次無條件`pod repo update`。只有resolution失敗且經review確認需要更新Specs時才使用repo update。

### Swift Package Manager evidence

Milestone 25只記錄plugin manifest readiness，不建立`Package.resolved` authority。未來啟用SPM時，必須提交並治理Xcode產生的`Package.resolved`，讓team與CI解析相同commit。

## Product Identity Governance

### Bundle Identifier

第一版固定使用與既有Android template identity一致的template-only identifier：

```txt
com.example.flutterarchitecture
```

此值必須符合：

- reverse-domain格式。
- 不含個人姓名或Team ID。
- 不使用真實公司domain。
- Debug／Profile／Release一致。
- 不建立production、staging或development native schemes。
- 文件明確標示不可直接視為正式App Store identity。

### Product Name

建議native Product Name：

```txt
Flutter Architecture
```

必須區分：

- Xcode `PRODUCT_NAME`。
- `CFBundleDisplayName`。
- Flutter localized app title。

第一版不建立localized native display name。

### Signing placeholders

Repository不得提交：

- Personal Team ID。
- Distribution certificate reference。
- Provisioning profile UUID或specifier。
- Developer account email。

CI simulator build不得依賴codesigning。

## Info.plist and Entitlements

第一版唯一需要的人機權限說明是：

```txt
NSFaceIDUsageDescription
```

不加入Camera、Photos、Microphone、Location、Contacts、Bluetooth、Tracking、Health、NFC或Notifications說明。

Secure Storage以Keychain entitlement治理，不透過`Info.plist`冒充安全設定。Entitlements只加入resolved plugin與runtime所需最小內容，不加入App Groups或unrelated capabilities。

## Verification Classification

### iOS build-verified

必須具備：

```txt
tracked ios/ runner
native dependency resolution succeeds
flutter build ios --simulator succeeds
no production signing dependency
clean rebuild is reproducible
```

此分類只代表compile、link與artifact generation成功。

### iOS simulator-verified

除build-verified外，必須在Simulator完成：

- App bootstrap。
- Mock Login與Profile。
- Catalog顯示與搜尋。
- Protected Route。
- Theme與Locale restart persistence。
- SharedPreferences local unlock preference。
- SQLite database建立、foreign keys與Catalog cache。
- Secure Storage write、restart read與delete。
- Logout destructive cleanup。
- Biometric capability、success、non-match／cancel與retry path。
- Cold-start local unlock gate。
- Background／resume grace與single-prompt ordering。

### iOS device-verified

必須在實體iPhone記錄：

- Device model與iOS version。
- 安裝與啟動。
- Face ID或Touch ID實際prompt。
- Secure credential restart restore。
- Background／foreground lifecycle。
- Force quit／restart restore。
- Logout cleanup。

若使用Personal Development signing，只能作local evidence；Team ID、certificate與profile不得提交。

### iOS Supported

正式平台矩陣維持簡單分類：

```txt
iOS: Supported
```

但evidence表必須拆分：

```txt
build: verified
simulator: verified
device: verified | not yet verified
distribution: out of scope
```

若device尚未驗證，文件必須明確標示physical-device biometric behavior尚未repository-verified。Supported不得被解讀為production signing、App Store distribution或所有device combinations均已驗證。

## Validation Matrix

| Area | Existing automated evidence | iOS Simulator | Physical iPhone |
|---|---|---|---|
| Bootstrap | Unit／widget／Android runtime | Required | Recommended |
| Auth navigation／Guard | Unit／integration-style widget | Required | Recommended |
| Theme preference | Unit／widget | Required | Optional |
| Locale preference | Unit／widget | Required | Optional |
| Local unlock preference | Unit／lifecycle integration | Required | Required |
| SQLite fresh schema | FFI integration | Required | Recommended |
| SQLite migration | FFI integration | Focused smoke | Optional |
| Catalog persistence | FFI integration | Required | Optional |
| Secure credential write/read/delete | Platform mocks | Required | Required |
| Restart restore | Lifecycle tests／Android evidence | Required | Required |
| Biometric capability／success／cancel | Adapter tests／Android evidence | Required | Required |
| Biometric lockout | Mapping tests | Document simulator limit | Recommended |
| Background／resume grace | Coordinator tests | Required | Required |
| Duplicate prompt prevention | Coordinator tests | Required | Required |
| Real API refresh／replay | Automated tests／Android evidence | Optional | Non-goal |
| Production signing | None | Non-goal | Non-goal |

## Golden Authority

目前只有Windows與Linux reviewed golden authority。Milestone 25必須新增：

```txt
design_system_gallery_macos.png
```

規則：

1. macOS第一次產生的image只作candidate，必須人工review。
2. Windows、Linux、macOS各自保留host-specific authority。
3. 不提高pixel tolerance掩蓋renderer差異。
4. `flutter test` on macOS不等於iOS Simulator rendering。
5. 第一版不建立iOS screenshot golden framework。

## GitHub Actions Design

Milestone 25應加入獨立macOS job：

```txt
iOS / Simulator Build
```

基本責任：

```txt
checkout
→ setup exact Flutter
→ record macOS/Xcode/Swift/CocoaPods toolchain
→ dart pub get
→ native dependency resolution
→ flutter build ios --simulator --no-codesign -t lib/main.dart
→ upload failure logs when useful
```

不得把iOS build混入Android artifact job。Repository checks預期為：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
Android / Release APK
iOS / Simulator Build
```

第一版mandatory CI只要求unsigned simulator build。完整Simulator UI與biometric runtime smoke維持local release gate；若後續證明automation穩定，再獨立提升為CI gate。

## Architecture Decision Requirements

### New ADR

新增：

```txt
ADR-024 — iOS Platform Runner, Native Dependency and Verification Contract
```

Authoritative scope至少包含：

```txt
ios-platform-support-contract
ios-runner-ownership
ios-minimum-deployment-target
ios-native-dependency-manager
ios-template-product-identity
ios-native-plugin-configuration
ios-verification-classification
```

Related ADR：ADR-004、ADR-010、ADR-011、ADR-012、ADR-021、ADR-022、ADR-023。

ADR-024不取代ADR-022的Authentication Security contract，也不取代ADR-023的repository CI authority；它提供iOS-specific realization。

### Existing ADR review

- ADR-010：確認iOS native sqflite contract是否已完整；只有缺口才clarify。
- ADR-022：不改變安全邊界；可補related evidence與review baseline。
- ADR-023：若iOS build成為required repository gate，必須擴充CI contract與Branch Protection guidance。

## Task Decomposition

### Task 25-0 — Planning Review and Active Promotion

- 落檔本design spec。
- 完成spec self-review。
- 建立planning review與findings disposition。
- 建立ADR-024草案。
- review Native Dependency Manager、platform claim與version strategy。
- 經使用者核准後更新Roadmap active authority。

Gate：planning review通過，無未處置P0／P1；不修改production source。

### Task 25-1 — Reproducible iOS Scaffold

- 以Flutter 3.41.6在temporary location生成iOS scaffold。
- 固定org、project name、language與generation command。
- 保存generated manifest與diff review。
- 只引入經review的`ios/`。
- 不重寫Android、Web、Dart source或existing metadata。

Gate：tracked runner完整、diff逐檔review、無個人signing資料。

### Task 25-2 — Native Identity and Toolchain

- 固定iOS 13.0。
- 固定template Bundle Identifier與Product Name。
- 建立CocoaPods-compatible resolution contract與tracked `Podfile.lock`。
- 驗證Debug／Profile／Release設定一致。
- 建立native static contract tests。

Gate：無Team ID、無provisioning data、deployment target一致。

### Task 25-3 — Native Plugin Configuration

- 加入`NSFaceIDUsageDescription`。
- 加入最小Keychain entitlements。
- 驗證plugin registration。
- 新增iOS local_auth、secure storage、preferences、sqflite contract tests。
- 不加入無關permission與capability。

Gate：native dependency resolution與static contract tests通過。

### Task 25-4 — Simulator Build Verification

- Clean simulator build。
- 驗證無codesigning依賴。
- 驗證plugin compile與link。
- 保存local build evidence。

Gate：clean rebuild可重現。

### Task 25-5 — Simulator Core Runtime Smoke

- Bootstrap、Mock Login、Profile、Catalog、Protected Route。
- Theme／Locale persistence。
- SQLite fresh schema、foreign keys與Catalog cache。
- Logout cleanup。

Gate：runtime checklist全數通過並保存可重現evidence。

### Task 25-6 — Security Plugin and Lifecycle Smoke

- Secure Storage write／read／restart／delete。
- Biometric enroll、match、non-match／cancel。
- Local unlock enable／disable與cold-start gate。
- Grace period、inactive／resumed與single-prompt ordering。
- Failure taxonomy與fail-closed behavior。

Gate：locked state不建立Session、不提前讀credential、不重複prompt。

### Task 25-7 — macOS Golden Authority

- 產生macOS candidate golden。
- 人工review語意與Windows／Linux一致。
- 更新platform golden resolver。
- 執行macOS完整tests。

Gate：macOS golden reviewed；pixel tolerance未放寬。

### Task 25-8 — GitHub-hosted iOS Build Gate

- 新增獨立macOS job。
- 固定或記錄runner與Xcode authority。
- 執行unsigned simulator build。
- 建立cache與failure diagnostics。
- 更新CI操作指南與Branch Protection建議。

Gate：remote run成功，既有Linux與Android jobs無退化。

### Task 25-9 — Physical Device Validation Disposition

- 在不提交任何account／signing material前提下嘗試實體iPhone smoke。
- 若可完成，保存device、OS與runtime evidence。
- 若不可完成，正式記錄deferred原因與未驗證範圍。

Gate：device-verified或formal deferred disposition。

### Task 25-10 — Holistic Final Review and Release

- Docs check、analyze、generated consistency與全部tests。
- Android release regression。
- iOS clean simulator build與runtime smoke。
- GitHub-hosted remote evidence。
- Architecture Decision、current snapshot、README、Roadmap、Backlog、CI guide與Milestone routing同步。
- Final review與release。

Gate：無未處置P0／P1，required evidence完整。

## Scope

- Tracked iOS runner。
- Flutter 3.41.6-compatible scaffold。
- iOS 13 minimum deployment target。
- Xcode／Swift／CocoaPods contract。
- Swift Package Manager readiness audit與future migration gate。
- Template Bundle Identifier與Product Name。
- Face ID purpose string。
- Keychain entitlement。
- `local_auth`、`flutter_secure_storage`、`shared_preferences`、`sqflite` integration。
- App lifecycle與local unlock validation。
- Simulator build與runtime smoke。
- macOS golden authority。
- GitHub Actions iOS simulator build。
- Platform capability documentation與evidence。

## Non-goals

- Flutter 3.44+ toolchain migration。
- 強制或純Swift Package Manager migration。
- Apple Developer帳號治理。
- Production signing。
- Distribution certificate。
- Provisioning profile。
- App Store Connect。
- TestFlight。
- App Store upload。
- Push Notifications。
- 正式產品Bundle Identifier。
- 多Scheme／多Flavor。
- Fastlane。
- App Groups或iCloud Keychain。
- Biometry-bound Keychain credential。
- Secure Enclave key與Device Binding。
- Passkey。
- Jailbreak detection。
- 完整iOS UI automation framework。
- iOS screenshot golden framework。
- macOS executable runner。

## Risks

### P0 candidates

1. Keychain設定表面成功但實際無法restart read。
2. Biometric prompt的`inactive → resumed`造成重複prompt或錯誤re-lock。
3. Scaffold生成覆蓋既有App設定或引入其他platform files。

### P1

1. Local Xcode 26.6與GitHub-hosted Xcode不一致。
2. deployment target在Xcode、Podfile與plugins不一致。
3. Personal Team ID或signing設定誤入template。
4. macOS golden被錯當成跨平台唯一authority。
5. Simulator evidence被誤宣稱為physical-device evidence。
6. CocoaPods與Swift Package Manager過渡狀態被誤描述為純SPM或純Pods長期承諾。

### P2

1. CocoaPods cache與Specs availability不穩定。
2. Xcode generated project churn。
3. Simulator runtime版本差異。
4. Lockout場景難以完整模擬。
5. Keychain與Preferences在uninstall／reinstall後的不同lifecycle被誤解。

## Validation Gates

### Static and test gates

```bash
dart pub get
dart run melos run docs_check
dart run melos run analyze
dart run melos run build_runner
dart run melos exec -- flutter test
```

Generated consistency必須在build runner後檢查tracked diff。

### Android regression

```bash
bash tools/ci/build_android_release.sh
```

### iOS build

```bash
cd apps/flutter_architecture
flutter clean
flutter pub get
flutter build ios --simulator --no-codesign -t lib/main.dart
```

必要時使用`xcodebuild -showBuildSettings`與targeted build command檢查deployment target、signing與configuration。

### Simulator runtime

必須使用乾淨Simulator或明確記錄container狀態，完成Task 25-5與25-6 matrix。

### Remote

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
Android / Release APK
iOS / Simulator Build
```

全部success。

## Version Strategy

Milestone 25新增tracked native runner與正式platform capability，屬新增功能：

```txt
1.6.1 → 1.7.0
```

使用MINOR release。

若只完成scaffold或build而未完成critical runtime/plugin evidence，不得宣稱iOS Supported，也不應發布不完整platform baseline。

## Documentation Impact

Planning與implementation預計涉及：

```txt
docs/roadmap.md
docs/roadmap/active.md
docs/roadmap/candidates.md
docs/backlog.md
docs/adr/README.md
docs/adr/adr-024-*.md
docs/project_context.md
README.md
apps/flutter_architecture/README.md
docs/guides/ci_cd_operations.md
docs/milestones/README.md
CHANGELOG.md
VERSION
```

視review結果可能更新ADR-010、ADR-022與ADR-023。

Backlog與Candidates只移出iOS platform runner scope；Web、Windows、macOS、Linux與Native Flavor工作仍保留。

## Approval Gate

本design spec與planning review通過後，下一步才是建立詳細implementation plan。Implementation plan核准前不得建立`ios/`或修改production source。
