---
document_type: implementation-plan
status: accepted
authoritative_for:
  - r1-current-authority-contradiction-closure-plan
last_reviewed_baseline: 1.14.0
---

# R1 — Current Authority Contradiction Closure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修復Template Baseline 1.14.0整體總審查確認的五個current authority矛盾，關閉全部P1 documentation findings，並在不建立新Milestone或release的前提下完成可重現的R1治理closure。

**Architecture:** 採Finding-to-Task單一owner模型。R1-1修Milestone／Candidate authority，R1-2修Documentation Hub／ADR routing，R1-3修human entry與Design／Plan index，R1-4才更新central findings並完成cross-document holistic review。任何Task不得提前改寫其他Finding status或吸收R2～R5。

**Tech Stack:** Markdown、YAML front matter、Git、PowerShell semantic assertions、Python unittest、repository documentation checker、Melos `docs_check`。

## Global Constraints

- Design authority：`docs/superpowers/specs/2026-08-01-r1-current-authority-contradiction-closure-design.md`，status必須維持`accepted`。
- Design commit：`9187dd4654ac91b8d31e98edb1d05eef4e047fa7`。
- Branch：`audit/template-baseline-1.14-project-holistic`；不得在`main`直接修改。
- Implementation hard gate：本Plan完成雙層review、使用者明確核准、轉為`accepted`並建立獨立approval commit前，不得開始R1-1。
- Finding allowlist：只允許關閉`F-A1-01`、`F-A1-02`、`F-A1-03`、`F-A7-01`、`F-A7-03`。
- Remaining findings：`F-A1-04`、`F-A2-01`、`F-A6-01`、`F-A7-02`必須保持Open與原disposition。
- Scope：只修改Design列出的五份current入口／索引，以及R1 review、central findings與必要routing index。
- No R2～R5：不得重寫Project Context、修改Dio boundary、修inventory CLI或清理branch／worktree。
- No portfolio change：不得在R1執行Web／Windows／macOS／Linux candidate disposition。
- No release：不得修改`VERSION`、`CHANGELOG.md`或建立release／post-release artifact。
- No architecture change：不得修改ADR正文、supersession graph、production source、tests、workflow或platform configuration。
- No integration：不得merge、push、刪branch或清理worktree。
- 每個implementation Task都必須完成focused review、finding修正、fresh re-review、whole-Task review、authority check、必要validation與獨立commit。
- 一般documentation defect與validation failure不得停下詢問；直接修正並fresh重跑。只有推翻accepted Design／Plan的P0／P1、使用者scope決策或external blocker才停止。

---

## File and Artifact Map

### Planning artifacts

- Design：`docs/superpowers/specs/2026-08-01-r1-current-authority-contradiction-closure-design.md`
- Design review：`docs/audits/r1_current_authority_contradiction_closure_design_review.md`
- Plan：`docs/superpowers/plans/2026-08-01-r1-current-authority-contradiction-closure.md`
- Plan review：`docs/audits/r1_current_authority_contradiction_closure_plan_review.md`

### Implementation review artifacts

```txt
docs/audits/r1_current_authority_contradiction_closure/
  r1_1_milestone_candidate_authority_review.md
  r1_2_documentation_hub_adr_routing_review.md
  r1_3_human_entry_design_plan_index_review.md
  r1_4_holistic_final_review.md
```

不得預先建立空白review檔。每個artifact在對應Task首次需要時建立。

---

## Task R1-P — Implementation Plan Governance

**Files:**

- Create: `docs/superpowers/plans/2026-08-01-r1-current-authority-contradiction-closure.md`
- Create: `docs/audits/r1_current_authority_contradiction_closure_plan_review.md`
- Modify: `docs/superpowers/README.md`
- Modify: `docs/audits/README.md`

**Consumes:** accepted R1 Design、Design Review findings `F-R1-D01`／`F-R1-D02`、accepted Audit Final Review與central findings。

**Produces:** exact R1-1～R1-4 execution order、file scope、semantic assertions、finding closure guards、commit boundaries與兩個使用者approval gates。

- [ ] 對照Design逐項確認Requirement Decision、五Finding allowlist、R2～R5 non-goals、file-level design、R1-1～R1-4、validation、closure與integration boundary都有Plan owner。
- [ ] 執行placeholder與scope scan；Plan不得含未完成標記、未解析路徑、模糊validation wording或未定義commit boundary。
- [ ] 完成focused Plan review；任何P0／P1 planning finding必須修正並fresh re-review。
- [ ] 完成whole-Plan review，確認四個implementation Tasks可被獨立接受或拒絕，且共享central findings時仍採串行執行。
- [ ] Fresh validation：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] 只stage本Task四份artifact，執行`git diff --cached --check`後建立proposal commit：

```bash
git commit -m "docs(governance): 建立R1 current authority修復計畫"
```

- [ ] 停在使用者Plan approval gate。Plan維持`proposed`時不得開始R1-1。
- [ ] 使用者核准後，將Plan、Plan Review與Plan index更新為`accepted`，記錄2026-08-01明確核准，fresh重跑validation並建立獨立approval commit：

```bash
git commit -m "docs(governance): 核准R1 current authority修復計畫"
```

**Task acceptance:** Plan accepted、Open planning P0=0、Open planning P1 without disposition=0、working tree clean。只有此時R1-1可開始。

---

## Task R1-1 — Milestone and Candidate Authority Repair

**Files:**

- Modify: `docs/milestones/README.md`
- Modify: `docs/roadmap/candidates.md`
- Create: `docs/audits/r1_current_authority_contradiction_closure/r1_1_milestone_candidate_authority_review.md`

**Consumes:** `docs/roadmap/active.md`的`Current active milestone: None`、M32 final／post-release evidence、Findings `F-A1-01`與`F-A1-03`。

**Produces:** Active／Closed／Candidate互斥且一致的Milestone routing；供R1-4關閉兩個Finding。

- [ ] 先記錄current contradiction與expected text contract，不修改central findings status。
- [ ] 將`docs/milestones/README.md`的Active section替換為：

```md
## Active routing

```txt
None
Template Baseline: 1.14.0
```

目前active authority：`docs/roadmap/active.md`。
```

- [ ] 將Milestone 32加入Closed milestone routing表：

```md
| 32 | Completed / Archived | accepted Design／Plan、`docs/audits/milestone_32/32-11_final_review.md`、`docs/audits/milestone_32/32-12_post_release_validation.md` |
```

- [ ] 將既有M32 artifact bullets移到`## Milestone 32 closed routing`，保留stable links；刪除Active語意與runtime counts，禁止複製Task checklist。
- [ ] 從`docs/roadmap/candidates.md`完整移除`## Completed — Milestone 32`及其closure routing；保留Additional Platform Support與Documentation Knowledge Expansion disposition原文。
- [ ] 執行exact semantic assertion：

```powershell
powershell -NoProfile -Command "$active = Get-Content docs/roadmap/active.md -Raw -Encoding UTF8; $milestones = Get-Content docs/milestones/README.md -Raw -Encoding UTF8; $candidates = Get-Content docs/roadmap/candidates.md -Raw -Encoding UTF8; if ($active -notmatch '(?s)目前active milestone：.*None') { throw 'active authority is not None' }; $activeSection = [regex]::Match($milestones, '(?s)## Active routing(.*?)## Closed milestone routing').Groups[1].Value; if ($activeSection -notmatch 'None' -or $activeSection -match 'Milestone 32') { throw 'milestone active routing mismatch' }; if ($milestones -notmatch '\| 32 \| Completed / Archived \|') { throw 'M32 missing from closed routing' }; if ($candidates -match 'Completed — Milestone 32' -or $candidates -match 'GitHub exact-ID cleanup') { throw 'M32 remains in candidate authority' }"
```

- [ ] 建立Task review，記錄focused findings、fix、fresh re-review、whole-Task authority判定與exact validation。
- [ ] 執行documentation gate：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Whole-Task review確認M1～M31 status、Roadmap active authority與platform candidate portfolio均未改變。
- [ ] 只stage本Task三份檔案，執行`git diff --cached --check`後commit：

```bash
git commit -m "docs(governance): 修正Milestone與Candidate authority"
```

**Task acceptance:** F-A1-01／F-A1-03 implementation evidence完成，但central findings仍保持Open直到R1-4。

---

## Task R1-2 — Documentation Hub and ADR Routing Repair

**Files:**

- Modify: `docs/README.md`
- Create: `docs/audits/r1_current_authority_contradiction_closure/r1_2_documentation_hub_adr_routing_review.md`

**Consumes:** Documentation Policy、canonical `docs/adr/README.md`、Finding `F-A1-02`。

**Produces:** 前後一致的canonical ADR routing與精確legacy boundary。

- [ ] 保存`docs/README.md`前段Architecture Decision authority與task-based reading route作為before evidence。
- [ ] 刪除Legacy段落中下列錯誤敘述：

```md
- `docs/adr/` 是第一階段 placeholder，不是正式 ADR 集合。
```

- [ ] 將Legacy段落改為只指向真正historical路徑：

```md
- `docs/architecture/` 是第一階段 historical／partially superseded guidance。
- 舊aggregate decision與已標記legacy的相容路徑只供歷史追溯；current Architecture Decision authority仍由`docs/adr/README.md`與canonical ADR records擁有。
```

- [ ] 執行exact semantic assertion：

```powershell
powershell -NoProfile -Command "$text = Get-Content docs/README.md -Raw -Encoding UTF8; if ($text -notmatch 'docs/adr/README\.md.*canonical ADR records') { throw 'canonical ADR authority missing' }; if ($text -match 'docs/adr/` 是第一階段 placeholder') { throw 'canonical ADR directory still degraded' }; if ($text -notmatch 'docs/architecture/` 是第一階段 historical') { throw 'historical architecture route missing' }"
```

- [ ] 建立Task review，逐段確認task-based reading route、ADR index與supersession graph未變。
- [ ] 執行documentation gate：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Whole-Task review確認沒有建立平行ADR authority，也沒有把所有legacy文件批量採納metadata。
- [ ] 只stage本Task兩份檔案，執行`git diff --cached --check`後commit：

```bash
git commit -m "docs(governance): 修正Documentation Hub ADR routing"
```

**Task acceptance:** F-A1-02 implementation evidence完成，但central finding仍保持Open直到R1-4。

---

## Task R1-3 — Human Entry and Design／Plan Index Repair

**Files:**

- Modify: `README.md`
- Modify: `docs/superpowers/README.md`
- Create: `docs/audits/r1_current_authority_contradiction_closure/r1_3_human_entry_design_plan_index_review.md`

**Consumes:** M31 accepted Spec／Plan metadata與R10／R11 closure、Template 1.14 Audit accepted Design／Plan／Final Review、Findings `F-A7-01`與`F-A7-03`。

**Produces:** 無stale future instruction的human entry，以及與linked artifacts一致的Design／Plan lifecycle index。

- [ ] 從root README移除整個`## 第一階段收尾流程`、M5-1～M5-3 future flow與重複的最終驗證命令；保留其後Android runtime、Auth persistence、安全邊界與Web注意事項原文。
- [ ] 將Template 1.14 Audit Plan摘要改為：

```md
- [`plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md`](plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md)：accepted Execution Plan；A1～A9、fresh full regression與B＋D Final Review均已完成並取得使用者核准，後續remediation依獨立Requirement Decision執行。
```

- [ ] 將M31 Plan摘要改為accepted historical routing，明確連到`docs/audits/milestone_31/31-r10_local_final_review.md`與`31-r11_post_release_validation.md`。
- [ ] 將M31 Design摘要改為accepted historical artifact，不再含`proposed`、`等待recovery`或`既有實作不等於設計已重新核准`。
- [ ] 將Template 1.14 Audit Design摘要補充Final Review已核准B＋D disposition；不得複製finding正文。
- [ ] 保留R1 Design與本Plan routing；本Plan在approval closure後必須顯示`accepted`，不得仍標`proposed`。
- [ ] 執行exact semantic assertion：

```powershell
powershell -NoProfile -Command "$root = Get-Content README.md -Raw -Encoding UTF8; $index = Get-Content docs/superpowers/README.md -Raw -Encoding UTF8; if ($root -match '第一階段 MVP 完成前' -or $root -match 'Milestone 5-1') { throw 'stale M5 future instruction remains' }; if ($index -match '原計畫已降回`proposed`' -or $index -match '等待Design Spec recovery') { throw 'M31 stale lifecycle remains' }; if ($index -notmatch '31-r11_post_release_validation\.md') { throw 'M31 closure route missing' }; if ($index -notmatch 'B＋D Final Review均已完成') { throw 'Audit accepted closure summary missing' }"
```

- [ ] 建立Task review，確認root README其餘current capability／security claims未被改寫，Superpowers index沒有取代linked artifacts。
- [ ] 執行documentation gate：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Whole-Task review確認只修正F-A7-01／F-A7-03與Design已納入的Audit lifecycle同步，不重寫其他Skill／Milestone歷史。
- [ ] 只stage本Task三份檔案，執行`git diff --cached --check`後commit：

```bash
git commit -m "docs(governance): 修正README與Design Plan routing"
```

**Task acceptance:** F-A7-01／F-A7-03 implementation evidence完成，但central findings仍保持Open直到R1-4。

---

## Task R1-4 — Cross-document Holistic Closure

**Files:**

- Create: `docs/audits/r1_current_authority_contradiction_closure/r1_4_holistic_final_review.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- Modify: `docs/audits/README.md`

**Consumes:** accepted Design／Plan、R1-1～R1-3 independent commits與reviews、five-finding allowlist、remaining-finding denylist。

**Produces:** five findings的exact closure evidence、cross-document consistency matrix、R1 final disposition與使用者Final Review Gate。

- [ ] 重新讀取R1-1～R1-3 committed files與reviews，建立Finding→file→commit→semantic assertion→validation矩陣。
- [ ] 逐項確認`F-A1-01`、`F-A1-02`、`F-A1-03`、`F-A7-01`、`F-A7-03`具備exact fix、focused review、fresh re-review、whole-Task review與independent commit。
- [ ] 僅將上述五項Status更新為`Resolved by R1`，加入Task commit與R1 final review route；不得改動其Severity、原始Evidence或Finding ID。
- [ ] 確認`F-A1-04`、`F-A2-01`、`F-A6-01`、`F-A7-02`仍含`Status：Open`。
- [ ] 將Current Summary更新為：

```txt
Confirmed findings: 9
Resolved by R1: 5
Open P0: 0
Open P1: 0
Open P2: 3
Open P3: 1
Open P1 without disposition: 0
```

- [ ] 更新`docs/audits/README.md`：新增R1 review directory routing，並把Template 1.14 A9摘要改為accepted B＋D closure，不再寫pending user gate。
- [ ] 建立R1 holistic final review，status先維持`proposed`，記錄scope、cross-document matrix、finding closure、remaining risks、validation與non-goals。
- [ ] 執行exact allowlist／denylist assertion：

```powershell
powershell -NoProfile -Command "$text = Get-Content docs/audits/template_baseline_1_14_project_holistic_audit/findings.md -Raw -Encoding UTF8; $resolved = @('F-A1-01','F-A1-02','F-A1-03','F-A7-01','F-A7-03'); $open = @('F-A1-04','F-A2-01','F-A6-01','F-A7-02'); foreach ($id in $resolved) { $block = [regex]::Match($text, '(?s)### ' + [regex]::Escape($id) + '.*?(?=\n### |\n## Current Summary)').Value; if ($block -notmatch 'Status：Resolved by R1') { throw ($id + ' not resolved') } }; foreach ($id in $open) { $block = [regex]::Match($text, '(?s)### ' + [regex]::Escape($id) + '.*?(?=\n### |\n## Current Summary)').Value; if ($block -notmatch 'Status：Open') { throw ($id + ' scope drift') } }"
```

- [ ] 執行跨文件semantic assertions，重新驗證Active=None、M32 Closed、Candidate無M32、canonical ADR唯一、README無M5 future、M31／Audit lifecycle accepted。
- [ ] Fresh documentation gate：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Whole-R1 review確認沒有R2～R5、platform portfolio、ADR、VERSION、CHANGELOG、source、test、workflow、release、merge、push或cleanup變更。
- [ ] 只stage本Task三份檔案，執行`git diff --cached --check`後建立final proposal commit：

```bash
git commit -m "docs(governance): 完成R1 current authority修復審查"
```

- [ ] 停在使用者R1 Final Review Gate。不得自動把holistic review轉為`accepted`。
- [ ] 使用者核准後，將R1 holistic final review更新為`accepted`，記錄明確核准，fresh重跑committed-state docs gate並建立獨立approval commit：

```bash
git commit -m "docs(governance): 核准R1 current authority修復結論"
```

- [ ] R1 accepted closure後停止。不得自動開始R2、merge、push或cleanup。

**Task acceptance:** 五個allowlisted findings Resolved、Open P0=0、Open P1=0、remaining four findings保持Open、working tree clean、R1 Final Review user-approved。

---

## Execution Model

R1-1～R1-4共享current authority與central findings，採串行`executing-plans`最安全。即使環境具備subagent，也不得平行修改同一index或findings register。

每個Task的固定流程：

```txt
implement
→ focused review
→ findings
→ fix
→ fresh focused re-review
→ whole-Task review
→ documentation authority check
→ required validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ next Task
```

## Plan Acceptance Gate

本Plan已於2026-08-01取得使用者明確核准並轉為`accepted`。開始R1-1前必須全部滿足：

1. Plan focused review與whole-Plan review通過。
2. Open planning P0=0。
3. Open planning P1 without disposition=0。
4. Documentation tests、`docs_check`與`git diff --check`fresh通過。
5. 使用者明確核准本Plan。
6. Plan與Plan Review轉為`accepted`並建立獨立approval commit。

上述條件均已完成；R1-1 implementation現已允許開始。此核准不包含R1 Final Review、R2～R5、merge、push或cleanup。

## Approval Closure

```txt
User approval: 核准 R1 Implementation Plan
Approval date: 2026-08-01
Plan proposal commit: 9d64b4ed6542c4ead5854593b46295af75624507
Plan status: accepted
Implementation allowed: Yes — R1-1～R1-4 only
```
