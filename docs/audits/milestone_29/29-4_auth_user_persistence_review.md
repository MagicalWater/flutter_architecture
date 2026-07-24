---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-4-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-4 — AuthUser Persistence Migration Review

## Scope

新增App-owned `AuthUserDao`與`DriftAuthUserStore`，保持`packages/auth`的`AuthUserStore` contract、single-active-row invariant與typed local-storage failure mapping。Production DI尚未切換。

## Focused findings

### F-29-4-01 — Generated table type與domain entity同名

Severity：P1。

Disposition：Resolved。Adapter與tests對`package:auth`使用namespace，Drift generated `AuthUser`不會洩漏到domain／repository boundary。

### F-29-4-02 — Closed database不是可靠的SQLite operational failure fixture

Severity：P2。

Disposition：Resolved。Failure test改為先建立schema再drop `auth_user`，讓DAO query產生真實`SqliteException`，並驗證映射為`AppExceptionKind.localStorage`且保留cause／stack。

## Architecture review

- DAO只提供`readActive`、`replaceActive`、`clearActive`三個one-shot operation。
- slot 1由DAO集中擁有。
- Adapter只映射generated row到`auth.AuthUser`。
- `packages/auth`沒有新增Drift／sqlite3 dependency。
- 沒有加入reactive stream。
- `SqfliteAuthUserStore`與production DI暫時保留，等待Task 29-8 single-owner cutover；本Task不發布雙軌production baseline。

## Behavior review

- Empty read回傳null。
- Sequential writes只保留最新active user。
- clear具idempotent semantics。
- SQLite operational failure映射為typed local storage exception。
- Schema check與historical malformed disposition由Task 29-2／29-3 coverage維持。

## Documentation and authority

- `AuthUserStore` package abstraction仍是business authority。
- `DriftAuthUserStore`是accepted target adapter。
- `SqfliteAuthUserStore`仍是current production binding直到Task 29-8。

## Validation

```text
flutter test test/features/auth/data/stores/drift_auth_user_store_test.dart
flutter test test/features/auth/data/auth_single_active_user_persistence_test.dart
flutter test test/features/auth/data/local_unlock/local_unlock_lifecycle_integration_test.dart
flutter test test/app/navigation/auth_navigation_app_integration_test.dart
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

## Final disposition

```text
Task 29-4: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Production DI switched: NO
Next Task: 29-5 Catalog Offline Cache Migration
```
