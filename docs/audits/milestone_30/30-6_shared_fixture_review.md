---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-30-task-30-6-shared-fixture-review
last_reviewed_baseline: 1.11.0
---

# Task 30-6 — Shared Fixtures and Focused Contract Extraction Review

## Reviewed duplication candidates

- `AppDatabase.forTesting(NativeDatabase.memory())` setup。
- Auth recording credential／legacy／user stores。
- Catalog page builders與fixed clock。
- Theme／Locale SharedPreferences setup。
- Widget pump helpers。
- Python workflow file loading與section extraction。

## Focused findings

### F-30-6-01 — AppDatabase helper節省行數但降低fixture可見性

Severity：P2

Disposition：No extraction。單行database construction直接表達current Drift path；抽成萬用helper會讓production／historical boundary較難從test file辨識。

### F-30-6-02 — Auth recording stores有相似外觀但failure controls不同

Severity：P2

Disposition：No generic extraction。Migration、Repository與Refresher各自需要不同operations、error與stack controls；共用萬用store會隱藏scenario語意。

### F-30-6-03 — Catalog builders已是局部且具domain語言

Severity：P2

Disposition：Keep local。`_page`、`_write`與fixed clock只服務單一owner file，未形成跨檔穩定contract。

### F-30-6-04 — Preference tests不應合併成generic storage contract

Severity：P1

Disposition：Rejected by design。Theme、Locale與local unlock的fallback、安全與diagnostic semantics不同；只共享framework mock能力，不抽取跨domain assertion。

## Accepted result

本Task沒有新增shared helper。這是刻意的YAGNI disposition，而不是未完成：

- Tasks 30-4／30-5已藉由切換正確owner消除最有害的implementation coupling。
- 剩餘重複多為簡短setup或domain-specific fake，不足以支持新的abstraction maintenance cost。
- Scenario名稱、fixture與assertion維持同檔，可直接理解failure原因。

未來只有當同一typed fixture在至少兩個owner files持續同步演進，且抽取後不隱藏domain language時，才可建立focused helper。

## Whole-task holistic review

- 沒有為追求LOC下降建立generic test framework。
- Production／historical boundary仍可從imports與setup直接辨識。
- Auth與Catalog大型files未因shared helper造成跨檔隱性coupling。
- Open P0：0。
- Open P1 without disposition：0。

## Documentation authority and validation

本文件保存「不抽取」的正式evidence，避免後續重複提出相同generic framework。執行：

```txt
python3 -m unittest tools.testing.test_test_inventory
dart run melos run docs_check
git diff --check
```

```txt
Task 30-6: ACCEPTED
Shared helpers added: 0
Next Task: 30-7 Platform, CI, Documentation and Generated Contract Audit
```

