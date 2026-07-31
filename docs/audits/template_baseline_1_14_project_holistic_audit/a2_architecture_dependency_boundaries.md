---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-architecture-boundary-evidence
last_reviewed_baseline: 1.14.0
---

# A2 — Architecture and Dependency Boundary Audit

## Scope and Method

本Task以current ADR、App／Feature／Package README、240個tracked production Dart files、pubspec dependency、representative call chains與focused tests審查架構責任邊界。

Grep只作導航。結論必須同時對照source、public exports、tests與ADR contract。

## Repository Responsibility Matrix

| Boundary | Current owner | Evidence | Conclusion |
|---|---|---|---|
| Composition Root | App `register_module.dart`與generated DI graph | Plugin、Dio、API selector、repository、store、router均在App組裝 | 符合ADR-004／012；可重用package沒有`get_it`／`injectable` production import。 |
| Feature presentation | 各Feature Page／Bloc | Feature內import均留在同Feature；Page只讀own Bloc | 沒有確認cross-feature Bloc dependency。 |
| Route Guard | `AuthGuard`＋Session abstraction | Router focused tests與navigation integration通過 | Guard沒有依賴AuthBloc。 |
| Networking | `api_client` Retrofit declarations、Dio factory／interceptors | App選擇Mock／Real implementation | 一般endpoint沒有在Feature手寫`dio.get／post`。 |
| Auth domain／data | `auth` package | Login、OTP、restore、refresh、migration、cleanup與session tests | Package邏輯邊界完整，但存在Dio type leak，見`F-A2-01`。 |
| Persistence | App `AppDatabase`、DAOs與Feature adapters | Production source沒有sqflite import；Drift由App擁有 | 符合ADR-010 single-owner contract。 |
| Platform plugins | App adapters／Feature App-owned adapters | Firebase、connectivity、secure storage、local auth只在App production paths | Reusable packages未直接依賴platform SDK。 |
| Failure／Reporting | `core` contracts＋boundary-local mapping＋App reporter adapter | ADR-020與Auth／API client tests | Unknown error identity與stack保留；provider未污染package。 |

## Static Inventory Results

```txt
Tracked production Dart files: 240
Package DI framework imports: 0
External consumer deep imports into package src: 0
Production sqflite imports: 0
Firebase imports: App observability adapter only
connectivity_plus imports: App connectivity／DI only
flutter_secure_storage imports: App Auth adapter／DI only
local_auth imports: App Auth adapter／DI only
```

Cross-feature grep輸出全部是同一Feature的absolute package imports；沒有Auth→Catalog、Catalog→Profile或Presentation跨Feature讀取其他Bloc的證據。

## Representative Call Chains

### Bootstrap and Composition

```txt
entrypoint
→ AppConfig／environment validation
→ configureDependencies
→ RegisterModule／API implementation selector
→ App／Router／Scopes
```

Environment、Mock／Real API與plugin lifecycle由App決定；Package只以constructor injection接收依賴。

### Authentication and Navigation

```txt
Login／OTP／Restore／Logout UI
→ AuthBloc
→ narrow UseCase
→ AuthRepository
→ AuthRemoteDataSource／credential／user stores
→ SessionManager
→ AuthGuard／navigation coordinator
```

AuthGuard讀取穩定session abstraction，不跨讀AuthBloc；navigation integration tests證明login、protected route與session expiration contract。

### Refresh and Replay

```txt
Authenticated request
→ AuthHeaderInterceptor
→ 401 AuthRefreshInterceptor
→ AuthRefresher／AuthSessionRefresher
→ refresh API＋persistence-first rotation
→ safe replay or typed terminal result
```

Interceptor、session refresher與credential authority各有package／App tests；temporary failure不等於invalid credential。

### Catalog and Connectivity

```txt
CatalogBloc
→ SearchCatalogUseCase
→ CatalogRepository
→ RemoteDataSource／LocalDataSource
→ Drift DAO

connectivity_plus adapter
→ App ConnectivityController／Scope
→ Catalog opt-in reconnect revalidation
```

Connectivity只提供network state authority，不冒充backend reachability；Catalog擁有是否revalidate的產品語意。

### Error Reporting

```txt
Boundary-local known exception mapping
→ typed AppException
→ Repository operation-specific Failure mapping
→ Presentation state

unexpected error／protocol violation／degraded diagnostic
→ ErrorReporter
→ App-owned Firebase reference adapter or test/debug adapter
```

符合ADR-020「expected與unexpected分離」及provider隔離規則。

## Focused Finding — Dio Type Crosses `api_client` Package Boundary

`packages/auth`依賴`api_client`，但同時在pubspec直接依賴Dio，且：

- `AuthRemoteDataSource`使用`DioException.response`解析OTP backend metadata。
- `AuthRefreshRemoteDataSource`以`on DioException`區分401／403與temporary failure。
- `api_client` public barrel export接受`DioException`的`mapDioException`與`rethrowMappedTransportException`。

ADR-013明文要求Dio不穿透`packages/api_client` boundary；RemoteDataSource應隔離transport exception。Current behavior因此是contract erosion，而不是受控special transport service，因為Dio type與response body interpretation已進入`packages/auth`。

此問題目前定為`F-A2-01`／P2：

- Auth仍透過Retrofit abstraction呼叫endpoint，沒有直接手寫request。
- Domain、Repository public result與App presentation未依賴Dio。
- 154個Auth package tests、55個API client tests與22個App DI／Router／Navigation testsfresh通過。
- 沒有current runtime failure或security bypass。

建議未來建立transport-neutral endpoint error envelope或由`api_client` API implementation先轉成typed transport／backend exception，再讓Auth boundary解析Auth-owned metadata；不得在本Audit直接重構。

## Not-an-Issue Dispositions

- Package內部使用`package:auth/src/...`或`package:api_client/src/...`不是consumer deep import。
- Feature內absolute import不是cross-feature coupling。
- App直接依賴Dio是Composition Root／transport configuration責任，不等同package leak。
- App Feature adapter直接依賴`local_auth`／`flutter_secure_storage`是明確App-owned platform seam。
- Generated `injection.config.dart`引用plugin與Dio是generated Composition Root evidence，不是package annotation leakage。

## Focused Validation

```txt
auth package: 154 tests passed
api_client package: 55 tests passed
App DI／Router／Navigation: 22 tests passed
Package DI grep: no match
Production sqflite grep: no match
External deep-import grep: no match
```

## Whole-Task Review

- 沒有把style preference提升為finding。
- 沒有把同package `src` import誤判為public boundary violation。
- `F-A2-01`同時具備ADR contract、source、pubspec與tests evidence。
- Finding severity維持P2，因為邊界耦合有界且fresh regression通過；沒有證據支持P0／P1。
- 沒有修改ADR、source、tests、pubspec或current architecture claim。

## Task Disposition

```txt
Architecture areas reviewed: Composition Root, DI, Feature, Bloc, Guard, API, Auth, Drift, platform adapters, Failure／Reporting
Confirmed findings added: F-A2-01
Not-an-issue dispositions: 5
Open P0: 0
Open P1 without disposition: 0
Task A2: ACCEPTED
```
