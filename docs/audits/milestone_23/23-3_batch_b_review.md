---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-3-batch-b-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-3 — Batch B Tooling, Governance and Platform Contracts Review

## Scope

本 Task 擷取 ADR-004、005、009–011、013–014，完成 ADR-004／012 partial supersession relation，並更新 migration-aware index 與 manifest。Aggregate `docs/architecture_decisions.md` 正文保持不變。

## Per-Decision Semantic Review

| ADR | Retained durable contract | Routed or normalized material | Result |
|---|---|---|---|
| 004 | App 使用 `get_it + injectable`、App-owned registration | Package 自行宣告 lifecycle 的可能解讀由 ADR-012 部分取代 | preserved |
| 005 | Auth domain/data/session package 與 App presentation boundary | 「長期」「後續移動」正規化為 current contract | preserved |
| 009 | 繁體中文預設、technical term 保留英文 | 詳細 agent/commit enforcement 路由 `AGENTS.md` | preserved |
| 010 | Conditional import、initializer isolation、no `dart:io` leakage | Web setup 屬操作；platform support claim 路由 current snapshot/evidence | preserved |
| 011 | Repository docs 優於聊天記憶、每項事實單一 authority | 舊固定 path list 與 aggregate-only 流程由 M22 governance 取代 | preserved |
| 013 | Retrofit、Dio、DTO、Mapper、DataSource、Repository 責任 | 具體 directory 與 milestone 完成敘述路由 README/source/history | preserved |
| 014 | Environment／ApiMode 分離、entrypoint authority、typed config、validation | M9/M18 journal 與 platform evidence 路由 review/snapshot/CHANGELOG | preserved |

所有 normative statement 均未弱化或擴張。Canonical body 未保留 test count、task checklist、completion status 或 release decision。

## Partial Supersession Review

ADR-004 與 ADR-012 建立 reciprocal metadata：

```txt
ADR-012 supersedes ADR-004
ADR-004 superseded_by ADR-012
```

此 edge 只代表 reusable package scope。兩份 ADR 正文都明確保留：

- ADR-004 仍擁有 App 採用 `get_it + injectable` 的選型。
- ADR-012 擁有 reusable package 不得綁 DI framework 與 App lifecycle 的限制。

ADR-004 status 維持 `accepted`，因其 App scope 未被取代；checker graph 不得出現 cycle 或 missing reciprocal edge。

## Inbound Reference Review

搜尋範圍：`Decision 004/005/009/010/011/013/014`、對應 `ADR-NNN` 與 `docs/architecture_decisions.md`。

- Current README 與 Documentation Hub 仍指向 aggregate authority，符合 Task 23-8 前 compatibility contract。
- Historical audits、plans、CHANGELOG 與 migration manifests 可保留原 Decision 名稱或 aggregate link。
- Legacy `docs/adr/000-*` 至 `005-*` 仍是 placeholder，未在本 Task 改寫或重用 identity。
- Batch B 新增 canonical paths 只由 ADR index、manifest 與 review 導向；未提前切換全 repository authority route。

## Index and Link Review

```txt
Extracted rows: 14
Aggregate rows: 8
Missing extracted targets: 0
Orphan canonical ADR files: 0
```

Related Evidence 使用 repository relative links，並由 `docs_check` 驗證。

## Aggregate and Rollback Safety

`docs/architecture_decisions.md` 不在本 Task change set 中。若本 batch 需要 rollback，只需 revert 新增的七份 ADR、ADR-012 relation、index、manifest 與本 review；aggregate 即可繼續作為唯一 authority。

## Validation

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed

git diff --quiet -- docs/architecture_decisions.md
→ Passed；aggregate正文未修改
```

Canonical ADR journal scan只命中ADR-009本身的durable `commit message`語言政策；未發現implementation status、test count、milestone completion、release decision或baseline bump殘留。

## Review Decision

Task 23-3 通過 whole-batch implementation review。Open P0／P1：0。下一批可進入 Task 23-4，但 ADR-015 高風險 mixed content 必須先建立 section disposition map。
