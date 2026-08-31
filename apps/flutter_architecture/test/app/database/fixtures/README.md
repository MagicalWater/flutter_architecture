---
document_type: guide
status: active
authoritative_for:
  - historical-database-fixtures
last_reviewed_baseline: 1.27.0
---

# Historical SQLite Fixtures

此目錄保存 v1～v6 historical SQLite資料庫。Fixtures由既有sqflite historical contract生成，不能由Drift current schema反向產生。

## Fixture matrix

| Fixture | 主要情境 |
|---|---|
| `v1.db` | 舊AuthUser schema，兩筆malformed identity，升級後必須清空 |
| `v2.db` | 單筆AuthUser、非unique position index、重複position與orphan item |
| `v3.db` | unique position index已生效 |
| `v4.db` | `chain_revision`、兩頁cursor cycle sentinel |
| `v5.db` | single-slot AuthUser、current Catalog schema、legacy orphan item |
| `v6.db` | current clean schema與sentinel data |

Canonical authority是正規化schema report與migration assertions，不是SQLite檔案的byte hash。SQLite內部page layout可能在等價重建後不同。

重新生成：

```bash
cd apps/flutter_architecture
dart run test/app/database/support/generate_legacy_fixtures.dart
```
