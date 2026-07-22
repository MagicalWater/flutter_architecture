---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-25-task-25-1-scaffold-review
last_reviewed_baseline: 1.6.1
---

# Milestone 25-1 — Reproducible iOS Scaffold Review

## Scope

本review驗證Task 25-1只建立可重現的tracked iOS runner，不覆蓋既有Android、Web、Dart source、App README或pubspec authority，也不引入個人signing資料。

## Generation Contract

Temporary generation使用目前repository exact toolchain：

```bash
flutter create /tmp/flutter_architecture_m25_ios \
  --platforms=ios \
  --project-name flutter_architecture \
  --org com.example \
  --description "Flutter enterprise architecture template"
```

Flutter evidence：

```txt
Flutter 3.41.6
Dart 3.11.4
Template revision db50e20168db8fee486b9abf32fc912de3bc5b6a
```

只引入temporary project的`ios/` scaffold，並在既有`.metadata`保留root與Android entries後新增iOS entry。Temporary project生成的README、pubspec、analysis options、Dart source、test與IDE files均未引入。

## Review Findings

| Finding | Severity | Result |
|---|---:|---|
| M25-1-R01 `flutter create`自動偵測本機Apple Development identity並寫入`DEVELOPMENT_TEAM = ZY28SRWLYV` | P0 | 引入前移除；repository全量scan無Team ID、email、certificate ID或provisioning資料 |
| M25-1-R02 Temporary `.metadata`會移除既有Android entry並改寫channel | P0 | 不複製temporary metadata；只在既有stable metadata新增iOS platform entry |
| M25-1-R03 Generated root README／pubspec會覆蓋repository authority | P0 | 未引入任何generated root file |
| M25-1-R04 Initial template不直接生成Podfile | P2 | `flutter pub get`依current plugin set生成CocoaPods-compatible Podfile；符合approved transition contract |
| M25-1-R05 Podfile尚未明寫iOS 13，CocoaPods以plugin floor自動選擇13.0 | P1 | 已有Task 25-2固定Podfile／Xcode deployment target與static tests；本Task不提前混入toolchain contract |
| M25-1-R06 CocoaPods提示custom xcconfig base configuration | P2 | Flutter generated Debug／Release xcconfig已include Pods support files；Simulator build成功，Task 25-2再做正式setting review |

Open P0／P1 without disposition：0。

## Tracked Scaffold

Tracked內容包括：

- Xcode project／workspace與shared scheme。
- Runner Swift bootstrap、storyboards、Info.plist與asset catalogs。
- Flutter Debug／Release xcconfig與AppFrameworkInfo.plist。
- CocoaPods Podfile與resolved Podfile.lock。
- Runner native test target。

Generated／ephemeral內容由iOS `.gitignore`排除，包括Pods、Generated.xcconfig、Flutter environment exports、ephemeral helpers、build outputs與generated plugin registrant。

## Verification Evidence

```txt
flutter pub get: passed
pod install: passed; 5 pods installed
flutter build ios --simulator -t lib/main.dart: passed
Artifact: build/ios/iphonesimulator/Runner.app
Personal signing scan: clean
Existing Android/Web/Dart source diff: none
```

Installed plugin pods：

```txt
flutter_secure_storage_darwin
local_auth_darwin
shared_preferences_foundation
sqflite_darwin
Flutter
```

## Review Decision

Task 25-1通過。iOS scaffold可由Flutter 3.41.6與current dependency set重現，既有App authority未被generated root files覆蓋，個人signing資料已在引入前清除，unsigned Simulator build成功。

下一步只允許進入Task 25-2，固定iOS 13、template identity、CocoaPods resolution與static contract tests；在25-2 review通過前不加入Face ID或Keychain configuration。
