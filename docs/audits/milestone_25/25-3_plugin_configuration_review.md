---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-25-native-plugin-configuration-review
last_reviewed_baseline: 1.6.1
---

# Milestone 25-3 — Native Plugin Configuration Review

## Scope

本Task建立iOS Face ID purpose string、最小Keychain entitlement、Xcode configuration引用與generated plugin registration contract。它只驗證tracked native configuration與unsigned Simulator integration；Keychain跨restart與biometric runtime行為仍由Task 25-6負責。

## TDD Evidence

先擴充`ios_scaffold_contract_test.dart`。修正測試本身的Dart `$`跳脫後，首次有效RED因`DebugProfile.entitlements`不存在而失敗。之後新增最小entitlements、`NSFaceIDUsageDescription`與Xcode references，使focused contract test轉為GREEN。

## Final Native Contract

### Face ID

`Info.plist`加入：

```txt
NSFaceIDUsageDescription =
Use Face ID to verify the current user before unlocking the local signed-in session.
```

文字只描述本機user-presence unlock，不宣稱server authentication、Device Binding、交易授權或biometric資料保存。

### Keychain Entitlements

Tracked files：

```txt
ios/Runner/DebugProfile.entitlements
ios/Runner/Release.entitlements
```

兩者只包含：

```txt
keychain-access-groups
→ $(AppIdentifierPrefix)$(CFBundleIdentifier)
```

Debug與Profile使用`DebugProfile.entitlements`；Release使用`Release.entitlements`。沒有App Groups、Push Notifications或其他無關capability。

### Plugin Registration

Generated iOS registrant確認註冊：

- `FlutterSecureStorageDarwinPlugin`
- `LocalAuthPlugin`
- `SharedPreferencesPlugin`
- `SqflitePlugin`

`path_provider_foundation 2.6.0`存在於`.flutter-plugins-dependencies`，但current metadata標記`native_build: false`，因此不產生Pod或GeneratedPluginRegistrant entry。這是current resolved implementation disposition，不得被誤寫成缺少plugin integration。

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M25-3-R01 Runner缺少Face ID purpose string | P0 | 加入精確且不誇大的`NSFaceIDUsageDescription` |
| M25-3-R02 Secure Storage缺少tracked Keychain entitlement | P0 | 建立DebugProfile與Release最小entitlements並加入Xcode references |
| M25-3-R03 初始contract test未跳脫Dart `$` | P2 | 修正測試語法後重新取得有效RED evidence |
| M25-3-R04 Planning文字暗示path provider應出現在registrant | P1 | 依actual metadata記錄`native_build: false`，測試其不應產生native registrant |
| M25-3-R05 unsigned Simulator app的embedded entitlements為空 | P2 | 明確分類為no-sign build限制；Task 25-6以runtime Keychain evidence驗證實際能力 |

Open P0／P1 without disposition：0。

## Verification

- Focused iOS scaffold/plugin contract tests：通過。
- `plutil`檢查tracked plist與entitlements：通過。
- `pod install`：通過；5個Pods。
- Generated plugin registrant inspection：四個native plugins符合contract。
- `.flutter-plugins-dependencies`：`path_provider_foundation native_build: false`。
- `flutter build ios --simulator -t lib/main.dart`：通過。
- Built app `Info.plist`包含Bundle Identifier、Display Name與Face ID purpose string。
- `xcodebuild -showBuildSettings`包含正確`CODE_SIGN_ENTITLEMENTS`設定。
- Documentation checker、analyze與Git diff check：通過。

## Review Decision

Task 25-3通過。Open P0／P1為0；下一步是25-4 Simulator Build Verification。
