---
document_type: planning-review
status: accepted
authoritative_for:
  - repository-local-skills-zh-tw-governance-recovery-design-review
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 繁體中文化治理恢復 Design Review

## Task scope

審查 `docs/superpowers/specs/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery-design.md` 是否能正確恢復 commit `c8a77a5` 缺失的 Level 3 治理證據，且不把 review recovery 變成新的 Skill redesign。

## Focused review

### F-D01 — 原分類低估 repository governance 風險

- Severity：P1。
- Finding：原 review 將修改中央治理 Skill、全部 adopted Skill descriptions 與 shared workflow wording 的工作分類為 Level 1。
- Fix：Design 明確改為 Level 3 Cross-cutting repository governance recovery，要求 Design／Plan、full Task mode、逐 Skill review與 holistic final review。
- Fresh re-review：classification 與 current `work-classification.md` 的「repository-wide governance／shared contracts」訊號一致。

### F-D02 — Recovery 可能改寫歷史證據

- Severity：P1。
- Finding：若直接把舊 review 改成 Level 3，會使歷史時間線失真。
- Fix：Design 規定舊 review 保留，僅加入 supersession route；新 evidence 由獨立 recovery files 保存。
- Fresh re-review：historical evidence 與 current authority ownership 已分離。

### F-D03 — 文件語言規則可能只靠人工記憶

- Severity：P2。
- Finding：語言規則具備機械檢查可能性，但原 implementation 只新增 policy 與 one-off scan。
- Fix：Design 將 docs checker review 與最小 TDD enforcement 納入 Task 5，並限制 checker 不判斷翻譯品質或禁止技術英文。
- Fresh re-review：mechanical rule 的範圍明確且不建立第二套 Skill authority。

## Whole-Task review

- Design 只定義 review recovery，不修改四個 Skills 的 product／workflow scope。
- Task boundaries 可獨立接受或拒絕，且每一 Task 都有明確 authority owner。
- `AGENTS.md`、central Skill、Skill registry、source／tests／CI 的優先順序維持不變。
- User approval 已由 2026-07-30 明確指示記錄。

## Validation

```txt
Design status                                              accepted
Requirement Decision fields                               complete
Task boundaries                                            6
TODO／TBD／placeholder                                      0
Open P0                                                    0
Open P1 without disposition                               0
Open P2 without disposition                               0
```

## Disposition

```txt
Design Task：Accepted
Next：建立並審查 Implementation Review Plan
```
