---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-024-ios-platform-runner-native-dependency-verification-contract
last_reviewed_baseline: 1.6.1
id: ADR-024
title: iOS Platform Runner, Native Dependency and Verification Contract
supersedes: []
superseded_by: []
related:
  - ADR-004
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-021
  - ADR-022
  - ADR-023
---

# ADR-024 — iOS Platform Runner, Native Dependency and Verification Contract

## Status

Accepted。

## Authoritative Scope

本Decision定義tracked iOS runner、minimum deployment target、template product identity、native dependency resolution、plugin configuration ownership、verification classification與repository-level iOS build gate。

## Context

Repository在Milestone 25前只有Android tracked executable runner。iOS雖具備Dart dependency與conditional implementation，但沒有Xcode project、application artifact或runtime evidence，因此只能分類為Dependency-ready。

iOS runner也會引入Bundle Identifier、Product Name、deployment target、Swift、CocoaPods／Swift Package Manager、Keychain、Face ID、signing與Simulator evidence。若沒有單一contract，容易把dependency存在誤稱為platform support、把個人Development Team提交到template，或把Simulator build誤稱為physical-device／distribution evidence。

## Decision

### Runner ownership and generation

`apps/flutter_architecture/ios/`是App-owned tracked runner。Runner由repository exact Flutter toolchain在temporary project生成後逐檔review引入，不允許以無限制`flutter create .`覆蓋既有App、Android、Web、README或pubspec authority，也不手工重建Xcode project。

### Minimum platform and Swift contract

Minimum iOS deployment target固定為13.0，並同時由Podfile與Xcode project明確表達。Swift維持Flutter 3.41.6 generated default 5.0；Darwin plugins可以使用其自身較高Swift toolchain requirement，但App不在本Milestone啟用Swift 6 strict concurrency或新增native business module。

### Template identity and signing

Template identity固定為：

```txt
Bundle Identifier: com.example.flutterarchitecture
Product Name: Flutter Architecture
Development Team: unset
```

RunnerTests使用相同identifier prefix。Repository不得保存個人Apple account、Development Team、certificate、provisioning profile或正式產品identifier。Production signing、distribution與Store workflow由未來獨立Decision治理。

### Native dependency manager

Current executable authority使用Flutter 3.41.6產生的CocoaPods-compatible integration，並追蹤`Podfile.lock`作為resolved native dependency authority。Milestone 25不宣稱pure Swift Package Manager。

Flutter 3.44+的Swift Package Manager migration必須獨立review，至少確認所有required Darwin plugins的`Package.swift` readiness、fallback disposition、`Package.resolved` authority、CI cache與rollback。只要任何required plugin仍需CocoaPods fallback，就不得宣稱CocoaPods已完全移除。

### Plugin and platform configuration ownership

Flutter Secure Storage、SharedPreferences、sqflite、path provider與local_auth的native integration由App runner與Composition Root擁有。Reusable packages不得直接依賴Darwin plugin implementation、Keychain、LocalAuthentication或Xcode configuration。

Face ID purpose text、Keychain entitlements與plugin registration必須經static contract與runtime evidence驗證。Biometric只代表本機user presence，不構成server authentication、Device Binding或biometric template storage。

### Verification classification

iOS evidence必須分為：

```txt
iOS build-verified
iOS simulator-verified
iOS device-verified
iOS Supported
```

Simulator build不得冒充runtime、physical-device、signing或distribution evidence。Supported claim必須附帶build、simulator、device與distribution disposition，並精確揭露尚未驗證的範圍。

### CI boundary

Repository應建立獨立GitHub-hosted macOS iOS Simulator build gate。第一版CI只要求unsigned Simulator build，不讀production secrets、不配置Development Team，也不產生App Store-ready artifact。Runtime biometric smoke維持local release evidence，直到未來證明remote automation穩定。

## Consequences

- iOS runner與identity成為reviewable repository contract。
- iOS 13、Swift與native dependency resolution不再依賴Xcode或CocoaPods隱式推導。
- 個人signing資料不得污染template。
- CocoaPods是current toolchain的可重現implementation，不是永久生態承諾。
- Platform capability claim由evidence決定，而不是由dependency或successful compile單獨決定。
- Android既有Supported contract與CI evidence必須保持不退化。

## Supersession

本Decision未取代既有ADR。

## Related Decisions

- ADR-004：App Dependency Injection與Composition Root。
- ADR-010：跨平台SQLite initialization。
- ADR-011：Documentation Single Authority。
- ADR-012：Reusable package不綁定plugin或DI framework。
- ADR-021：Auth startup與navigation coordination。
- ADR-022：Credential、OTP與biometric capability boundary。
- ADR-023：Repository CI quality gates與artifact classification。

## Related Evidence

- [Milestone 25 planning review](../audits/milestone_25/25-0_planning_review.md)
- [Milestone 25 design](../superpowers/specs/2026-07-22-milestone-25-ios-platform-support-foundation-design.md)
- [Milestone 25 implementation plan](../superpowers/plans/2026-07-22-milestone-25-ios-platform-support-foundation.md)
- [Task 25-1 scaffold review](../audits/milestone_25/25-1_scaffold_review.md)

## Last Reviewed Baseline

1.6.1。
