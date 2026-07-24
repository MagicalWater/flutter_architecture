---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-31-recovery-design-spec-review
last_reviewed_baseline: 1.13.0
---

# Milestone 31-R1 — Design Spec Recovery Review

## Reviewed scope

- Task：31-R1 Design Spec Recovery。
- Artifact：`docs/superpowers/specs/2026-07-24-milestone-31-template-development-workflow-governance-design.md`。
- Parent decision：Milestone 31 Governance Recovery Entry。

## Focused review findings

### P1 — Authority fallback未定義

原Spec把`.agents` Skill設為executable owner，但未處理runtime無法自動discover Skill時的行為，可能造成入口被跳過。

**Fix：** 定義`AGENTS.md`必須提供exact path與explicit loading fallback；缺少自動discover不能視為免除分類。

### P1 — Approval gate只存在於口頭流程

原Spec沒有把Design與Plan的使用者approval寫成behavioral requirement，導致原執行連續越過兩個拍板點。

**Fix：** 新增BR-8與正式Approval and Execution Gates。

### P1 — Review evidence contract不足

原Spec允許review摘要被誤當完整治理，沒有要求Task ID、findings、fix、re-review、whole-task、authority、validation與commit一對一。

**Fix：** 新增BR-9、BR-10及Evidence and Traceability章節。

### P1 — Pressure scenario僅做static coverage

原Validation只要求scenario覆蓋，無法證明Skill改變agent行為。

**Fix：** 新增BR-12，要求同情境RED／GREEN／REFACTOR behavioral evidence。

### P1 — Release與closure狀態混用

原Spec要求post-release晚於release，但未明確禁止「版本已發布＝Milestone已closure」推論。

**Fix：** 新增BR-11、BR-13與Recovery and Rollout，保留1.13.0歷史但撤回治理closure。

### P1 — Final review後變更未要求重審

原Validation沒有明確規定final review之後若變更受審查實作，必須重新執行受影響review與holistic validation。

**Fix：** 擴充Validation與Success Criteria。

## Focused re-review

逐項重新檢查後：

- Authority policy、executable procedure、human overview、Superpowers method與evidence owner已分離。
- Design與Plan approval gate已成為明確behavioral contract。
- Task失敗不得先commit為完成，後續Task不能掩蓋前一Task失敗。
- Recovery與正常新工作均有明確status語意。
- Pressure testing從static scenario presence提升為behavioral RED／GREEN／REFACTOR。

上述focused findings均已修正，未發現新的P0／P1。

## Whole-Spec review

### Requirement coverage

- OpenSpec reject／concept absorption：covered。
- `.agents`固定路徑與Skill structure：covered。
- Requirement Decision與Level 0～5：covered。
- Superpowers與雙層Task連接：covered。
- Anti-over-governance與risk upgrade：covered。
- User approval、traceability、failure gate：covered after recovery fixes。
- Skill adoption與behavioral verification：covered。
- Release／post-release／recovery：covered。
- Milestone 30 stale authority與checker：covered。

### Internal consistency

- `AGENTS.md`擁有policy；Skill擁有procedure，無循環讀取AGENTS的設計。
- Human governance document不複製完整矩陣。
- Design Spec與Plan、ADR、Audit、source／tests／CI責任無重疊。
- Level 0／1仍可使用minimal／simplified流程，不會被本Milestone自身full governance外推。

### Scope and non-goals

未引入OpenSpec、未建立`openspec/`、未遷移歷史`docs/superpowers/`、未讓Skill覆蓋runtime／release authority。

## Authority check

- Spec目前維持`proposed`，因尚未通過使用者Design approval。
- 原Plan維持`proposed`且不得開始Plan recovery。
- `docs/roadmap/active.md`正確指向Design recovery階段。
- 1.13.0 release history保留，未被重寫成未發布。

## Validation

```txt
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

## Disposition

- Internal Design review：PASS。
- Open P0：0。
- Open P1 without disposition：0。
- Design Spec status：`proposed`，等待使用者approval。
- Next allowed action：獨立commit後停下；未經approval不得進入Plan recovery。
