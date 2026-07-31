---
document_type: implementation-plan
status: accepted
authoritative_for:
  - r2-project-context-current-only-rationalization-plan
last_reviewed_baseline: 1.14.0
---

# R2 — Project Context Current-only Rationalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將`docs/project_context.md`恢復為可維護的current-only snapshot，在不遺失任何current capability／platform／security／CI claim的前提下移除Milestone chronology，並關閉`F-A7-02`。

**Architecture:** R2-1先建立逐段preservation matrix且不得修改Project Context；R2-2依matrix做有界rewrite與machine-readable claim preservation；R2-3才更新central finding並完成holistic final review。所有歷史內容路由至既有Milestone、Audit、CHANGELOG、Archive或Git owner。

**Tech Stack:** Markdown、YAML front matter、Python／PowerShell semantic assertions、Git、repository documentation checker、Melos `docs_check`。

## Global Constraints

- Design authority：`docs/superpowers/specs/2026-08-01-r2-project-context-current-only-rationalization-design.md`。
- Design commit：`bd2de0f350b6e4c2fffed8420c84883806b38535`。
- Design status必須維持`accepted`。
- Branch：`audit/template-baseline-1.14-project-holistic`；不得在`main`修改。
- Finding owner：只允許關閉`F-A7-02`。
- Remaining findings：`F-A1-04`、`F-A2-01`、`F-A6-01`必須保持Open。
- R1 resolved findings不得回退。
- 不修改production、tests、workflow、platform、ADR、Roadmap、Backlog、VERSION或CHANGELOG。
- 不執行R3、R4、R5。
- 不merge、不push、不刪branch／worktree、不release。
- Standing authorization只適用於沒有新scope／architecture decision的R2治理鏈。
- 每個Task必須完成focused review、finding修正、fresh re-review、whole-Task review、authority check、validation與獨立commit。

---

## Artifact Map

### Governance

- Design：`docs/superpowers/specs/2026-08-01-r2-project-context-current-only-rationalization-design.md`
- Design review：`docs/audits/r2_project_context_current_only_rationalization_design_review.md`
- Plan：`docs/superpowers/plans/2026-08-01-r2-project-context-current-only-rationalization.md`
- Plan review：`docs/audits/r2_project_context_current_only_rationalization_plan_review.md`

### Implementation evidence

```txt
docs/audits/r2_project_context_current_only_rationalization/
  preservation_matrix.md
  r2_1_preservation_matrix_review.md
  r2_2_current_only_rewrite_review.md
  r2_3_holistic_final_review.md
```

---

## Task R2-P — Plan Governance

**Files:**

- Create: `docs/superpowers/plans/2026-08-01-r2-project-context-current-only-rationalization.md`
- Create: `docs/audits/r2_project_context_current_only_rationalization_plan_review.md`
- Modify: `docs/superpowers/README.md`
- Modify: `docs/audits/README.md`

**Produces:** exact R2-1～R2-3 sequencing、preservation contract、semantic assertions、finding closure guard與commit boundaries。

- [ ] 對照Design確認Requirement Decision、matrix、section contract、current fact re-home、historical routing、semantic invariants與non-goals都有Task owner。
- [ ] 執行placeholder scan與exact path review。
- [ ] 完成focused Plan review並修正planning findings。
- [ ] 完成whole-Plan review，確認R2-1可以在不修改Project Context的情況下獨立接受。
- [ ] Fresh validation：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] 使用2026-08-01 standing authorization記錄Plan approval，Plan／Review保持`accepted`。
- [ ] 只stage本Task四份artifact，執行`git diff --cached --check`後commit：

```bash
git commit -m "docs(governance): 核准R2 current snapshot rationalization計畫"
```

**Acceptance:** accepted Plan、Open planning P0=0、Open planning P1 without disposition=0、working tree clean。

---

## Task R2-1 — Preservation Matrix

**Files:**

- Create: `docs/audits/r2_project_context_current_only_rationalization/preservation_matrix.md`
- Create: `docs/audits/r2_project_context_current_only_rationalization/r2_1_preservation_matrix_review.md`

**Consumes:** committed pre-R2 `docs/project_context.md`、R2 Design section contract、current Milestone／Audit／CHANGELOG／Guide routes。

**Produces:** 每個chronology段落與`Active Work`段落的Preserve／Re-home／Replace／Remove disposition，供R2-2唯一執行依據。

- [ ] 記錄Project Context pre-change blob：

```bash
git rev-parse HEAD:docs/project_context.md
```

- [ ] 執行pre-change RED inventory，記錄Milestone paragraph、release chronology與exact evidence count：

```powershell
powershell -NoProfile -Command "$t = Get-Content docs/project_context.md -Raw -Encoding UTF8; $m = [regex]::Matches($t, '(?m)^Milestone\s+\d+'); $r = [regex]::Matches($t, 'Template Baseline.*(?:封存|提升|發布)'); $e = [regex]::Matches($t, '(?:bytes|objects|manifest|release SHA)'); Write-Output ('milestone_paragraphs=' + $m.Count); Write-Output ('release_chronology=' + $r.Count); Write-Output ('exact_evidence_terms=' + $e.Count); if ($m.Count -lt 10) { throw 'expected chronology not reproduced' }"
```

- [ ] 建立matrix，每個原chronology／Active Work段落一列，必須包含exact current owner與historical route。
- [ ] Matrix至少覆蓋：M19～M30 baseline chronology、CI aggregation paragraph、M32／M30／M31／M26 Active Work paragraphs。
- [ ] 對iOS 15、CI modes、managed artifact store、flavor identity、observability、connectivity、Drift與testing governance逐項標記current fact去向。
- [ ] Focused review確認沒有`Remove`列同時包含無替代owner的current fact。
- [ ] Whole-Task review確認本Task未修改`docs/project_context.md`。
- [ ] Fresh validation：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] 只stage兩份R2-1 artifact並commit：

```bash
git commit -m "docs(governance): 建立Project Context preservation matrix"
```

**Acceptance:** matrix完整、Project Context blob未變、Open P0=0、Open P1 without disposition=0。

---

## Task R2-2 — Current-only Rewrite

**Files:**

- Modify: `docs/project_context.md`
- Create: `docs/audits/r2_project_context_current_only_rationalization/r2_2_current_only_rewrite_review.md`

**Consumes:** committed preservation matrix及pre-change blob。

**Produces:** 無Milestone chronology的current snapshot，且current claims可由semantic assertions定位。

- [ ] 將`Current Baseline`保留為五項current identity，刪除其後M19～M30 chronology與CI演進paragraph。
- [ ] 在`Current Capabilities`新增`### Connectivity and Offline State`，只保留typed authority、startup／resume recheck、offline banner、Catalog reconnect revalidation與backend reachability boundary。
- [ ] 在`Current Capabilities`新增`### Delivery and Verification`，保留change-aware CI、三種execution modes、managed local artifact store與GitHub transport exception；細節連到CI guide。
- [ ] 確認iOS 15.0 current deployment baseline在Platform section可定位；必要時補一句current contract，不寫Milestone來源。
- [ ] 將`## Active Work`整段替換為`## Current Work and Maintenance State`，只保留Active=None、latest completed initiative route與maintenance intake rule。
- [ ] 刪除manifest ID、object／byte counts、release SHA、逐initiative completion與remote validation歷史。
- [ ] 保留Documentation Routing、Verification Commands與Update Rule，並讓Update Rule明確禁止release／runtime evidence journal。
- [ ] 執行chronology removal assertion：

```powershell
powershell -NoProfile -Command "$t = Get-Content docs/project_context.md -Raw -Encoding UTF8; if ([regex]::IsMatch($t, '(?m)^Milestone\s+\d+')) { throw 'milestone chronology remains' }; if ($t -match 'Template Baseline.*(?:封存|提升|發布)') { throw 'release chronology remains' }; if ($t -match '7ad138bb845e42cbb133d07c|10,247,881,699|113次attempt|release SHA') { throw 'exact historical evidence remains' }; if ($t -match '^## Active Work' ) { throw 'Active Work journal section remains' }"
```

- [ ] 執行current claim preservation assertion，至少確認：Baseline 1.14.0、Active None、M32 latest route、ADR authority、Android／iOS Supported、其餘四平台Dependency-ready、Auth／OTP／Biometric／Catalog／Design System／Localization／Failure／Drift／Connectivity、CI三種模式、managed local artifact store、production signing deferred。
- [ ] Focused review逐列對照matrix，任何遺失current fact必須修正並fresh re-run。
- [ ] Whole-document review確認沒有新增第二份Guide／ADR／Roadmap authority。
- [ ] Fresh validation：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] 只stageProject Context與R2-2 review並commit：

```bash
git commit -m "docs(governance): 收斂Project Context current-only snapshot"
```

**Acceptance:** chronology assertions與current claim preservation全部通過，Project Context current-only contract成立。

---

## Task R2-3 — Holistic Closure

**Files:**

- Create: `docs/audits/r2_project_context_current_only_rationalization/r2_3_holistic_final_review.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- Modify: `docs/audits/README.md`

**Consumes:** R2 Design／Plan、R2-1 matrix commit、R2-2 rewrite commit與reviews。

**Produces:** `F-A7-02` exact closure evidence、remaining finding preservation與accepted R2 final review。

- [ ] 建立matrix→rewrite→assertion→commit evidence chain。
- [ ] 僅將`F-A7-02`改為`Status：Resolved by R2`，保留Finding ID、Severity、原Evidence與Recommendation。
- [ ] 確認`F-A1-04`、`F-A2-01`、`F-A6-01`仍為Open，R1五個Findings仍為Resolved by R1。
- [ ] 更新summary：Resolved by R1=5、Resolved by R2=1、Open P0=0、Open P1=0、Open P2=2、Open P3=1。
- [ ] 建立accepted R2 holistic final review，記錄standing authorization、current claim matrix、validation與remaining risks。
- [ ] 更新Audit index route，不複製Project Context正文。
- [ ] Fresh重跑R2-2全部semantic assertions與documentation gate。
- [ ] Whole-R2 scope review確認只修改R2 artifacts、Project Context、central finding與routing indexes。
- [ ] 只stage三份R2-3 files並commit：

```bash
git commit -m "docs(governance): 完成R2 Project Context rationalization"
```

- [ ] Committed-state重跑documentation gate，確認working tree clean。

**Acceptance:** `F-A7-02` Resolved、remaining three findings保持Open、Open P0=0、Open P1=0、working tree clean；不得自動merge／push／cleanup。

---

## Execution Order

```txt
R2-P
→ R2-1 preservation matrix
→ R2-2 current-only rewrite
→ R2-3 holistic closure
```

R2-1與R2-2不得合併commit，否則無法證明rewrite依據在正文修改前已完成。

## Plan Approval Closure

```txt
Focused Plan review: PASSED after findings disposition
Whole-Plan review: PASSED
Open planning P0: 0
Open planning P1 without disposition: 0
User authorization: covered by standing authorization on 2026-08-01
Plan status: ACCEPTED
Implementation allowed: YES after Plan approval commit
```
