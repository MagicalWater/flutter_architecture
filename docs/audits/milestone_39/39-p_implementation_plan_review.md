---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-39-implementation-plan-review
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Implementation Plan Review

## Review target

`docs/superpowers/plans/2026-08-15-milestone-39-pencil-flutter-fidelity-enforcement-recovery.md`

## Focused findings

### F-39-P-01 — Plan不得先改Skill再補RED
- Severity：P1。
- Review：Task 39-1先鎖machine contract RED；Task 39-2才實作schema/checker。
- Result：PASS。

### F-39-P-02 — Mapping checker不得解析`.pen`
- Severity：P1 authority/tool boundary。
- Review：Plan只驗Pencil MCP extraction後的implementation mapping evidence；native `.pen` parse仍禁止。
- Result：PASS。

### F-39-P-03 — Geometry tests不得every-node化
- Severity：P1 test-cost regression。
- Review：Task 39-3只建立constraint-sensitive critical owner，普通geometry可`no-new-test justified`。
- Result：PASS。

### F-39-P-04 — Local visual gate不得取代whole-screen
- Severity：P1 regression coverage。
- Review：Task 39-3明確保留whole-screen broad owner，local gate只對critical failure override。
- Result：PASS。

### F-39-P-05 — Recovery必須阻止錯素材pixel tuning
- Severity：P1 confirmed failure mode。
- Review：Task 39-4固定invalid mapping → stop tuning → return classification/provenance → fresh validation。
- Result：PASS。

### F-39-P-06 — Behavioral evidence不得由本對話自審替代
- Severity：P1 Skill effectiveness。
- Review：Task 39-5要求fresh independent context；無harness時fail closed。
- Result：PASS。

### F-39-P-07 — 不建立第二Skill／第二ADR／global registry
- Severity：P1 authority fragmentation。
- Review：Plan只amend ADR-028、補強existing Skill、initiative-local mapping；沒有第二domain owner。
- Result：PASS。

### F-39-P-08 — Proof adoption不得重做既有UI
- Severity：P2 scope creep。
- Review：Task 39-6只為既有proof補最小critical mapping evidence與validator acceptance，禁止無必要production rewrite。
- Result：PASS。

## Whole-Plan coverage

| Design acceptance | Plan owner |
|---|---|
| critical mapping machine contract | 39-1 / 39-2 |
| exact/equivalent/deviation/unresolved | 39-2 |
| runtime RenderBox geometry | 39-3 |
| local fidelity overrides global PASS | 39-3 |
| wrong-representation recovery | 39-4 |
| fresh Agent behavior | 39-5 |
| ADR/Guide/proof authority sync | 39-6 |
| holistic/full/release/post-release | 39-7 |

## Test-cost review

Plan沒有把critical inventory轉成test-count quota：

- every-node test：禁止。
- every-icon golden：禁止。
- every-section visual test：禁止。
- machine checker：Required direct owner。
- geometry/local fidelity fixtures：只為confirmed deterministic failure mode建立最小owner。
- behavioral pressure：驗Skill behavior，不當Flutter runtime test數量。

Result：PASS。

## Current disposition

```txt
Open P0: 0
Open P1 without disposition: 0
Plan status: accepted
User approval: accepted on 2026-08-15
Implementation: Task 39-1 may start under Full two-layer governance
```

## Required validation before approval request

- `dart run melos run docs_check`
- existing Pencil representation policy tests
- existing Pencil single-renderer policy tests
- `git diff --check`
- fresh status／roadmap／Design→Plan authority consistency review

