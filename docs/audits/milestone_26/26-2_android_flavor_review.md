---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-android-product-flavor-review
last_reviewed_baseline: 1.7.0
---

# Milestone 26-2 — Android Product Flavors Review

## Scope

本Task將repository environment mapping contract投影至Android product flavors，建立application ID、App顯示名稱、Dart target與native environment sentinel的一致性契約。本Task不修改iOS scheme、production signing或Store distribution。

## Implemented Contract

| Flavor | Application ID | Display name | Dart target | Native sentinel |
|---|---|---|---|---|
| `development` | `com.example.flutterarchitecture.development` | `Flutter Architecture Dev` | `lib/main_development.dart` | `development` |
| `staging` | `com.example.flutterarchitecture.staging` | `Flutter Architecture Staging` | `lib/main_staging.dart` | `staging` |
| `production` | `com.example.flutterarchitecture` | `Flutter Architecture` | `lib/main_production.dart` | `production` |

Flavor dimension固定為`environment`。App label與manifest sentinel由flavor manifest placeholders提供；`BuildConfig.NATIVE_ENVIRONMENT`與Flutter `dart-defines`同時注入相同值。

Flutter CLI未指定`-t`時仍會傳入`lib/main.dart`。Gradle contract將此值視為tooling default並覆寫成flavor entrypoint；任何其他明確target若與flavor不符則在Flutter task建立期間fail fast。

## Build Evidence

### Development Debug

Command：

```bash
flutter build apk \
  --debug \
  --flavor development \
  --dart-define=API_MODE=mock
```

Result：

```txt
build/app/outputs/flutter-apk/app-development-debug.apk
package: com.example.flutterarchitecture.development
application-label: Flutter Architecture Dev
```

### Production Release Verification

Command：

```bash
flutter build apk \
  --release \
  --flavor production \
  --dart-define=API_MODE=real \
  --dart-define=API_BASE_URL=https://api.example.com
```

Result：

```txt
build/app/outputs/flutter-apk/app-production-release.apk
package: com.example.flutterarchitecture
application-label: Flutter Architecture
signer: Android Debug
distribution: verification-only
```

### Deliberate Mismatch

Command：

```bash
flutter build apk \
  --debug \
  --flavor production \
  -t lib/main_staging.dart \
  --dart-define=API_MODE=real \
  --dart-define=API_BASE_URL=https://api.example.com
```

Expected and observed failure：

```txt
Android flavor production requires target lib/main_production.dart,
but received lib/main_staging.dart
```

## Review Findings

| Finding | Severity | Disposition |
|---|---:|---|
| M26-2-R01 Flutter CLI未指定target仍傳入`lib/main.dart`，初版將其誤判為明確錯配 | P1 | 將`lib/main.dart`分類為tooling default並覆寫成flavor target |
| M26-2-R02 Flutter plugin會建立所有flavor tasks，初版對未請求variant也執行target validation | P1 | 先解析Gradle requested task，僅配置唯一被請求environment |
| M26-2-R03 Manifest metadata key若包含template base identifier，產品採用時會增加無必要替換點 | P1 | 改用穩定中立key `flutter.native_environment` |
| M26-2-R04 同一Gradle invocation若同時要求多個environment，單一global target與dart-defines無法安全表達 | P1 | 明確拒絕multi-environment invocation，CI與本機每次只建一個environment |
| M26-2-R05 Production release artifact仍使用debug certificate | P2 | 保持ADR-023 verification-only分類；production signing維持non-goal |

Open P0／P1：0。

## Rollback Boundary

Rollback只需還原Android Gradle flavor block、manifest placeholders與environment verifier的Android projection。Dart mapping manifest、ADR-025與既有Dart entrypoints不需回退。

## Disposition

Android flavor、identity、target與sentinel contract完成。Task 26-3可開始建立iOS scheme與build configuration projection；不得把本Task的debug-signed APK宣稱為production distribution artifact。
