---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-25-ios-platform-support-foundation-planning-review
last_reviewed_baseline: 1.6.1
---

# Milestone 25-0 — iOS Platform Support Foundation Planning Review

## Scope

本review審查Milestone 25將iOS從Dependency-ready提升為具tracked runner、Simulator build、runtime plugin evidence與repository CI gate的平台能力設計。

本階段只建立design與planning authority，不執行`flutter create`、不建立`ios/`、不修改Xcode project、不加入iOS CI、不commit且不push。

正式設計：

- `../../superpowers/specs/2026-07-22-milestone-25-ios-platform-support-foundation-design.md`

## Current Repository State

```txt
Template Baseline: 1.6.1
Branch: main
HEAD: be37533 docs(release): 發布 1.6.1 CI 相容性修正
Remote relation: main ahead of origin/main by 1 commit
Working tree before planning files: clean
Current iOS classification: Dependency-ready
Tracked iOS runner: absent
```

`be37533`尚未push；Milestone 25 planning不得改變remote state。

## Planning Audit Summary

### App and package compatibility

Reusable packages沒有native plugin ownership；iOS integration集中在App Composition Root，符合ADR-004、ADR-012與ADR-022。

目前關鍵Darwin implementation：

| Capability | Darwin package | Resolved version | Minimum iOS | `Package.swift` |
|---|---|---:|---:|---|
| Biometric | `local_auth_darwin` | 2.0.3 | 13.0 | 有 |
| Secure Storage | `flutter_secure_storage_darwin` | 0.3.2 | 12.0 | 有 |
| Preferences | `shared_preferences_foundation` | 2.5.6 | 13.0 | 有 |
| SQLite | `sqflite_darwin` | 2.4.2 | 12.0 | 有 |
| Path Provider | `path_provider_foundation` | 2.6.0 | plugin-defined | 無 |

Minimum deployment target因此固定為iOS 13.0。

### Native dependency manager

Flutter 3.44起預設採Swift Package Manager，並對尚未支援SPM的plugin回退至CocoaPods。Current repository exact toolchain仍是Flutter 3.41.6，且resolved `path_provider_foundation 2.6.0`沒有`Package.swift`。

Planning decision：

```txt
Milestone 25 executable integration:
  Flutter 3.41.6 CocoaPods-compatible scaffold

Milestone 25 Swift Package Manager scope:
  readiness audit only
  no pure-SPM claim
  no Flutter toolchain upgrade
```

Flutter 3.44+與SPM migration必須獨立review，避免把platform scaffold、toolchain upgrade與dependency-manager migration綁在同一rollback boundary。

### Critical native boundaries

- `local_auth`：必須加入`NSFaceIDUsageDescription`，維持biometric-only與single-prompt lifecycle。
- `flutter_secure_storage`：必須加入最小Keychain entitlement並以restart smoke證明write/read/delete。
- `shared_preferences`：驗證Theme、Locale與local unlock preference persistence，不與Keychain lifecycle混淆。
- `sqflite`：iOS走native implementation，不初始化FFI；驗證schema、foreign keys與Catalog preservation。
- App lifecycle：特別驗證iOS biometric prompt造成的`inactive → resumed`不會重複prompt。

## Architecture Decisions

### Scaffold

採temporary generation與逐檔引入。禁止在production checkout直接執行無限制的`flutter create .`，也不手工建立Xcode project。

### Toolchain

```txt
Flutter: 3.41.6 exact
Dart: 3.11.4 bundled
Local Xcode evidence: 26.6
Local CocoaPods evidence: 1.16.2
iOS minimum: 13.0
Swift: Flutter generated default; plugin floor 5.5
```

CI的macOS image與Xcode版本必須從實際remote run記錄，不得假設等於local Xcode 26.6。

### Template identity

```txt
Bundle Identifier: com.example.flutterarchitecture
Product Name: Flutter Architecture
Development Team: unset in repository
Native schemes/flavors: not included
```

### Verification classification

正式區分：

```txt
iOS build-verified
iOS simulator-verified
iOS device-verified
iOS Supported
```

`iOS Supported`文件仍必須附build、simulator、device與distribution evidence欄位；Simulator evidence不得冒充physical-device evidence。

### CI

新增獨立`iOS / Simulator Build` macOS job；不與Android artifact job混合。第一版remote mandatory gate只做unsigned simulator build，完整runtime／biometric smoke維持local release gate。

### Golden

新增macOS-specific reviewed golden authority；Windows、Linux、macOS各自獨立，不建立iOS screenshot golden framework。

## Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M25-PR01 Repository沒有tracked iOS runner，無法建立application artifact | P1 | Task 25-1以temporary generation建立最小runner |
| M25-PR02 Dependency-ready容易被誤宣稱為Supported | P1 | 固定四級verification classification與evidence matrix |
| M25-PR03 Flutter生態已轉向SPM，但current toolchain仍為3.41.6 | P1 | 本Milestone維持CocoaPods-compatible integration，SPM migration獨立治理 |
| M25-PR04 `path_provider_foundation 2.6.0`缺少`Package.swift` | P1 | 禁止pure-SPM claim；記錄future migration gate |
| M25-PR05 Keychain write可能表面成功但restart read失敗 | P0 | Keychain entitlement與write/restart/read/delete runtime gate |
| M25-PR06 iOS biometric prompt lifecycle可能觸發重複prompt | P0 | Task 25-6驗證inactive/resumed、grace與single-prompt ordering |
| M25-PR07 Direct `flutter create`可能覆蓋既有App設定 | P0 | Temporary generation、manifest與逐檔diff review |
| M25-PR08 iOS deployment target尚未形成repository contract | P1 | 固定iOS 13.0並建立Xcode／Podfile／plugin一致性test |
| M25-PR09 Template Bundle Identifier與Product Name未治理 | P1 | 固定`com.example.flutterarchitecture`與`Flutter Architecture` |
| M25-PR10 Personal Team或provisioning資料可能誤入template | P1 | Static scan、repository Team unset、CI no-codesign |
| M25-PR11 macOS沒有reviewed golden authority | P1 | Task 25-7建立獨立macOS baseline，不放寬tolerance |
| M25-PR12 iOS build若只在本機執行，缺少repository-level gate | P1 | Task 25-8新增GitHub-hosted macOS build job |
| M25-PR13 Physical device需要signing但account governance不在scope | P2 | Task 25-9允許local evidence或formal deferred disposition |
| M25-PR14 CocoaPods與SPM過渡狀態可能被寫成永久二選一 | P2 | ADR-024記錄current integration與future migration gate |

Open P0／P1 without disposition：0。

## Architecture Decision Gate

需要新增：

```txt
ADR-024 — iOS Platform Runner, Native Dependency and Verification Contract
```

原因：tracked runner ownership、minimum deployment target、native dependency manager、template identity、Keychain／Face ID configuration、verification classification與iOS CI gate都會形成長期repository contract。

ADR-024應related至ADR-004、ADR-010、ADR-011、ADR-012、ADR-021、ADR-022與ADR-023，不取代Authentication Security或repository CI的通用contract。

ADR-023需要在Task 25-8 review是否擴充required iOS build gate；ADR-010與ADR-022只有發現current contract缺口才修改。

## Implementation Phases

1. **25-1 — Reproducible iOS Scaffold**：temporary generation、manifest、tracked runner與diff review。
2. **25-2 — Native Identity and Toolchain**：iOS 13、template identity、CocoaPods-compatible resolution與static tests。
3. **25-3 — Native Plugin Configuration**：Face ID、Keychain、plugin registration與native contracts。
4. **25-4 — Simulator Build Verification**：clean unsigned build與local evidence。
5. **25-5 — Simulator Core Runtime Smoke**：bootstrap、Auth、Catalog、preferences、SQLite與Logout。
6. **25-6 — Security Plugin and Lifecycle Smoke**：Keychain、biometric、cold start、resume與fail-closed behavior。
7. **25-7 — macOS Golden Authority**：host-specific reviewed baseline與full tests。
8. **25-8 — GitHub-hosted iOS Build Gate**：macOS runner、unsigned build、cache、diagnostics與CI guide。
9. **25-9 — Physical Device Validation Disposition**：local device evidence或formal defer。
10. **25-10 — Final Review and Release**：holistic regression、remote evidence、documentation、archive與1.7.0 release decision。

## Acceptance Criteria

- Tracked iOS runner以Flutter 3.41.6可重現建立，沒有覆蓋其他platform或App設定。
- Minimum deployment target固定為iOS 13.0。
- Bundle Identifier固定為`com.example.flutterarchitecture`；repository不含Personal Team或provisioning資料。
- `NSFaceIDUsageDescription`與最小Keychain entitlement通過static與runtime review。
- `local_auth`、Secure Storage、SharedPreferences與sqflite完成Simulator integration evidence。
- Biometric prompt lifecycle不造成重複prompt或提前Session restore。
- Clean unsignedSimulator build可在local與GitHub-hosted macOS runner重現。
- macOS使用獨立reviewed golden authority，Windows／Linux baseline不被取代。
- Android既有tests、release build與CI evidence無退化。
- 文件精確區分build、simulator、device、Supported與distribution。
- 未完成critical runtime/plugin evidence前不宣稱iOS Supported。
- Final review Open P0／P1為0。

## Scope and Non-goals Review

Scope包含tracked iOS runner、iOS 13、CocoaPods-compatible Flutter 3.41.6 integration、SPM readiness audit、plugin integration、Simulator build／runtime、macOS golden與GitHub-hosted build gate。

明確不包含Flutter 3.44+升級、pure-SPM migration、Apple Developer account governance、production signing、provisioning、App Store Connect、TestFlight、App Store、Push Notifications、正式Bundle Identifier、Schemes／Flavors、Fastlane、App Groups、Device Binding與Passkey。

Scope可由單一implementation plan管理；各Task具有獨立review與rollback boundary，不需要拆成另一個Milestone。

## Version Decision

Planning candidate：

```txt
1.6.1 → 1.7.0
```

新增tracked native runner與正式platform capability屬MINOR。Final version仍以25-10 holistic evidence為準；若只完成scaffold／build而未完成critical runtime integration，禁止發布iOS Supported baseline。

## Review Status

第一輪planning review完成以下檢查：

- Design placeholder scan：通過；template identifier已固定。
- Design internal consistency：通過；Flutter 3.41.6、CocoaPods-compatible integration與SPM future gate一致。
- Scope check：通過；沒有混入Flutter upgrade、distribution或native flavor。
- Architecture boundary：通過；plugins維持App-owned，packages保持plugin-neutral。
- Documentation checker：通過。

使用者已完成review並核准本planning authority。Milestone 25可提升為active，下一步建立並review implementation plan，再依逐Task implementation／review／修正／re-review／commit流程執行。
