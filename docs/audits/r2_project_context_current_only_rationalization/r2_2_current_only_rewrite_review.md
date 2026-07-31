---
document_type: phase-review
status: accepted
authoritative_for:
  - r2-project-context-current-only-rewrite-review
last_reviewed_baseline: 1.14.0
---

# R2-2 — Project Context Current-only Rewrite Review

## Scope

本Task依committed preservation matrix修改`docs/project_context.md`，移除chronology並保全current claims。

## Implementation Summary

- Current Baseline移除M19～M30與CI演進journal，只保留current identity及historical routing。
- 新增Connectivity and Offline State current capability。
- 新增Delivery and Verification current capability。
- Platform section明確保存iOS 15.0 current baseline。
- `Active Work`替換為`Current Work and Maintenance State`。
- Update Rule新增release chronology與runtime evidence count禁止規則。

## Focused Findings

### F-R2-2-01 — Connectivity current behavior原本只存在於Milestone chronology

- Severity：P1。
- Status：Resolved in Rewrite。
- Fix：新增typed connectivity authority、lifecycle recheck、offline banner、Catalog revalidation與backend reachability boundary。
- Fresh re-review：Current Capabilities可獨立讀取connectivity contract，不依賴M28 history。

### F-R2-2-02 — CI current contract需要與historical runtime evidence分離

- Severity：P1。
- Status：Resolved in Rewrite。
- Fix：新增Delivery and Verification，只保留change-aware、fail-safe、三模式、managed store、transport exception與deferred boundary；移除counts、manifest、Mac root與release SHA。
- Fresh re-review：CI guide仍是operator detail owner。

### F-R2-2-03 — Active state不可留下新的remediation journal入口

- Severity：P1。
- Status：Resolved in Rewrite。
- Fix：新section只保存Active=None、latest completed initiative route與Requirement Decision intake rule；明確禁止Task／commit／test／runtime journal。
- Fresh re-review：R1／R2 progress不寫入Project Context。

## Matrix Reconciliation

- P01～P03：current capability／ADR facts保留，history移除。
- P04～P11：current facts歸位至Platform、Capability、Security與Guide route。
- P12～P14：exact evidence與completed initiative journal移除。
- P15：deferred signing／Store／Branch Protection boundary保留於Security與Delivery。

## Validation

```txt
Milestone-prefixed paragraphs: 0
Release chronology matches: 0
Exact historical evidence matches: 0
Legacy Active Work section: 0
Current claim assertions: 23 / 23 passed
Documentation unit tests: 19 passed
docs_check: PASSED
git diff --check: PASSED
Post-rewrite lines: 421
Remaining `Milestone` word count: 6 — authority／routing usage only
```

## Disposition

```txt
Focused review: PASSED after three findings
Whole-document review: PASSED
Open P0: 0
Open P1 without disposition: 0
```
