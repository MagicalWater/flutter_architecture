---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-27-task-27-4-android-native-symbol-pipeline-review
last_reviewed_baseline: 1.8.0
---

# Task 27-4 — Android Native and Symbol Pipeline Review

## Scope

審查Android Google Services／Crashlytics Gradle plugin wiring、environment config projection、R8 mapping、Flutter split debug symbols、PR-safe缺省行為與artifact evidence。

## Implementation review

- Google Services `4.5.0`與Crashlytics Gradle plugin `3.0.7`在Android settings提供，但只有任一environment config存在時才套用。
- `google-services.json`只允許位於`android/app/src/<environment>/`且被Git忽略；verification script檢查package name與Firebase App ID存在。
- Release build啟用R8、resource shrinking與Crashlytics需要的source／line attributes，實際產生`mapping.txt`。
- Production release正式採`--obfuscate`與`--split-debug-info`，build wrapper在symbols缺失時fail-fast。
- Flutter symbols upload使用獨立Firebase CLI script；缺少App ID、CLI或symbols時明確標示not executed，不偽裝verified。
- 未提交任何Firebase project config或credential；沒有config的PR／local build仍可完成provider-neutral build。

## Findings and fixes

- P1：macOS Bash 3.2不支援`${value^}`，導致artifact後處理失敗；改為portable case mapping並re-review。
- P1：首次incremental build沒有重新產生已刪除的Flutter symbols；wrapper新增symbols存在性fail-fast，並以clean production build驗證3個ABI symbols。
- P1：Release未啟用R8，無法形成mapping evidence；啟用minify／shrink與ProGuard attributes後確認mapping存在。
- P2：Firebase config可能對錯environment package；新增JSON projection verifier。

## Evidence

- Android observability contract tests：4 passed。
- Production release APK：成功，package `com.example.flutterarchitecture`。
- Flutter symbols：3 files（arm、arm64、x64）。
- R8 mapping：present。
- Provider config：not present，因此Gradle provider wiring與remote upload皆為not executed。

## Disposition

ACCEPTED AFTER FIX。Open P0／P1／P2 = 0。

