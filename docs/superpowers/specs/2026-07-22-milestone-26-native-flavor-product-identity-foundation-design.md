---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-26-native-flavor-product-identity-foundation-design
last_reviewed_baseline: 1.7.0
---

# Milestone 26 — Native Flavor & Product Identity Foundation Design

## Status

Proposed / Planning Review。

本文件只定義Milestone 26的正式設計，不直接修改Android Gradle、Xcode project、shared scheme或CI implementation。

## Goal

將既有Dart `development`／`staging`／`production` environment延伸為可驗證的Android product flavor與iOS shared scheme，建立唯一mapping contract、原生產品身份、entrypoint綁定、安全限制與最小CI代表矩陣，避免同一binary使用錯誤Dart environment或錯誤native identity。

## Current Mapping Audit

### Dart

| Entrypoint | Environment |
|---|---|
| `lib/main.dart` | development compatibility default |
| `lib/main_development.dart` | development |
| `lib/main_staging.dart` | staging |
| `lib/main_production.dart` | production |

`AppConfigFactory`已集中解析`API_MODE`與`API_BASE_URL`。Development允許mock／real；staging與production拒絕mock；production另強制HTTPS並拒絕mock、localhost、loopback與`.invalid`host。

### Android

目前只有：

```txt
namespace/applicationId: com.example.flutterarchitecture
productFlavors: none
App label: Flutter Architecture
release signing: debug verification only
CI target: lib/main.dart
```

### iOS

目前只有：

```txt
Bundle Identifier: com.example.flutterarchitecture
Shared scheme: Runner
Build configurations: Debug / Profile / Release
Display name: Flutter Architecture
CI target: lib/main.dart
```

## Identified Mismatch Entrypoints

1. `flutter run`或`flutter build`未指定target時固定使用development Dart environment，但產生無環境區分的native identity。
2. Android可在未來指定任意`--flavor`與任意`-t`，若沒有variant gate會形成錯配binary。
3. iOS scheme、build configuration與`FLUTTER_TARGET`目前沒有關聯。
4. Android label與iOS display name是獨立hard-coded值，無法證明與identity一致。
5. CI scripts明確使用`lib/main.dart`，因此目前release-mode artifact實際是development/mock verification artifact。
6. application ID、bundle identifier與template placeholder沒有正式替換邊界。
7. staging若只存在Dart entrypoint而沒有native projection，可能被跳過或與production identity混用。
8. production binary即使使用production entrypoint，仍可能由外部`dart-define`提供錯誤API設定；目前只有Dart bootstrap validation，尚無native environment sentinel。
9. Xcode personal signing、Android production keystore與Store distribution若混入本Milestone，會破壞template與verification-only邊界。

## Considered Approaches

### A. CLI convention only

只文件化`--flavor`與`-t`命令。修改最少，但無法阻止錯配，拒絕採用。

### B. Platform-local independent configuration

Android與iOS各自維護名稱、identifier與entrypoint。符合原生工具習慣，但會形成三套獨立authority，拒絕採用。

### C. Repository mapping contract with verified projections

建立一份小型repository-owned mapping manifest；Android Gradle、iOS xcconfig／scheme與Dart sentinel都是該contract的projection。Static verifier、build-time target gate與runtime fail-fast共同阻止錯配。採用此方案。

## Authority Model

```txt
Dart environment semantics
  → ADR-014 + AppEnvironment + environment entrypoints

Native product identity and cross-platform mapping
  → repository environment mapping manifest

Android projection
  → productFlavors + manifest placeholders + variant target gate

iOS projection
  → shared schemes + build configurations + xcconfig

Verification
  → repository-owned static contract verifier + representative builds
```

Mapping manifest只擁有「environment對應哪些原生值」；不取代Dart entrypoint作為`AppEnvironment`語意來源，也不承擔signing secret或Store metadata。

建議位置：

```txt
apps/flutter_architecture/config/environments.json
```

格式保持專案專用，不建立Generic Flavor Framework。

## Formal Naming and Mapping

| Environment | Android flavor | iOS shared scheme | Dart entrypoint | App display name | Android application ID | iOS bundle identifier |
|---|---|---|---|---|---|---|
| development | `development` | `Development` | `lib/main_development.dart` | `Flutter Architecture Dev` | `com.example.flutterarchitecture.development` | `com.example.flutterarchitecture.development` |
| staging | `staging` | `Staging` | `lib/main_staging.dart` | `Flutter Architecture Staging` | `com.example.flutterarchitecture.staging` | `com.example.flutterarchitecture.staging` |
| production | `production` | `Production` | `lib/main_production.dart` | `Flutter Architecture` | `com.example.flutterarchitecture` | `com.example.flutterarchitecture` |

Android flavor dimension固定為`environment`。

iOS build configuration固定為：

```txt
Debug-development / Profile-development / Release-development
Debug-staging / Profile-staging / Release-staging
Debug-production / Profile-production / Release-production
```

Scheme action mapping：

| Scheme | Run/Test/Analyze | Profile | Archive |
|---|---|---|---|
| Development | `Debug-development` | `Profile-development` | `Release-development` |
| Staging | `Debug-staging` | `Profile-staging` | `Release-staging` |
| Production | `Debug-production` | `Profile-production` | `Release-production` |

`Runner` scheme在遷移完成後移除，避免產生第四個未治理入口。

## Entrypoint Binding and Fail-fast Contract

每個native environment必須同時提供：

1. 固定Dart target。
2. 固定native environment sentinel。
3. 固定product identity與display name。

Android variant建立前檢查Gradle `target`property；未指定時由flavor選擇正確target，若明確指定但不相符則build fail。

iOS各environment xcconfig固定`FLUTTER_TARGET`與native environment sentinel；shared scheme只指向相符configuration。不得以scheme arguments維護另一份target mapping。

Dart bootstrap讀取repository注入的`NATIVE_ENVIRONMENT` sentinel，與entrypoint傳入的`AppEnvironment`比較；不同即在建立DI graph與`runApp`前fail fast。此sentinel只用於一致性驗證，不取代entrypoint authority。

`main.dart`保留為development compatibility入口，但所有正式native flavor／scheme與CI command必須使用明確environment entrypoint；不得再把`main.dart`當production verification target。

## Template Placeholder and Product Replacement Boundary

### Repository template-owned defaults

- Base identity：`com.example.flutterarchitecture`。
- Environment suffix：`.development`、`.staging`、production無suffix。
- Template display names。
- Environment names、entrypoint names與mapping schema。
- No Apple Development Team。
- Android release verification仍使用debug signing。

### Adopting product must replace

- Base application ID／bundle identifier。
- Product display name與環境suffix文案。
- Production API endpoint與產品domain policy。
- Android production keystore、key alias與secret ownership。
- Apple Team、certificate、provisioning profile與App Store identifiers。
- Store listing、release channel與distribution workflow。

替換必須更新mapping manifest後由verifier指出所有需同步的platform projection；不得只在Gradle或Xcode單點搜尋取代。

## Environment Safety Restrictions

### Development

- Mock與real API皆允許。
- HTTP可用於本機測試。
- 使用獨立`.development`identity，可與production同時安裝。

### Staging

- 只允許real API。
- Native identity必須為`.staging`。
- 預設要求HTTPS；若未來確有受控內網HTTP需求，必須另立Decision，不在本Milestone開例外。

### Production

- 只允許real API。
- 強制production entrypoint與無suffix正式identity。
- 強制HTTPS。
- 拒絕mock、localhost、loopback、`.invalid`與明確template placeholder host。
- CI production representative build使用非敏感、不可部署的example endpoint，只證明configuration/build contract，不宣稱可連線production backend。

## Responsibility Boundaries

### Local development

使用明確wrapper command或文件化命令啟動Development／Staging／Production。Local可以使用debug signing或no-codesign；不得把本機個人signing state提交repository。

### Repository CI verification

驗證mapping、entrypoint、identity、display name、安全規則與代表性build。CI不讀Store secrets、不產生distribution-ready artifact。

### Production signing

負責keystore、Apple certificate、Team與provisioning；獨立於environment mapping，未納入Milestone 26。

### Store distribution

負責AAB／IPA、protected Environment、approval、version、release notes與upload；未納入Milestone 26。

## Minimal CI Matrix

### Static contract gate

在Ubuntu quality job驗證全部三個environment的manifest、Dart entrypoint、Gradle flavor、Android identity、iOS scheme/configuration/xcconfig、display name與security mapping。

### Representative builds

| Platform | Environment | Mode | Purpose |
|---|---|---|---|
| Android | development | Debug APK, mock | 快速證明開發flavor、suffix identity與development entrypoint |
| Android | production | Release APK, real | 證明production identity、entrypoint與release-mode contract；仍為debug verification signing |
| iOS | Development | Debug Simulator | 證明Development scheme/configuration/entrypoint |
| iOS | Production | Release Simulator, no codesign | 證明Production scheme/configuration/entrypoint；非Archive／IPA |

不建置staging artifact；staging由static verifier完整覆蓋。若staging出現平台特有差異，才在後續review增加代表build，不預先擴張矩陣。

## Acceptance Criteria

- 三個environment有唯一、可機械驗證的cross-platform mapping。
- Android三個product flavor與`environment`dimension存在。
- iOS三個shared scheme與九個build configuration存在，舊`Runner`入口移除。
- 每個native environment固定正確Dart entrypoint、sentinel、display name與identifier。
- 任意已知flavor／scheme與entrypoint錯配會在build或bootstrap前失敗。
- Development與production可同時安裝；staging也使用獨立identity。
- Production不能使用mock、不安全URL或template placeholder endpoint。
- Repository verifier可在clean checkout執行，錯誤訊息指出具體projection。
- CI完成四個代表build且不引入production signing或Store secrets。
- Android與iOS既有plugin、tests與Supported claim無退化。
- 文件ownership修正，Open P0／P1為0。

## Non-goals

- Production keystore、Apple Team、certificate、provisioning與signing secret。
- AAB、IPA、TestFlight、App Store或Play Store publishing。
- Firebase per-environment configuration。
- 多品牌、white-label、region或customer dimension。
- Generic Flavor Framework或code generator。
- 遠端environment promotion、feature flag或secret manager。
- Package依賴native flavor或DI framework。

## Risks and Rollback

| Risk | Mitigation | Rollback |
|---|---|---|
| Gradle target hook與Flutter plugin時序不相容 | focused Gradle contract test與兩種代表build | revert target gate，保留manifest與static verifier後修正 |
| Xcode configuration／Pods mapping遺漏 | `pod install`、`xcodebuild -showBuildSettings`與clean builds | 恢復Milestone 25單一Runner project，再逐步重建configuration |
| CLI大小寫或scheme discovery差異 | 使用固定wrapper commands與remote macOS evidence | 調整scheme命名但維持environment canonical name |
| Production artifact被誤稱distribution-ready | metadata固定signing／distribution classification | 停止artifact upload，不降低build gate |
| Template adopter只替換單一identifier | manifest verifier與adoption guide | verifier阻擋，回復一致template identity |

Rollback以Task commit為單位；不得以刪除production validation或讓錯配fallback為development來換取build通過。

## ADR Decision

需要新增ADR-025。Planning階段先保存於`docs/audits/milestone_26/adr-025_draft.md`；Task 26-1驗證通過後才建立canonical ADR。理由是cross-platform environment mapping、native identity authority、entrypoint binding、template replacement boundary與verification matrix都屬長期repository contract，且會擴充ADR-014、ADR-023與ADR-024的責任邊界。
