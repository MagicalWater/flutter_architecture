---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-task-30-5-review-evidence
last_reviewed_baseline: 1.11.0
---

# Task 30-5 Review — Catalog Test Rationalization

## Focused review findings

### F-30-5-01 — Repository與data-layer tests依賴historical sqflite DAO

Severity：P1

Disposition：Resolved。`catalog_repository_cache_test.dart`與`catalog_data_layer_test.dart`改用DriftCatalogCacheDao，所有focused cases通過。

### F-30-5-02 — Logout integration使用兩個historical stores

Severity：P1

Disposition：Resolved。AuthUser與Catalog cache同時切換至同一AppDatabase-owned Drift adapters，仍證明logout清除Auth但保留public Catalog cache。

### F-30-5-03 — Local boundary current behavior與historical migration混合

Severity：P1

Disposition：Partially resolved with explicit follow-up。一般behavior已切換Drift；三個v1～v4 historical migration cases保留並指定Task 30-9搬移，不在本Task誤刪oracle。

### F-30-5-04 — Drift import與Flutter matcher名稱衝突

Severity：P1

Disposition：Resolved。Drift import收窄為`Table`、`TableInfo`與`Variable`，不污染`isNull`／`isNotNull` matcher。

### F-30-5-05 — 關閉Drift database後read可能回null而非operational failure

Severity：P1

Disposition：Resolved。Operational mapping test改用明確`CatalogCacheDaoException` fake，直接驗證local boundary contract，不依賴executor關閉後的implementation-specific behavior。

## Focused re-review

- Catalog current data／repository／logout tests不再使用historical fixture。
- Local behavior由Drift執行，corruption、transaction與exception mapping維持通過。
- Historical migration oracle仍可執行且有明確後續owner。
- Bloc concurrency與Widget rendering未被錯誤合併。

## Whole-task holistic review

- Page、cursor、revision、cache policy、SWR、append、refresh、reconnect、corruption與logout invariants均保留。
- App仍為Composition Root，Domain／Bloc未依賴Drift。
- 沒有為減少重複建立generic Catalog test framework。

## Documentation authority check

- Catalog architecture與persistence authority未改變。
- 本audit保存test owner與historical move disposition。
- Inventory CSV更新current snapshot；起始baseline仍由30-2 summary保存。

## Validation

```txt
catalog_data_layer_test.dart
→ 12 passed

catalog_repository_cache_test.dart
→ 27 passed

catalog_local_data_source_test.dart
→ 25 passed

catalog_logout_persistence_test.dart
→ passed

flutter test test/features/catalog
→ 125 passed

python3 tools/testing/inventory.py
→ files=135 loc=22952 cases=769

python3 -m unittest tools.testing.test_test_inventory
dart run melos run docs_check
git diff --check
```

## Final disposition

```txt
Task 30-5: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Current Catalog tests using historical fixture: 0
Historical migration cases retained: 3, dispositioned for Task 30-9 move
Next Task: 30-6 Shared Fixtures and Focused Contract Extraction
```

