# Milestone 22-0 — Documentation Governance Planning Review

## Review Status

```txt
Milestone: 22 — Documentation Authority & Navigation Foundation
Phase: 22-0 — Documentation Governance Planning Review
Status: Approved for phased implementation
Template Baseline: 1.5.0
Production code changes: None
Large-scale document migration: Not authorized
```

本文件固定 Milestone 22 的文件治理決策、planning findings、phase boundary、review gate 與後續 implementation scope。本階段只建立治理規格與執行計畫，不搬移、拆分或刪除既有大型文件。

## Reviewed Baseline

審查範圍包含 root governing documents、`docs/` 全目錄、App／Feature／Package README 與缺失 README。

實際盤點：

```txt
docs/**/*.md: 66
Feature README: 5
Package README: 1
App README: 0

README.md                         602 lines
CHANGELOG.md                      591 lines
docs/project_context.md         1297 lines
docs/architecture_decisions.md  3164 lines
docs/roadmap.md                 2217 lines
```

正式設計輸入：

```txt
docs/superpowers/specs/
  2026-07-21-documentation-authority-navigation-foundation-design.md
```

## Approved Governance Decisions

### M22-PD01 — Authority before migration

先固定 document type、authoritative scope、AI reading route、update trigger、archive trigger 與 migration manifest，再進行物理拆分。單純拆檔不構成治理改善。

### M22-PD02 — Split by responsibility, not size

行數與大小只觸發 responsibility review。文件拆分邊界必須是 authority 或 lifecycle 邊界，不得按固定行數分卷。

### M22-PD03 — Bounded active reading path

目標每次進入 repository 只需讀：

```txt
AGENTS.md
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

其他 Decision、README、Plan、Audit 與 Archive 依 task routing 按需讀取。

### M22-PD04 — Roadmap target model

Roadmap 採：

```txt
index
active
candidates
closed milestone routing
```

完成 milestone 的逐 Task journal、review 與 runtime evidence 不再留在 active Roadmap。

### M22-PD05 — Decision target model

`architecture_decisions.md` 最終成為 Decision index，Decision 001–022 保留 ID 並分批 semantic extraction。Milestone 22 不直接完成全面 extraction。

### M22-PD06 — Current Project Context

`project_context.md` 最終只描述現在有效的 baseline、architecture map、capabilities、constraints、active direction 與 documentation routing。歷史 milestone journal、commit、測試數與過去 next step 必須離開 current snapshot。

### M22-PD07 — CHANGELOG remains one file

目前保留單檔 CHANGELOG。先固定未來 release entry responsibility；是否抽取既有 detailed journal 需後續獨立 review。

### M22-PD08 — README is a local contract

Root、App、Feature、Package README 只描述各自 current public boundary、使用方式與 navigation，不保存完整 Decision、Plan、Audit 或 Milestone journal。

### M22-PD09 — Incremental metadata and automation

先建立最小 metadata 與人工 authority contract；22-6 才導入 automated checks。不得為追求完整 schema 延誤 P0／P1 修正。

### M22-PD10 — Safe migration sequence

大型文件 migration 固定採：

```txt
copy
→ semantic verify
→ update indexes / links
→ transitional stub
→ remove duplicate only after review
```

### M22-PD11 — Fixed Task review protocol

每個小階段逐 Task 執行、立即 review、修正後再 review；全部 Tasks 完成後執行 whole-phase implementation review，通過後提交並統一回報。小階段內不等待逐 Task 使用者確認。

## Authoritative Ownership

| Information | Authoritative owner |
|---|---|
| Current baseline version | `VERSION` |
| Release history | `CHANGELOG.md` |
| AI operation policy | `AGENTS.md` |
| Documentation taxonomy / routing | `docs/README.md` |
| Current architecture snapshot | `docs/project_context.md` |
| Stable architecture decision | Single Decision record |
| Active direction | Roadmap index / active milestone |
| Deferred / explicitly unplanned scope | `docs/backlog.md` |
| Implementation sequence | Approved implementation plan |
| Finding / observed evidence | Audit or review artifact |
| Closed milestone history | Milestone archive manifest |
| App / Feature / Package contract | Local README |

其他文件只能摘要或連結，不得成為平行 SSOT。

## Controlled Growth Rules

目標 active context budget：

```txt
AGENTS.md                  100–180 lines
docs/README.md              80–150 lines
docs/project_context.md    150–300 lines
docs/roadmap.md             50–120 lines
VERSION                       1 line
```

超過 threshold 不會自動拆檔，但必須重新 review responsibility。

新增文件前必須回答：

1. Document type 是什麼？
2. 它對哪項資訊 authoritative？
3. 哪些文件只能摘要或連結？
4. 何時更新？
5. 何時轉為 historical？
6. 哪種 task 需要讀取？

無法回答時，不新增文件。

## AI Reading Contract

```txt
Repository entry
→ minimal active reading path

Architecture task
→ Decision index + relevant Decision + local README

Feature / Package task
→ corresponding README + relevant Decision + source/tests

Milestone execution
→ active milestone + approved plan + relevant contracts

Review / release
→ review evidence + CHANGELOG + VERSION
```

禁止以「可能有用」為理由，每次掃描全部 Decisions、Audits、Plans 或 Archive。

## Planning Findings

### M22-PR01 — P0 — Legacy architecture paths can be mistaken for current authority

`docs/adr/` 不是 ADR，只是第一階段 placeholder；`docs/architecture/` 仍以現在式描述早期 MVP。

**Disposition:** 22-1 加入明確 Historical / Superseded warning；不搬移、不刪除。

### M22-PR02 — P0 — Mandatory reading path loads conflicting history

現有 Agent／README／Conversation Rules 要求讀取多份大型 current + history 混合文件，局部搜尋或 context truncation 可能採用過時 next step。

**Disposition:** 22-1 先消除直接衝突；22-2 建立新 routing；22-3／22-4 縮小 current documents。

### M22-PR03 — P1 — Root README security capability contradiction

README 前段標示 OTP 與 Biometric 已完成，後段仍表示兩者不屬目前 baseline。

**Disposition:** 22-1 修正。

### M22-PR04 — P1 — Auth and Shell README are stale

Auth README 仍描述 SharedPreferences credential authority；Shell README 未反映 App-owned auth navigation、OTP 與 local unlock。

**Disposition:** 22-1 修正明顯錯誤；22-5 套用完整模板。

### M22-PR05 — P1 — Docs and Archive indexes are stale

`docs/README.md` 只列第一階段結構；Archive routing 未反映近期 Milestone artifacts 的實際分布。

**Disposition:** 22-1 interim correction；22-2 正式重寫。

### M22-PR06 — P1 — App and critical package README are missing

缺少 App、Core、API Client、Auth README。

**Disposition:** 22-5 建立，不在 22-1 提前建立半成品。

### M22-PR07 — P1 — Project Context is not current-only

`project_context.md` 同時包含 current state、Milestone 1–21 journal、commit、test count、Decision 摘要與 evidence。

**Disposition:** 22-3 先建 migration manifest，再完整重寫。

### M22-PR08 — P1 — Roadmap combines four responsibilities

`roadmap.md` 同時是 roadmap、plan、progress journal 與 archive。

**Disposition:** 22-4 分離 index、active、candidates 與 closed routing。

### M22-PR09 — P1 — Decision aggregate mixes architecture and milestone outcomes

Decision 015–022 含 implementation sequencing、test requirements、review gate、final milestone decision 與 version rules。

**Disposition:** Milestone 22 只建立 extraction gate；全面 extraction 留到後續獨立 Milestone。

### M22-PR10 — P2 — CHANGELOG contains implementation journal

**Disposition:** 本 Milestone 只固定 future entry policy，不改寫已發布歷史。

### M22-PR11 — P2 — Audit and plan artifacts lack unified indexes

**Disposition:** 22-2 建立 indexes；22-7 review archive normalization readiness。

### M22-PR12 — P2 — Design System README is milestone-history heavy

**Disposition:** 22-5 保留 current contract、收斂歷史 journal。

### M22-PR13 — P2 — Rules are duplicated without normative-source labels

**Disposition:** 22-2 建 authority map；22-3／22-5 改為 summary + links。

### M22-PR14 — P3 — Metadata is inconsistent

**Disposition:** 22-2 定義最小 contract；22-6 lint；legacy adoption 分階段。

### M22-PR15 — P3 — No documentation consistency checker

**Disposition:** 22-6 建立 local checker，涵蓋 links、baseline、IDs、README coverage、status contradiction 與 metadata。

## Finding Gate

```txt
P0: 2
P1: 7
P2: 4
P3: 2
Open without disposition: 0
```

P0／P1 均已有 approved target phase，因此允許進入 22-1。Finding 只有在對應 phase review 提供 implementation evidence 後才可 Closed。

## Phase Contract

### 22-1 Current-State Contradiction Remediation

只修正 P0／P1 current misinformation、legacy warning 與 interim routing；不搬移大型文件。

### 22-2 Documentation Index & AI Reading Contract

建立 Documentation Hub、authority map、task routing、artifact indexes 與最小 metadata contract。

### 22-3 Current Project Snapshot Rewrite

建立 migration manifest，將 Project Context 重寫為 current-only snapshot。

### 22-4 Roadmap Active / Candidate Separation

建立 Roadmap index、active、candidates 與 closed milestone routing。

### 22-5 README Coverage Baseline

新增 App、Core、API Client、Auth README，同步全部 Feature 與 Design System README。

### 22-6 Documentation Lint Foundation

以 Python standard library 建立 repository-local checker，不導入遠端 service。

### 22-7 Final Review & Decision Extraction Gate

重跑 inventory、findings、links、README coverage 與 active context review，決定下一個 Decision Extraction / Archive Normalization Milestone。

## Non-Goals

- 不修改 production code 或 runtime behavior。
- 不全面拆分 Decision 001–022。
- 不一次搬移所有 Audit／Plan／Archive。
- 不刪除歷史文件。
- 不全面重寫或分卷 CHANGELOG。
- 不導入 Wiki、documentation generator 或遠端 CI service。

## Review Conclusion

Document taxonomy 足以涵蓋目前 repository；authority、growth control、reading contract、migration safety 與 phased scope 已具備可執行邊界。

```txt
Milestone 22-0: Approved
Next phase: 22-1 Current-State Contradiction Remediation
```
