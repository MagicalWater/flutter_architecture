---
document_type: phase-review
status: active
authoritative_for:
  - milestone-27-task-27-7-self-hosted-ci-implementation-review
last_reviewed_baseline: 1.8.0
---

# Task 27-7 — Self-hosted CI Implementation Review

## Review state

Task 27-7 implementation進行中。本文件累積各小Task的focused review、findings disposition與最後holistic closure；在Task 8通過前不得視為final review。

## Task 2 — Execution Mode Contract and Naming Migration

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1: 0
```

### Focused review

- 合法runtime mode固定為`manual-local`、`self-hosted`、`github-hosted`。
- `repository-default`只作為manual override sentinel，不屬runtime mode。
- Legacy `local`、空值與未知值均fail closed。
- Resolver是純validation contract，不讀取GitHub context，也不修改repository variable。
- `run_local_ci.sh`明確標示自己是`manual-local`入口，suite contract沒有漂移。

### Finding

本機tooling仍使用Python 3.9，初版`str | None`型別語法在import時失敗。已改用`typing.Optional`，維持現有Python基線；focused tests重新執行後全部通過。

### Whole-task review

Task 2只建立mode validation與命名契約，沒有提前修改workflow routing。Runtime mode集合、manual sentinel與本機入口責任互斥，未發現新的P0／P1。
