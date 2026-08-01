---
document_type: implementation-plan
status: accepted
authoritative_for:
  - r4-test-inventory-external-output-bugfix-plan
last_reviewed_baseline: 1.14.0
---

# R4 — Test Inventory External Output Bugfix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use strict test-driven-development and execute tasks serially.

**Goal:** 讓inventory CLI對root內／root外output都成功產生CSV與正確summary，並關閉`F-A6-01`。

**Architecture:** R4-1先新增unit＋subprocess RED tests，再以pure helper完成最小GREEN；R4-2驗證tracked baseline不變、更新finding與accepted final review。

## Global Constraints

- Design：`docs/superpowers/specs/2026-08-01-r4-test-inventory-external-output-bugfix-design.md`。
- Design commit：`6bbd22f557e4bf485860ed898c6754b3cc249cf3`。
- 只允許關閉`F-A6-01`；`F-A1-04`保持Open。
- 不改discovery、classification、CSV fields、tracked M30 baseline或testing governance policy。
- 不執行R5、merge、push、cleanup或release。

## Task R4-P — Plan Governance

**Files:** Plan、Plan Review、Superpowers／Audit indexes。

- [ ] 確認root內／root外behavior、TDD、baseline hash與closure都有owner。
- [ ] 完成focused／whole-Plan review與placeholder scan。
- [ ] Fresh執行docs tests、`docs_check`、`git diff --check`。
- [ ] 依standing authorization標記accepted並建立獨立commit。

## Task R4-1 — TDD Bugfix

**Files:**

- Modify: `tools/testing/test_test_inventory.py`
- Modify: `tools/testing/inventory.py`
- Create: `docs/audits/r4_test_inventory_external_output_bugfix/r4_1_tdd_review.md`

### RED

- [ ] 新增`display_output_path` root內與root外unit tests。
- [ ] 新增subprocess test，在system temp directory執行CLI，assert exit 0、CSV存在、stdout含absolute output。
- [ ] Production未修改前執行test，確認import／behavior RED。

### GREEN

- [ ] 新增pure `display_output_path(output, root)`。
- [ ] 只將summary的`output.relative_to(root)`替換為helper結果。
- [ ] 執行inventory unit tests與system-temp command。
- [ ] 驗證root內output summary仍為relative POSIX path。
- [ ] 建立review與獨立commit：

```bash
git commit -m "fix(testing): 支援inventory external output path"
```

## Task R4-2 — Holistic Closure

**Files:**

- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- Modify: `docs/audits/README.md`
- Create: `docs/audits/r4_test_inventory_external_output_bugfix/r4_2_holistic_final_review.md`

- [ ] 比對tracked inventory baseline pre／post hash，必須相同。
- [ ] Fresh執行inventory tests、system-temp CLI、repository-local temp CLI、docs tests與`docs_check`。
- [ ] 只將`F-A6-01`標記`Resolved by R4`；`F-A1-04`保持Open。
- [ ] 建立accepted final review與獨立commit。
- [ ] Committed-state重跑focused gates，working tree clean。

## Approval Closure

```txt
Focused Plan review: PASSED
Whole-Plan review: PASSED
Open P0: 0
Open P1 without disposition: 0
User authorization: standing authorization on 2026-08-01
Plan status: ACCEPTED
```
