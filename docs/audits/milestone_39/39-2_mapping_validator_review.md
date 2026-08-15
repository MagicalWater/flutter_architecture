---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-39-task-39-2-mapping-schema-validator-green
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Task 39-2 Mapping Schema & Validator GREEN Review

## Scope

Task 39-2把Task 39-1的machine RED轉為initiative-local critical mapping validator，不解析`.pen`、不建立global registry，也不修改Flutter production UI。

## Implementation ownership

```txt
tools/visual/pencil_implementation_mapping.py
→ machine validation runtime truth

asset-and-typography-mapping.md
→ critical mapping disposition / provenance decision rules

flutter-mapping.md
→ only consumes resolved, machine-valid critical mappings
```

Python module單一擁有schema semantics，因此本Task不額外建立重複的JSON Schema檔。

## Test Authoring Decision

**Required。** Validator新增非平凡failure classification，Task 39-1 fixture tests是direct regression owner。本Task只擴充valid mapping與authority-hash mismatch兩個必要contract，不依node數量增加tests。

## Focused review

### F-39-2-01 — Validator不得解析`.pen`
- Severity：P1。
- Review：Input只有`implementation_mapping.json`與可選accepted authority SHA；沒有`.pen` parser／regex／fallback。
- Result：PASS。

### F-39-2-02 — Disposition不得被名稱語意自動推導
- Severity：P1。
- Review：Validator只接受explicit enum；`verified-equivalent`必須有`evidence_ref`，不檢查或猜測glyph名稱等價。
- Result：PASS。

### F-39-2-03 — Intentional deviation不得由Agent自封
- Severity：P1。
- Review：`intentional-deviation`沒有`approval_ref`即machine FAIL。
- Result：PASS。

### F-39-2-04 — Asset provenance需fail closed
- Severity：P1。
- Review：Raster／Vector critical mapping要求source identity、derived transformation、destination與有效SHA-256 content hash。
- Result：PASS。

### F-39-2-05 — 不新增global registry或第二schema authority
- Severity：P2。
- Review：Validator module單一擁有schema semantics；不建立global asset database，也不重複新增JSON Schema檔。
- Result：PASS。

## Current disposition

```txt
Task: complete / accepted
Mapping validator tests: 10/10 PASS via python -m unittest
Open P0: 0
Open P1 without disposition: 0
```

## Recovery carried from Task 39-1

39-2第一次執行時使用舊的direct-script test command，暴露repository root不在script-mode import path。這不是validator logic failure；39-1已用fresh detached `a300601`與正確`python -m unittest ...`補證真正RED。Current GREEN同樣固定使用module-mode command，避免import-path假象。

## Whole-Task review

- Machine contract只處理initiative-local critical mapping evidence；沒有global registry。
- 六類representation保持Milestone 34既有authority；沒有all-icons-raster規則。
- `exact`不由validator透過icon名稱推導；equivalence／deviation都需要explicit evidence reference。
- Production acceptance會fail closed於`unresolved`。
- Asset provenance要求有效SHA-256與source／transformation／destination。
- Validator沒有Pencil／`.pen` dependency。
