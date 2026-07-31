---
document_type: phase-review
status: accepted
authoritative_for:
  - r3-api-client-endpoint-boundary-review
last_reviewed_baseline: 1.14.0
---

# R3-1 — API Client Endpoint Boundary Review

## TDD Evidence

### RED

`auth_endpoint_boundary_test.dart`先建立，production types尚不存在時fresh失敗：

```txt
ApiEndpointException: type not found
DioAuthEndpoint: method not found
DioAuthRefreshEndpoint: method not found
```

Failure原因與Design預期一致，不是test syntax或fixture錯誤。

### GREEN

新增：

- `AuthEndpoint`／`AuthRefreshEndpoint`。
- `DioAuthEndpoint`／`DioAuthRefreshEndpoint`。
- `ApiEndpointException`。
- Internal Dio mapper與safe metadata extraction。

Boundary focused tests：4 passed。

## Focused Findings

### F-R3-1-01 — Existing Mock OTP tests仍期待DioException

- Severity：P1。
- Status：Resolved。
- Observation：Mock已正確改throw neutral envelope，但四個state-machine tests仍以Dio response matcher驗證。
- Fix：改為`ApiEndpointException.backendCode`與immutable `backendMetadata` matcher。
- Fresh re-review：invalid code、attempt exhaustion、expired、cooldown、predecessor invalidation案例全部保留。

### F-R3-1-02 — Mock backend helper保留無用途path參數

- Severity：P2。
- Status：Resolved。
- Fix：移除path參數與callsite，避免neutral mock假裝擁有transport request identity。
- Fresh re-review：status／backend code／metadata contract不變。

## Public Boundary Review

```txt
transport_failure_details public export: absent
neutral endpoint／adapter／exception exports: present
consumer interface signatures containing DioException: 0
MockAuthApi package:dio import: absent
```

`rethrowMappedTransportException(Object, StackTrace)`仍保留供App-owned Profile／Catalog DataSources使用；Dio-specific mapper與safe details改為api_client internal implementation。

## Scope Review

- Profile／Catalog source未修改。
- Interceptors與safe replay仍在api_client內使用Dio，符合transport ownership。
- Auth與App composition尚未修改，保留至R3-2／R3-3。
- 沒有新增generic framework、ADR、release或integration變更。

## Validation

```txt
New endpoint boundary tests: 4 passed
api_client full tests: 59 passed
api_client analyze: No issues found
Public API assertions: PASSED
git diff --check: required before commit
```

## Disposition

```txt
Focused review: PASSED after two findings
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
R3-2 allowed: YES after independent commit
```
