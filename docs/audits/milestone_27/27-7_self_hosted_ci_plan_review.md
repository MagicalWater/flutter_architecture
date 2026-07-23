---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-27-task-27-7-self-hosted-ci-plan-review
last_reviewed_baseline: 1.8.0
---

# Task 27-7 — Self-hosted CI Implementation Plan Review

## Review scope

本Review審查：

```txt
docs/superpowers/plans/2026-07-24-self-hosted-ci-execution-mode.md
```

審查重點為Spec coverage、Task順序、TDD步驟、workflow routing可實作性、runner安裝安全、runtime acceptance、current authority同步、Task-level review／commit gate與holistic closure。

本Review不代表任何workflow、runner、repository variable或runtime狀態已改變。

## Decision

```txt
Disposition: ACCEPTED
Task: Task 27-7 Implementation Plan
Open P0: 0
Open P1: 0
```

Plan在修正findings後，已可作為Task-by-Task implementation authority。Implementation不得跳過Plan內任一review或runtime gate。

## Findings and disposition

| Finding | Severity | Disposition |
|---|---|---|
| Manual `choice`缺少沿用repository variable的可靠語意 | P1 | 回補Spec與Plan，加入`repository-default` sentinel；正式mode仍只有三種 |
| Mode validation module若未與workflow literals互相檢查，會形成假的single source | P1 | 明定module只作validation contract，static tests必須解析四份workflow並比對mode集合 |
| Plan原本沒有可直接落地的job `if`／`runs-on`語意 | P1 | 補上self-hosted event expression、GitHub-hosted對稱條件與完整label array範例 |
| ADR-023與active roadmap原本排在實作後才同步 | P1 | 新增Task 1 activation gate，先更新durable Decision與current Task，再改workflow |
| 原Plan只有最後closure commit，不符合每個Task完整循環 | P1 | Task 1～7全部加入focused review、whole-task review、驗證與commit gate；Task 8再做跨Task holistic closure |
| Runner registration token可能被寫入文件或history | P1 | 安裝Task固定不記錄token，只保存runner name、labels、status與非敏感service evidence |
| Observability可能被一般main push或concurrency自動中斷 | P1 | Static contract固定manual explicit acceptance，且Observability禁止自動`cancel-in-progress` |
| GitHub-hosted mode在額度已滿時不應為了驗收實際啟動 | P1 | Runtime Task只做static validation，不執行付費hosted job |
| Task 27-6與27-7 closure可能再次混淆 | P1 | Activation與closure都明確分開：27-7完成runner能力，27-6繼續擁有iOS Firebase Console symbolication判定 |

所有P1均已在Plan中轉成精確Task、命令、expected result或review gate。

## Task flow review

核准的Task順序：

```txt
Task 1  ADR與active Task同步
Task 2  Mode contract與命名遷移
Task 3  Workflow routing
Task 4  Persistent workspace secret cleanup
Task 5  Mac runner註冊與service
Task 6  Runtime routing acceptance
Task 7  Operations／current authority／Task 27-6同步
Task 8  Full regression與holistic closure
```

此順序確保架構authority先於implementation，runtime evidence先於current completion claim，並且每個Task可獨立review與commit。

## Security review

Plan沒有把self-hosted runner描述成sandbox。已固定：

- 使用`water`帳號。
- Repository-scoped runner。
- 專用runner directory與`_work`。
- 完整labels。
- 只接受可信main push與manual dispatch。
- PR、fork與Dependabot不得執行。
- Materialized secrets以`always()` cleanup。
- Runner offline不自動fallback到付費runner。

## Test and runtime review

Static tests覆蓋：

- 三種正式mode與legacy `local`拒絕。
- `repository-default` sentinel。
- Event／mode矩陣。
- Self-hosted完整labels。
- Stable job names。
- Observability manual gate與concurrency。
- Secret cleanup與shell safety。

Runtime acceptance覆蓋：

- `manual-local`零runner。
- Manual self-hosted smoke。
- Main push自動派送。
- PR不派送。
- Runner offline queued且不fallback。
- Observability不因main push自動執行。

## Documentation governance review

- Plan使用`implementation-plan`，不宣稱current state。
- ADR-023擁有durable CI architecture。
- `docs/roadmap/active.md`擁有current Task。
- Operations guide擁有操作方式。
- Runtime evidence擁有觀察結果。
- Implementation review擁有findings與closure判定。
- Task 27-6 review只保存observability evidence，不被27-7 review取代。

## Whole-plan holistic review

第二輪逐段比對accepted Spec後，確認以下需求均有對應Task：

```txt
三模式與manual sentinel
trusted event boundary
repository-scoped labels
water帳號風險
background service
single Mac serialization
offline queue
secret cleanup
artifact成本
ADR ownership
Branch Protection提醒
runtime acceptance
Task 27-6 handoff
文件治理與holistic closure
```

沒有保留占位字樣或「實作時再決定」形式的blocking requirement。Runner版本與registration token刻意在執行當下依GitHub官方頁面取得，這是時效與secret要求，不是未決設計。

## Validation evidence

```txt
placeholder scan
spec-to-plan coverage review
dart run melos run docs_check
git diff --check
```

Plan Task只修改文件，不要求Flutter regression或platform build。

## Gate

Plan Task正式通過。下一步可以進入：

```txt
Task 27-7 Task 1 — Task activation與ADR authority同步
```

Implementation必須逐Task執行、review、commit，不得再次把文件同步與holistic review延後到push之後。

