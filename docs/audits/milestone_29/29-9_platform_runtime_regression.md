---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-9-platform-runtime-regression-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-9 — Platform Runtime and Full Regression Validation

## Scope

以production Drift opener、historical fixtures與repository artifact scripts驗證single-owner
cutover，並依current platform policy記錄可執行與環境受限的證據。

## Full Repository Verification

- `dart pub get`：passed。
- `dart run melos run build_runner`：passed；generated normalization完成。
- `dart run melos run docs_check`：passed。
- `dart run melos run analyze`：passed。
- `dart run melos exec -- flutter test`：passed；App package 467項，所有workspace packages皆通過。
- `cd apps/flutter_architecture && flutter build bundle`：passed。

## Database Upgrade and Runtime Evidence

- v1～v6 checked-in sqflite fixtures均由Drift升級至canonical v6。
- migration failure不留下partial schema或錯誤推進`user_version`。
- rollback compatibility確認Drift升級後仍維持SQLite constraints與可讀性。
- macOS production opener實際使用background executor、建立精確
  `flutter_architecture.db`、執行query並驗證idempotent close。
- Android／iOS同檔directory bridge由native channel與path contract tests固定；實際artifact
  build使用production Composition Root與Drift dependencies。

## Android Acceptance

第一次執行production artifact script因缺少`API_BASE_URL`按environment contract拒絕。
以verification URL重新執行後通過：

```txt
artifact: artifacts/android/production/flutter-architecture-production-release.apk
package_id: com.example.flutterarchitecture
build_mode: release
signing: debug signing for verification only
mapping_file: present
flutter_symbols: 3
```

Flutter 3.44 build migrator補入`android.builtInKotlin=false`與`android.newDsl=false`，保留為
current toolchain compatibility設定；不改變database architecture或platform support claim。

## iOS Acceptance

第一次Simulator build在`GeneratedPluginRegistrant`找不到`connectivity_plus` module。
調查確認Flutter 3.44.8自動啟用Swift Package Manager，但current ADR-024與Milestone 25
authority仍採CocoaPods-compatible integration，pure SPM不在本階段scope。

修正方式：

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

重新`flutter pub get`、`pod install`後，10個Podfile dependencies與23個Pods正確整合，
Simulator artifact build通過：

```txt
artifact: artifacts/ios/development/Flutter Architecture Dev.app
bundle_id: com.example.flutterarchitecture.development
sdk: iphonesimulator
signing: unsigned verification build
dsym: present
```

`Runner.xcodeproj`保留CocoaPods重新整合後的tracked project state。Firebase CocoaPods
deprecation警告與sqlite3／objective_c native asset framework-name警告不影響本次build，
但需由future dependency-manager／upstream package治理處理。

## Web Acceptance

- Web storage disposition維持Task 29-6選定的`explicit reset`。
- `sqlite3.wasm`與`drift_worker.js`存在、hash與reproducible generation tests通過。
- App沒有tracked Web runner，因此不宣稱browser runtime或multi-tab acceptance通過；
  current platform classification仍是Dependency-ready。

## Desktop Matrix

| Platform | Evidence | Disposition |
|---|---|---|
| macOS | production native opener smoke passed | Dependency-ready；未新增runner／Supported claim |
| Windows | current macOS host無Windows runner | 明確environment-blocked，保留future host build requirement |
| Linux | current macOS host無Linux runner | 明確environment-blocked，保留future host build requirement |

## Focused Review Findings

### Finding 1 — Production build需要明確API_BASE_URL

**Disposition:** 確認environment guard正確工作；以verification URL重跑Android／iOS artifact。

### Finding 2 — Flutter 3.44自動SPM破壞current CocoaPods build contract

**Disposition:** App pubspec明確關閉SPM，新增CI contract test並重新執行pod install與Simulator build。

### Finding 3 — Platform tools產生tracked compatibility updates

**Disposition:** 保留Android Gradle compatibility flags與CocoaPods重新整合後的Xcode project；
二者均由current toolchain生成，且重新build證明有效。

## Focused Re-review

- iOS dependency graph重新包含`connectivity_plus`、Firebase、secure storage、local auth、
  shared preferences與test-only sqflite Pods。
- iOS Simulator build由失敗轉為`BUILD SUCCEEDED`，artifact與dSYM均產出。
- Android production artifact、macOS opener與v1～v6 migration／rollback tests全綠。
- SPM disable contract與CocoaPods build script sequencing有自動測試保護。

## Whole-task Review

- Production App只使用Drift authority；sqflite只存在historical test harness。
- Android／iOS artifacts均由current production Composition Root建立。
- same-file upgrade由checked-in fixtures、exact path contract與native opener smoke共同證明。
- Web／Windows／Linux限制均按current platform policy記錄，沒有把dependency capability誤寫為Supported。
- 所有finding均有修正或明確future disposition，沒有隱藏失敗或false pass。

## Documentation Authority Check

- 本文件是Task 29-9 platform/runtime evidence authority。
- Platform support classification仍由`docs/project_context.md`與既有platform ADR治理。
- Drift schema／generation authority仍由Task 29-7 tooling與snapshots承載。
- Web storage disposition仍由Task 29-6 review承載，本文件只引用runtime結果與限制。

## Exit Criteria

- Open P0：0。
- Open P1 without disposition：0。
- Android artifact：passed。
- iOS Simulator artifact：passed after finding fix。
- macOS opener：passed。
- Web／Windows／Linux：no false support claim。
- Task 29-9：accepted。
