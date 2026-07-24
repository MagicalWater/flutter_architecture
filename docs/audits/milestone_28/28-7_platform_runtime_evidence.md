---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-28-task-28-7-platform-evidence
last_reviewed_baseline: 1.9.0
---

# Task 28-7 — Android and iOS Platform Evidence

## Representative artifacts

2026-07-24於commit `1166ec4`重新建立兩個development代表產物：

```txt
Android: artifacts/android/development/flutter-architecture-development-debug.apk
package: com.example.flutterarchitecture.development
entrypoint: lib/main_development.dart
API mode: mock
result: pass

iOS: artifacts/ios/development/Flutter Architecture Dev.app
bundle: com.example.flutterarchitecture.development
scheme: Development
configuration: Debug-development
SDK: iphonesimulator
result: pass
```

兩端native dependency resolution均包含`connectivity_plus`；iOS `Podfile.lock`已同步plugin entry與checksum。

## Findings and disposition

### F1 — Production Android verification需要外部API_BASE_URL

`tools/ci/build_android_release.sh`依既有production environment contract拒絕缺少`API_BASE_URL`的執行。此項不是Connectivity implementation failure；本Task使用development representative artifact驗證plugin linking與App composition，未宣稱production distribution acceptance。

### F2 — Development Firebase config未提供

Android與iOS build均依既有observability contract跳過provider wiring。Connectivity adapter不依賴Firebase，因此不影響本Task的native plugin evidence。

### F3 — Physical-device network toggle不在repository-controlled環境內

本Task以controller／adapter／widget tests、Android APK與iOS Simulator app build作為可重現證據。Physical-device airplane mode、Wi-Fi切換與backend reachability仍屬adoption/runtime acceptance責任，不宣稱已完成。

## Disposition

```txt
Representative Android artifact: accepted
Representative iOS artifact: accepted
Native connectivity_plus integration: accepted
Production signing / Store distribution: deferred
Physical-device acceptance: deferred
Open P0: 0
Open P1 without disposition: 0
```

Task 28-7 accepted，可進入Task 28-8。
