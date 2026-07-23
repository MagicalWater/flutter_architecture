---
document_type: planning-review
status: accepted
authoritative_for:
  - change-aware-ci-plan-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Implementation Plan Review

## Preconditions

- Design spec formal review已通過：`change_aware_ci_spec_review.md`。
- 本review在spec通過後才開始，未將人工核准或plan self-review視為formal gate。

## First Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-PR01 | P1 | Task 2仍計畫將Generated Consistency與Tests整個job skipped，再新增不同名稱Gate；無法保持既有required check | 改為原job永遠建立、重量steps條件執行、同job no-op成功，不新增替代Gate |
| CA-CI-PR02 | P1 | Task 4將`iOS / Simulator Build`整個job skipped並以Summary替代，與spec的required-check closure衝突 | 改為Simulator job永遠建立，docs-only使用Ubuntu dynamic runner與同名no-op；Production Release維持可skipped |
| CA-CI-PR03 | P1 | Task 1測試清單未明確覆蓋classifier自身／classification wiring變更強制全矩陣 | 增加classifier自身變更case，要求Android／iOS均為true |
| CA-CI-PR04 | P1 | Remote docs-only acceptance把iOS workflow描述成classification／summary，未驗證原stable Simulator check成功存在 | 改為驗證同名Simulator job在Ubuntu no-op成功、Production skipped且無macOS runner |
| CA-CI-PR05 | P2 | Task 5要求在implementation階段才把spec改accepted，與formal review lifecycle順序顛倒 | spec與plan在implementation前即由formal review接受；Task 5只同步implementation current state |
| CA-CI-PR06 | P2 | 原plan的implementation review檔名過於泛化，容易與spec／plan formal review混淆 | 改為`change_aware_ci_implementation_review.md`，spec與plan各自有獨立review artifact |

## Re-review

修正後逐Task重新檢查：

- Task 1輸出、fail-safe與classifier自我變更測試完整。
- Task 2保留三個既有CI status check名稱且docs-only不執行重量工作。
- Task 3只跳過目前非required的Android build jobs，並保留明確summary。
- Task 4不啟動docs-only macOS runner，同時維持`iOS / Simulator Build`status check存在且成功。
- Task 5文件authority不再倒置review／implementation順序。
- Task 6可分別證明docs-only與manual full matrix，不形成evidence遞迴。
- 每個Task都有test-first、review、validation與獨立commit boundary。

## Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Spec status: Accepted
Plan status: Accepted
Implementation allowed: Yes, starting from Task 1 only
```

