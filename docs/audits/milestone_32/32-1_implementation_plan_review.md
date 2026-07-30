---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-32-implementation-plan-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Implementation Plan Review

## Review Scope

本Task審查：

```txt
docs/superpowers/plans/2026-07-30-milestone-32-ci-artifact-local-storage-cutover.md
```

Review依據為accepted Design、ADR-023 current contract、四份workflows、現有CI scripts／tests、Windows與Mac capability、GitHub fresh storage inventory及Level 4 full two-layer governance。

本Review不代表ADR、workflow、artifact tooling、本機root、GitHub variable或storage cleanup已變更。

## Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| Plan若在建立writer前先改workflow，會形成無artifact owner的中間狀態 | P1 | Tasks 2–5先完成contract、writer、cleanup與local integration，Task 6才切workflow transport |
| Python tooling若使用3.10 union syntax會重演Milestone 27 portability defect | P1 | Global constraint固定Python 3.9+與`typing.Optional`；Task 2加入portability tests |
| Multi-job aggregation若由最後job覆寫run manifest會遺失其他job evidence | P1 | Task 3固定job-level atomic publish與run-level聚合，只讀已finalize job manifests |
| Writer失敗可能覆蓋真正的test／build failure | P1 | Task 3加入primary-result precedence test，分離`result`與`evidence_status` |
| Retention只有age沒有count／capacity仍可能短期塞滿磁碟 | P1 | Task 4同時實作age、count、30 GiB max與15 GiB minimum-free |
| Cleanup apply若直接刪除沒有本機短期復原 | P1 | Task 4固定trash 24小時、restore與purge gate |
| GitHub-hosted failure-only若沒有allowlist與size preflight仍可能上傳大型binary | P1 | Task 6加入extension denylist、25 MiB preflight與manual-only matrix |
| Observability storage驗收若綁定controlled event會重複污染Firebase | P1 | Task 7加入`emit_controlled_event=false`預設與獨立tests |
| Runtime acceptance只看run success無法證明storage停止增加 | P1 | Task 9固定pre／post GitHub count、bytes與latest timestamp比較 |
| GitHub cleanup不可因Milestone Plan已核准就直接執行 | P1 | Task 10只產生exact deletion manifest並強制停下取得獨立cleanup approval；Task 11才可DELETE |
| Cleanup manifest若inventory drift仍沿用舊approval會刪錯物件 | P1 | Task 11執行前重新比對manifest hash與fresh inventory；drift即回到Task 10重新review |
| Mac absolute root若成為source default會破壞模板可移植性 | P1 | Task 8只把該路徑記為operator example；Task 2維持environment／platform contract |
| Branch Protection目前不可用，若列入runtime acceptance會形成虛假closure | P1 | Plan只保留job name與Guide語意，不包含settings mutation或成功claim |
| Release與GitHub cleanup若混成無停止點Task，無法保證不可逆操作先獲批准 | P1 | Task 10／11拆分，cleanup approval是Task間硬停止點 |

所有P1已回補Plan正文，沒有留給implementation自行決定的blocking architecture choice。

## Fresh Focused Re-review

- Design每一項behavioral requirement都有對應Task。
- Task順序維持authority → contract → writer → cleanup → local integration → workflow → Observability → docs/static → runtime → cleanup manifest → deletion/release。
- 每個Task都有明確Files、Consumes／Produces、RED／GREEN、review與commit gate。
- Python介面名稱在後續Tasks一致，沒有`begin`／`begin_job`、`finalize`／`finalize_job`漂移。
- Self-hosted與manual-local共用writer；github-hosted只有remote transport policy，不要求持久local root。
- Windows不承擔iOS；Mac承擔iOS與完整Observability。
- Secret leakage、path traversal、symlink、lock、manifest drift與primary failure precedence都有test route。
- GitHub DELETE被隔離至獨立approval後，Plan核准本身不構成cleanup核准。

Fresh re-review未發現新的P0／P1。

## Whole-Plan Review

第二輪依完整生命週期檢查：

```txt
accepted Design
→ durable ADR authority
→ root／schema contract
→ atomic writer／aggregation
→ retention／cleanup
→ manual-local integration
→ workflow transport cutover
→ Observability／failure evidence
→ static regression／operator docs
→ Windows／Mac／self-hosted runtime acceptance
→ exact GitHub deletion manifest
→ independent cleanup approval
→ deletion／release／post-release closure
```

結果：

- 沒有在replacement local evidence成立前移除GitHub artifact route。
- 沒有把self-hosted evidence冒充github-hosted clean-run evidence。
- 沒有把local path冒充遠端下載能力。
- Local cleanup具24小時restore；GitHub deletion不可逆性如實記錄。
- Runtime acceptance可證明GitHub storage不再增長，而非只證明workflow成功。
- Release identity、push、clean-checkout與post-release validation晚於cleanup與holistic review。

Open P0 = 0。Open P1 without disposition = 0。

## Spec Coverage Matrix

| Design area | Plan Task |
|---|---|
| ADR／authority | Task 1 |
| root、schema、host portability | Task 2 |
| job writer、checksums、aggregation | Task 3 |
| retention、capacity、pins、trash | Task 4 |
| manual-local／platform integration | Task 5 |
| self-hosted prohibition、github-hosted transport | Task 6 |
| failure evidence、Observability event separation | Task 7 |
| operations、static regression | Task 8 |
| Windows／Mac／self-hosted runtime and no-growth | Task 9 |
| GitHub exact deletion manifest | Task 10 |
| cleanup execution、release、post-release | Task 11 |

## Validation

```txt
placeholder／ambiguous wording scan
interface consistency scan
Spec coverage matrix review
python tools/docs/check_docs.py .
dart run melos run docs_check
git diff --check
```

本Task只建立Plan與review routing，不執行production tests或platform build。

## Gate

```txt
Internal Plan review: Passed
Open P0: 0
Open P1 without disposition: 0
Plan status: proposed
User approval: required
Implementation: forbidden
GitHub cleanup: forbidden
```

下一步只能是使用者review並明確核准本Plan。核准後Plan才轉為`accepted`，才可進入Task 1 implementation；Task 10完成後仍需另一次cleanup approval。
