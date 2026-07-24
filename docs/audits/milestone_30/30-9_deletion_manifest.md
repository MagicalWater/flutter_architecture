---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-controlled-cleanup-manifest
last_reviewed_baseline: 1.11.0
---

# Task 30-9 — Controlled Cleanup and Deletion Manifest

## Executed changes

| Previous coverage | Action | Reason | Replacement owner | Validation |
|---|---|---|---|---|
| Auth integration內4個sqflite schema／migration cases | Delete duplicate cases | 已由Drift adapter與historical migration suites擁有 | `drift_auth_user_store_test.dart`、`drift_historical_migration_test.dart` | Auth focused/full suites passed |
| Catalog current data tests使用historical DAO | Rewrite fixture | current behavior必須驗證production Drift path | `DriftCatalogCacheDao` based tests | Catalog 125 passed |
| Catalog local boundary內3個historical migration cases | Move | current behavior與historical oracle分離 | `test/app/database/historical_catalog_migration_contract_test.dart` | moved 3 cases + current local 22 cases passed |

## Explicitly retained

- v1～v6 historical fixtures、Drift migration與rollback suites。
- Auth security、refresh、cleanup、identity、redaction與local unlock cases。
- Catalog cache policy、cursor、revision、concurrency、Bloc與Widget cases。
- CI、platform、generated、docs與classifier contracts。

## Inventory result

Cleanup後為136 files／22,943 LOC／769 static cases；新增historical owner file取代原檔內位置，沒有coverage loss。檔案數因governance tooling與owner split增加，不以檔案數下降作為成功標準。
