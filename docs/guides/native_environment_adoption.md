---
document_type: guide
status: active
authoritative_for:
  - native-environment-product-identity-adoption
last_reviewed_baseline: 1.8.0
---

# Native Environment and Product Identity Adoption Guide

## Purpose

本指南說明採用此模板時，如何從 repository 內建的 `development`／`staging`／`production` contract，安全替換成實際產品的 identifier、display name、API domain 與後續 signing ownership。

正式 cross-platform mapping authority 是：

```txt
apps/flutter_architecture/config/environments.json
```

Android Gradle、iOS scheme／configuration、Dart entrypoint 與 verification tooling 都是此 mapping 的 projection。不要只修改單一平台或單一 build command。

## Agent-assisted Entry

將模板跨Android與iOS採用為具體產品時，Agent可使用repository-local [`adopting-template-product-identity`](../../.agents/skills/adopting-template-product-identity/SKILL.md) Skill作為薄型入口。該Skill必須先委派`governing-template-development`；本Guide仍是完整adoption procedure與exact-command authority，ADR-014、ADR-025、`environments.json`、source與tests仍分別擁有產品contract與runtime truth。

## Repository Default Mapping

| Environment | Android flavor | iOS scheme | Entrypoint | Display name | Identifier |
|---|---|---|---|---|---|
| development | `development` | `Development` | `lib/main_development.dart` | `Flutter Architecture Dev` | `com.example.flutterarchitecture.development` |
| staging | `staging` | `Staging` | `lib/main_staging.dart` | `Flutter Architecture Staging` | `com.example.flutterarchitecture.staging` |
| production | `production` | `Production` | `lib/main_production.dart` | `Flutter Architecture` | `com.example.flutterarchitecture` |

`com.example.flutterarchitecture`、`Flutter Architecture`、`api.acme.test` 與 `api.your-domain.example` 都是 template／verification placeholder，不是可直接發布的正式產品資料。

## Exact Local Verification Commands

所有命令都在 repository root 執行。產物預設輸出至：

```txt
artifacts/android/<environment>/
artifacts/ios/<environment>/
```

### Android

Development Debug、Mock API：

```bash
bash tools/ci/build_android_development.sh
```

Staging Debug、Real HTTPS API：

```bash
API_BASE_URL=https://staging-api.your-domain.example \
  bash tools/ci/build_android_environment.sh \
    staging debug lib/main_staging.dart real
```

Production Release verification、Real HTTPS API：

```bash
API_BASE_URL=https://api.your-domain.example \
  bash tools/ci/build_android_production.sh
```

Android production verification APK 使用 debug signing，只能用於 identity／entrypoint／artifact contract 驗證，不是 Play Store AAB，也不是 production signing artifact。

### iOS

Development Debug Simulator、Mock API：

```bash
bash tools/ci/build_ios_development.sh
```

Staging Debug Simulator、Real HTTPS API：

```bash
API_BASE_URL=https://staging-api.your-domain.example \
  bash tools/ci/build_ios_environment.sh \
    staging Staging Debug-staging iphonesimulator \
    lib/main_staging.dart real
```

Production Release generic-device verification、Real HTTPS API：

```bash
API_BASE_URL=https://api.your-domain.example \
  bash tools/ci/build_ios_production.sh
```

iOS production verification 使用 `Release-production`、generic `iphoneos` 與 `CODE_SIGNING_ALLOWED=NO`。它不是 archive、IPA、TestFlight 或 App Store artifact。Flutter 不支援 Release／Profile Simulator AOT build。

## Manifest-first Replacement Order

採用模板時依以下順序處理，完成每一步後再執行 environment verifier。

### 1. 決定產品 base identity

先決定一個由組織控制的 reverse-DNS identifier，例如：

```txt
com.yourcompany.yourproduct
```

建議維持：

```txt
development → <base>.development
staging     → <base>.staging
production  → <base>
```

這能讓三個環境共存安裝，也維持 production 無 suffix 的產品 identity。

### 2. 更新 environment manifest

先修改：

```txt
apps/flutter_architecture/config/environments.json
```

替換三個 environment 的 identifier 與 display name。Environment 名稱、flavor、scheme 與 entrypoint 若無正式 architecture decision，不應任意改名。

### 3. 更新 Android projection

同步檢查並修改：

```txt
apps/flutter_architecture/android/app/build.gradle.kts
apps/flutter_architecture/android/app/src/main/AndroidManifest.xml
apps/flutter_architecture/android/app/src/main/kotlin/
```

至少包含：

- `namespace`
- production `applicationId`
- development／staging suffix contract
- Kotlin package 與目錄
- environment app labels

正式 signing configuration 不應放入 tracked template config；應由 adopter 自己的 protected release process 管理。

### 4. 更新 iOS projection

同步檢查並修改：

```txt
apps/flutter_architecture/ios/Flutter/*-development.xcconfig
apps/flutter_architecture/ios/Flutter/*-staging.xcconfig
apps/flutter_architecture/ios/Flutter/*-production.xcconfig
apps/flutter_architecture/ios/Runner/Info.plist
apps/flutter_architecture/ios/Runner.xcodeproj/project.pbxproj
```

保持三個 shared schemes 與九個 build configurations，更新 `PRODUCT_BUNDLE_IDENTIFIER`、`PRODUCT_NAME` 與 `APP_DISPLAY_NAME`。不要提交個人 `DEVELOPMENT_TEAM`、certificate、provisioning profile 或 signing credential。

### 5. 更新 repository verification expectations

目前 verifier 與 artifact inspection scripts 會阻止 native projection 漂移。替換 identity 後同步更新／檢查：

```txt
tools/ci/verify_environment_contract.py
tools/ci/test_environment_contract.py
tools/ci/build_android_environment.sh
tools/ci/build_ios_environment.sh
```

這不是建立第二份 product authority；它們是 blocking verification projection。最終 mapping 仍以 App-owned manifest 與 ADR-025 為正式契約。

### 6. 替換 API domain

API endpoint 不寫入 Gradle、Xcode project 或 environment manifest。由 local command、CI environment 或未來 protected release workflow 明確提供：

```txt
API_MODE
API_BASE_URL
```

規則：

- Development 可使用 mock 或 real。
- Staging／production 只允許 real。
- Staging／production 必須 HTTPS。
- Production 拒絕 localhost、loopback、`.invalid` 與 example placeholder hosts。

不要把 token、password、private key 或 Store credential 放入 `--dart-define`、repository file、artifact metadata 或 workflow log。

### 7. 執行完整 contract verification

```bash
python3 tools/ci/verify_environment_contract.py
python3 -m unittest \
  tools.ci.test_environment_contract \
  tools.ci.test_environment_workflow_matrix_contract \
  tools.ci.test_local_build_commands \
  tools.ci.test_ios_workflow_contract \
  tools.ci.test_shell_portability_contract
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
```

接著執行本指南的 Android／iOS 三環境命令，核對 `artifact-metadata.txt` 與實際 package／bundle identity。

## Placeholder and Secret Boundary

### 必須由 adopter 替換

- `com.example.flutterarchitecture` base identifier
- Development／staging／production display names
- Real staging／production API domains
- Android namespace／Kotlin package
- Store listing、privacy、support 與 legal metadata
- Production signing ownership與rotation policy

### 絕對不可 commit

- Android keystore、key alias password、store password
- Apple certificate private key
- Provisioning profile（除非未來有明確受控政策）
- Apple Team／App Store Connect API private key
- Play Console service account key
- Production API token、refresh token、password或其他 credential
- `.env` 中的真實 secret

### 可以被 version control 管理

- 非秘密的 identifier、display name、scheme、flavor、entrypoint mapping
- Public API base URL（若組織政策允許）
- Verification-only placeholder URL
- CI job、artifact metadata schema與non-secret release policy

## Responsibility Boundary

| Capability | Repository CI verification | Production signing | Store distribution |
|---|---|---|---|
| Environment mapping | 負責 | 使用既有 mapping | 使用 production mapping |
| Package／bundle identity | 驗證 | 必須與 production identity 相符 | Store record 必須相符 |
| Android artifact | debug-signed APK | release-signed AAB／APK | Play Console upload／rollout |
| iOS artifact | unsigned `.app` | signed archive／IPA | TestFlight／App Store Connect |
| Credentials | 不讀取 Store secrets | Protected secret／OIDC／manual custody | Store-specific access control |
| Approval | Repository checks | Release approval | Store review／rollout approval |

目前 repository 只實作第一欄。Production signing 與 Store distribution 必須由獨立 architecture decision、protected environment、credential ownership與rollback procedure治理。

## Related Authority

- [ADR-025 — Native Environment Mapping and Product Identity Contract](../adr/adr-025-native-environment-mapping-product-identity-contract.md)
- [ADR-014 — App Configuration and Environment Entrypoints](../adr/adr-014-app-configuration-environment-entrypoints.md)
- [CI/CD Operations Guide](ci_cd_operations.md)

