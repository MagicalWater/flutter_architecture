---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-task-30-4-review-evidence
last_reviewed_baseline: 1.11.0
---

# Task 30-4 Review — Auth Test Rationalization

## Focused review findings

### F-30-4-01 — Auth integration仍依賴historical sqflite store

Severity：P1

Disposition：Resolved。`auth_single_active_user_persistence_test.dart`改用AppDatabase、AuthUserDao與DriftAuthUserStore。

### F-30-4-02 — Rewrite初版產生generated AuthUser名稱衝突

Severity：P1

Disposition：Resolved。App database import改用`db` alias，domain `AuthUser`維持清楚owner。

### F-30-4-03 — Rewrite使用不存在的token pair型別

Severity：P1

Disposition：Resolved。依current Auth API改用`StoredAuthTokens`，focused test重新通過。

### F-30-4-04 — 四個migration／schema cases與current owner重複

Severity：P1

Disposition：Resolved。移除舊integration file中的重複cases，replacement mapping記錄於`30-4_auth_rationalization.md`；historical migration與Drift adapter tests維持通過。

### F-30-4-05 — Inventory tool把自身誤算成test

Severity：P2

Disposition：Resolved。Generator由`test_inventory.py`改名`inventory.py`，只保留真正的`test_test_inventory.py`作governance test。

## Focused re-review

- Current integration不再import historical sqflite helpers或`sqflite_common_ffi`。
- Sequential login／restart與identity mismatch仍驗證secure credential、Drift user與runtime session整合。
- Drift adapter、historical migration與Auth package tests維持通過。
- 大型Auth files沒有因LOC被機械拆分。

## Whole-task holistic review

- Auth security、latest-intent、refresh、replay、cleanup、redaction與local unlockowner均保留。
- Reduced cases都有current／historical replacement owner。
- App仍是Composition Root；packages/auth沒有新增Drift dependency。

## Documentation authority check

- Auth architecture authority未改變。
- 本audit只保存test ownership與replacement evidence。
- Inventory CSV更新為current managed snapshot；起始baseline仍記錄於30-2 summary與本文件。

## Validation

```txt
flutter test auth_single_active_user_persistence_test.dart
→ 2 passed

melos auth + api_client tests
→ passed

App Auth／local unlock／Auth navigation focused suites
→ passed

python3 -m unittest tools.testing.test_test_inventory
→ 4 passed

python3 tools/testing/inventory.py
→ files=135 loc=22958 cases=769

dart run melos run docs_check
git diff --check
```

## Final disposition

```txt
Task 30-4: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Current Auth tests using historical sqflite fixture: 0 in rewritten integration target
Next Task: 30-5 Catalog Test Rationalization
```

