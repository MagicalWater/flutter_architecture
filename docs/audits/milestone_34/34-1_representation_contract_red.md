---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-34-task-34-1-representation-contract-red
last_reviewed_baseline: 1.15.1
---

# Milestone 34 — Task 34-1 Representation Contract RED

## Scope

Task 34-1只建立mechanical RED與缺口證據，不修改任何Pencil-to-Flutter Skill production artifact、human Guide、ADR、`.pen`或Flutter source。

Baseline HEAD：

```txt
f880aac34843a0b18201a4d5b8bded35ca65532b
```

新增測試：

```txt
tools/docs/test_pencil_representation_mapping_policy.py
```

## RED Execution

Fresh command：

```powershell
python tools/docs/test_pencil_representation_mapping_policy.py
```

Observed result：

```txt
Ran 7 tests in 0.004s
FAILED (failures=7)
```

七個failure均來自Milestone 34 Design要求的representation contract尚不存在，而不是syntax、encoding、test import或path typo：

1. `asset-and-typography-mapping.md`尚不存在。
2. 缺少`representation classification` contract。
3. 缺少`Typography authority unresolved` fail-closed contract。
4. 缺少`approximate icon` visual-equivalence guard。
5. 缺少`derived transformation` provenance contract。
6. 缺少`raster-everything` shortcut guard。
7. 缺少`static CustomPainter` overbuild guard。

Missing reference由loader回傳明確`missing policy file`訊息；測試本身可正常載入與執行。

## Focused Review

- RED只觀察current baseline，沒有預先加入GREEN wording。
- Test assertions直接對應accepted Design acceptance criteria與Plan 34-1 interfaces。
- Missing reference不是Python import failure；因此GREEN時新增reference即可讓同一測試驗證contract。
- 測試沒有讀取或解析`.pen`。
- 測試沒有修改既有single-renderer contract。

Result：PASS。

## Whole-Task Review

Task 34-1已證明confirmed gap：現有route在Pencil extraction後仍可直接進Flutter mapping，沒有正式asset／vector／typography representation與provenance gate。這正是Task 34-2必須修正的行為缺口。

Task 34-1沒有引入第二個Skill、第二renderer、global asset registry或production workaround。

Open P0：0。

Open P1 without disposition：0。

## Validation

Task completion gate要求下列既有contract保持GREEN：

```powershell
python tools/docs/test_pencil_single_renderer_policy.py
dart run melos run docs_check
git diff --check
```

新的representation test在Task 34-1 completion時**必須保持預期RED**；若它意外PASS，代表沒有觀察到真正baseline gap，Task不得接受。

## Disposition

Task 34-1可在既有policy／docs validation保持GREEN、representation test保持上述7-failure RED後completion commit。下一Task 34-2才允許修改`implementing-pencil-flutter-design`與其references。

