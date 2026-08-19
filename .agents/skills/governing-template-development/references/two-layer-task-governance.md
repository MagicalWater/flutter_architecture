# 雙層 Task 治理

## 模式

### Minimal — Level 0

```txt
change → diff review → focused validation → authority check → commit
```

### Simplified — Level 1

```txt
reproduce／confirm → focused fix／必要temporary RED → focused validation
→ review → findings/fix if any → authority check → commit
```

### Standard — Level 2

使用brief behavioral/design decision、implementation與一次final review。不得要求每個implementation unit建立獨立audit artifact或independent commit。Validation只覆蓋changed risk與critical owners。

Test Authoring與Task數量沒有一對一關係。**TDD test lifecycle不等於permanent portfolio**；temporary RED在GREEN後必須做Retention Decision，普通test預設在closure前刪除。

### Cross-cutting — Level 3

Design與Plan可各自review一次；implementation完成後做一次whole-scope holistic review：

```txt
Design / Plan accepted
→ implementation
→ relevant focused checks during work
→ whole-scope holistic review
→ documentation authority check
→ required validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ commit
```

Design／Plan approval gates仍存在，但不要求為每個implementation subtask重複formal evidence chain。

### Formal Critical — Level 4～5

只有真正repository-wide stable architecture、security、irreversible migration、platform／release infrastructure等高風險工作使用formal evidence。即使Level 4～5，也以risk boundary為artifact單位，不以subtask數量機械建立audit files。

## 自動繼續

Task 通過後直接進入下一個 Task。不得因一般 findings、failed tests、implementation defects 或 stale documents 停下；必須修正並重跑 gate。

只有使用者擁有的 scope／architecture decision、external／manual blocker、推翻 approved artifacts 的 P0／P1 finding，或完整 Milestone closure 才停止。

## Milestone closure

```txt
holistic review
→ cross-Task consistency
→ architecture 與 authority review
→ runtime／remote evidence
→ explicit release candidate時才fresh full logical regression
→ findings 與 fixes
→ holistic re-review
→ VERSION／CHANGELOG／roadmap／current authority sync
→ release 與 archive decision
→ commit 與 push
→ post-release identity／artifact verification；same SHA不重跑相同full source regression
→ formal closure
```

最後一個 implementation Task 通過，不代表 Milestone 已完成。Open P0 必須為零，且每個 P1 都必須有 disposition。

## 接受與 commit gate

只有全部必要 validation 通過後，Task 才能以 completion semantics commit。失敗的 Task 必須維持 open，或明確標記為 blocked／rejected。後續 Task 可以修復，但必須記錄 recovery，不能回寫早期 gate 為已通過。

Design 與 Plan 在完成完整 Task cycle 並取得使用者明確核准前，都維持 `proposed`。不得從 proposed Plan 開始 implementation。

## Evidence chain

Formal evidence只記錄decision scope、material findings／fixes、authority check、exact relevant validation與final disposition。沒有material finding時不要求建立空白re-review artifact；subtask不要求independent commit。

若Task新增或修改test，closure evidence記錄Retention Decision。`0 permanent tests`與`0 automated tests`都可以合法，只要changed risk已由最低充分validation／runtime acceptance覆蓋且沒有缺失critical owner。

## Critical additions — Level 5

依適用範圍要求 rollback／recovery、compatibility matrix、migration fixtures、failure injection、platform artifacts 與明確的 deferred scope。
