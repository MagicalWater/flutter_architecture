---
document_type: guide
status: active
authoritative_for:
  - repository-ci-cd-operations
last_reviewed_baseline: 1.7.0
---

# CI/CD Operations Guide

## Scope

本指南說明 repository CI quality gates、Android verification artifact、Branch Protection 建議、常見失敗處理與 rollback 流程。

Durable architecture contract 由 `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md` 保存；本指南不取代 ADR，也不宣稱 GitHub repository settings 已被修改。

## Workflow Inventory

### Repository CI

```txt
.github/workflows/ci.yml
```

Events：

- Pull Request 到 `main`。
- Push 到 `main`。
- `workflow_dispatch`。

Stable checks：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
iOS / Simulator Build
```

Environment representative checks另外包含：

```txt
Android / Development Debug APK
Android / Release APK
iOS / Production Release Build
```

`iOS / Simulator Build`維持Development Debug Simulator，避免既有Branch Protection名稱漂移。Flutter不支援iOS Simulator的Release/Profile AOT，因此Production代表建置使用`Release-production`、generic `iphoneos`與`CODE_SIGNING_ALLOWED=NO`，不是Simulator build。

### Android Verification Artifact

```txt
.github/workflows/android.yml
```

Events：

- Push 到 `main`。
- `workflow_dispatch`。

Jobs：

```txt
Android / Development Debug APK
Android / Release APK
```

兩個job分別建立development Debug與production Release verification APK；production仍使用debug signing，不是production distribution pipeline。

## Recommended Branch Protection

Milestone 24 只文件化以下建議；repository administrator 必須在 GitHub settings 中人工確認與套用。

建議 `main`：

- Require a pull request before merging。
- Require approvals，數量依團隊規模決定。
- Require conversation resolution before merging。
- Require status checks to pass before merging。
- Require branches to be up to date before merging，若團隊接受額外等待成本。
- Block force pushes。
- Block branch deletion。

Required status checks使用穩定名稱：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
iOS / Simulator Build
```

第一版不建議把 `Android / Release APK` 設為 Pull Request required check，因為它只在 `main` push或manual dispatch執行。`iOS / Simulator Build`會在Pull Request建立run；Milestone 25 remote validation已證明GitHub-hosted macOS job可成功執行，可依repository治理決定是否加入required checks。

啟用 Merge Queue 前，必須先讓`ci.yml`與`ios.yml`支援`merge_group` event，確認所有已設定的required checks在merge queue context會建立run，再修改Branch Protection。

## Rerun Policy

### GitHub／network transient failure

先確認失敗不是source、generated file、test或build contract問題。只有下載、runner provisioning、GitHub service或外部registry暫時性錯誤，才直接rerun failed jobs或整個workflow。

同一commit重跑仍失敗時，不得以「可能是網路問題」忽略；應依一般failure流程處理。

### Manual verification

三份workflow都支援`workflow_dispatch`。Manual run只重驗當下選定ref，不取代Pull Request required checks，也不改變歷史commit的結果。

## Cache Degradation

Flutter SDK、Pub與Gradle cache只用來降低時間，不是正確性前提。

Cache miss、eviction或restore failure時：

1. Workflow仍應執行dependency resolution與正式build／test command。
2. Fresh resolution成功即屬non-blocking degradation。
3. 若沒有cache便失敗，視為reproducibility defect，不得新增workspace build cache來掩蓋。

不得cache：

```txt
.dart_tool/
workspace build/
generated source
APK output
```

## Generated Consistency Failure

`CI / Generated Consistency`會從clean checkout執行：

```bash
bash tools/ci/verify_generated.sh
```

失敗時：

1. 在本機clean working tree執行`dart pub get`。
2. 執行`dart run melos run build_runner`。
3. Review所有generated diff，確認source與generator版本正確。
4. 提交需要追蹤的generated files。
5. 不得讓CI自動commit，也不得只忽略dirty-tree結果。

若本機Windows checkout因CRLF或WSL／Windows Git混用產生假dirty狀態，使用單一Git環境確認實際content diff；正式CI authority仍是Ubuntu clean checkout。

## Quality or Test Failure

### Documentation／analysis failure

依workflow log執行對應repository command：

```bash
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

修正root cause後提交新的commit，不修改workflow讓既有錯誤變成non-blocking。

### Test failure

```bash
dart run melos exec -- flutter test
```

確認是否可重現、是否為flaky test、shared state或平台差異。沒有證據前不得直接rerun直到變綠；若確認flaky，先建立focused fix與regression evidence。

Design System golden test使用`design_system_gallery_<platform>.png`保存各host renderer的獨立authority；Windows、Linux與macOS均有reviewed baseline。失敗時，`CI / Tests`會嘗試上傳`golden-test-failures-<full-sha>` artifact並保存14天。應下載比較master、test與isolated diff images，先確認字型、renderer與host差異，再判斷是否為真正UI regression；不得只放寬pixel tolerance掩蓋失敗。

## Android Artifact Failure

Android workflow依序執行generated consistency與：

```bash
bash tools/ci/build_android_development.sh
API_BASE_URL=https://api.acme.test bash tools/ci/build_android_production.sh
```

Local development與production的正式入口分別為：

```bash
bash tools/ci/build_android_development.sh
API_BASE_URL=https://api.your-domain.example bash tools/ci/build_android_production.sh
```

失敗時：

1. 確認generated gate是否先失敗。
2. 在repository root執行`dart pub get`。
3. 使用 environment-aware build script，或在App目錄直接驗證：

   ```bash
   flutter build apk --release --flavor production \
     -t lib/main_production.dart \
     --dart-define=API_MODE=real \
     --dart-define=API_BASE_URL=https://api.your-domain.example
   ```

4. ReviewGradle、Android SDK、Java 17、Flutter 3.41.6與entrypoint evidence。
5. 建立fix commit或revert造成失敗的commit。

不得上傳舊APK並標成新commit artifact，也不得把失敗commit對應到其他SHA的產物。

## iOS Simulator Build Failure

`iOS / Simulator Build`與`iOS / Production Release Build`都在`macos-15`執行：

```bash
bash tools/ci/build_ios_development.sh
API_BASE_URL=https://api.acme.test bash tools/ci/build_ios_production.sh
```

Local development與production verification的正式入口分別為：

```bash
bash tools/ci/build_ios_development.sh
API_BASE_URL=https://api.your-domain.example bash tools/ci/build_ios_production.sh
```

Production iOS verification使用`Release-production`、generic `iphoneos` SDK與`CODE_SIGNING_ALLOWED=NO`，不產生可上架IPA。不得改成Release Simulator；Flutter toolchain會以「release/profile builds are only supported for physical devices」拒絕該組合。

此gate會重新取得Pub與CocoaPods dependencies並建立unsigned Simulator `.app`，不讀取Apple signing secrets，也不把`.app`上傳為distribution artifact。失敗時會保留7天的`toolchain.txt`與`build.log` diagnostics。

處理順序：

1. 下載`ios-simulator-build-diagnostics-<full-sha>`。
2. 核對macOS、Xcode、Flutter與CocoaPods版本。
3. 在macOS repository root重跑`bash tools/ci/build_ios_development.sh`；production failure則重跑`API_BASE_URL=https://api.your-domain.example bash tools/ci/build_ios_production.sh`。
4. 若是runner或registry transient failure，只可在確認source contract無誤後rerun。
5. 若是Pod resolution、native identity、plugin registration或Xcode build failure，建立focused fix並重新review。

此check通過不代表實體裝置、Face ID／Touch ID、signing、archive或App Store上架已驗證。

## Artifact Contract

Environment-aware local artifact預設放在：

```txt
artifacts/android/<environment>/
artifacts/ios/<environment>/
artifact-metadata.txt
```

GitHub artifact名稱包含full SHA，retention為14天。

Metadata至少包含commit SHA、environment、platform、flavor或scheme、configuration／SDK、entrypoint、API mode、native identifier、artifact filename與以下分類：

```txt
signing=debug signing for verification only
distribution=not production-ready
```

下載後應先核對metadata SHA與預期commit，再用於verification或debug。

完整三環境本地命令、manifest-first identity替換順序、placeholder與secret boundary請讀：

```txt
docs/guides/native_environment_adoption.md
```

## Workflow Rollback

Workflow regression優先使用focused fix。若workflow本身讓repository無法正常merge或持續消耗runner：

1. 找出最後一個已知正常workflow commit。
2. Revert造成regression的workflow commit，或建立最小修復commit。
3. 執行YAML/static contract與repository commands。
4. 若required check名稱被改壞，repository administrator需同步修復Branch Protection settings。
5. 不得藉rollback降低既有quality gate，除非另有正式Decision與review。

GitHub settings不在Git history內。任何Branch Protection修改都應由管理者另外記錄變更內容、時間與操作者。

## Future Production Release Extension

Production release必須建立獨立workflow與protected Environment，至少重新設計：

- Production keystore ownership與rotation。
- Secret／OIDC／Store credential管理。
- AAB而非verification APK。
- Approval與environment protection rules。
- Signing verification。
- Version／release notes／Store upload contract。
- Artifact provenance與retention。

不得直接把現有debug-signed verification workflow加上Store upload step後稱為production pipeline。

## Explicit Non-goals

Milestone 24不包含：

- Production signing。
- Play Store／App Store publishing。
- iOS build。
- GitHub Release automation。
- Environment promotion。
- Dependency auto-update。
- Flutter flavors或production endpoint配置。

