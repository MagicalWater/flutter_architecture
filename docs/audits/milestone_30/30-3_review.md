---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-task-30-3-review-evidence
last_reviewed_baseline: 1.11.0
---

# Task 30-3 Review — Historical and Persistence Boundary

## Focused review findings

### F-30-3-01 — Current與historical tests同時存在但owner未明確

Severity：P1

Disposition：Resolved。Audit逐項分為historical oracle、historical implementation tooling、current-with-historical-fixture與policy assertion，並指定Task 30-4／30-5 replacement owner。

### F-30-3-02 — Catalog一般tests以historical DAO作current fixture

Severity：P1

Disposition：Accepted for rewrite。五個Catalog current data tests中四個直接使用historical DAO；Task 30-5改為Drift integration＋narrow fake分層，本Task不先大量重寫。

### F-30-3-03 — Auth integration仍使用historical AuthUser store

Severity：P1

Disposition：Accepted for rewrite。`auth_single_active_user_persistence_test.dart`保留business value，但Task 30-4切換current Drift owner。

### F-30-3-04 — Milestone 19.5 test看似失效

Severity：P2

Disposition：Resolved。確認正確working directory下7 tests passed，新增README標示historical manual tooling與正確命令。

## Focused re-review

- 沒有把sqflite名稱直接當成Delete條件。
- v1～v6 migration、rollback、fixture integrity與historical expected oracle全部Keep。
- Current Drift replacement tests已確認存在。
- Rewrite範圍與後續Task owner明確。

## Whole-task holistic review

- Production authority仍只有Drift。
- Historical harness未被削弱。
- 本Task只做boundary audit與tooling documentation，未提前進行大規模test cleanup。
- Auth／Catalog後續重構具清楚replacement gate。

## Documentation authority check

- Milestone 29 final review仍擁有Drift cutover完成證據。
- 本audit只擁有Milestone 30 test boundary disposition。
- Local tooling README只說明historical執行方式，不成為current Auth API authority。

## Validation

```txt
cd tools/milestone_19_5
python3 -m unittest test_auth_fixture_server.py
→ 7 passed

flutter test focused database／Drift persistence suites
python3 -m unittest tools.testing.test_test_inventory
dart run melos run docs_check
git diff --check
```

## Final disposition

```txt
Task 30-3: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Historical oracle deleted: 0
Next Task: 30-4 Auth Test Rationalization
```

