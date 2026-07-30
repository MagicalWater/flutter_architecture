---
document_type: runtime-evidence
status: active
authoritative_for:
  - milestone-32-task-11-github-cleanup-execution
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 11 GitHub Cleanup Execution

## Current status

```txt
First independent approval: Received for manifest 48e2233a0cee0f5d9cad29e2
Pre-delete fresh inventory gate: Failed closed due drift
GitHub DELETE requests executed: 0
Objects deleted: 0
Superseded manifest: 48e2233a0cee0f5d9cad29e2
Superseded re-review manifest: b6af1142e872515b7f8252d1
Current reviewed manifest: 9772870197227aed2ff33db6
Current gate: New independent approval required
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

Current reviewed scope：

```txt
Manifest ID: 9772870197227aed2ff33db6
Deletion-scope Inventory SHA-256: d53ec46b8fadc023a1e637f0a1cc1343a2817340bbef5f179644d99735a30235
Artifacts: 110 / 7,835,943,504 bytes
Caches: 8 / 6,403,177,326 bytes
All: 118 / 14,239,120,830 bytes
Whole-file SHA-256: a1c14d0030c75cbe3ce1158417e24d86d4ae6d9624b47e5a04b111998de74979
Review status: reviewed
```

Current manifest建立後連續fresh GET，deletion-scope SHA、totals、exact IDs與bytes均一致。

## Stop condition

Manifest `48e2233a0cee0f5d9cad29e2`及其approval token已失效；intermediate manifest `b6af1142e872515b7f8252d1`也已被stable-scope redesign supersede，兩者都不得使用。Task 11保持open，必須針對current manifest `9772870197227aed2ff33db6`、110個artifacts、8個caches、14,239,120,830 bytes及不可逆影響取得新的獨立明確核准後，才能重新執行exact-ID DELETE。
