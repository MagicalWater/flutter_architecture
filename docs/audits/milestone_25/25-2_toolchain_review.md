---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-25-native-identity-toolchain-review
last_reviewed_baseline: 1.6.1
---

# Milestone 25-2 — Native Identity and Toolchain Review

## Scope

本Task固定iOS 13、template Bundle Identifier、Product Name、Swift generated default、CocoaPods resolution authority與signing exclusion，並建立ADR-024 canonical contract。

## TDD Evidence

先新增`ios_scaffold_contract_test.dart`，初次執行正確失敗於generated mixed-case Bundle Identifier與未固定Product Name。之後只修改Podfile與Xcode project使contract轉為GREEN。

## Final Contract

```txt
iOS minimum: 13.0
Bundle Identifier: com.example.flutterarchitecture
RunnerTests prefix: com.example.flutterarchitecture
Product Name: Flutter Architecture
Swift: 5.0 (Flutter 3.41.6 generated default)
Development Team: unset
Provisioning identifiers: absent
CocoaPods: 1.16.2 locally validated
Native resolution authority: ios/Podfile.lock
```

`Info.plist`的`CFBundleDisplayName`為`Flutter Architecture`，`CFBundleIdentifier`持續從`PRODUCT_BUNDLE_IDENTIFIER`取得。

## Swift Package Manager Readiness

Current resolved Darwin packages：

| Package | Version | `Package.swift` |
|---|---:|---|
| `local_auth_darwin` | 2.0.3 | 有 |
| `flutter_secure_storage_darwin` | 0.3.2 | 有 |
| `shared_preferences_foundation` | 2.5.6 | 有 |
| `sqflite_darwin` | 2.4.2 | 有 |
| `path_provider_foundation` | 2.6.0 | 無 |

因此current Flutter 3.41.6 integration維持CocoaPods-compatible，禁止pure-SPM claim。Flutter 3.44+與SPM migration必須另行review。

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M25-2-R01 Podfile只以註解提示iOS 13 | P1 | 明確設定`platform :ios, '13.0'` |
| M25-2-R02 Generated Bundle Identifier含mixed-case segment | P1 | 全configuration統一為lowercase template identifier |
| M25-2-R03 Product Name仍依賴generic Runner target | P1 | Runner Debug／Profile／Release固定`Flutter Architecture` |
| M25-2-R04 Implementation plan漏列ADR-024落檔 | P1 | 補正plan、建立canonical ADR與index routing |
| M25-2-R05 `pod install`從App root執行會找不到Podfile | P2 | 操作contract固定在`apps/flutter_architecture/ios`執行 |
| M25-2-R06 CocoaPods提示custom base configuration | P2 | Flutter xcconfig已include對應Pods xcconfig；Simulator build gate持續驗證實際integration |
| M25-2-R07 Canonical ADR checker上限仍停在ADR-023 | P1 | 擴充coverage至ADR-024並新增缺少ADR-024的regression |

Open P0／P1 without disposition：0。

## Verification

- Focused iOS scaffold contract test：通過。
- `pod install`：通過；5個Pods，lockfile只更新Podfile checksum。
- `xcodebuild -showBuildSettings`：iOS 13、lowercase identifier、Product Name與Swift 5.0符合contract，沒有Development Team。
- `flutter build ios --simulator -t lib/main.dart`：通過。
- Documentation checker：通過。
- Git diff check：通過。

## Review Decision

Task 25-2通過。Open P0／P1為0；下一步是25-3 Native Plugin Configuration。
