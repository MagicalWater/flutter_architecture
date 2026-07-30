---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-32-task-11-github-cleanup-execution
last_reviewed_baseline: 1.14.0
---

# Milestone 32 — Task 11 GitHub Cleanup Execution

## Current status

```txt
First independent approval: Superseded after fail-closed drift
Final independent approval: Received for manifest 7ad138bb845e42cbb133d07c
Final pre-delete fresh inventory gate: Passed
GitHub DELETE requests executed: 113
Objects deleted: 113
Superseded manifest: 48e2233a0cee0f5d9cad29e2
Superseded re-review manifest: b6af1142e872515b7f8252d1
Superseded stable-scope manifest: 9772870197227aed2ff33db6
Executed manifest: 7ad138bb845e42cbb133d07c
Post-delete fresh inventory: 0 objects / 0 bytes
Exact-ID absence verification: 113 / 113 passed
Current gate: Cleanup completed / release validation required
```

## First approved execution attempt

2026-07-30 23:16（Asia/Taipei），使用者依舊manifest提供完整獨立cleanup核准，並在Mac terminal執行repository-owned CLI：

```txt
manifest: 48e2233a0cee0f5d9cad29e2
approved artifacts: 110
approved caches: 10
approved bytes: 16,251,375,511
```

CLI在送出第一個DELETE前執行fresh GET並回報：

```txt
error: GitHub inventory drift detected; regenerate and review manifest
```

`deletion-execution.json`因錯誤訊息輸出至stderr而為0 bytes；它不包含成功或失敗DELETE attempt。Production工具沒有進入artifact或cache deletion loop。

## Drift evidence

Fresh comparison：

```txt
Artifacts
  manifest: 110 / 7,835,943,504 bytes
  fresh:    110 / 7,835,943,504 bytes

Caches
  manifest: 10 / 8,415,432,007 bytes
  fresh:     8 / 6,403,177,326 bytes

Missing exact IDs
  cache:5944279142 / 386,978,487 bytes
  cache:5992099875 / 1,625,276,194 bytes
```

沒有新增object、沒有現存object metadata變更，也沒有任何DELETE attempt。兩個cache在GitHub端已不存在，使舊inventory SHA與scope失效。

## Replacement scope and stable drift gate

依Plan回到Task 10後，重新產生並review：

```txt
Intermediate manifest ID: b6af1142e872515b7f8252d1
Initial full-metadata Inventory SHA-256: 00c6d89fb4bee1fe113413cdf5de70e2fe2cdca3450c04decc2a0b641187fa5b
Artifacts: 110 / 7,835,943,504 bytes
Caches: 8 / 6,403,177,326 bytes
All: 118 / 14,239,120,830 bytes
Whole-file SHA-256: f7a532013cdbd05654d4e438d2412252b3fda96d9338f05e51820b9d8e79d65f
Review status: reviewed
```

之後fresh GET只出現artifact `8568824484`的`expired=false → true`，DELETE候選scope未變。TDD確認原inventory SHA過度綁定非DELETE metadata後，工具改為stable deletion-scope fingerprint；ID、bytes、名稱、時間、workflow run或ref任何變更仍會阻擋。

Stable-scope reviewed scope：

```txt
Manifest ID: 9772870197227aed2ff33db6
Deletion-scope Inventory SHA-256: d53ec46b8fadc023a1e637f0a1cc1343a2817340bbef5f179644d99735a30235
Artifacts: 110 / 7,835,943,504 bytes
Caches: 8 / 6,403,177,326 bytes
All: 118 / 14,239,120,830 bytes
Whole-file SHA-256: a1c14d0030c75cbe3ce1158417e24d86d4ae6d9624b47e5a04b111998de74979
Review status: reviewed
```

該manifest建立並commit後，post-commit fresh GET又發現5個舊cache已不存在，合計3,991,239,131 bytes。沒有新增object、沒有artifact變更、沒有DELETE attempt，因此`9772870197227aed2ff33db6`在取得核准前被supersede。

Current reviewed scope：

```txt
Manifest ID: 7ad138bb845e42cbb133d07c
Deletion-scope Inventory SHA-256: f37f377593bc79114f86c5509ca22b274b04de7ed2ec2d810b4450ac00f8fe80
Artifacts: 110 / 7,835,943,504 bytes
Caches: 3 / 2,411,938,195 bytes
All: 113 / 10,247,881,699 bytes
Whole-file SHA-256: c37c34b327cb8c7ab26677e2916aea67da791b43237da42d236523ac1fd7c1e5
Review status: reviewed
```

Current manifest建立後連續fresh GET，deletion-scope SHA、totals、exact IDs與bytes均一致。

## Final approved execution

2026-07-31 00:02～00:04（Asia/Taipei），使用者針對current reviewed manifest提供完整獨立cleanup核准，並在Mac terminal執行repository-owned CLI。Delete前fresh GET再次確認：

```txt
Manifest ID: 7ad138bb845e42cbb133d07c
Artifacts: 110 / 7,835,943,504 bytes
Caches: 3 / 2,411,938,195 bytes
All: 113 / 10,247,881,699 bytes
Deletion-scope SHA-256: f37f377593bc79114f86c5509ca22b274b04de7ed2ec2d810b4450ac00f8fe80
Whole-file SHA-256: c37c34b327cb8c7ab26677e2916aea67da791b43237da42d236523ac1fd7c1e5
```

Execution result：

```txt
attempts: 113
status=deleted: 113
status=failed: 0
deleted artifacts: 110
deleted caches: 3
unique exact IDs: 113
first attempt: 2026-07-30T16:02:58Z
last attempt: 2026-07-30T16:04:16Z
```

Execution evidence：

```txt
/Users/water/Developer/ci-artifacts/flutter_architecture/cleanup-manifests/github/7ad138bb845e42cbb133d07c/deletion-execution.json
```

該JSON已通過secret leakage scan；沒有plaintext credential、provider config或原始exception message。

## Post-delete verification

CLI完成後重新查詢GitHub Actions storage：

```txt
Artifacts: 0 / 0 bytes
Caches: 0 / 0 bytes
All: 0 / 0 bytes
```

另對manifest中的113個exact API endpoints逐一GET；全部回傳object不存在，`verification_issues=0`。Repository沒有依CLI exit code單獨宣稱完成。

## Post-cleanup regression

```txt
Repository CI contract tests: 202 passed
Documentation checks: passed
Workspace analyze: passed in 5 packages
All Flutter package tests: passed
App Flutter suite: 463 passed
Mac Android development / production: passed
Mac iOS development Simulator / production unsigned device: passed
Windows Android development / production: passed
Android symbols / mapping: present
iOS dSYM: present
Checksums: all passed
Managed evidence secret scan: passed
```

Fresh representative local runs：

```txt
Mac Android: local-20260730t160911z-25286-2bf3b528
Mac iOS: local-20260730t161035z-26325-e6073e69
Windows Android: local-20260730t161547z-1659-7a71f753
Commit: bc5bc170575af04ebff7accaaeb890b2b7502609
```

Mac Android永久evidence為284,338,275 bytes／13 files；Mac iOS為232,818,009 bytes／271 files，`DerivedData`與`.build`均為0。Windows Android為284,501,727 bytes／13 files。

## Final disposition

Manifest `48e2233a0cee0f5d9cad29e2`及其approval token已失效；`b6af1142e872515b7f8252d1`與`9772870197227aed2ff33db6`也都已supersede，不得使用。Final manifest `7ad138bb845e42cbb133d07c`已完整執行，也不得再次使用；GitHub目前沒有可刪除的artifact或cache。

```txt
Task 11 cleanup execution: ACCEPTED
GitHub storage cleanup: COMPLETED
Objects deleted by repository CLI: 113
Objects remaining: 0
Open P0: 0
Open P1 without disposition: 0
Next gate: Template Baseline 1.14.0 release and post-release validation
```
