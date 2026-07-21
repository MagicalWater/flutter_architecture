---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-23-adr-extraction-planning-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-0 — ADR Extraction Planning Review

## Scope

本 review 定義 Decision 001–022 從 aggregate `docs/architecture_decisions.md` 遷移為正式 Architecture Decision Records 的 inventory、風險、分類、migration strategy、批次策略與 implementation gate。

本階段只建立規劃與可執行 plan，不拆分 Decision 正文、不刪除 aggregate、不搬移 audits／plans，也不改變 production runtime behavior。

## Current Authority Inventory

### Aggregate authority

目前唯一正式 Decision authority 仍是：

```txt
docs/architecture_decisions.md
```

檔案包含連續且未缺號的 Decision 001–022。所有 heading 都使用 `Decision NNN` stable identity，但尚未具備單檔 metadata、正式 status relation、supersession graph 或 machine-verifiable index coverage。

### Legacy paths

```txt
docs/adr/
  000-template-positioning.md
  001-why-bloc.md
  002-why-get-it-and-injectable.md
  003-why-flutter-hooks-and-hooked-bloc.md
  004-why-freezed-and-json-serializable.md
  005-why-auto-route.md

docs/architecture/
  000-principles.md
  001-folder-structure.md
  002-clean-architecture.md
```

`docs/adr/` 目前是「暫不實作」placeholder，不是 Decision authority；`docs/architecture/` 已有 historical／superseded warning，但仍保留第一階段 guidance 正文。兩者都可能被外部連結、Git history 或既有文件引用，因此 Milestone 23 不可直接刪除或無條件覆寫。

### Existing checker capability

`tools/docs/check_docs.py` 目前已檢查 relative Markdown links、baseline consistency、managed metadata、explicit metadata `id` uniqueness、active milestone contradiction，以及 App／Package／Feature README coverage。

它尚未理解 ADR filename、Decision index coverage、status transition、supersession graph 或 legacy routing contract。

## Decision Classification Summary

完整逐 Decision disposition 位於 `docs/migrations/m23_adr_extraction_manifest.md`。

| Decision | Current validity | Primary classification | Normalization risk |
|---|---|---|---|
| 001 | current | current architecture contract | low |
| 002 | current | current architecture contract | low |
| 003 | current | current architecture contract | low |
| 004 | partially superseded by 012 in package scope | partially superseded | medium |
| 005 | current, wording contains historical future tense | current architecture contract | medium |
| 006 | current | current architecture contract | low |
| 007 | current | current architecture contract | low |
| 008 | current | current architecture contract | low |
| 009 | current, governance-owned overlap | release/version policy / governance contract | medium |
| 010 | current with platform claim caveat | current architecture contract | medium |
| 011 | current principle, paths partially outdated | mixed architecture + milestone journal | high |
| 012 | current | current architecture contract | low |
| 013 | current | current architecture contract | medium |
| 014 | current contract plus historical platform evidence | mixed architecture + milestone journal | high |
| 015 | current core contract plus extensive implementation evidence | mixed architecture + implementation evidence | very high |
| 016 | current core contract plus milestone completion and tests | mixed architecture + implementation evidence | high |
| 017 | current core contract plus schema/evidence journal | mixed architecture + implementation evidence | very high |
| 018 | current core contract plus sequencing/tests | mixed architecture + milestone journal | very high |
| 019 | current core contract plus implementation completion | mixed architecture + implementation evidence | high |
| 020 | current core contract plus audit/test/release evidence | mixed architecture + implementation evidence | very high |
| 021 | current | current architecture contract | medium |
| 022 | current umbrella boundary, mixed with three milestone journals and releases | mixed architecture + release/version policy | critical |

## Material That Must Not Remain in ADR Bodies

- `實作狀態` 與 Milestone completion summary。
- implementation sequencing、phase order與 task checklist。
- test list、test count、build result與 review gate。
- milestone completion journal、finding closure與 final holistic conclusion。
- release decision、baseline bump、commit與日期流水帳。
- SQL／API exact implementation evidence；只有 ownership 或 invariant 是 durable contract 時保留摘要。
- Milestone 19／20／21 的 planning supplement與 final decision journal。

## ADR Target Contract

### Canonical path and filename

```txt
docs/adr/
  README.md
  adr-001-clean-architecture-feature-first.md
  ...
  adr-022-authentication-security-capability-boundaries.md
```

- filename 使用 `adr-NNN-<stable-kebab-title>.md`。
- `NNN` 永不重新編號或重用。
- `docs/adr/README.md` 是 architecture-decision-index，不承載 Decision 正文。

### YAML metadata

```yaml
---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-001-clean-architecture-feature-first
last_reviewed_baseline: 1.5.1
id: ADR-001
title: Clean Architecture and Feature First
supersedes: []
superseded_by: []
related:
  - ADR-002
---
```

- `id` 必填且格式為 `ADR-NNN`，需與 filename number 一致。
- 已發布 Decision 001–022 第一版只使用 `accepted` 或 `superseded`。
- `supersedes`／`superseded_by` 必須 reciprocal；partial supersession以正文限定 scope。
- `related` 只列真正有 contract 關聯的 ADR。

### Body sections

```txt
# ADR-NNN — Title
## Status
## Authoritative Scope
## Context
## Decision
## Consequences
## Supersession
## Related Decisions
## Related Evidence
## Last Reviewed Baseline
```

ADR 只保存 durable current contract；evidence 以 link routing保存，不複製 journal。

## Supersession Review

- ADR-004 與 ADR-012：ADR-012 只取代 reusable package自行宣告 DI lifecycle的可能解讀，不取代 App 使用 `get_it + injectable`。
- ADR-011：Single Authority 原則仍有效；舊關鍵文件清單與 aggregate-only update流程已被 Milestone 22 governance更新。
- ADR-015：SharedPreferences Token Pair implementation已被 ADR-022／Milestone 19 secure credential authority取代；refresh concurrency、runtime Session與 replay contract仍 current。
- ADR-022：只在 credential-at-rest scope supersede ADR-015，不取代其完整 refresh contract。

Graph rules：target 必須存在、relation reciprocal、禁止 self-reference與 cycle；`superseded` status必須有 `superseded_by`。

## Legacy Routing Strategy

### Aggregate

在 22 個 ADR 全部完成 semantic review、link review與 checker validation前：

- `docs/architecture_decisions.md` 保留完整正文並維持 current authority。
- 每批只可增加 migration marker，不移除該批正文。
- 最終 cutover才改為 transitional index／stub，且 cutover commit必須可獨立 rollback。

### Existing `docs/adr/`

- 不刪除現有路徑。
- canonical filename不重用 `000-*` 至 `005-*`，避免 identity偷換。
- final cutover時改為 `status: legacy` transitional stub，連向正確 canonical ADR或 index。
- 無一對一 Decision對應的 placeholder不得建立錯誤 redirect。

### Existing `docs/architecture/`

- 保留 historical warning與正文，至少到 inbound links完成 review。
- 可增加 current authority links，但不偽裝成 redirect。
- 未建立 heading-level manifest前不物理搬移。

## Extraction Batches

1. **Batch A — Foundation：ADR-001–003、006–008、012**
2. **Batch B — Tooling／governance／platform：ADR-004、005、009–011、013–014**
3. **Batch C — Auth refresh／navigation：ADR-015、021**
4. **Batch D — Catalog lifecycle：ADR-016–017**
5. **Batch E — Presentation foundations：ADR-018–020**
6. **Batch F — Authentication security umbrella：ADR-022**
7. **Batch G — Authority cutover and legacy compatibility**

每批完成 per-ADR review與 whole-batch review後才可進下一批。

## Per-Batch Review Gate

```txt
Extract one ADR
→ immediate semantic review
→ fix / re-review
→ index and relation update
→ link review
→ checker validation
→ whole-batch review
→ commit
```

Semantic review必須確認 normative statement未遺失、未弱化、未擴張；historical detail有 route；partial supersession scope明確；ADR body沒有 test count、journal或 release decision。

Rollback：aggregate正文在 Batch G前保留；revert該 batch的新 ADR、index、checker與 links後執行 `docs_check`及 `git diff --check`，aggregate即恢復唯一 authority。

## Checker Expansion Decision

需要擴充 `tools/docs/check_docs.py`：

- ADR ID format／uniqueness與 filename一致性。
- Decision index coverage、missing／orphan ADR file。
- invalid status relation。
- supersession target、reciprocity與 cycle。
- broken managed legacy routing。

採 migration-aware activation：中途只驗證已存在 canonical ADR與 index rows；22／22 full coverage在 final cutover才啟用。每項 rule先 fixture RED，再 minimal implementation GREEN。

## Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M23-PR01 Aggregate cannot be removed early | P0 | Keep full aggregate until Batch G |
| M23-PR02 Decision 015–022 mix contract and journal | P0 | High-risk isolated batches and manifest |
| M23-PR03 ADR-022 combines three milestones and releases | P0 | Dedicated Batch F; no mechanical split |
| M23-PR04 Legacy ADR filenames conflict with canonical numbering | P1 | `adr-NNN-*` plus retained legacy stubs |
| M23-PR05 Partial supersession is not machine-readable | P1 | Scope review and reciprocal graph metadata |
| M23-PR06 ADR-015 storage implementation is stale | P1 | Supersede storage scope only |
| M23-PR07 ADR-011 routing is outdated after M22 | P1 | Preserve principle; route to governance |
| M23-PR08 Checker lacks ADR integrity validation | P1 | TDD expansion before broad extraction |
| M23-PR09 Historical links may target aggregate/legacy paths | P1 | Inbound inventory and compatibility stub |
| M23-PR10 Mechanical extraction may preserve obsolete claims | P1 | Per-Decision validity review |
| M23-PR11 Evidence can pollute ADR authority | P2 | Route to audits/plans/CHANGELOG |
| M23-PR12 Full coverage would fail during staged migration | P2 | Migration-aware activation |

Open P0／P1 without disposition：0。

## Planning Gate Decision

Milestone 23-0 通過。後續只允許依 plan從 checker／index foundation與 Batch A開始；不允許全面拆分，也不允許提前將 aggregate改成 stub。
