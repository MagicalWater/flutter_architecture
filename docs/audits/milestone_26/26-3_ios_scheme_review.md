---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-task-26-3-review
last_reviewed_baseline: 1.7.0
---

# Milestone 26-3 Review — iOS Schemes and Build Configurations

## Scope

本 Task 將 ADR-025 environment mapping contract 投影到 iOS Runner，建立三個 shared schemes、九個 project／Runner／RunnerTests build configurations、environment xcconfig、CocoaPods mapping與product identity。

## Implemented Contract

- Shared schemes：`Development`、`Staging`、`Production`。
- Build configurations：每個 environment皆有 `Debug`、`Profile`、`Release`，共九組。
- `Runner` shared scheme已移除，避免第四個未治理入口。
- `Info.plist`的`CFBundleDisplayName`與`CFBundleName`由`APP_DISPLAY_NAME` build setting提供。
- 每個 xcconfig固定bundle identifier、display name、`FLUTTER_TARGET`、`NATIVE_ENVIRONMENT`與Dart define sentinel。
- Podfile明確映射九個configuration，`pod install`成功。
- Template project未加入Apple Development Team、certificate或provisioning設定。

## Verification Evidence

### Static Contract

```text
python3 -m unittest tools.ci.test_environment_contract
9 tests passed

python3 tools/ci/verify_environment_contract.py
Environment mapping contract verified.
```

### Scheme and Build Settings

`xcodebuild -workspace Runner.xcworkspace -list`可發現三個App schemes。

| Scheme | Configuration | Bundle ID | Display name | FLUTTER_TARGET | Sentinel |
|---|---|---|---|---|---|
| Development | Debug-development | `com.example.flutterarchitecture.development` | Flutter Architecture Dev | `lib/main_development.dart` | development |
| Staging | Debug-staging | `com.example.flutterarchitecture.staging` | Flutter Architecture Staging | `lib/main_staging.dart` | staging |
| Production | Debug-production | `com.example.flutterarchitecture` | Flutter Architecture | `lib/main_production.dart` | production |

三者`IPHONEOS_DEPLOYMENT_TARGET`皆為13.0。

### Build Evidence

Development Debug Simulator：

```text
configuration: Debug-development
sdk: iphonesimulator
bundle id: com.example.flutterarchitecture.development
display name: Flutter Architecture Dev
signing: unsigned
result: BUILD SUCCEEDED
```

Production Release verification：

```text
configuration: Release-production
sdk: iphoneos generic device
bundle id: com.example.flutterarchitecture
display name: Flutter Architecture
signing: unsigned
result: BUILD SUCCEEDED
```

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---|---|
| M26-3-R01 新xcconfig file reference最初未指向`Flutter/`實際路徑，導致build settings未載入 | P1 | 修正九個PBXFileReference path並重跑`-showBuildSettings` |
| M26-3-R02 Planning假設Production Release可使用Simulator SDK，但Flutter明確拒絕release/profile simulator AOT | P1 | 改採generic iOS device SDK搭配`CODE_SIGNING_ALLOWED=NO`，不需憑證或實機 |
| M26-3-R03 CocoaPods對custom base configuration輸出提醒 | P2 | 每個environment xcconfig明確include對應Pods generated config；實際build通過 |
| M26-3-R04 Product name含空白可能影響module name | P2 | Xcode自動產生合法`Flutter_Architecture` module；Debug與Release build皆通過 |
| M26-3-R05 舊`Runner` scheme會形成未治理入口 | P1 | 移除shared Runner scheme，verifier強制scheme集合精確相等 |
| M26-3-R06 Personal signing資料可能污染模板 | P1 | verifier拒絕非空`DEVELOPMENT_TEAM`；兩個verification artifacts皆unsigned |

Open P0／P1 without disposition：0。

## Rollback Boundary

若需要回退本Task，必須一起回復：

- 三個shared schemes與舊Runner scheme。
- 九個project／Runner／RunnerTests configurations。
- 九個environment xcconfig與PBX file references。
- Podfile configuration mapping與Podfile.lock。
- Info.plist display name projection。
- iOS projection verifier與tests。

不得只刪scheme而保留custom configuration，或只回復pbxproj而保留Podfile mapping。
