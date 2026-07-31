---
document_type: design-spec
status: accepted
authoritative_for:
  - r2-project-context-current-only-rationalization-design
last_reviewed_baseline: 1.14.0
---

# R2 — Project Context Current-only Rationalization Design

## Requirement Decision

- Request（需求）：修復`docs/project_context.md`宣稱current-only，卻重新累積Milestone chronology的矛盾。
- Problem（問題）：固定最小讀取集混入Milestone 19～32完成歷史、release敘述、commit／runtime counts與過去治理過程，current facts與historical narrative失去責任邊界。
- Current behavior（目前行為）：文件約四百餘行，包含多段以Milestone編號開頭的時間線，以及`Active Work`中的已完成initiative journal。
- Expected behavior（預期行為）：只保留目前仍有效的baseline、repository purpose、ownership、architecture、technology、capability、platform／security boundary、active state、routing與verification contract；歷史演進改由Milestone、Audit、CHANGELOG與Git history擁有。
- Value（價值）：降低固定讀取成本、避免每個Milestone都回流current snapshot、提高Agent／maintainer判斷current truth的可靠性。
- Classification（分類）：Level 3 — Cross-cutting semantic documentation architecture。
- Decision（決策）：Accept。
- Scope（範圍）：`docs/project_context.md`的section preservation、current fact re-home、chronology removal與R2 review evidence；必要index只新增routing。
- Non-goals（非目標）：不改production、tests、workflow、platform、ADR、Roadmap、Backlog、VERSION、CHANGELOG；不處理R3、R4、R5；不建立新Milestone；不merge、不push、不release。
- Behavioral requirements required（是否需要行為需求）：Yes，文件讀取與authority行為是本次主要contract。
- Design Spec required（是否需要Design Spec）：Yes。
- Implementation Plan required（是否需要Implementation Plan）：Yes。
- ADR required（是否需要ADR）：No；current snapshot ownership既有policy不改變。
- Task governance mode（Task治理模式）：Full。
- Worktree／branch：既有隔離branch `audit/template-baseline-1.14-project-holistic`。
- Regression level（Regression等級）：Documentation unit tests、`docs_check`、semantic preservation matrix、cross-authority review。
- Release required（是否需要發布）：No。
- Post-release validation（發布後驗證）：No。
- Required Superpowers skills（必要Skills）：brainstorming、writing-plans、executing-plans、verification-before-completion。
- Required artifacts（必要artifacts）：Design／Review、Plan／Review、preservation matrix、implementation review、holistic final review。

## User Authorization

使用者於2026-08-01核准R1 Final Review時，明確授權依既定治理自動推進剩餘remediation tasks；只有scope／architecture決策、external blocker或推翻既有核准的P0／P1才停止。

R2沒有新增產品、architecture或portfolio decision，因此該standing authorization適用於本Design、Plan與implementation治理鏈。它不包含merge、push、remote branch deletion或release。

## Design Goals

1. 消除`F-A7-02`的current-only／Milestone journal矛盾。
2. 不因刪除chronology而遺失仍有效的current facts。
3. 每項保留資訊都能回答「目前是什麼」，而非「何時完成」。
4. 每項歷史資訊都有既有owner route，不在current snapshot留下第二份歷史摘要。
5. 防止未來再次把Milestone completion、commit hash、測試數或runtime counts追加回本文件。

## Considered Approaches

### A — Mechanical chronology deletion

直接刪除所有含`Milestone`的段落。成本最低，但會同時遺失current iOS 15 baseline、CI execution modes、managed local artifact store、Drift authority與testing governance等仍有效資訊。

**Rejected。**

### B — Preservation matrix + current fact re-home

逐段分類為Preserve、Re-home、Replace或Remove。Current facts放回對應current section，歷史原因、版本與完成過程移至既有historical owners。

**Selected。**

### C — Full document rewrite

從空白重新撰寫Project Context。可大幅縮短，但容易漏掉capability／security boundary，review diff也難以證明語意保全。

**Rejected。**

## Section Contract

### Preserve with bounded edits

- `Purpose and Authority`
- `Current Baseline`
- `Project Purpose`
- `Repository Map`
- `Architecture Boundaries`
- `Current Technology Map`
- `Current Capabilities`
- `Platform Capability`
- `Security and Support Boundaries`
- `Documentation Routing`
- `Standard Verification Commands`
- `Update Rule`

### Replace

`## Active Work`改為`## Current Work and Maintenance State`。

新section只允許：

- `Current active milestone: None`。
- Latest completed initiative的一行routing。
- Maintenance工作必須先走Requirement Decision的規則。
- Audit／remediation progress只提供authority route，不保存Task／commit journal。

### Remove from current snapshot

- Milestone 19～32逐項完成敘述。
- Template Baseline 1.x release chronology。
- Remote validation、artifact count、byte count、exact manifest、commit／SHA等歷史evidence。
- 「先前完成什麼、後來又加入什麼」的演進敘事。
- 已完成initiative在`Active Work`中的多段journal。

## Preservation Matrix Contract

Implementation前建立`docs/audits/r2_project_context_current_only_rationalization/preservation_matrix.md`，每個被刪除或移動的原段落必須記錄：

| Field | Meaning |
|---|---|
| Source section | 原section |
| Source fact | 原段落的可識別摘要 |
| Classification | Preserve／Re-home／Replace／Remove |
| Current owner | 保留後的current section或既有authority |
| Historical route | Milestone／Audit／CHANGELOG／Git route |
| Verification | 如何證明current claim未遺失 |

禁止使用「已由其他文件處理」等模糊描述；必須給出exact route。

## Current Fact Re-home

### Delivery and Verification

在`Current Capabilities`新增`### Delivery and Verification`，只保存目前仍有效的contract：

- Change-aware CI會依changed scope選擇documentation-only、workspace與platform gates，unknown classification fail-safe到完整矩陣。
- CI execution modes為`manual-local`、`self-hosted`與`github-hosted`。
- Manual-local／self-hosted raw evidence由checkout外managed local artifact store擁有，包含manifest、SHA-256、retention、capacity、pin與trash restore。
- GitHub-hosted artifact transport只供明確例外。
- Production signing、Store distribution與repository Branch Protection settings不在baseline內。

操作細節只連到`docs/guides/ci_cd_operations.md`，不複製runtime counts。

### Platform and capability facts

以下current facts已在既有section擁有，不再於Baseline chronology重複：

- iOS deployment baseline 15.0：Platform／native current contract owner。
- Environment／flavor identity：Environment and API Composition與adoption guide。
- Observability：Exception and Failure Architecture、security boundary與CI guide。
- Connectivity：App responsibility與current capability。
- Drift：Persistence and Platform與Credential Persistence。
- Testing governance：Standard Verification與testing guide route。

若現有section缺少必要current fact，只補一句current contract與authority link，不補Milestone來源。

## Historical Routing

- Milestone completion與artifact route：`docs/milestones/README.md`。
- Review／runtime evidence：`docs/audits/README.md`及對應directory。
- Release identity與內容：`VERSION`、`CHANGELOG.md`。
- 已封存摘要：`docs/archive/`。
- Exact commit history：Git history。

Project Context只需說明以上routing，不重複歷史正文。

## Semantic Invariants

R2完成後必須同時成立：

1. 文件仍明確自述`current-only snapshot`。
2. `Current Baseline`仍含Baseline 1.14.0、MVP Completed、Active milestone None、latest completed initiative與ADR authority。
3. 不再存在以`Milestone <number>`開頭的chronological paragraphs。
4. 不再存在`Template Baseline提升為`、`以Template Baseline ...封存`等release chronology。
5. 不再含exact cleanup object／byte counts、manifest ID或release SHA。
6. Android／iOS／Web／Windows／macOS／Linux classification保持不變。
7. Auth、OTP、Biometric、Catalog、Design System、Localization、Failure、Persistence與Connectivity current claims保持可定位。
8. CI modes與managed local artifact store current contract仍可定位。
9. R1已修復的current authority contract不得回退。
10. `F-A7-02`以外的remaining findings不得改變status。

## Task Design

### R2-D／R2-P — Governance artifacts

建立並核准Design、Plan及各自Review；standing authorization只在沒有新decision時使用。

### R2-1 — Preservation Matrix

逐段盤點Project Context chronology，建立保留／歸位／刪除證據；不修改Project Context正文。

### R2-2 — Current-only Rewrite

依matrix最小修改Project Context，新增Delivery and Verification、替換Active Work並刪除chronology。

### R2-3 — Holistic Closure

重新對照current capability／platform／security矩陣，只將`F-A7-02`標記`Resolved by R2`，其餘findings保持原狀，建立R2 Final Review。

## Validation

每個Task至少執行：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

R2-2／R2-3另執行machine-readable semantic assertions，確認chronology清除與current facts保全。

不執行Flutter tests、analyze或platform build，因本Design禁止runtime、dependency、workflow與platform mutation。

## Acceptance Criteria

- Project Context不再保存Milestone chronology或release／runtime evidence counts。
- Current capability、platform、安全、CI與persistence claims無遺失或降級。
- `Current Work and Maintenance State`不形成新的Task journal入口。
- `F-A7-02`有matrix、focused review、fresh validation、whole-document review與獨立commit evidence。
- Open P0=0；Open P1 without disposition=0。
- Working tree clean。
- 未merge、未push、未release。

## Design Approval Closure

```txt
Focused Design review: PASSED after findings disposition
Whole-Design review: PASSED
Open Design P0: 0
Open Design P1 without disposition: 0
User authorization: covered by standing authorization on 2026-08-01
Design status: ACCEPTED
```
