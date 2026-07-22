---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-task-26-4-review
last_reviewed_baseline: 1.7.0
---

# Milestone 26-4 Review — Dart Bootstrap Mismatch Guard

## Scope

本 Task 將 Android flavor／iOS scheme 注入的 `NATIVE_ENVIRONMENT` sentinel 與 Dart entrypoint 的 `AppEnvironment` 在 Composition Root 建立前進行一致性驗證，並補強 staging／production API safety contract。本 Task 不修改 native product identity、build scripts或 CI matrix。

## Implemented Contract

- `AppConfigFactory.fromEnvironment`集中讀取`NATIVE_ENVIRONMENT`、`API_MODE`與`API_BASE_URL`。
- Native sentinel為空或與entrypoint environment不一致時，在`configureDependencies`與`runApp`前fail fast。
- `lib/main.dart`是唯一允許缺少sentinel的development compatibility入口。
- `main_development.dart`、`main_staging.dart`與`main_production.dart`必須取得native sentinel。
- Development仍允許mock／real與HTTP本機測試。
- Staging只允許real API且必須使用HTTPS。
- Production只允許real HTTPS，並拒絕mock、localhost、loopback、`.invalid`與`example.com`／`.org`／`.net` template placeholder hosts。

## TDD Evidence

### RED

新增matching sentinel、mismatch、missing compatibility sentinel、staging HTTP與production placeholder host tests後，focused test因`nativeEnvironmentValue`參數尚不存在而編譯失敗。

### GREEN

```text
flutter test test/app/config/api_config_test.dart
16 tests passed

flutter test \
  test/app/config/api_config_test.dart \
  test/app/navigation/auth_navigation_app_integration_test.dart
17 tests passed
```

Environment verifier亦強制：

- explicit environment entrypoints不得使用missing-sentinel例外。
- compatibility例外只存在於`main.dart`。
- AppConfig包含sentinel與HTTPS／placeholder policies。
- AppConfig validation順序早於DI與`runApp`。

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---|---|
| M26-4-R01 原有bootstrap沒有讀取或比較native sentinel，native identity與Dart environment仍可能錯配 | P1 | 在`AppConfigFactory`集中解析與比對，錯配立即拋出`ArgumentError` |
| M26-4-R02 若所有入口都允許sentinel缺少，native build可能靜默退化為CLI convention | P1 | 只有`main.dart`明確傳入`allowMissingNativeEnvironment: true`，verifier禁止其他入口使用 |
| M26-4-R03 Staging原本仍接受HTTP，與ADR-025 safety contract不一致 | P1 | staging與production統一要求HTTPS，development保留HTTP能力 |
| M26-4-R04 Production原本接受template常見的`api.example.com` placeholder | P1 | 阻擋example.com／.org／.net及其subdomain，合法adopter domain不受影響 |
| M26-4-R05 Sentinel validation若晚於DI會建立錯誤environment的service graph | P1 | verifier固定`AppConfigFactory.fromEnvironment`早於`configureDependencies`與`runApp` |
| M26-4-R06 舊verifier只接受單行compatibility bootstrap，無法表達新的明確例外 | P2 | 改以跨行regex驗證development compatibility contract |
| M26-4-R07 Integration smoke test仍使用舊`fromValues`介面，analyze發現缺少sentinel migration | P1 | 補上明確development sentinel並重跑全量analyze／tests |
| M26-4-R08 iOS scaffold test仍假設單一bundle ID／product name與三組entitlements，未跟隨Task 26-3 projection | P1 | 改驗environment xcconfig與九組configuration下的6／3 entitlements引用 |
| M26-4-R09 iOS scaffold test中的Xcode build-setting字串未使用raw literal，造成Dart插值語法錯誤 | P2 | 改用raw string並重跑focused test |

Open P0／P1 without disposition：0。

## Rollback Boundary

回退本 Task 時必須一起回復：

- `AppConfigFactory`的sentinel參數、解析與validation。
- `bootstrap`的compatibility參數。
- `main.dart`唯一missing-sentinel例外。
- staging HTTPS與production placeholder host限制。
- focused tests與environment verifier projection。

不得只移除Dart comparison而保留native sentinel injection，否則sentinel將成為無效metadata。
