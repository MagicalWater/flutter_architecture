---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-25-ios-simulator-build-verification
last_reviewed_baseline: 1.6.1
---

# Milestone 25-4 — Simulator Build Verification Review

## Scope

本Task建立repository-owned iOS Simulator verification build，固定clean dependency restoration、unsigned build entrypoint、artifact identity、deployment target、plugin registration與personal signing exclusion。

## TDD Evidence

先在`ios_scaffold_contract_test.dart`新增build script contract。首次執行正確失敗於`tools/ci/build_ios_simulator.sh`不存在；建立最小腳本後，focused test轉為GREEN。

## Repository Build Contract

入口：

```txt
bash tools/ci/build_ios_simulator.sh
```

腳本依序執行：

```txt
flutter clean
flutter pub get
cd apps/flutter_architecture/ios && pod install
flutter build ios --simulator --no-codesign -t lib/main.dart
```

Build後必須驗證：

- `build/ios/iphonesimulator/Flutter Architecture.app`存在。
- `CFBundleIdentifier`為`com.example.flutterarchitecture`。
- `IPHONEOS_DEPLOYMENT_TARGET`為`13.0`。
- Generated registrant包含secure storage、local auth、shared preferences與sqflite。
- Xcode project沒有Development Team或provisioning profile設定。

## Reproducibility Evidence

同一個repository state連續執行兩次完整clean build，兩次均得到：

```txt
Artifact: Flutter Architecture.app
Bundle identifier: com.example.flutterarchitecture
IPHONEOS_DEPLOYMENT_TARGET: 13.0
Signing: no Apple Development Team or provisioning profile required
```

兩次均重新移除build、`.dart_tool`、Flutter ephemeral與plugin metadata，再重新執行Pub與CocoaPods resolution，不依賴前次workspace build output。

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M25-4-R01 repository沒有可供本機與CI共用的iOS build入口 | P1 | 新增`tools/ci/build_ios_simulator.sh` |
| M25-4-R02 build若只檢查command exit code，無法證明artifact identity | P1 | 腳本額外驗證app bundle、Bundle Identifier與deployment target |
| M25-4-R03 plugin resolution可能成功但registrant不完整 | P1 | 腳本驗證四個native plugin registration |
| M25-4-R04 Simulator build不應依賴個人Apple signing | P1 | 使用`--no-codesign`，並掃描project排除Development Team與provisioning設定 |
| M25-4-R05 CocoaPods仍輸出custom base configuration提示 | P2 | Flutter xcconfig已includePods xcconfig，兩次clean build均成功；不以隱藏warning取代實際build gate |
| M25-4-R06 `zh`仍有16筆未翻譯訊息提示 | P2 | 既有localization backlog，不阻擋iOS artifact；不在本Task擴張scope |
| M25-4-R07 macOS full workspace test缺少`design_system_gallery_macos.png` | P1 | 精確確認只有planned Task 25-7 golden authority gate失敗；其餘Design System tests與其他packages通過。本Task不提前產生未review golden |

Open P0／P1 without disposition：0。

## Verification

- Focused iOS scaffold contract tests：通過，3 tests。
- `bash -n tools/ci/build_ios_simulator.sh`：通過。
- Clean Simulator build run 1：通過。
- Clean Simulator build run 2：通過。
- Artifact identity與deployment target：兩次一致。
- Documentation checker：通過。
- Analyze：通過。
- Full workspace tests：App 373 tests與其餘packages通過；唯一失敗為Task 25-7已規劃的macOS golden authority缺檔。
- Design System non-golden tests：通過。
- Git diff check：通過。

## Review Decision

Task 25-4通過。Open P0／P1為0；下一步是25-5 Simulator Core Runtime Smoke。
