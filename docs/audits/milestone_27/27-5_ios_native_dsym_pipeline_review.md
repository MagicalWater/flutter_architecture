---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-27-task-27-5-ios-native-dsym-pipeline-review
last_reviewed_baseline: 1.8.0
---

# Task 27-5 — iOS Native and dSYM Pipeline Review

## Scope

審查iOS environment Firebase config projection、Crashlytics Xcode run script、release dSYM generation、manual upload fallback、unsigned device build evidence與deployment target相容性。

## Implementation review

- `GoogleService-Info.plist`只允許位於`ios/Firebase/<environment>/`且被Git忽略；verification script檢查`BUNDLE_ID`與`GOOGLE_APP_ID`。
- Runner先依`NATIVE_ENVIRONMENT`複製對應plist，再於plist與Crashlytics run script均存在時執行dSYM upload；缺少任一條件時明確標示not executed。
- Xcode 15+要求的dSYM、DWARF、Info.plist、GoogleService plist與executable input paths均已列入build phase。
- 所有Release environment固定`dwarf-with-dsym`，build wrapper對release dSYM缺失fail-fast並保存artifact。
- 另提供`upload-symbols` manual fallback script；缺少config、dSYM或uploader時不偽裝成功。
- Firebase Apple SDK 12.15要求iOS 15；Podfile、Runner configurations、Pods targets、tests與ADR authority已同步提升至15.0。

## Findings and fixes

- P1：原iOS 13 baseline無法解析Firebase Apple SDK 12.15；提升current minimum deployment target至iOS 15.0並同步authority。
- P1：artifact collector將dSYM名稱錯寫為`Runner.app.dSYM`；改依實際product app名稱定位與保存。
- P2：部分Pods仍宣告iOS 9造成Xcode警告；post-install統一Pods deployment target為15.0。
- P2：Firebase environment plist可能對錯bundle；新增BUNDLE_ID與GOOGLE_APP_ID verifier。

## Evidence

- iOS observability contract tests：3 passed。
- iOS scaffold focused tests：3 passed。
- Production unsigned iphoneos build：succeeded。
- Bundle ID：`com.example.flutterarchitecture`。
- App dSYM：present。
- App binary UUID與dSYM UUID：`77F83E41-0C49-356F-87C7-6EA9EAA58E27`，一致。
- Provider config：not present，因此config copy與remote dSYM upload皆為not executed。

## Disposition

ACCEPTED AFTER FIX。Open P0／P1／P2 = 0。

