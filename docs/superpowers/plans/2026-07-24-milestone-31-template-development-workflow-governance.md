---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-31-template-development-workflow-governance-plan
last_reviewed_baseline: 1.12.0
---

# Milestone 31 — Template Development Workflow Governance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans task-by-task. Repository雙層Task治理覆蓋Superpowers預設checkpoint。

**Goal:** 建立`.agents`內的repository-local工作治理Skill，連接Requirement Decision、Superpowers與雙層Task治理，並修復closure authority缺口。

**Architecture:** `AGENTS.md`強制觸發；`.agents/skills/governing-template-development`擁有可執行流程；`docs/governance/development_workflow.md`只作人類總覽；checker驗證可機械化的一致性。

**Tech Stack:** Markdown Agent Skill、Python standard-library docs checker、現有Melos／Flutter validation。

## Global Constraints

- 不引入OpenSpec或`openspec/`。
- Skill固定放在`.agents/skills/governing-template-development/`。
- Repository authority高於Skill。
- Level 0／1不得被迫建立完整Spec／Plan／Milestone。
- 每個正式Task完成focused review、findings、fix、re-review、whole-task review、authority check、validation與commit。

### Task 31-1：建立Skill與pressure scenarios

建立`SKILL.md`及五份references；以Level 0～5、降級／過度治理、停止／續跑、Spec／Plan gate作pressure scenarios。驗證檔案可被解析、無placeholder、相對連結正確後commit。

### Task 31-2：接入AGENTS與人類治理總覽

建立`docs/governance/development_workflow.md`，更新`AGENTS.md`與`docs/README.md`導覽；確認不複製完整Skill矩陣，完成文件authority review後commit。

### Task 31-3：修正Milestone 30 stale authority

修正`docs/project_context.md`、`docs/milestones/README.md`、`docs/superpowers/README.md`及相關metadata，使Milestone 30只有Completed／Archived狀態，完成focused docs validation後commit。

### Task 31-4：增加closure一致性checker

先在`tools/docs/test_check_docs.py`加入失敗測試，再於`tools/docs/check_docs.py`實作pending active routing與duplicate milestone row檢查；執行Python tests與docs_check後commit。

### Task 31-5：整體治理驗證與release closure

執行Skill pressure review、docs checker、docs_check、analyze、Flutter tests、diff check與holistic review；同步VERSION、CHANGELOG、Roadmap、Project Context、Milestone／Spec indexes，release後push並做clean-checkout與remote validation。
