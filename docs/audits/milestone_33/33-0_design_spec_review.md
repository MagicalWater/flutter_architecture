---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-33-design-spec-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Design Spec and ADR Review

## Scope

本 review 涵蓋：

- 修訂後 Level 4 Requirement Decision。
- [Milestone 33 Design](../../superpowers/specs/2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation-design.md)。
- [ADR-028 stable decision draft](../../superpowers/specs/2026-08-04-adr-028-repository-local-pencil-to-flutter-design-implementation-workflow-draft.md)。
- 第三方 Skill ownership／語言／provenance／integrity contract。
- Repository-local Pencil-to-Flutter Skill responsibility。
- `.pen` visual authority、Pencil MCP boundary、Flutter mapping與visual acceptance。
- Planned Task families、release、rollback與approval gates。

本 review 不核准 Implementation Plan、不建立 managed worktree、不 copy 外部 source、不安裝 Skills、不操作 Pencil canvas，也不修改 Flutter production source。

## Baseline

```txt
Template Baseline: 1.14.0
Base commit: de8d95a584d32e7a63d509527d24ef0d0a5544d8
Branch: main
Working tree before Design Task: clean
Remote origin/main: de8d95a584d32e7a63d509527d24ef0d0a5544d8
Prior active milestone: None
```

## Focused Findings

### F-33-D01 — 第三方 Skill 語言豁免不能只依路徑

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：只把 `.agents/skills/<name>` 標記為第三方，就能讓任意英文 Skill 繞過 repository language gate，且無法發現上游 bytes 被修改。
- Fix：Design／ADR要求 immutable upstream identity、license、exact install path、逐檔 inventory與raw SHA-256；checker只對 lock完全匹配的 files豁免，missing lock／unknown file／hash drift／path escape全部fail closed。
- Fresh re-review：Repository-authored與fork仍受中文policy；unmodified third-party保留原文與可驗證 integrity，沒有 path-only bypass。

### F-33-D02 — Workflow Foundation與一次性 UI proof的authority可能混淆

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：若把 `Write Pre-check` 畫面描述成主要產品能力，未來流程會綁死單一畫面；若只寫抽象 workflow，又可能在沒有實證時宣稱 foundation完成。
- Fix：Design明定 Workflow Foundation是主要交付物，單頁畫面是第一個 executable acceptance fixture；Final Review必須同時驗證 reusable process與實際 fidelity。
- Fresh re-review：Task families分別擁有 governance、source／Skill admission、orchestration、Flutter proof、visual validation與Guide，不存在只做文件或只做畫面的closure路線。

### F-33-D03 — Canonical fixed viewport可能被錯用成全畫面縮放捷徑

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：先前空白 Flutter proof 使用固定 `941 × 1672` canvas與全畫面 containment；直接照搬可能在 canonical screenshot通過，但窄畫面、accessibility與 production layout不成立。
- Fix：保留 `941 × 1672` 作 deterministic primary comparison，但禁止 full-screen raster、禁止全畫面 fixed-canvas scaling作通用策略；要求 narrow viewport scroll／no-overflow與 supported runtime screenshot。
- Fresh re-review：Canonical fidelity與 responsive behavior由不同 tests擁有，不再互相冒充。

### F-33-D04 — Repository-local Skill存在不代表 runtime載入該份 copy

- Severity：P1。
- Status：Resolved in proposed Design。
- Finding：DevSpace discovery目前以 user-global path先於 project path，且同名 first-loaded wins；單純 copy Taste Skills到 worktree不足以證明生效。
- Fix：Design／ADR要求 fresh worktree reload、absolute loaded path、hash matching與 zero collision；任何先行遮蔽都fail closed。
- Fresh re-review：Skill discovery evidence成為 Task completion gate，外部 `ui-agent` path不得作 active source。

### F-33-D05 — Canonical ADR-028觸發既有hard-coded coverage failure

- Severity：P1。
- Status：Resolved in proposed artifacts。
- Reproduction：新增canonical ADR-028與index row後，`docs_check`固定回報`expected ADR-001..ADR-027; extra=['ADR-028']`。
- Root cause：`tools/docs/check_docs.py`在legacy aggregate cutover check中把expected coverage硬編碼為`range(1, 28)`，合法新增ADR也會被視為extra。
- Constraint：直接修正checker屬implementation，不得在Design／Plan核准前提前執行。
- Fix：移除未核准的canonical ADR file／index row，將完整stable decision保存為Design companion draft；Plan的第一個TDD governance Task先generalize checker，再建立canonical ADR-028。
- Fresh re-review：Design artifacts可在不修改production checker的情況下通過current validation；ADR stable content仍可由使用者書面review，且canonicalization被設為所有後續implementation的hard gate。

## Focused Re-review

- Requirement Decision包含 problem、value、Level 4依據、scope、non-goals、Design／Plan／ADR、worktree、regression、release與post-release routing。
- Scope同時涵蓋 repository workflow與可執行 proof，沒有擴張為任意 code generator或完整 NFC產品。
- Third-party unmodified Skill保留上游原文；repository-authored／fork仍遵守繁體中文治理。
- `skills-lock.json`只擁有 provenance／integrity；human registry擁有 trigger／responsibility；review擁有 findings，沒有平行 authority。
- `.pen`、derived preview、original reference與historical benchmark的順位由 manifest明確定義。
- Pencil MCP是唯一 `.pen` structure／mutation boundary，沒有 native parser fallback。
- Repository-local orchestration Skill先委派中央治理，不取得 Level、approval、Task、release或closure authority。
- Flutter mapping遵守 Feature First、App-only Composition Root、Localization、router與 Design System。
- Proof是 presentation-only，明確禁止虛假 Domain／Data／DI與全畫面 image embedding。
- Visual acceptance同時包含 canonical golden、runtime screenshot、deterministic diff、narrow viewport與人工語意 review。
- Plan核准前不得建立 managed worktree、copy source、安裝 Skills、操作 Pencil或修改 Flutter source。

## Whole-Design Review

### Architecture consistency

Design不建立第二套 App architecture。Pencil workflow只把 design source映射到既有 ownership；App、Feature、Design System、Localization與 tests仍由既有 ADR／source擁有。

### Authority consistency

- Design擁有 scope、behavioral requirements與technical design。
- ADR-028 stable decision draft保存待接受的 stable source／Skill／MCP／mapping／visual acceptance contract；canonical ADR將由核准Plan的第一個Task建立。
- 未來 Plan擁有 exact files、commands、Task order與commit boundaries。
- Visual manifest擁有每個 initiative的source順位與hash。
- Audit擁有 findings與runtime evidence。
- Current Project Context、Roadmap、VERSION與CHANGELOG仍擁有 current／release state。

### Governance consistency

Design、ADR、Plan與每個 implementation Task都採 Full two-layer Task governance。一般 findings與validation failure必須在當前 Task內修正並fresh re-review；只有使用者 architecture／scope decision、external blocker、推翻 accepted artifact的P0／P1或完整 Milestone closure才停止。

### Scope-control review

Design明確拒絕：

- 未核准前建立 worktree或 implementation artifacts。
- 翻譯未修改第三方 Skill。
- Path-only語言豁免。
- Taste Skill取得 authority。
- Native `.pen` parsing。
- 任意 `.pen` 自動產碼 framework。
- Web runner adoption。
- 完整 NFC Lab scope。
- 單張 screenshot embedding或全畫面 fixed-canvas cheat。
- 沒有第二個 consumer就擴張全域 Design System。

## Validation

Fresh validation結果：

```txt
Placeholder scan: TODO=0, TBD=0
Design／ADR draft relative link check: passed through docs_check
Documentation checker unit tests: 19 passed
Repository docs_check: passed
git diff --check: passed
```

首次validation正確發現既有ADR coverage checker硬編碼至ADR-027。由於修正checker是implementation，Design Task沒有提前修改production code，而是將ADR-028保存為完整stable decision draft，並把checker TDD＋canonicalization設為Plan第一個hard gate。調整後fresh rerun的19個checker tests、repository `docs_check`與`git diff --check`全部通過。

## User Approval Gate

使用者已於2026-08-04分兩個gate核准：

- 將工作提升為 Milestone 33。
- Workflow Foundation與單頁 compatibility proof同屬本大階段。
- 修正第三方 Skill 語言治理邊界。
- 開始建立正式 Design與ADR草案。
- 書面 `Milestone 33 Design`。
- 書面 `ADR-028 stable decision draft`。

Design與ADR draft因此轉為`accepted`。該核准不包含尚未建立的Implementation Plan，也不允許提前建立managed worktree或開始implementation。

## Current Disposition

```txt
Focused findings: resolved
Whole-Design internal review: PASSED
Documentation validation: PASSED after ADR coverage recovery
Open P0: 0
Open P1 without disposition: 0
Design status: ACCEPTED
ADR-028 stable decision draft status: ACCEPTED
Implementation Plan: NOT CREATED
Managed worktree: NOT CREATED
Implementation: NOT STARTED
Next gate: create and fully review Implementation Plan
```
