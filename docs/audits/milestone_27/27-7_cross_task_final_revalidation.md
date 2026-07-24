---
document_type: final-review
status: completed
authoritative_for:
  - milestone-27-task-27-7-cross-task-final-revalidation
last_reviewed_baseline: 1.9.0
---

# Task 27-7 — Cross-task Final Revalidation

## Scope

在Task 27-6完成Firebase Console closure後，重新驗證Task 27-7 self-hosted CI能力沒有取代observability authority，且仍能安全承載manual remote acceptance。

## Findings closure

- `Observability Acceptance`仍只接受manual explicit gate；普通`main` push保持skipped。
- PR、fork PR與Dependabot程式碼不會進入`water`帳號self-hosted runner，也不會取得Environment secrets。
- Android／iOS secret materialization均有`always()` cleanup，持久workspace不依賴runner銷毀。
- Runner offline時job維持queued，不會自動fallback到付費GitHub-hosted runner。
- Task 27-6擁有provider acceptance與symbolication證據；Task 27-7只擁有execution mode、runner與routing能力。
- `manual-local`、`self-hosted`、`github-hosted`三種mode與`repository-default`sentinel語意仍互斥且fail closed。

## Disposition

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1: 0
```

Task 27-7在Task 27-6 closure後未出現authority、security、cost或routing regression。
