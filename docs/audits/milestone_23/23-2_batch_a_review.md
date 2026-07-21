---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-2-batch-a-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-2 — Batch A Foundation Contracts Review

## Scope

本 Task 擷取 ADR-001、002、003、006、007、008、012，更新 migration-aware index 與 manifest。`docs/architecture_decisions.md` 正文保持不變，正式 authority 尚未 cutover。

## Per-Decision Semantic Review

| ADR | Source contract preserved | Normalization | Expansion check | Result |
|---|---|---|---|---|
| 001 | Feature First、Clean dependency direction、package promotion | 將簡短原因與影響整理為 durable scope | 未新增 generic framework要求 | Accepted |
| 002 | Monorepo、Pub Workspace、Melos、dependency ordering | 指令細節改由 AGENTS routing；保留 ordering invariant | 未改變 workspace ownership | Accepted |
| 003 | Bloc business state、Hooks UI-local state、hooked_bloc presentation usage | 移除非必要 sample code | 未授權跨 Feature Bloc dependency | Accepted |
| 006 | Guard依賴Session authority，不依賴AuthBloc | 將「後續改」正規化為 current contract | 未讓Guard取得restore／persistence responsibility | Accepted |
| 007 | 跨 Feature 不直接依賴對方 Bloc | 將Profile案例提升為一般規則 | 未禁止合法 App coordinator／domain abstraction | Accepted |
| 008 | 一個UseCase對應一個業務行為 | 補充不為純技術步驟建立UseCase | 未建立過度嚴格 class-per-method規則 | Accepted |
| 012 | reusable package constructor injection、App-only lifecycle | 補充正式 feature module例外需另有Decision | 未取代App使用get_it／injectable | Accepted |

## Relation Review

- Batch A沒有建立 supersession edge，因此不存在 target、reciprocity或cycle風險。
- ADR-012與尚未擷取的ADR-004只先在正文說明 scope；reciprocal partial supersession metadata延後至Batch B，避免對不存在 canonical target建立 graph edge。
- `related`只保存 contract adjacency，不具 supersession語意。

## Non-ADR Disposition

- ADR-002 的具體操作命令由 `AGENTS.md` 維護，ADR保留 dependency-ordering invariant。
- ADR-003 的 hook code只是示例，不是 durable contract。
- ADR-006、007、012 的「目前／後續／不再使用」敘述已正規化為 current responsibility，不保存 milestone completion journal。

## Link and Compatibility Review

- 七個 canonical filenames 與 `ADR-NNN` metadata一致。
- ADR index 七列已由 `aggregate`改為`extracted`並指向存在檔案。
- Legacy `000-*`至`005-*` placeholders未修改，也未被誤當canonical ADR。
- Aggregate Decision heading與正文未刪除；rollback時移除本批 ADR並把index列改回`aggregate`即可恢復單一authority。

## Validation

Task完成後實際結果：

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed
```

`docs/architecture_decisions.md`不在本Task change set中；七個 extracted index targets均存在且無orphan ADR。

## Findings

Open P0／P1：0。

Deferred：ADR-004／012 scope-specific supersession relation在Task 23-3處理；ADR-003／018 relation於ADR-018 extraction時重新確認。

## Review Decision

Batch A semantic preservation、index coverage、link compatibility與rollback boundary符合Milestone 23-0 gate，可進入repository validation與commit。
