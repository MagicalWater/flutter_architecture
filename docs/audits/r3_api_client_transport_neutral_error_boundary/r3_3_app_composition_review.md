---
document_type: phase-review
status: accepted
authoritative_for:
  - r3-app-composition-review
last_reviewed_baseline: 1.14.0
---

# R3-3 — App Composition and Generated DI Review

## TDD Evidence

### RED

Selector／DI tests先要求：

- Mock graph resolve `AuthEndpoint`／`AuthRefreshEndpoint`。
- Real graph使用`DioAuthEndpoint`／`DioAuthRefreshEndpoint`。
- GetIt可resolve兩個endpoint與Auth DataSources。

Production source尚未修改時compile RED，錯誤精確指出Selector／RegisterModule仍回傳`AuthApi`／`AuthRefreshApi`。

### GREEN

- Selector real path建立Retrofit declarations後包裝Dio adapters。
- RegisterModule只註冊consumer endpoint interfaces。
- Auth DataSources由endpoint interface注入。
- `injection.config.dart`由build_runner重新產生。

## Focused Findings

### F-R3-3-01 — App persistence fake仍使用AuthApi

- Severity：P1。
- Status：Resolved。
- Observation：DI focused tests通過後，App analyze發現single-active-user persistence test fake仍宣告`AuthApi`。
- Fix：helper與fake改為`AuthEndpoint`，behavior不變。
- Fresh re-review：該測試兩個single-active-user cases與DI四個cases全部通過。

### F-R3-3-02 — build_runner造成無關generated checkout狀態

- Severity：P2。
- Status：Resolved。
- Observation：Router與兩個Bloc generated files顯示modified，但content diff為0，屬line-ending checkout副作用。
- Fix：只還原三個無content diff files；保留`injection.config.dart`的endpoint registration實質變更。
- Fresh re-review：working diff只含六個R3-3 files。

## Composition Review

- App仍是唯一DI Composition Root。
- `api_client`與`auth`沒有GetIt／Injectable annotation。
- Retrofit declarations只在App Selector的Real branch建立。
- Mock與Real都以同一endpoint interface注入Auth。
- Profile／Catalog composition未修改。

## Validation

```txt
Selector／DI／single-active-user focused tests: 6 passed
App analyze: No issues found
build_runner: SUCCESS in api_client, auth and app
Generated DI: source-derived endpoint registration present
Unrelated generated content changes: 0 after restore
git diff --check: required before commit
```

## Disposition

```txt
Focused review: PASSED after two findings
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
R3-4 allowed: YES after independent commit
```
