---
document_type: phase-review
status: active
authoritative_for:
  - milestone-36-task-36-6-reference-feature-test-density-review
last_reviewed_baseline: 1.16.0
---

# Task 36-6 — Reference Feature Test Density Audit

## Scope

Read-only-first審查Auth／Catalog／Profile的current README、tests與Milestone 30 ownership evidence，確認高密度tests是否來自實際risk owners，以及這些Feature是否會被新Feature機械模仿為test-density quota。

## Findings

### Auth

Auth的高密度coverage主要對應credential persistence、OTP、session restore／expiration、refresh single-flight、security、local unlock lifecycle、navigation coordination、sensitive output與migration compatibility。

這些是Template／Foundation級failure owners。沒有證據支持「一般Product Feature應複製Auth test file數／layer分布」。

Disposition：保留existing coverage；README補充reference-role警語。

### Catalog

Catalog的高密度coverage主要對應cursor pagination、SWR、cache chain、revision CAS、cycle guard、reconnect ordering、dedupe、generation protection與SQLite coordination。

Milestone 30已確認其大型Bloc／Repository／DAO suites各自有不同failure-source ownership；不能只因LOC大就判為duplicate。

Disposition：保留existing coverage；README補充risk-driven density說明。

### Profile

Profile表面上是簡單read Feature，但existing coverage除happy path外還擁有session expiration、stale old response、account-switch race、failure mapping、localized UI與responsive presentation等observable contracts。

其中stale async／account-switch cases具明確regression value；但其存在不代表所有簡單read Feature都需要Data／Bloc／Widget逐層建立同樣數量tests。

Disposition：保留existing coverage；README明確禁止以Profile test數作quota。

## Duplicate / trivial deletion disposition

本Task沒有發現足以在accepted scope內直接啟動deletion manifest的P1 evidence。部分mapping／presentation tests可被視為低風險，但目前沒有證據證明它們與另一primary owner完全重複且可安全刪除。

因此：

```txt
Existing test deletion: NO
Bulk rationalization: NO
New Requirement Decision required: NO
```

若未來要刪除existing tests，仍須依Testing Governance保存replacement owner與deletion evidence；不得用本Milestone的「避免未來over-authoring」反向推導「existing tests應大量刪除」。

## Whole-Task review

- Auth／Catalog／Profile local contract沒有被改成中央test policy。
- 三個README只說明自身density provenance與non-quota role。
- Canonical authoring decision仍由`governing-template-development/references/test-authoring.md`與ADR-029擁有。
- 沒有刪除tests、assertions或降低security／migration／concurrency coverage。

## Disposition

```txt
Task 36-6: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Reference features remain valid: YES
Reference features as test-density quota: NO
Existing tests deleted: 0
Next Task allowed: YES — proceed to Task 36-7
```
