---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-documentation-authority-evidence
last_reviewed_baseline: 1.14.0
---

# A7 — Documentation and Current Authority Audit

## Scope

本Task依Documentation Governance Policy審查唯一authority、current／historical角色、metadata lifecycle、index routing、語意一致性與可控增長。

Checker是mechanical safety net，不取代prose semantic review。`last_reviewed_baseline`較舊只代表最近完整語意審查版本，不自動表示內容失效。

## Managed Document Inventory

2026-07-31 read-only inventory：

```txt
Markdown documents under docs/: 352
Managed metadata documents: 290
Unmanaged／legacy documents: 62

Largest managed types:
phase-review 116 / planning-review 39 / architecture-decision 27
final-review 25 / runtime-evidence 21 / implementation-plan 18
design-spec 17 / guide 11

Managed status:
accepted 195 / completed 67 / active 17 / legacy 7
proposed 2 / superseded 2
```

Baseline metadata從1.5.0至1.14.0皆存在，符合historical artifact保留當時baseline的政策。62份unmanaged文件主要是Milestone 22前historical audits、archive、legacy architecture／mistakes knowledge與舊分Task plans；Legacy Adoption Rule不要求無語意review的批次metadata補齊。

## Current Authority Graph

```txt
AGENTS.md → AI entry／mandatory workflow
README.md → Human entry／template positioning
docs/README.md → Documentation hub／reading route
docs/project_context.md → Current-only snapshot
docs/adr/README.md + canonical ADRs → Architecture decisions
docs/roadmap.md + active／candidates／backlog → Direction authority
docs/superpowers/README.md → Design／Plan routing
docs/audits/README.md → Review／runtime evidence routing
docs/milestones/README.md → Milestone archive routing
VERSION + CHANGELOG.md → Release identity／content
source + tests + current runtime evidence → Production truth
```

本Audit只保存finding與evidence，不取代Project Context、Roadmap、ADR或release authority。

## Semantic Candidate Disposition

### `docs/README.md` canonical ADR與legacy placeholder wording

**Confirmed，既有`F-A1-02`。** 同一Hub先指定`docs/adr/README.md`與canonical records為正式authority，後面又把整個`docs/adr/`稱為第一階段placeholder。Milestone 23後後段說法已失效。

### `docs/milestones/README.md` Active routing列Completed Milestone 32

**Confirmed，既有`F-A1-01`。** Active authority為None，Milestone index的Active section仍列M32 Completed。

### Root README Milestone 5 future-tense MVP closure

**Confirmed，新增`F-A7-01`。** README頂部已宣告Phase 1／MVP Completed與Baseline 1.14.0，後段仍寫「第一階段MVP完成前，Milestone 5會……」及5-1～5-3 future flow。這不是明確historical note。

### `docs/roadmap/candidates.md` Completed Milestone 32正文

**Confirmed，既有`F-A1-03`。** Candidate authority自述只保存尚未核准方向，卻保留已完成M32 closure正文。

### `docs/project_context.md` current-only與Milestone journal回流

**Confirmed，新增`F-A7-02`。** 文件明文宣稱不保存逐Milestone journal，但421行中有15次Milestone reference，13個段落直接以Milestone編號開頭，逐一記錄19～30完成、封存、baseline與演進。

部分內容支撐current capability，但以chronology呈現，使固定最小讀取集重新累積release journal。後續應保留current capability／limitations，把「哪個Milestone完成、當時baseline」路由至Milestone／Audit／CHANGELOG。

### Local README／ADR baseline metadata較舊

**Not an issue by age alone。** Policy不要求每次release機械更新。A2～A5抽查ADR-022～026與App／Package／Feature README語意仍與current source／claims一致；不做bulk baseline bump。

### `docs/superpowers/README.md` Milestone 31 routing

**Confirmed，新增`F-A7-03`。** Current index仍稱M31 Design／Plan降回`proposed`並等待recovery；實際Spec／Plan metadata為accepted，31-r11記錄user-approved與Completed／Archived。這是過期current routing，不是可接受historical note。

## Navigation and Growth Assessment

### Reasonable preservation

- Per-Task／final／runtime evidence保存在`docs/audits/`並按需路由。
- Accepted Specs／Plans保留追溯性，不宣稱implementation current state。
- Pre-M22 legacy files沒有被機械標成accepted。
- Archive不強制物理搬檔，避免link breakage。

### Current drift

- Milestone index未完成M32 Active→Closed transition。
- Superpowers index未同步M31 recovery closure。
- Documentation Hub保留Milestone 23前ADR placeholder敘述。
- Candidate index保留completed M32正文。
- Project Context由current snapshot回流為Milestone chronology。

Root README完整Milestone清單可作高階狀態摘要，但M5 future section需刪除或明確歷史化。

## Checker Coverage

Current checker可捕捉link、release版本、metadata、ID、active milestone metadata與README coverage；無法可靠判斷：

- Active section內的Completed prose。
- Canonical ADR與legacy paragraph語意衝突。
- Future-tense M5是否過期。
- Project Context是否過度journal化。
- Index摘要是否與linked artifact lifecycle一致。

F-A1-01、F-A1-02與F-A7-03具穩定cross-file fields，修復時可評估低誤報checker；F-A7-01／02依賴語意，不應建立脆弱keyword rule。本Audit不修改checker。

## Bounded Remediation Direction

1. 修正current indexes／hub的明確contradiction。
2. 移除或歷史化Root README M5 future section。
3. 將Project Context的Milestone chronology收斂為current capability／limitation。
4. 保留historical audits、Plans與legacy docs原位，除非另有migration manifest。
5. 不做bulk metadata baseline bump。

## Validation and Review

```txt
Documentation unit tests: 19 passed
docs_check: passed
Managed docs inventoried: 290
Unmanaged／legacy docs inventoried: 62
Metadata-age-only findings: 0
```

- 每個initial candidate皆有Confirmed或Not-an-issue disposition。
- Finding不依baseline age或文件數量單獨成立。
- Audit自身沒有改寫current authority。
- 新增三個findings均有exact owner與bounded remediation。

## Task Disposition

```txt
Documents inventoried: 352
Existing findings confirmed: F-A1-01, F-A1-02, F-A1-03
New findings: F-A7-01, F-A7-02, F-A7-03
Open P0: 0
Open P1 without disposition: 0
Task A7: ACCEPTED
```
