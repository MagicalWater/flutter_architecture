---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-39-task-39-3-critical-geometry-local-fidelity
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Task 39-3 Critical Geometry & Local Fidelity Review

## Scope

本Task新增兩個最小direct owners：

1. Flutter widget fixture證明source宣告尺寸可被parent constraint壓縮，critical geometry必須讀actual `RenderBox`。
2. Repository visual gate helper證明critical local failure可覆蓋whole-screen PASS，並鎖定ROI contract必須candidate前固定。

沒有修改Pencil proof production UI，也沒有建立every-node／every-icon／every-section tests。

## Test Authoring Decision

- Runtime geometry fixture：**Recommended**，因confirmed historical failure顯示source constant與actual geometry可不同，fixture成本低且直接證明contract。
- Local fidelity gate engine：**Required**，因新增`whole-screen PASS + critical local FAIL = overall FAIL` machine behavior，需要direct regression owner。
- Every-node geometry／golden：**Should-not-add**。

## Focused review

### F-39-3-01 — Geometry contract不得固定所有canonical x/y
- Severity：P1 single-renderer/responsive risk。
- Review：Reference允許size、inset、alignment、gap、proportion與container relationship；fixture只證明actual RenderBox ownership。
- Result：PASS。

### F-39-3-02 — Local gate不得取代whole-screen regression
- Severity：P1。
- Review：Gate採AND semantics；whole-screen failure仍blocking，local owner只補critical blind spot。
- Result：PASS。

### F-39-3-03 — ROI不得candidate-driven調整
- Severity：P1 anti-cheat。
- Review：`roi-diff` evidence若`contract_locked=false`即FAIL；reference要求candidate前固定region／projection／threshold。
- Result：PASS。

### F-39-3-04 — Test scope不得every-node化
- Severity：P1 test-cost regression。
- Review：只新增一個deterministic geometry fixture與一個small gate test module；沒有按Pencil node數量擴張。
- Result：PASS。

## Current disposition

```txt
Task: implementation complete / validation pending
Python fidelity/mapping tests: 14/14 PASS
Critical geometry Flutter fixture: PASS
Existing representation policy: 7/7 PASS
Existing single-renderer policy: 5/5 PASS
docs_check: PASS
git diff --check: PASS
Open P0: 0
Open P1 without disposition: 0
```

## Validation recovery note

第一次validation command錯把repository-root Python module tests放到`apps/flutter_architecture` working directory執行，導致`ModuleNotFoundError: tools`。此run記錄為invalid execution context，不作contract判斷；之後分別在repository root執行Python owners、在app root執行Flutter fixture，fresh results全部PASS。

## Whole-Task review

Task 39-3沒有修改Pencil proof production source；新增的Flutter test只作constraint-sensitive geometry contract fixture。Local gate helper仍要求whole-screen broad owner通過，並只讓critical local failure額外block overall acceptance。沒有canonical fixed-coordinate contract、沒有every-node test expansion、沒有candidate-driven ROI調整。
