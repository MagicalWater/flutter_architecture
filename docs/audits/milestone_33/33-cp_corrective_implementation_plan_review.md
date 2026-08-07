---
document_type: planning-review
status: proposed
authoritative_for:
  - milestone-33-corrective-implementation-plan-review
last_reviewed_baseline: 1.15.0
---

# Milestone 33 Corrective — Implementation Plan Review

## Scope

本review涵蓋：

- accepted Corrective Design／ADR amendment draft對Plan的coverage。
- C1 governance contract、C2 fixed runtime RED contract、C3 single-renderer implementation、C4 actual Android/user acceptance、C5 holistic/release closure。
- TDD order、visual threshold immutability、same-renderer proof、commit boundaries與release gate。

本review不建立worktree、不修改canonical ADR／Skill／Guide／tests／Flutter production source，也不提交先前dirty Task 33-13 closure文件。

## Focused Findings

### F-33-C-P01 — Runtime reference必須在candidate前固定

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：若runtime reference在C3 implementation後才生成，candidate可反向影響projection方式。
- Fix：C2先實作`projectPng`、生成360×640 derived reference、記錄hash與固定8%／mean 8.0 thresholds，再建立RED candidate tests。
- Re-review：C3只能消費C2 artifacts，不能修改算法／target／threshold取得GREEN。

### F-33-C-P02 — 不能只做source grep就宣稱single renderer

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：單純禁止字串`>=900`仍可能以別的breakpoint建立第二套root tree。
- Fix：C2 architecture guard同時驗證production source沒有parallel root branch，C3 source reference scan證明舊parallel widgets零consumer，canonical/runtime tests都從`WritePrecheckView`render。
- Re-review：same renderer由source architecture＋runtime behavior雙重證明。

### F-33-C-P03 — 「等比例」不能使226×400變成不可操作縮圖

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：primary 360×640可直接width projection，但extreme narrow不能因此降低layout health責任。
- Fix：C3允許同一component tree在極窄width做content-aware adaptation；C2/C3保留226×400 no-overflow／scroll／semantics tests，但不要求它冒充360×640 fidelity。
- Re-review：single renderer不等於所有viewport都只能純比例縮放。

### F-33-C-P04 — Android screenshot不能再由automation自行接受

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：33-10原semantic review把debug Android screenshot判PASS，但使用者實際看到的畫面不接受。
- Fix：C4把實際BlueStacks前景畫面與使用者書面接受列為hard gate；拒絕就回C3，C5不得執行release closure。
- Re-review：automation仍提供metrics/evidence，但不覆蓋human semantic P1。

### F-33-C-P05 — Dirty historical closure state不能混入corrective commits

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：`main`仍有未提交的33-13 closure docs，內容宣稱Milestone 33 completed/archived，已被本次P1推翻。
- Fix：Design／Plan commits只stage exact corrective artifacts；implementation在新managed worktree從corrective approved ancestor開始。C5重新決定current closure state。
- Re-review：舊dirty files不會進C1-C4 commits或成為錯誤current authority。

## Focused Re-review

- Plan先鎖治理，再鎖runtime reference／RED，再改production source，TDD順序正確。
- Runtime threshold在candidate前固定為ratio 8%／mean 8.0；沒有「先看結果再調門檻」。
- 360×640 reference由Pencil canonical preview生成，不由Flutter candidate生成。
- Canonical與runtime golden都render`WritePrecheckView`，same renderer可被實際測試。
- 1.15.0不rewrite；預期1.15.1但由C5 Final Review決定。
- C4明确要求實際使用者視覺接受，修補原Milestone最重要的review漏洞。
- 每個Task有自己的review evidence與commit boundary。

## Whole-Plan Review

### Design coverage

Accepted Corrective Design的single tree、design-space projection、runtime fidelity、anti-cheat、Design System ownership、semantic P1、Android runtime與release requirements均有對應Task；沒有要求修改`.pen`或建立第二份mobile design。

### Execution safety

Plan不在dirty main實作；Plan accepted後才建立managed worktree。C2允許以intentional RED commit保存reproduction contract，C3必須把同一RED轉GREEN；這個順序避免「先修再補test」。

### Scope control

沒有完整NFC功能、generic renderer framework、Design System大改、產品identifier修改、top-level fixed scaling或release-history rewrite。

## Validation

Plan artifact完成後fresh執行：

```txt
placeholder / ambiguity scan
repository docs_check
git diff --check
scope/staging review
```

Fresh Plan validation：

```txt
placeholder / ambiguity scan: PASS after removing self-referential forbidden-token wording
repository docs_check: PASS
git diff --check: PASS
Plan/review scope: exactly 2 new corrective Plan artifacts
Existing Task 33-13 closure dirty files: detected and explicitly excluded
```

## Current Disposition

```txt
Focused findings: RESOLVED IN PROPOSED PLAN
Whole-Plan internal review: PASSED
Documentation validation: PASSED
Plan status: PROPOSED
Managed corrective worktree: NOT CREATED
Implementation: NOT STARTED
Next gate: user written Plan approval
```
