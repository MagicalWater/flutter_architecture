---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-repository-baseline-evidence
last_reviewed_baseline: 1.14.0
---

# A1 — Repository Baseline、Authority and Evidence Ledger

## Scope

本Task鎖定Template Baseline 1.14.0整體總審查的exact Git、release、worktree、文件authority與可重用evidence基線。

本文件不修改current project state，不清理branch／worktree，也不把historical review當成current truth。

## Exact Baseline

執行日期：2026-07-31。

```txt
Audit branch: audit/template-baseline-1.14-project-holistic
Audit HEAD: dd8e51ff9cc54c204d0b4a15625a14462975d6f6
Accepted audit Design commit: b966030
Proposed audit Plan commit: 4b7d06a
Accepted audit Plan commit: dd8e51f
Initial main baseline: b3c71b6264227050180ffb5be62b14bbfb8e19aa
Local main: b3c71b6264227050180ffb5be62b14bbfb8e19aa
origin/main: b3c71b6264227050180ffb5be62b14bbfb8e19aa
VERSION: 1.14.0
Active milestone: None
Working tree before A1 evidence: clean
```

Audit branch相對`main`為`0 behind／3 ahead`，三個commit全部屬本Audit Design／Plan治理，不是未記錄的產品或Milestone變更。

## Worktree and Branch Ledger

| Path／Branch | HEAD | State | Ancestry／Disposition |
|---|---|---|---|
| `D:/Developer/flutter_architecture`／`main` | `b3c71b6` | Clean | 與`origin/main`一致，是initial current authority。 |
| `C:/Users/crazy/.devspace/worktrees/flutter_architecture-33cfb473`／Audit branch | `dd8e51f` | Clean before A1 | 隔離Audit worktree，僅含三個approved planning commits。 |
| `C:/Users/crazy/.devspace/worktrees/flutter_architecture-59fd973d`／Milestone 32 branch | `bc5bc17` | 先前交接確認clean | Branch完全為`main` ancestor；沒有只存在該branch而未進入main的closure commit。 |
| `origin/milestone-32-ci-artifact-storage-cutover` | `f4f6a8e` | Remote historical ref | 落後local historical branch與main，但不影響1.14.0 closure authority。 |

Milestone 32 branch／worktree殘留只形成repository hygiene finding `F-A1-04`。本Audit禁止cleanup，因此不刪除、不reset、不rebase。

## Release Identity Review

`VERSION`、`docs/roadmap/active.md`、`CHANGELOG.md`與Milestone 32 final／post-release evidence均指向Template Baseline 1.14.0。

`docs/roadmap/active.md`明確記錄：

```txt
Active milestone: None
Latest completed: Milestone 32
Template Baseline: 1.14.0
```

沒有發現未提交、未推送或只存在舊worktree的Milestone 32 closure內容。

## Authority Owner Map

| Information | Current authoritative owner | Supporting／historical evidence | Boundary |
|---|---|---|---|
| AI操作與工作入口 | `AGENTS.md` | repository-local Skills、governance guide | Chat紀錄不取代repository policy。 |
| 人類入口、模板定位與快速開始 | root `README.md` | App／Feature／Package README | README不得成為Roadmap或release journal。 |
| Current project snapshot | `docs/project_context.md` | ADR、source、tests、current runtime evidence | Historical milestone narrative不得覆蓋current source。 |
| Architecture decisions | `docs/adr/README.md`與canonical ADR files | superseded legacy paths、historical audits | Aggregate／legacy文件不能建立平行authority。 |
| Current／candidate roadmap | `docs/roadmap.md`、`docs/roadmap/active.md`、`docs/roadmap/candidates.md` | Milestone index、handoff audits | Completed item不應持續表現為candidate。 |
| Deferred／rejected scope | `docs/backlog.md` | candidate reviews、historical plans | Backlog不代表commitment。 |
| Design／Plan | `docs/superpowers/` | planning reviews | Accepted artifact定義scope／execution，不代表implementation完成。 |
| Review／runtime evidence | `docs/audits/` | artifacts、command outputs、remote runs | Audit不取代current snapshot或ADR。 |
| Milestone routing | `docs/milestones/README.md` | final reviews、CHANGELOG、Git history | Routing index不應成為第二份active roadmap。 |
| Reusable procedures | `docs/guides/` | scripts、tests | Guide描述操作，不擁有runtime結果。 |
| Release version | `VERSION` | `CHANGELOG.md`、release review | App store version不等於Template Baseline。 |
| Production behavior | source | tests、runtime evidence | 文件claim必須受source／tests支持。 |
| Regression contract | current tests／CI contracts | testing governance、historical inventories | Historical test inventory不代表current test count。 |
| CI／platform execution | current workflows、scripts、tracked native config | remote／managed evidence | Supported不等於signed、physical-device或Store-ready。 |

## Reusable Evidence Ledger

| Evidence | Reusable scope | Cannot replace |
|---|---|---|
| Milestone 18 holistic audit | Audit methodology、舊風險分類與baseline比較起點 | 1.14.0 current architecture、capability、tests、CI或platform conclusion。 |
| Milestone 30 final／post-release review | Test governance、production／historical boundary、當時full regression | Current test inventory、current duplication assessment、Milestone 31／32後的CI成本。 |
| Milestone 31 recovery／post-release review | Requirement Decision、Full Task governance與Skill adoption evidence | Product architecture、runtime capability或未來方向判定。 |
| Milestone 32 final／post-release review | Managed artifact contract、1.14.0 release SHA、Windows／Mac／self-hosted evidence與GitHub cleanup | Current no-growth inventory、整體文件authority、其他runtime flows。 |
| Milestone 19～29 domain reviews | Auth、OTP、Biometric、CI、iOS、identity、Observability、Connectivity、Drift的bounded historical evidence | Current source／test reading及cross-domain consistency review。 |

## Confirmed Current Authority Findings

### `F-A1-01` — Milestone index把Completed Milestone 32放在Active routing

`docs/milestones/README.md`的Status rule指定Active以`docs/roadmap/active.md`為準；後者明確為None，但同一Milestone index仍在`## Active routing`列出Milestone 32，且其狀態文字是Completed。

這是current navigation contradiction，不影響release identity，但可能讓進入repository的執行者誤判仍有active milestone。

### `F-A1-02` — Documentation Hub對`docs/adr/`的authority自相矛盾

`docs/README.md`前段將`docs/adr/README.md`與canonical ADR records定義為Architecture Decision authority，後段卻把整個`docs/adr/`描述為「第一階段 placeholder，不是正式ADR集合」。

Current repository實際已在Milestone 23完成canonical ADR extraction；後段legacy wording會把正確入口降級成非正式路徑。

### `F-A1-03` — Candidate authority保留已完成Milestone 32正文

`docs/roadmap/candidates.md`明確聲明只保存尚未核准為active的candidate，卻保留`Completed — Milestone 32`完整closure routing。內容本身沒有錯，但位於current candidate authority會增加第二份closed routing並弱化candidate-only語意。

### `F-A1-04` — 已合併Milestone 32 branch／worktree殘留

Local historical branch完全為main ancestor，工作樹先前確認clean，沒有遺失內容。風險限於operator hygiene、錯誤進入舊worktree與branch列表噪音，不是1.14.0 blocker。

## Candidates Deferred to A7 Semantic Review

下列項目只在A1記為candidate，不在未完成語意審查前建立finding：

- Root README仍以current tense描述「第一階段MVP完成前，Milestone 5會……」。
- `docs/project_context.md`宣稱current-only，但保存大量Milestone 19～32敘事與closure細節。
- 多份local README／ADR的`last_reviewed_baseline`早於1.14.0；metadata較舊不等於內容過期。
- `docs/audits/README.md`在Plan核准後仍把Plan描述為proposed；本Task已因其屬Audit routing而同步為accepted，不列為current project finding。

## Focused Review

- Baseline commands於accepted Plan後fresh執行。
- `main`與`origin/main` exact SHA一致。
- VERSION、active milestone與Milestone 32 closure identity一致。
- 所有non-main branches均完成ancestry檢查。
- Historical evidence均標記reuse boundary，沒有被當作current source evidence。
- 四個confirmed findings都有可重現path與風險；未完成語意確認的項目仍維持candidate。

## Task Disposition

```txt
Baseline identity: PASSED
Authority owner map: COMPLETE
Evidence reuse ledger: COMPLETE
Confirmed findings added: F-A1-01 through F-A1-04
Open P0: 0
Open P1 without disposition: 0
Current source／Roadmap／VERSION mutation: 0
Branch／worktree cleanup: NOT PERFORMED
Task A1: ACCEPTED
```
