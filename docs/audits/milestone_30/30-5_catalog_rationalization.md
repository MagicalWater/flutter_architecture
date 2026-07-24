---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-30-catalog-test-rationalization
last_reviewed_baseline: 1.11.0
---

# Task 30-5 — Catalog Test Rationalization

## Catalog invariant ownership

| Invariant | Primary owner | Secondary boundary |
|---|---|---|
| SQL transaction、cascade、replacement atomicity | Drift DAO／local data source integration | Historical migration harness |
| Cache identity、corruption cleanup、chain persistence | Catalog local data source | Repository只消費typed outcome |
| Fresh／stale／retain、fallback、emission ordering | Catalog repository | Bloc只驗證state orchestration |
| Debounce、generation、append／refresh／reconnect cancellation | Catalog Bloc | Widget只驗證可見state與actions |
| Loading、empty、cached notice、append／background failure rendering | Catalog widget | Bloc state contract |
| Logout保留public cache | App composition integration | Auth cleanup與Catalog persistence各自保留owner |

## Implemented production-path correction

以下current Catalog tests已從historical sqflite fixture切換至production Drift path：

- `catalog_data_layer_test.dart`
- `catalog_repository_cache_test.dart`
- `catalog_logout_persistence_test.dart`
- `catalog_local_data_source_test.dart`的一般local behavior區段

共同current setup：

```txt
AppDatabase.forTesting(NativeDatabase.memory())
→ DriftCatalogCacheDao
→ CatalogLocalDataSource
```

Logout integration同時使用：

```txt
AuthUserDao → DriftAuthUserStore
CatalogCacheDao → CatalogLocalDataSource
```

因此一般feature behavior不再依賴已退出production的sqflite AuthUser／Catalog adapter。

## Historical cases retained

`catalog_local_data_source_test.dart`底部仍保留三個明確historical migration cases：

1. v1→current保留AuthUser並建立Catalog tables。
2. v2→v3將item position index升級為unique。
3. v3→v4保留page並加入chain revision。

這些cases不是current local behavior fixture，而是舊sqflite migration oracle。Task 30-9將它們搬移至database historical owner並加入deletion／move manifest；本Task不在切換current path時同時刪除或改寫oracle。

## Large-file disposition

- `catalog_bloc_test.dart`雖為1,170 LOC，但主要仍集中於同一Bloc的initial、append、refresh與reconnect concurrency contract。現階段不只為LOC拆檔。
- `catalog_repository_cache_test.dart`維持Repository cache policy owner；切換Drift後27 cases全部通過。
- `catalog_local_data_source_test.dart`目前仍混合current local behavior與3個historical migration cases，已列入Task 30-9搬移。
- `catalog_view_test.dart`只驗證rendering／interaction，不因與Bloc使用相似state名稱而視為重複。

## Current inventory effect

```txt
135 files
22,952 LOC
769 static cases
```

本Task沒有刪除Catalog cases；LOC微幅下降來自移除historical database setup與adapter imports。成功標準是production path與coverage owner正確，而不是case數下降。

