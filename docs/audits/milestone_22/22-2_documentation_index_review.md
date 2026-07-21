---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-22-phase-2-review-evidence
last_reviewed_baseline: 1.5.0
---

# Milestone 22-2 — Documentation Index & AI Reading Contract Review

## Scope

本階段建立正式 Documentation Hub、Audits／Superpowers／Milestones indexes、AI task-based reading route 與最小 metadata policy。

本階段不重寫 `docs/project_context.md`、不拆分 `docs/roadmap.md`、不進行 Decision extraction，也不搬移歷史 artifacts。

## Task 1 Review — Documentation authority hub

狀態：Completed / Reviewed。

建立：

- `docs/README.md` 正式 Documentation Hub。
- `docs/audits/README.md`。
- `docs/superpowers/README.md`。
- `docs/milestones/README.md`。

Review criteria：

- 每一類文件都有單一 authoritative scope。
- Index 只保存 routing 摘要，不複製完整 architecture contract。
- Historical artifact 與 current authority 明確分離。
- Legacy `docs/adr/`、`docs/architecture/` status 保持明確。

Result：Passed。

## Task 2 Review — Task-based AI reading route

狀態：Completed / Reviewed。

更新：

- `AGENTS.md`：固定最小讀取集與 Architecture／Feature／Package／Milestone／Review／Release 路由。
- `docs/conversation_rules.md`：Rule 4 與 Rule 12 改為最小讀取集加按需路由。
- root `README.md`：只保留人類可理解的文件入口與 AI 恢復摘要，移除重複完整必讀清單。

Review criteria：

- 每種常見任務都有 deterministic route。
- `CHANGELOG.md`、完整 Decision aggregate、全部 audits 與 plans 不再是每次必讀。
- `AGENTS.md` 是 AI 操作規則 authority，Root README 只提供摘要與連結。
- Historical artifact 不得覆蓋 current authority。

Result：Passed。

## Task 3 Review — Minimal metadata policy

狀態：Completed / Reviewed。

建立 `docs/governance/documentation_policy.md`，正式定義：

- `document_type` whitelist。
- `status` whitelist 與 lifecycle 語意。
- `authoritative_for` 唯一 scope rule。
- `last_reviewed_baseline`。
- Optional metadata 的 YAGNI 原則。
- Archive trigger。
- Legacy adoption rule。
- Controlled growth、summary 與 migration safety contract。

Review criteria：

- 不要求對既有文件無差別批量加 metadata。
- 不允許未經 semantic review 將 legacy 文件標成 `accepted`。
- Metadata 用於 routing、authority 與 checker，不成為裝飾性欄位。
- Policy 不複製完整 AI reading route，只連回其 authority。

Result：Passed。

## Whole-phase Implementation Review

狀態：Passed after one self-consistency remediation。

### Review finding 22-2-R01 — New managed documents initially lacked the metadata required by the new policy

- Severity：P1 within phase scope。
- Observation：Task 3 建立 minimal metadata policy 後，本階段新建立的 managed indexes、policy 與 phase review 尚未套用相同 contract。
- Risk：Policy 與第一批受治理文件立即不一致，會削弱後續 checker 與 adoption rule 的可信度。
- Remediation：為 `docs/README.md`、Audits／Superpowers／Milestones indexes、governance policy 與本 phase review 加入 `document_type`、`status`、`authoritative_for`、`last_reviewed_baseline`。
- Re-review：Passed；scope keys 無重複，status 與 lifecycle 一致。

### Review finding 22-2-R02 — Index types were initially too generic

- Severity：P2 within phase scope。
- Observation：Audits 與 Superpowers indexes 最初共用 `milestone-index`，無法準確表達其 routing responsibility。
- Remediation：新增 `audit-index` 與 `design-plan-index` whitelist values，分別套用至對應 index。
- Re-review：Passed；每個 index 的 document type 與 authoritative scope 一致。

### Deterministic routing review

以下任務都有明確路由：

```txt
Architecture
Feature
Package
Active Milestone execution
Review / runtime evidence
Release
Historical investigation
```

`AGENTS.md` 擁有 AI 操作與最小讀取規則；`docs/README.md` 擁有完整 taxonomy 與 task-based routing；root `README.md` 與 `docs/conversation_rules.md` 只保留必要摘要與連結。

### Index authority review

- Index 只保存分類、status、summary 與 link。
- Audits index 不宣稱 current architecture authority。
- Superpowers index 不宣稱 implementation completion authority。
- Milestones index 不成為第二份 Roadmap 或 CHANGELOG。
- Documentation Hub 不複製完整 Decision contract。

### Scope guard

本階段沒有：

- 重寫 `docs/project_context.md`。
- 拆分 `docs/roadmap.md`。
- 拆分 Decision 001 至 022。
- 搬移、刪除或重新命名歷史 artifacts。
- 修改 production code、generated files、dependency 或 platform configuration。

## Finding Disposition

| Finding | Result |
|---|---|
| `M22-PR02` Mandatory reading path loads conflicting history | Closed：固定最小讀取集與 task-based route 已建立 |
| `M22-PR11` Audit and plan artifacts lack unified indexes | Closed for routing：Audits、Superpowers、Milestones indexes 已建立；closed milestone 細部索引留待 22-4 |
| `M22-PR13` Rules duplicated without normative-source labels | Closed：AGENTS、Documentation Hub、Root README 與 Conversation Rules 的 owner／summary 關係已明確 |
| `M22-PR14` Metadata is inconsistent | Partially resolved：新 managed documents 已採 minimal metadata；legacy adoption 依需求分階段進行 |

## Verification

```txt
Managed metadata required fields
→ Passed

Architecture / Feature / Package / Milestone / Review / Release route scan
→ Passed

Referenced core document targets
→ Passed

Authoritative scope uniqueness for new managed indexes
→ Passed

git diff --check
→ Passed
```

## Phase Decision

Milestone 22-2 通過 implementation review。Documentation Hub、AI reading contract、indexes 與 metadata policy 已建立，可進入 Milestone 22-3 Current Project Snapshot Rewrite。
