---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-task-26-6-remote-validation
last_reviewed_baseline: 1.7.0
---

# Task 26-6 — Remote Validation Evidence

## Status

Completed。Milestone 26 Task 26-6 的 GitHub-hosted representative matrix 已完成兩輪遠端驗證，所有 required jobs 與四個代表性 build 均成功。

## Validated Commits and Runs

### Initial representative matrix

Commit：

```txt
8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
```

| Workflow | Run ID | Conclusion |
|---|---:|---|
| CI | `29970226490` | success |
| Android | `29970226525` | success |
| iOS | `29970226484` | success |

### iOS toolchain evidence closure

Initial iOS run 的 toolchain diagnostics 只在 failure path 保留，成功 run 無法永久提供精確 Xcode／CocoaPods evidence。修正後 commit：

```txt
715d5cec16f661eac64a4dd4382249aed144cf06
```

| Workflow | Run ID | Conclusion |
|---|---:|---|
| iOS | `29971307542` | success |

此 rerun 同時重新驗證 Development Debug Simulator 與 Production Release unsigned device build，沒有用只上傳 diagnostics 的輕量假驗證取代實際 build。

## Job Conclusions

| Workflow | Job | Conclusion |
|---|---|---|
| CI | Quality | success |
| CI | Generated Consistency | success |
| CI | Tests | success |
| Android | Development Debug APK | success |
| Android | Release APK | success |
| iOS | Simulator Build | success |
| iOS | Production Release Build | success |

## Runner and Toolchain Evidence

### Android

- Runner image：`ubuntu-24.04`
- Runner image version：`20260714.240.1`
- Java：Temurin `17.0.19+10`
- Flutter：repository authority `3.41.6`

### iOS

- Runner image：`macos-15-arm64`
- Runner image version：`20260715.0234.1`
- macOS：`15.7.7` (`24G720`)
- Xcode：`16.4` (`16F6`)
- Flutter：`3.41.6`
- Dart：`3.11.4`
- DevTools：`2.54.2`
- CocoaPods：`1.17.0`

成功 run 產生並上傳：

```txt
ios-development-toolchain-715d5cec16f661eac64a4dd4382249aed144cf06
ios-production-toolchain-715d5cec16f661eac64a4dd4382249aed144cf06
```

## Artifact Identity Evidence

### Android Development

```txt
commit_sha=8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
environment=development
platform=android
flavor=development
entrypoint=lib/main_development.dart
api_mode=mock
package_id=com.example.flutterarchitecture.development
signing=debug signing for verification only
distribution=not production-ready
artifact=flutter-architecture-development-debug.apk
```

### Android Production

```txt
commit_sha=8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
environment=production
platform=android
flavor=production
entrypoint=lib/main_production.dart
api_mode=real
package_id=com.example.flutterarchitecture
signing=debug signing for verification only
distribution=not production-ready
artifact=flutter-architecture-production-release.apk
```

下載後使用 `apkanalyzer` 再次確認 production APK application ID 為：

```txt
com.example.flutterarchitecture
```

### iOS Development

```txt
commit_sha=8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
environment=development
platform=ios
scheme=Development
configuration=Debug-development
sdk=iphonesimulator
entrypoint=lib/main_development.dart
api_mode=mock
bundle_id=com.example.flutterarchitecture.development
signing=unsigned verification build
distribution=not production-ready
artifact=Flutter Architecture Dev.app
```

下載後使用 `plutil` 再次確認：

```txt
CFBundleIdentifier=com.example.flutterarchitecture.development
CFBundleDisplayName=Flutter Architecture Dev
```

### iOS Production

```txt
commit_sha=8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
environment=production
platform=ios
scheme=Production
configuration=Release-production
sdk=iphoneos
entrypoint=lib/main_production.dart
api_mode=real
bundle_id=com.example.flutterarchitecture
signing=unsigned verification build
distribution=not production-ready
artifact=Flutter Architecture.app
```

下載後使用 `plutil` 再次確認：

```txt
CFBundleIdentifier=com.example.flutterarchitecture
CFBundleDisplayName=Flutter Architecture
```

## Artifact Inventory

Initial matrix artifacts：

```txt
android-development-debug-8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
android-production-release-8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
ios-development-debug-simulator-8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
ios-production-release-8a89a47b3ce9064bde1f55e895cbff8c2ae52bfc
```

Toolchain closure run 另外重新產生兩個 iOS build artifacts 與兩個 toolchain artifacts。所有 artifact 均使用完整 commit SHA，retention 為 14 天，且 verification metadata 明確標示非 production-ready。

## Failure and Warning Disposition

### M26-6-R06 — Successful iOS runs did not retain exact toolchain evidence

- Severity：P1
- Evidence：initial iOS workflow 將 `toolchain.txt` 寫入 diagnostics directory，但該 directory 只在 failure 時上傳。
- Risk：run 成功後只能看到 runner image，無法永久核對精確 Xcode、Flutter、Dart與CocoaPods版本。
- Fix：development與production jobs各自上傳 bounded `toolchain.txt` artifact。
- Re-validation：run `29971307542` 兩個 jobs成功，兩個 toolchain artifacts可下載並核對。
- Disposition：closed。

### Node.js 20 deprecation annotation

GitHub runner 對 `actions/cache@v4` 顯示 Node.js 20 deprecation annotation，並由平台強制使用 Node.js 24。此 annotation 未造成 job failure，且 action 仍為 full-SHA pinned；不屬本 Task 的 P0／P1 blocker，留待 dependency maintenance 依官方 action release 更新。

## Final Disposition

```txt
Remote workflows failed: 0
Representative build jobs failed: 0
Artifact identity mismatches: 0
Open P0: 0
Open P1 without disposition: 0
```

Task 26-6 remote validation completed。下一步為 Task 26-7 Adoption and Operations Documentation。
