---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-33-single-renderer-corrective-design-review
last_reviewed_baseline: 1.15.0
---

# Milestone 33 Corrective — Single-Renderer Design Review

## Scope

本review涵蓋：

- Level 4 Corrective Requirement Decision。
- [Corrective Design](../../superpowers/specs/2026-08-07-milestone-33-corrective-single-renderer-responsive-fidelity-recovery-design.md)。
- [ADR-028 amendment draft](../../superpowers/specs/2026-08-07-adr-028-single-renderer-responsive-fidelity-amendment-draft.md)。
- 使用者runtime visual rejection對舊33-10／33-12 acceptance的supersession。
- Single component model、design-space projection、runtime fidelity與anti-cheat boundary。

本review不修改canonical ADR-028、不建立Corrective Plan／worktree、不修改Skill／Guide／tests／Flutter production source，也不提交尚未完成的Milestone 33 closure routing。

## Baseline

```txt
Template Baseline: 1.15.0
Published main/origin release SHA: ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
Branch: main
1.15.0: historical released baseline; no rewrite / no force push
Current new finding: Android runtime visual fidelity FAIL by user acceptance
```

Main checkout存在未提交的Task 33-13 closure documentation；其`Completed / Archived` routing已被本次runtime P1推翻，因此Corrective Design commit不得stage這些dirty files。

## Focused Findings

### F-33-C-D01 — Pencil export width被誤當Flutter logical breakpoint

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：`941`是accepted mobile design/comparison width，不是runtime breakpoint；`>=900`／`<900`分支使360 logical runtime走另一套UI。
- Design fix：canonical size改為design-space；runtime使用同一component model的geometry projection。
- Re-review：沒有新增第二份mobile `.pen`，也沒有把Pencil authority改成runtime screenshot。

### F-33-C-D02 — Parallel whole-screen renderer使visual tests各自PASS但產品FAIL

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：canonical branch擁有pixel fidelity，mobile branch只擁有layout health，形成test escape hatch。
- Design fix：一個accepted screen只能有一套whole-screen visual tree；breakpoint只能改component-level layout policy。
- Re-review：canonical與runtime gates現在要求same renderer，不能互相冒充。

### F-33-C-D03 — 「等比例」不能退化成top-level FittedBox

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：使用者正確要求同一UI依比例自適應，但直接整頁`FittedBox`會把touch／text／accessibility一起盲縮。
- Design fix：shared `visualScale`只計算真Flutter widget geometry；hit targets與accessibility content-aware policy維持獨立責任。
- Re-review：可見geometry能忠實投影，同時沒有恢復原Design明確禁止的fixed-canvas cheat。

### F-33-C-D04 — Runtime visual evidence只有layout-health semantics

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：舊review把scroll／no-overflow／可讀當成runtime fidelity PASS。
- Design fix：runtime新增Pencil-derived projection reference、runtime-sized golden／diff與side-by-side semantic review；narrow tests只擁有layout health。
- Re-review：pixel與semantic仍互補，任何runtime semantic P1都撤銷automation PASS。

### F-33-C-D05 — Silent resize禁令需要區分「作弊resize」與「accepted derived projection」

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：舊contract正確禁止candidate失敗後silent resize，但corrective需要從唯一手機`.pen`產生runtime expected reference。
- Design fix：derived runtime reference的target、algorithm、crop／scroll contract與hash必須在candidate前固定；它只作derived evidence，不取得authority。
- Re-review：沒有為了candidate結果改reference，也不比較不同尺寸圖片。

## Focused Re-review

- Requirement Decision正確提升為Level 4；工作會修改ADR、repository Skill、Guide、visual acceptance與production proof architecture。
- 1.15.0不rewrite；corrective預期以patch release處理。
- `source.pen`仍是唯一手機visual authority；不存在「缺第二份mobile pen」的錯誤假設。
- One screen／one component model／one geometry model是stable boundary。
- Design-space projection使用真widgets數值，不是top-level transform。
- Design System／Theme／asset ownership維持Milestone 33既有mapping order。
- Canonical與runtime visual acceptance改由same renderer共同承擔。
- Existing narrow no-overflow tests保留，但不再冒充fidelity evidence。
- Corrective Plan accepted前不修改ADR／Skill／Guide／tests／production source。

## Whole-Design Review

### Architecture consistency

Corrective不新增Flutter architecture；只移除parallel visual renderer並建立single visual model。Feature First、Localization、Design System與App Composition Root不變。

### Authority consistency

- `.pen`仍擁有design structure／geometry／visual hierarchy。
- Manifest擁有canonical與derived reference roles。
- ADR-028擁有stable single-renderer／runtime fidelity boundary。
- Skill擁有execution orchestration與hard stop rules。
- Guide擁有人類操作方式。
- Tests／runtime screenshot擁有implementation evidence。
- Audit擁有本次superseding P1與fresh disposition。

### Governance consistency

使用者runtime rejection是accepted artifact的P1 finding，因此依中央治理必須停止原closure並進corrective Design／Plan；不能直接在1.15.0 source上順手改UI後宣稱修好。

### Scope control

Corrective明確拒絕：第二份mobile `.pen`、重新設計accepted source、top-level FittedBox、parallel whole-screen renderer、完整NFC功能、Design System大改、generic renderer framework與release history rewrite。

## Validation

Design Task在書面artifact完成後fresh執行：

```txt
placeholder / ambiguity scan
repository docs_check
git diff --check
scope/staging review
```

Fresh results：

```txt
TODO / TBD / PLACEHOLDER: 0
repository docs_check: PASS
git diff --check: PASS
Corrective Design files: exactly 3 untracked artifacts before staging
Existing Task 33-13 closure dirty files: detected and explicitly excluded from Corrective Design scope
```

使用者已於2026-08-07書面核准Corrective Design與ADR amendment draft；本review轉為`accepted`。該核准只開啟Implementation Plan gate，不等於Plan approval或implementation admission。

## Current Disposition

```txt
Focused findings: RESOLVED IN PROPOSED DESIGN
Whole-Design internal review: PASSED
Documentation validation: PASSED
User runtime visual acceptance: FAIL (corrective trigger)
Design status: ACCEPTED
ADR amendment draft: ACCEPTED
Implementation Plan: NOT CREATED
Managed corrective worktree: NOT CREATED
Production implementation: NOT STARTED
Next gate: create and fully review Corrective Implementation Plan
```
