---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-task-26-5-review
last_reviewed_baseline: 1.7.0
---

# Milestone 26-5 Review — Local Build and Artifact Commands

## Scope

本 Task 建立 Android／iOS development與production的明確本機驗證命令，並讓既有CI入口降為相容alias。所有產物都屬verification artifact，不是Store distribution artifact。

## Command Contract

| Platform | Environment | Command | Native selector | Entrypoint | API mode |
|---|---|---|---|---|---|
| Android | development | `build_android_development.sh` | flavor `development`, debug | `lib/main_development.dart` | mock |
| Android | production | `build_android_production.sh` | flavor `production`, release | `lib/main_production.dart` | real |
| iOS | development | `build_ios_development.sh` | `Development` / `Debug-development` / Simulator | `lib/main_development.dart` | mock |
| iOS | production | `build_ios_production.sh` | `Production` / `Release-production` / generic device | `lib/main_production.dart` | real |

Production commands require caller-provided `API_BASE_URL`。Android production APK仍使用debug signing；iOS production `.app`使用`CODE_SIGNING_ALLOWED=NO`。兩者metadata皆標示`distribution=not production-ready`。

## Build Evidence

四個commands均從獨立、預先清空的`ARTIFACT_DIR`執行成功：

- Android development：`com.example.flutterarchitecture.development`。
- Android production：`com.example.flutterarchitecture`。
- iOS development：`com.example.flutterarchitecture.development`。
- iOS production：`com.example.flutterarchitecture`。

Android identifier由`apkanalyzer manifest application-id`讀取；iOS identifier由`plutil -extract CFBundleIdentifier`讀取。

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---|---|
| M26-5-R01 舊Android command仍建置`lib/main.dart` | P1 | 改為production wrapper alias，正式command使用production flavor與entrypoint |
| M26-5-R02 舊iOS command仍依賴已移除Runner scheme | P1 | 改為Development wrapper alias |
| M26-5-R03 `apkanalyzer`在macOS找不到system Java | P1 | 加入Android Studio JBR fallback並重跑兩個Android artifacts |
| M26-5-R04 iOS command-line `DART_DEFINES`若整串base64會破壞多define格式 | P1 | 每個define分別base64，包含native sentinel、API mode與URL |
| M26-5-R05 Artifact目錄可能殘留舊產物 | P1 | 每次build先清除目標environment artifact與DerivedData |
| M26-5-R06 Production command未提供API URL時可能建立不完整產物 | P1 | wrapper在build前要求非空`API_BASE_URL` |
| M26-5-R07 Existing iOS scaffold test固定舊命令文字 | P2 | 更新為environment-aware command contract |

Open P0／P1 without disposition：0。

## Rollback Boundary

Rollback必須一起回復四個wrapper、兩個common builders、兩個相容aliases、contract tests與operations guide。不得只回復alias而保留舊metadata或只刪wrapper造成CI重新建置`lib/main.dart`。
