---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-30-auth-test-rationalization
last_reviewed_baseline: 1.11.0
---

# Task 30-4 — Auth Test Rationalization

## Auth invariant ownership

| Invariant | Primary owner | Secondary boundary |
|---|---|---|
| Credential authority resolution／legacy migration | `AuthCredentialMigrationCoordinator` | App store adapters |
| Login latest-intent／persistence compensation | `AuthRepositoryImpl` | Production persistence integration |
| Logout cleanup policy／diagnostics | Auth lifecycle cleanup policy | Repository integration只驗證session outcome |
| Refresh single-flight／rotation persistence-first | `AuthSessionRefresher` | API interceptor只驗證request coordination |
| Replay eligibility／safe payload preservation | `AuthRefreshInterceptor` | Session refresher result contract |
| Secure storage exception mapping／redaction | Flutter secure adapter | Repository不重做plugin matrix |
| Single-active public user persistence | Drift AuthUser adapter | End-to-end login／restart integration |
| Local unlock lifecycle | App coordinator／preference adapter | Widget只驗證呈現與actions |

## Implemented rationalization

`auth_single_active_user_persistence_test.dart`已從historical sqflite改為current Drift path：

```txt
AppDatabase.forTesting(NativeDatabase.memory())
→ AuthUserDao
→ DriftAuthUserStore
→ AuthRepositoryImpl
```

保留兩項真正跨boundary的integration coverage：

1. Sequential Login A→B後restart只restore User B。
2. Secure credential與Drift public user identity mismatch時清除兩者且不建立session。

## Reduced duplicate cases and replacement coverage

| Removed case | Replacement owner |
|---|---|
| Historical store sequential writes只保留最新user | `drift_auth_user_store_test.dart` current adapter replacement test |
| v4 single-row upgrade保留user | `drift_historical_migration_test.dart` v4 fixture migration matrix |
| v4 multi-row upgrade清除ambiguous users | Drift v4 historical fixture／migration report與Auth migration compatibility matrix |
| sqflite schema拒絕illegal slot／second row | Canonical Drift schema、fresh schema report與single-slot adapter integration |

這四項不是單純刪除，而是將owner移回current Drift adapter或historical migration harness。Historical sqflite adapter test仍保留作archive candidate，未在本Task刪除。

## Large Auth files disposition

本Task審查了四個主要大型檔案：

- `auth_credential_migration_coordinator_test.dart`
- `auth_repository_persistence_test.dart`
- `auth_session_refresher_test.dart`
- `auth_refresh_interceptor_test.dart`

結論：目前各檔雖大，但主要仍各自對應單一production class，且內部matrix具安全／concurrency價值。沒有足夠證據支持只為LOC拆檔；本階段維持Keep，僅在未來同檔需要新增第二種fixture lifecycle時再按責任拆分。

## Current inventory effect

Starting repository baseline：134 files／23,066 LOC／769 cases。

Task 30-2新增一個inventory tool unit test file與4 cases；Task 30-4移除4個重複Auth cases並大幅縮短錯綁historical implementation的integration file。Current managed inventory：

```txt
135 files
22,958 LOC
769 static cases
```

Case總數與起始baseline相同：Task 30-2新增4個governance tooling tests，Task 30-4移除4個重複Auth cases。Auth current integration由6 cases收斂為2 cases，replacement coverage另存於Drift／migration owners。

