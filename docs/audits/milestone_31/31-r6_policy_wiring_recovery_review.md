---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-31-policy-wiring-recovery-review
last_reviewed_baseline: 1.13.0
---

# Task 31-R6 — Policy Wiring and Human Overview Recovery Review

## Reviewed scope

- `AGENTS.md`
- `docs/governance/development_workflow.md`
- `docs/README.md`
- `docs/superpowers/README.md`

## Focused findings

- P1：Human overview的`last_reviewed_baseline`仍為`1.12.0`，未反映1.13.0 workflow release與recovery review。Resolved：同步為`1.13.0`。
- P1：Human overview將Skill adoption state寫為不存在的`Restricted`，與Skill-owned`Approved with restrictions`不一致。Resolved：使用canonical state名稱。

## Focused re-review

- `AGENTS.md`明確提供`.agents/skills/governing-template-development/SKILL.md` exact path；即使runtime只載入AGENTS而未主動選Skill，也有不可繞過的explicit-load fallback。
- `AGENTS.md`只保存強制入口、authority priority與不得跳過規則，未複製Level／artifact完整矩陣。
- Human overview只提供purpose、responsibility、lifecycle與authority boundary，完整executable routing仍由Skill與references擁有。
- `docs/README.md`提供治理總覽route；`docs/superpowers/README.md`只管理Spec／Plan routing，不成為workflow authority。

## Whole-task review

Authority chain維持：`AGENTS.md` policy → repository-local Skill executable procedure → Superpowers methods → repository artifacts/evidence。沒有平行authority、broken route或stale completion claim。

## Validation

```txt
python3 -m unittest tools.docs.test_check_docs
→ 17 passed

dart run melos run docs_check
→ passed

git diff --check
→ passed
```

Open P0 = 0；Open P1 without disposition = 0。Task 31-R6 accepted。

## R8-triggered reopen and fresh re-review

R8 cross-authority audit發現`docs/superpowers/README.md`在recovery中已修改routing內容，但metadata仍為`1.12.0`。R6重新開啟並修正為`1.13.0`。

Fresh re-review：Spec／Plan index仍只負責artifact routing；沒有新增workflow authority。Docs tests、repository `docs_check`與diff check重新通過。R6維持accepted。
