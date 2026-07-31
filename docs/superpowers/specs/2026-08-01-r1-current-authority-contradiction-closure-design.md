---
document_type: design-spec
status: accepted
authoritative_for:
  - r1-current-authority-contradiction-closure-design
last_reviewed_baseline: 1.14.0
---

# R1 — Current Authority Contradiction Closure Design

## Requirement Decision

- Request（需求）：處理Template Baseline 1.14.0整體總審查確認的current authority矛盾，優先關閉全部P1 documentation findings。
- Problem（問題）：Milestone、ADR、Design／Plan routing與Root README存在互斥或過時current-tense敘述，可能讓Agent與維護者選錯authority或重做已完成工作。
- Current behavior（目前行為）：source、tests、ADR正文、release identity與runtime evidence一致，但五個current入口／索引仍保留已完成Milestone、placeholder或pending敘述。
- Expected behavior（預期行為）：每個current入口只保存其唯一責任；Active、Candidate、Closed、canonical ADR與accepted historical Design／Plan routing彼此一致。
- Value（價值）：關閉全部P1 authority風險，讓Template Baseline 1.14.0具備進入Maintenance Mode的必要文件前提。
- Classification（分類）：Level 3 — Cross-cutting documentation governance。
- Decision（決策）：Accept。
- Scope（範圍）：修正`docs/milestones/README.md`、`docs/README.md`、`docs/roadmap/candidates.md`、root `README.md`與`docs/superpowers/README.md`的已確認矛盾；建立Task review與holistic final review evidence。
- Non-goals（非目標）：不處理Project Context瘦身、Dio boundary、inventory CLI、worktree cleanup、platform candidate重分類、ADR正文、Roadmap active authority、VERSION、CHANGELOG、release、merge或push。
- Behavioral requirements required（是否需要行為需求）：Yes；文件routing會影響Agent行為與maintenance gate。
- Design Spec required（是否需要 Design Spec）：Yes。
- Implementation Plan required（是否需要 Implementation Plan）：Yes。
- ADR required（是否需要 ADR）：No；stable architecture與documentation policy不變，只修復實作與摘要偏離。
- Task governance mode（Task治理模式）：Full雙層Task治理。
- Worktree／branch：沿用`audit/template-baseline-1.14-project-holistic`隔離worktree，直到Audit與R1 disposition另行決定。
- Regression level（Regression等級）：documentation checker、`docs_check`、跨文件semantic matrix與受影響navigation review。
- Release required（是否需要發布）：No。
- Post-release validation（發布後驗證）：No。
- Required Superpowers skills（必要Superpowers Skills）：brainstorming、writing-plans、executing-plans、verification-before-completion。
- Required artifacts（必要artifacts）：Design Spec、Design Review、Implementation Plan、Plan Review、逐Task review、R1 holistic final review。

## Authority Inputs

本Design只依下列accepted authority定義問題與邊界：

- `docs/audits/template_baseline_1_14_project_holistic_audit/a9_holistic_final_review.md`
- `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- `docs/governance/documentation_policy.md`
- `docs/README.md`
- `docs/roadmap/active.md`
- `docs/roadmap/candidates.md`
- `docs/milestones/README.md`
- `docs/superpowers/README.md`
- root `README.md`

Audit findings是問題與disposition authority；本Design不得擴大finding set，也不得把R2～R5偷偷納入R1。

## Problem Contract

R1關閉下列accepted findings：

| Finding | Current contradiction | Required outcome |
|---|---|---|
| F-A1-01 | Completed Milestone 32位於Active routing | Active routing明確為None；M32移入Closed routing |
| F-A1-02 | Documentation Hub把canonical ADR目錄降級為placeholder | canonical ADR authority維持正式；legacy wording只指向真正legacy路徑 |
| F-A1-03 | Completed Milestone 32仍存在Candidate authority | Candidate正文移除M32完成項與重複closure routing |
| F-A7-01 | Root README仍描述Milestone 5尚待收尾 | 移除或改為明確historical note，不再形成current instruction |
| F-A7-03 | Superpowers index把完成的M31寫成proposed／pending | M31 Spec／Plan routing與accepted metadata及R11 closure一致 |

本Design不把`Open` finding直接改為`Resolved`。只有implementation、fresh verification與R1 holistic review通過後，才能在central findings register記錄closure evidence。

## Design Principles

### 1. Single Authority

每份文件只回答自己的問題：

- `docs/roadmap/active.md`：目前是否有active work。
- `docs/roadmap/candidates.md`：尚未promote的候選方向。
- `docs/milestones/README.md`：Milestone名稱、status與artifact routing。
- `docs/adr/README.md`與canonical ADR files：Architecture Decision authority。
- `docs/superpowers/README.md`：Design／Plan navigation與lifecycle摘要。
- root `README.md`：human current entry與穩定使用入口。

索引可以摘要與連結，不得保存第二份完整closure history或相反status。

### 2. Minimal Semantic Repair

只修改Audit已證實的矛盾，不藉機全面重寫文件。每個修改必須能直接對應Finding ID、current contract與verification。

### 3. Historical Preservation Without Current-tense Leakage

已完成工作的細節保留在Git history、Audit、Milestone reviews與CHANGELOG。Current入口若保留歷史，只能使用明確historical wording與stable link，不得讓讀者誤認為仍待執行。

### 4. No Parallel Authority

R1 reviews只擁有finding、fix與validation evidence；不複製current authority正文，也不新增與Documentation Policy、Roadmap或ADR平行的規則。

## File-level Design

### `docs/milestones/README.md`

Required changes：

- `## Active routing`只表達`None`，並連到`docs/roadmap/active.md`。
- Milestone 32加入Closed milestone routing表。
- M32完整artifact route可以保留在Closed routing下的有界section，或壓縮為表格primary routing加stable links。
- 不複製Task checklist、runtime counts或release journal。

Forbidden changes：

- 不修改M1～M31既有status。
- 不改Roadmap priority或建立新active milestone。

### `docs/README.md`

Required changes：

- 保留前段`docs/adr/README.md`與canonical ADR records為Architecture Decision authority。
- Legacy段落只標記真正的aggregate／historical／partially superseded路徑，例如`docs/architecture/`與已明確legacy的舊文件。
- 不再把整個`docs/adr/`描述成placeholder。

Forbidden changes：

- 不修改task-based reading route。
- 不改ADR內容或supersession graph。

### `docs/roadmap/candidates.md`

Required changes：

- 移除`Completed — Milestone 32`正文與closure routing。
- Candidate文件只保留尚未promote或正式disposition的方向。

Forbidden changes：

- 不在R1執行A8對Web、Windows、macOS、Linux的B＋D portfolio調整。
- 不新增candidate或backlog commitment。

### Root `README.md`

Required changes：

- 移除「第一階段MVP完成前，Milestone 5會……」與5-1～5-3 future flow。
- 保留仍有效的驗證命令、current runtime能力與安全邊界。
- 若需要保存Milestone 5脈絡，只能用一句historical note並導向CHANGELOG／archive；預設推薦直接移除過時section。

Forbidden changes：

- 不全面重排README。
- 不更新capability、platform或security claim，除非只是維持段落連續性所需的最小文字銜接。

### `docs/superpowers/README.md`

Required changes：

- M31 Design與Plan摘要改為accepted historical artifact，並連到R10／R11 closure evidence。
- Template 1.14 holistic Audit Plan摘要改為accepted且A1～A9／Final Review已完成。
- Template 1.14 holistic Audit Design摘要維持accepted，補充Final Review已核准B＋D disposition；摘要不得變成finding正文。

Forbidden changes：

- 不重寫其他Milestone／Skill lifecycle。
- 不用index取代linked Spec、Plan或Final Review。

## Task Architecture

### Task R1-1 — Milestone and Candidate Authority Repair

Scope：

- `docs/milestones/README.md`
- `docs/roadmap/candidates.md`
- Task review artifact

Findings：F-A1-01、F-A1-03。

Acceptance：Active=None、M32只在Closed routing、Candidate不再含M32 completed正文、links與docs checks通過。

### Task R1-2 — Documentation Hub and ADR Routing Repair

Scope：

- `docs/README.md`
- Task review artifact

Finding：F-A1-02。

Acceptance：canonical ADR route前後一致、legacy wording不再降級`docs/adr/`、task-based reading route不變。

### Task R1-3 — Human Entry and Design／Plan Index Repair

Scope：

- root `README.md`
- `docs/superpowers/README.md`
- Task review artifact

Findings：F-A7-01、F-A7-03。

Acceptance：Root README沒有M5 future instruction；M31與Template 1.14 Audit lifecycle摘要與accepted artifacts一致。

### Task R1-4 — Cross-document Holistic Closure

Scope：

- R1 holistic final review
- central findings register的closure evidence與status更新
- 必要時只更新Audit routing index

Acceptance：五個findings具fix、fresh re-review與exact verification；Open P0=0、Open P1 without disposition=0；沒有R2～R5 scope drift；working tree clean。

## Two-layer Task Governance

Design、Plan與R1-1～R1-4每個Task都執行：

```txt
create／implement
→ focused review
→ findings
→ fix
→ focused re-review
→ whole-Task holistic review
→ documentation authority check
→ required validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ next Task
```

一般documentation finding或validation failure必須直接修正並fresh重跑。只有推翻本Design的P0／P1、需要使用者重新決定scope，或外部環境blocker才停止。

## Validation Design

每個implementation Task至少執行：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

另需執行Task-specific semantic assertions：

- Active routing與`docs/roadmap/active.md`一致。
- Candidate文件不存在M32 completed section。
- Documentation Hub只有單一canonical ADR authority敘述。
- Root README不存在M5 future-tense instruction。
- Superpowers index的M31與Template 1.14 Audit status和linked metadata／closure一致。

R1-4再執行跨文件矩陣、所有Finding closure欄位檢查與committed-state documentation gate。因不修改source、test、dependency、workflow或platform configuration，不執行Flutter full regression、platform build或release。

## Findings and Closure Contract

Implementation前central findings保持`Open／Remediation proposed`。R1-4只有在下列條件全部成立後，才能將對應finding改為`Resolved`：

1. Exact source file已修改。
2. Focused review無open P0／P1。
3. Task-specific semantic assertion通過。
4. Documentation tests與`docs_check`通過。
5. Independent Task commit存在。
6. Cross-document holistic review確認沒有新的矛盾。

R1 closure只關閉F-A1-01、F-A1-02、F-A1-03、F-A7-01、F-A7-03。F-A7-02、F-A2-01、F-A6-01與F-A1-04保持Open並保留原disposition。

## Release and Integration Boundary

- R1不提升Template Baseline，不修改VERSION或CHANGELOG。
- R1不自動merge或push。
- R1完成後是否先執行R2、合併Audit branch或建立maintenance closure，由新的使用者決策決定。
- Audit worktree與M32 worktree cleanup不屬R1。

## Success Criteria

R1 Design與後續implementation成功時必須滿足：

```txt
F-A1-01 Resolved
F-A1-02 Resolved
F-A1-03 Resolved
F-A7-01 Resolved
F-A7-03 Resolved

Open P0: 0
Open P1 without disposition: 0
Current active milestone: None
Canonical ADR authority: unambiguous
Completed M31／M32 routing: historical／closed
Root README: no stale M5 future instruction
New Milestone: none
Release: none
```

## Approval Record

使用者已於2026-08-01明確核准本R1 Design。此核准允許完成Design治理closure與建立Implementation Plan；不授權Plan尚未核准前開始修改五份current authority文件。
