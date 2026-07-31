---
document_type: implementation-plan
status: accepted
authoritative_for:
  - r3-api-client-transport-neutral-error-boundary-plan
last_reviewed_baseline: 1.14.0
---

# R3 — API Client Transport-neutral Error Boundary Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans with strict test-driven-development for every production change.

**Goal:** 在`api_client`內封閉Dio transport exception，讓Auth只依賴neutral endpoint interface／exception，移除Auth Dio dependency並保持OTP／refresh行為不變。

**Architecture:** R3-1先以TDD建立endpoint contracts、neutral envelope與Dio adapters；R3-2再以RED source／behavior tests遷移Auth；R3-3更新App Composition Root與generated DI；R3-4執行cross-package review、documentation與finding closure。

**Tech Stack:** Dart／Flutter、Dio／Retrofit、Freezed generated source、Injectable／GetIt、Flutter Test、Melos、Markdown governance。

## Global Constraints

- Design：`docs/superpowers/specs/2026-08-01-r3-api-client-transport-neutral-error-boundary-design.md`。
- Design commit：`9c8fa28dbed1846f6b1fe0ebf2797ad5ff40232d`。
- Finding owner：只允許關閉`F-A2-01`。
- Remaining findings：`F-A1-04`、`F-A6-01`保持Open。
- ADR-013 contract不改變；不得新增平行ADR。
- Production code遵守TDD：每個behavior先RED、確認expected failure、再GREEN。
- Auth不得新增任何transport library dependency或generic exception framework。
- Profile／Catalog source不在R3 mutation scope。
- 不改refresh single-flight、safe replay、OTP domain semantics或user-facing localization。
- 不merge、不push、不cleanup、不release。

---

## Task R3-P — Plan Governance

**Files:**

- Create: `docs/superpowers/plans/2026-08-01-r3-api-client-transport-neutral-error-boundary.md`
- Create: `docs/audits/r3_api_client_transport_neutral_error_boundary_plan_review.md`
- Modify: `docs/superpowers/README.md`
- Modify: `docs/audits/README.md`

- [ ] 確認Design所有boundary、error、TDD、composition、public API與validation requirements都有Task owner。
- [ ] 完成focused／whole-Plan review、placeholder scan與exact path check。
- [ ] Fresh執行documentation tests、`docs_check`、`git diff --check`。
- [ ] 依2026-08-01 standing authorization記錄accepted Plan。
- [ ] 建立獨立commit：

```bash
git commit -m "docs(architecture): 核准R3 transport-neutral error boundary計畫"
```

---

## Task R3-1 — API Client Endpoint Boundary

**Files:**

- Create: `packages/api_client/lib/src/endpoints/auth_endpoint.dart`
- Create: `packages/api_client/lib/src/endpoints/auth_refresh_endpoint.dart`
- Create: `packages/api_client/lib/src/endpoints/dio_auth_endpoint.dart`
- Create: `packages/api_client/lib/src/endpoints/dio_auth_refresh_endpoint.dart`
- Create: `packages/api_client/lib/src/errors/api_endpoint_exception.dart`
- Create: `packages/api_client/lib/src/errors/dio_exception_mapper.dart`
- Modify: `packages/api_client/lib/src/errors/transport_exception_mapper.dart`
- Modify: `packages/api_client/lib/api_client.dart`
- Modify: `packages/api_client/lib/src/mocks/mock_auth_api.dart`
- Modify: `packages/api_client/lib/src/mocks/mock_auth_refresh_api.dart`
- Modify: `packages/api_client/test/api_client_smoke_test.dart`
- Create: `packages/api_client/test/auth_endpoint_boundary_test.dart`
- Create: `docs/audits/r3_api_client_transport_neutral_error_boundary/r3_1_api_client_endpoint_review.md`

### RED

- [ ] 寫`auth_endpoint_boundary_test.dart`，要求：
  - `DioAuthEndpoint`把bad response轉`ApiEndpointException`。
  - envelope保存httpStatus、backendCode、immutable metadata。
  - `toString()`不包含metadata value／OTP code／raw payload。
  - connection error保留typed transport kind。
  - unknown erroridentity與stack不變。
  - `DioAuthRefreshEndpoint`使用相同contract。
- [ ] 執行focused test，確認因types不存在而RED。

### GREEN

- [ ] 建立`AuthEndpoint`／`AuthRefreshEndpoint`interfaces，method signatures與既有DTO contract一致。
- [ ] 建立`ApiEndpointException`，constructor defensive-copy並使用unmodifiable map。
- [ ] 將Dio→AppException與response metadata extraction放入internal `dio_exception_mapper.dart`。
- [ ] `transport_exception_mapper.dart`只公開neutral-signature `rethrowMappedTransportException(Object, StackTrace)`。
- [ ] 建立兩個Dio adapters；只catch DioException，unknown error用`Error.throwWithStackTrace`。
- [ ] `MockAuthApi`／`MockAuthRefreshApi`改實作endpoint interfaces；Mock OTP failure不再建立DioException。
- [ ] Public barrel exportendpoints、adapters與neutral exception；移除`transport_failure_details.dart` export。
- [ ] 更新smoke test，不再透過public API assert`TransportFailureDetails`，改驗證AppException safe fields。
- [ ] 執行api_client focused tests，確認GREEN。

### Review and Commit

- [ ] Mechanical public API assertion：public exported files不得宣告含`DioException`／`DioExceptionType`的public signature。
- [ ] Whole-Task review確認Profile／Catalog未修改、interceptor仍可內部使用Dio。
- [ ] 執行`cd packages/api_client && flutter test`與`dart analyze`。
- [ ] 建立review artifact與獨立commit：

```bash
git commit -m "refactor(api_client): 建立transport-neutral Auth endpoint boundary"
```

---

## Task R3-2 — Auth Consumer Migration

**Files:**

- Modify: `packages/auth/lib/src/data/data_sources/auth_remote_data_source.dart`
- Modify: `packages/auth/lib/src/data/data_sources/auth_refresh_remote_data_source.dart`
- Modify: `packages/auth/pubspec.yaml`
- Modify: `packages/auth/test/auth_otp_remote_mapping_test.dart`
- Modify: `packages/auth/test/auth_session_refresher_test.dart`
- Modify: `packages/auth/test/auth_session_refresher_secure_lifecycle_test.dart`
- Create: `packages/auth/test/auth_transport_independence_test.dart`
- Create: `docs/audits/r3_api_client_transport_neutral_error_boundary/r3_2_auth_consumer_review.md`

### RED

- [ ] 新增source contract test：Auth pubspec與`lib/`、`test/`不得含`package:dio`，DataSource constructor types必須是endpoint interfaces。
- [ ] 先只建立test並執行，確認因既有Dio dependency／imports而RED。
- [ ] 將OTP／refresh fake APIs改為neutral endpoint interfaces與`ApiEndpointException`，在production migration前確認compile／behavior RED。

### GREEN

- [ ] `AuthRemoteDataSource`改依賴`AuthEndpoint`，login／OTP catch neutral exception。
- [ ] OTP只讀`backendCode`與`backendMetadata`；recognized code維持typed details，unknown code退回transport exception。
- [ ] `AuthRefreshRemoteDataSource`改依賴`AuthRefreshEndpoint`；401／403與temporary semantics不變。
- [ ] 移除`packages/auth`的Dio dependency與所有Dio imports。
- [ ] 更新tests以`TransportExceptionKind`／`AppException`建neutral envelope，不降低case coverage。
- [ ] 執行RED tests與auth全量，確認GREEN。

### Review and Commit

- [ ] Mechanical assertion確認Auth pubspec／source／tests無`dio`與`DioException`。
- [ ] Whole-Task reviewOTP metadata、unknown identity、refresh 401／403／5xx／connection behavior。
- [ ] 執行`cd packages/auth && flutter test`與`dart analyze`。
- [ ] 建立review artifact與獨立commit：

```bash
git commit -m "refactor(auth): 移除Dio transport dependency"
```

---

## Task R3-3 — App Composition and Generated DI

**Files:**

- Modify: `apps/flutter_architecture/lib/app/di/api_implementation_selector.dart`
- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Modify: `apps/flutter_architecture/test/app/di/api_implementation_selector_test.dart`
- Modify: `apps/flutter_architecture/test/app/di/configuration_injection_test.dart`
- Regenerate: `apps/flutter_architecture/lib/app/di/injection.config.dart`
- Create: `docs/audits/r3_api_client_transport_neutral_error_boundary/r3_3_app_composition_review.md`

### RED

- [ ] 更新selector tests：Mock回傳`AuthEndpoint`mock，Real必須是`DioAuthEndpoint`／`DioAuthRefreshEndpoint`。
- [ ] 更新DI test要求GetIt可resolve兩個endpoint interfaces與Auth DataSources。
- [ ] 在production／generated source變更前執行focused tests，確認RED。

### GREEN

- [ ] Selector real path組裝Retrofit declaration再包Dio adapter；mock path回傳Mock endpoint。
- [ ] RegisterModule提供endpoint types並注入Auth DataSources。
- [ ] 執行`dart run melos run build_runner`更新generated DI；不得手動修改generated source。
- [ ] 執行App DI focused tests，確認GREEN。

### Review and Commit

- [ ] Whole-Task review確認App仍是唯一Composition Root，api_client／auth無DI annotation。
- [ ] 執行App DI tests、App analyze與generated consistency。
- [ ] 建立review artifact與獨立commit：

```bash
git commit -m "refactor(di): 組裝transport-neutral Auth endpoints"
```

---

## Task R3-4 — Documentation and Holistic Closure

**Files:**

- Modify: `packages/api_client/README.md`
- Modify: `packages/auth/README.md`
- Modify: `docs/project_context.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- Modify: `docs/audits/README.md`
- Create: `docs/audits/r3_api_client_transport_neutral_error_boundary/r3_4_holistic_final_review.md`

- [ ] 更新package docs：api_client擁有endpoint adapters／neutral envelope；Auth明確不依賴Dio／Retrofit。
- [ ] Project Context package responsibility只補current boundary，不加入R3 journal。
- [ ] 僅將`F-A2-01`標記`Resolved by R3`；`F-A1-04`與`F-A6-01`保持Open。
- [ ] 執行mechanical dependency／public API／generated source assertions。
- [ ] Fresh完整validation：

```bat
dart pub get
dart run melos run build_runner
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

- [ ] 建立accepted holistic final review，記錄exact test counts、build結果、scope與remaining findings。
- [ ] 建立獨立commit：

```bash
git commit -m "docs(architecture): 完成R3 transport-neutral boundary審查"
```

- [ ] Committed-state重跑docs、analyze與affected focused tests，working tree必須clean。

## Plan Approval Closure

```txt
Focused Plan review: PASSED after findings disposition
Whole-Plan review: PASSED
Open planning P0: 0
Open planning P1 without disposition: 0
User authorization: standing authorization on 2026-08-01
Plan status: ACCEPTED
Implementation allowed: YES after independent Plan commit
```
