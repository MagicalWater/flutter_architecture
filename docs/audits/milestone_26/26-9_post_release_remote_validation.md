---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-post-release-remote-validation
last_reviewed_baseline: 1.8.0
---

# Milestone 26-9 — Post-release Remote Validation

## Scope

本文件記錄Template Baseline 1.8.0 release／archive commit在GitHub-hosted runners上的最終驗證結果。

```txt
Release commit: 40ce1f97a2c6db568cb42f2734cb5ee19d564f3e
Release baseline: 1.8.0
Validation date: 2026-07-23
```

這是release-SHA closure evidence，不取代Task 26-6的implementation matrix review，也不擴張production signing或Store distribution claim。

## Workflow Results

| Workflow | Run ID | Jobs | Result |
|---|---:|---|---|
| CI | `29973185824` | Quality、Generated Consistency、Tests | success |
| Android | `29973185891` | Development Debug APK、Release APK | success |
| iOS | `29973185825` | Simulator Build、Production Release Build | success |

七個release-SHA jobs全部成功，沒有cancelled、timed out或failure job。

## Representative Artifact Identity

| Artifact | Environment | Entrypoint | Native identity | Classification |
|---|---|---|---|---|
| `flutter-architecture-development-debug.apk` | development | `lib/main_development.dart` | `com.example.flutterarchitecture.development` | debug signing；verification only |
| `flutter-architecture-production-release.apk` | production | `lib/main_production.dart` | `com.example.flutterarchitecture` | debug signing；verification only |
| `Flutter Architecture Dev.app` | development | `lib/main_development.dart` | `com.example.flutterarchitecture.development` | unsigned Simulator verification build |
| `Flutter Architecture.app` | production | `lib/main_production.dart` | `com.example.flutterarchitecture` | unsigned device-SDK verification build |

四個artifact metadata均記錄：

```txt
commit_sha=40ce1f97a2c6db568cb42f2734cb5ee19d564f3e
distribution=not production-ready
```

Environment、flavor／scheme、configuration、SDK、API mode與entrypoint均符合ADR-025 mapping。

## Artifact Retention and Digest

| Artifact | Digest | Expires |
|---|---|---|
| `android-development-debug-40ce1f9...` | `sha256:fb2746e35fc105f5cd6caf0608fb3ad834553ff6aeb9dd3c54354a83329057a2` | 2026-08-06 |
| `android-production-release-40ce1f9...` | `sha256:296cd5fb7d3e5afed0fb5bb5a761e6ee636ebc37a06886b73e397288dc653c3e` | 2026-08-06 |
| `ios-development-debug-simulator-40ce1f9...` | `sha256:326a4c19449df650a41dfdb338e9d06e328df3b598faf656d0d5958778e85a63` | 2026-08-06 |
| `ios-production-release-40ce1f9...` | `sha256:7e57fbcffdaad20f298d1544038a365f597bace0b31cebdfe7fdeb28a37be5ae` | 2026-08-06 |
| `ios-development-toolchain-40ce1f9...` | `sha256:683a04a87ece29bfc67c6fae15dff72be8d4c52a236517ce9f03bf104d9e5972` | 2026-08-06 |
| `ios-production-toolchain-40ce1f9...` | `sha256:cc3a41c435b9a70424e4e1b33ef56b7bcd12d2c97e06b841a904a2c9f5635f2b` | 2026-08-06 |

所有artifact均使用release SHA命名並採14天bounded retention。

## iOS Toolchain Evidence

Development與Production jobs保存的toolchain evidence一致：

```txt
Runner OS: macOS 15.7.7 (24G720)
Runner architecture: darwin-arm64
Xcode: 16.4 (16F6)
Flutter: 3.41.6 stable
Dart: 3.11.4
DevTools: 2.54.2
CocoaPods: 1.17.0
Java: Temurin 21.0.11+10 LTS
```

`flutter doctor`只回報Android licenses未全部接受；該提示未影響iOS jobs，且兩個iOS representative builds均成功。

## Final Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| M26-9-R01 | P1 | Release與archive commit需要獨立remote closure evidence，不能只引用pre-release implementation SHA | 本次三個release-SHA workflows與七個jobs全部成功，已關閉 |
| M26-9-R02 | P2 | CI workflow沒有artifact是預期行為，quality evidence由job steps保存 | 無需修正；Quality、Generated Consistency、Tests均成功 |
| M26-9-R03 | P2 | iOS toolchain的Android license warning可能被誤讀為iOS gate不完整 | 明確分類為非相關doctor提示；Xcode與兩個build jobs均成功 |

```txt
Open P0: 0
Open P1 without disposition: 0
Release-SHA workflow failures: 0
Artifact identity mismatches: 0
```

## Disposition

Template Baseline 1.8.0已在release commit本身完成GitHub-hosted CI、Android與iOS驗證。Milestone 26的local review、implementation remote validation、release、archive與post-release remote closure均已完成。

Production signing、AAB、IPA、TestFlight、Play Store與App Store publishing仍不在目前claim內。
