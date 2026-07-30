---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-10-github-cleanup-manifest-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 10 GitHub Cleanup Manifest Review

## Current conclusion

```txt
Offline API fixtures and exact-ID tests: Passed
Manifest integrity and scope binding: Passed
Review and approval gates: Passed
Fresh inventory drift gate: Passed
Production read-only inventory: Passed
Real reviewed deletion manifest: Created and verified
GitHub DELETE requests executed: 0
Task 10 whole-Task review: Passed
Task 11 cleanup execution: Fresh inventory drift blocked the first approved attempt
Superseded approval scope: 48e2233a0cee0f5d9cad29e2
Superseded stable-scope manifest: 9772870197227aed2ff33db6
Current reviewed manifest: 7ad138bb845e42cbb133d07c
GitHub DELETE requests executed: 0
```

本Task只建立GitHub Actions storage的fresh inventory、exact-ID deletion manifest與不可逆操作前的安全gate。沒有刪除artifact、cache或local managed store內容。

## Implemented interfaces

新增：

```txt
tools/ci/github_storage_cleanup.py
tools/ci/test_github_storage_cleanup.py
```

Production interfaces：

```txt
collect_inventory(api_client) -> Inventory
classify_inventory(inventory) -> Sequence[DeletionCandidate]
write_deletion_manifest(candidates, output_dir) -> str
delete_from_manifest(api_client, manifest_path, approval_token) -> DeletionResult
```

CLI：

```txt
inventory
manifest
delete
```

`inventory`與`manifest`使用GitHub CLI的paginated read-only API。Production delete client只存在以下兩個exact-ID endpoint：

```txt
DELETE repos/{repository}/actions/artifacts/{artifact_id}
DELETE repos/{repository}/actions/caches/{cache_id}
```

不存在name prefix、cache key prefix、workflow、ref或時間範圍批次刪除入口。

## TDD evidence

### Initial RED

Test先建立artifact／cache offline fixtures，包含：

```txt
exact object ID
name / key
bytes
created / updated / last-accessed timestamp
workflow run ID
ref
head SHA
```

初始RED因production module不存在而失敗，之後逐項實作inventory、classification、manifest與delete gate。

### Focused security finding — rehashed scope tampering

第一版雖有payload SHA與whole-file sidecar，但攻擊者仍可修改`manifest_id`或approval token hash後重新計算兩層hash。新增RED tests後，load gate改為重新推導：

```txt
manifest_id = SHA-256(exact deletion scope)[0:24]
approval token hash = SHA-256(DELETE-GITHUB-STORAGE-{manifest_id})
```

Exact scope包含：

```txt
repository
inventory SHA-256
pre-delete totals
all exact candidates
replacement evidence routes
```

只重算檔案hash而沒有同時符合scope衍生規則時，manifest會在任何delete前被拒絕。

### Direct CLI portability finding

首次production read-only invocation發現direct script entrypoint沒有將repository root加入`sys.path`。依RED test補上與既有CI tools相同的direct-entry import contract，之後`python3 tools/ci/github_storage_cleanup.py --help`與real inventory均通過。

### GREEN and regression

```txt
Focused GitHub cleanup tests: 15 passed
Repository CI contract tests: 202 passed
Python 3.9 compile: passed
Documentation checks: passed
Workflow semantic lint: passed
git diff --check: passed
```

Focused coverage包含：

```txt
exact metadata與totals
artifact-first / cache-second exact ID order
unknown delete failure立即停止
pending review拒絕
wrong approval token拒絕
ID或bytes inventory drift拒絕
payload與sidecar tamper拒絕
rehashed manifest ID與token tamper拒絕
output symlink拒絕
direct CLI import
production exact-ID DELETE endpoints
artifact／cache name與key secret pattern拒絕且不回顯
partial delete structured attempts與failed exact ID
non-delete metadata drift不阻擋相同exact scope
```

Unit tests只使用fake API client；沒有對GitHub送出DELETE。

## Initial reviewed inventory — superseded by drift

Production `inventory` CLI於2026-07-30初次只讀取得：

```txt
Repository: MagicalWater/flutter_architecture
Inventory SHA-256: bc37c5c4ced06810e9ed2593af5f95838fce1550f5f8a920998d5016274ffd90

Artifacts
  count: 110
  bytes: 7,835,943,504

Caches
  count: 10
  bytes: 8,415,432,007

All objects
  count: 120
  bytes: 16,251,375,511
```

Candidate created timestamp range：

```txt
earliest: 2026-07-22T02:15:41.542581000Z
latest:   2026-07-24T14:52:05Z
```

全部objects都早於Task 9 self-hosted acceptance。Task 9三個self-hosted runs的GitHub artifact count均為0，因此不在manifest內。

Classification：

```txt
legacy-github-artifact: 110
legacy-github-cache: 10
```

Replacement evidence route：

```txt
docs/audits/milestone_32/32-9_runtime_acceptance_review.md
```

初次reviewed manifest：

Manifest保存在checkout與runner `_work`之外的formal managed store：

```txt
Manifest ID:
48e2233a0cee0f5d9cad29e2

Manifest path:
/Users/water/Developer/ci-artifacts/flutter_architecture/cleanup-manifests/github/48e2233a0cee0f5d9cad29e2/deletion-manifest.json

Review status:
reviewed

Reviewed by:
milestone-32-task-10-review

Reviewed at:
2026-07-30T14:39:33Z
```

Integrity：

```txt
Payload SHA-256:
b48e30659032a3078aaaba3c7a1a257c2b556b3f36aa4cb423f17ace99956494

Whole-file SHA-256 / sidecar SHA-256:
c9c04952f72a314b7d572649eaba949be62ace93b46e288ac81cfc5e1099d144

Approval token SHA-256:
8032bd10d257d9c4c0611886d14df499c33e553c60118dfc1bf6d473e0ca727a
```

Manifest含120組unique `(object_type, object_id)`，其count與bytes在建立及初次review時和fresh inventory一致。

2026-07-30 23:16（Asia/Taipei）使用者以完整approval token執行正式CLI時，delete前fresh GET發現inventory drift，工具在任何DELETE前fail closed：

```txt
error: GitHub inventory drift detected; regenerate and review manifest
```

Fresh comparison確認不是metadata時間變更，也沒有新增object；GitHub端已不存在下列兩個舊cache：

```txt
cache 5944279142
  bytes: 386,978,487

cache 5992099875
  bytes: 1,625,276,194

missing total:
  count: 2
  bytes: 2,012,254,681
```

因此manifest `48e2233a0cee0f5d9cad29e2`與其approval均正式失效，不得再次使用。

## Replacement fresh inventory

Drift後fresh inventory：

```txt
Repository: MagicalWater/flutter_architecture
Initial full-metadata Inventory SHA-256: 00c6d89fb4bee1fe113413cdf5de70e2fe2cdca3450c04decc2a0b641187fa5b

Artifacts
  count: 110
  bytes: 7,835,943,504

Caches
  count: 8
  bytes: 6,403,177,326

All objects
  count: 118
  bytes: 14,239,120,830
```

沒有新增object，也沒有現存object的ID、bytes或候選metadata變更。Classification更新為：

```txt
legacy-github-artifact: 110
legacy-github-cache: 8
```

建立replacement manifest `b6af1142e872515b7f8252d1`後，fresh GET又發現artifact `8568824484`的GitHub `expired`旗標由`false`變成`true`。該object仍存在，且ID、名稱、bytes、時間、workflow run與ref均未變。原gate因把`expired`、artifact `head_sha`與cache `version`納入inventory SHA而不必要地拒絕相同DELETE scope。

依TDD新增回歸後，`inventory_sha256`改為只綁定DELETE候選scope：

```txt
repository
artifact exact ID / name / bytes / created_at / updated_at / workflow_run_id / ref
cache exact ID / key / bytes / created_at / last_accessed_at / ref
```

完整`expired`、artifact `head_sha`與cache `version`仍保存在inventory輸出供審查，但不再影響不可逆DELETE gate。任何object增減、ID、bytes、名稱、時間或ref變更仍會fail closed。

Manifest `b6af1142e872515b7f8252d1`在取得使用者核准前即被stable-scope redesign supersede，不得使用。

Stable-scope manifest `9772870197227aed2ff33db6`通過連續fresh GET後完成commit；post-commit gate再次查詢時，GitHub端又不存在5個舊cache。Artifacts仍為110個且完全不變，沒有新增object；以下cache合計3,991,239,131 bytes已不在fresh inventory：

```txt
cache 5943454374 / 1,664,959,810 bytes
cache 5953460250 / 2,109,935,697 bytes
cache 5991962060 /    71,939,976 bytes
cache 5991964206 /    71,944,625 bytes
cache 5992013233 /    72,459,023 bytes
```

因此manifest `9772870197227aed2ff33db6`也在取得使用者核准前失效，不得使用。依既有fail-closed規則重新產生只涵蓋fresh現存objects的reviewed manifest。

## Current reviewed deletion manifest

Replacement manifest保存在同一formal managed store：

```txt
Manifest ID:
7ad138bb845e42cbb133d07c

Manifest path:
/Users/water/Developer/ci-artifacts/flutter_architecture/cleanup-manifests/github/7ad138bb845e42cbb133d07c/deletion-manifest.json

Review status:
reviewed

Reviewed by:
milestone-32-task-10-cache-eviction-rereview

Reviewed at:
2026-07-30T15:33:18Z
```

Integrity：

```txt
Deletion-scope Inventory SHA-256:
f37f377593bc79114f86c5509ca22b274b04de7ed2ec2d810b4450ac00f8fe80

Payload SHA-256:
b35ec78ecb8b8bb60a2b0ac0891fff39abb0cfd62fd964192b78052ce4797284

Whole-file SHA-256 / sidecar SHA-256:
c37c34b327cb8c7ab26677e2916aea67da791b43237da42d236523ac1fd7c1e5

Approval token SHA-256:
1163a0c049c1c69cafa4f0518bd48a38a2bc85173c8e0129812a2944ef8de586
```

Current manifest含113組unique `(object_type, object_id)`：110個artifacts與3個caches，共10,247,881,699 bytes。建立後連續兩次fresh GET確認deletion-scope inventory SHA、totals、exact IDs與bytes完全一致。

## Irreversible delete gates

實際delete必須同時滿足：

```txt
manifest regular file且不是symlink
whole-file sidecar hash通過
payload hash通過
manifest ID重新推導一致
approval token hash重新推導一致
review.status=reviewed
輸入exact approval token
CLI明確提供--execute-delete
repository一致
fresh GET deletion-scope inventory SHA一致
fresh exact IDs與bytes一致
```

任何inventory drift都必須回到Task 10重新產生、review與取得新approval；不得沿用舊manifest或舊核准。

Delete順序固定為artifacts後caches。任一未知API failure會立即停止後續操作；GitHub沒有restore API，已成功刪除的object不可恢復。

每次exact-ID API attempt都建立closed structured record：

```txt
object_type
object_id
status=deleted | failed
attempted_at
error_type
```

失敗紀錄不保存或回顯原始exception message。Manifest建立前也會以既有secret leakage scanner檢查artifact name與cache key；命中已知token／private-key pattern時直接拒絕，不把原值寫入錯誤訊息。

## Explicit non-actions

本Task與第一次Task 11 pre-delete gate實際執行過的production commands只有：

```txt
inventory
manifest pending
manifest reviewed
delete without --execute-delete gate rejection
delete with valid approval blocked by fresh inventory drift before first DELETE
```

以下皆未執行：

```txt
GitHub artifact DELETE
GitHub cache DELETE
local cleanup apply
local cleanup purge
manual filesystem deletion
```

## Whole-Task review

Task 10符合accepted Design與Plan：

```txt
fresh inventory: complete
exact object metadata: complete
replacement evidence: complete
manifest integrity: complete
review attestation: complete
approval token gate: complete
inventory drift gate: complete
exact-ID production endpoints: complete
real dry-run manifest: complete
```

Task 10在多次GitHub cache縮減與stable-scope修正後重新完成review並再次強制停止。Task 11只能在使用者對current manifest `7ad138bb845e42cbb133d07c`、113個objects、10,247,881,699 bytes與不可逆範圍給出新的獨立明確核准後重新開始；所有舊approval不得沿用。
