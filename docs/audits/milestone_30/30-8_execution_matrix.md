---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-test-execution-matrix
last_reviewed_baseline: 1.11.0
---

# Task 30-8 — Test Execution Matrix and Cost Audit

## Measured runtime

| Suite | Run 1 | Run 2 | Current disposition |
|---|---:|---:|---|
| All Flutter package tests | 21.81s | 19.11s | Tier 1／2，維持相關CI執行 |
| CI Python contracts（88） | 0.34s | 0.34s | Tier 1，維持quality gate |
| Documentation checker tests（15） | 0.07s | 0.07s | Tier 1，維持quality gate |

Flutter elapsed包含Melos並行啟動時的Flutter startup lock等待；所有測試仍通過。現有成本不足以支持刪除deterministic tests或建立複雜sharding。

## Execution tiers

| Tier | Owner／examples | Routing |
|---|---|---|
| Tier 1 | Python CI contracts、docs checker、inventory tooling、一般unit tests | 每次相關quality gate |
| Tier 2 | App／package Flutter regression、Auth／Catalog／Database integration | source／package／database相關變更 |
| Tier 3 | generated consistency、Drift schema export、Web worker／Wasm governance | generated／database-critical變更與完整驗證 |
| Tier 4 | Android／iOS scaffold與native build contracts | 對應native、dependency、environment與manual/full matrix |
| Tier 5 | physical device、remote hosted CI、post-release acceptance | release或明確人工驗證 |

## Classifier and fail-safe review

現有classifier已由24個tests覆蓋docs-only、Dart source、package、dependency、Android、iOS、Drift schema／DAO／snapshot／Web asset／tooling、classifier self-change、unknown path、invalid range與missing object。

Database-critical變更會提升至full CI及雙平台build路由；unknown path與invalid range採fail-safe full matrix。Task 30-7已確認workflow wiring failure亦會fallback至full matrix。

## Decision

- 不修改`.github/workflows`或`change_classifier.py`。
- 不把deterministic tests移出CI。
- 不新增shard、nightly-only或抽樣策略。
- 不以約20秒的本地Flutter regression成本交換coverage hole或routing複雜度。
