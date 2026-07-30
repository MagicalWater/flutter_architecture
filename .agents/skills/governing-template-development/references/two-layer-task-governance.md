# 雙層 Task 治理

## 模式

### Minimal — Level 0

```txt
change → diff review → focused validation → authority check → commit
```

### Simplified — Level 1

```txt
reproduce／confirm → 使用 TDD 或 focused fix 實作 → focused review
→ findings → fix → re-review → affected validation → authority check → commit
```

### Standard — Level 2

Design、Plan 與每個 implementation unit 都使用完整 formal Task cycle。Feature regression 必須執行；full workspace regression 是否需要，依受影響 boundary 決定。

### Full — Level 3～4

每個 Design Spec、Implementation Plan 與 implementation unit 都是 formal Task：

```txt
create／implement
→ focused review
→ findings
→ fix
→ focused re-review
→ whole-Task holistic review
→ documentation authority check
→ required validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ next Task
```

Design 必須先通過，才可建立 Plan。Plan 必須先通過，才可 implementation。

## 自動繼續

Task 通過後直接進入下一個 Task。不得因一般 findings、failed tests、implementation defects 或 stale documents 停下；必須修正並重跑 gate。

只有使用者擁有的 scope／architecture decision、external／manual blocker、推翻 approved artifacts 的 P0／P1 finding，或完整 Milestone closure 才停止。

## Milestone closure

```txt
holistic review
→ cross-Task consistency
→ architecture 與 authority review
→ runtime／remote evidence
→ full regression
→ findings 與 fixes
→ holistic re-review
→ VERSION／CHANGELOG／roadmap／current authority sync
→ release 與 archive decision
→ commit 與 push
→ clean-checkout／post-release validation
→ formal closure
```

最後一個 implementation Task 通過，不代表 Milestone 已完成。Open P0 必須為零，且每個 P1 都必須有 disposition。

## 接受與 commit gate

只有全部必要 validation 通過後，Task 才能以 completion semantics commit。失敗的 Task 必須維持 open，或明確標記為 blocked／rejected。後續 Task 可以修復，但必須記錄 recovery，不能回寫早期 gate 為已通過。

Design 與 Plan 在完成完整 Task cycle 並取得使用者明確核准前，都維持 `proposed`。不得從 proposed Plan 開始 implementation。

## Evidence chain

每個 formal Task 都要記錄 Task ID、artifact scope、focused findings、fixes、fresh re-review、whole-Task coverage、authority check、exact validation 與 independent commit。只標記 `Resolved`，但沒有 fix 與 re-review evidence，不足以通過。

## Critical additions — Level 5

依適用範圍要求 rollback／recovery、compatibility matrix、migration fixtures、failure injection、platform artifacts 與明確的 deferred scope。
