# Milestone 33 CP2 — Runtime Renderer Calibration Amendment Review

Status: accepted

## Finding

原C2 direct Pencil runtime hard gate存在P1 internal-consistency defect：

```txt
1.15.0 accepted canonical → same projectPng 360×640
vs Pencil-derived runtime reference
differentPixelRatio ≈ 0.0890842 > 0.08

C3 improved canonical（仍通過canonical Gate A）→ same projection
differentPixelRatio = 0.08782552083333334 > 0.08
```

因此繼續要求production runtime直接低於`0.08`會把cross-renderer/downsample差異誤當成implementation failure。

## Disposition

PASS — 接受renderer-calibrated四層模型：

1. Gate A：Pencil canonical ↔ Flutter canonical，`ratio<=0.08`、`mean<=8.0`。
2. Gate B：Flutter runtime 360×640 ↔ fresh projected Flutter canonical，`ratio<=0.10`、`mean<=4.0`。
3. Gate C：Flutter runtime ↔ Pencil-derived runtime reference保留diagnostic，不單獨宣告PASS。
4. Gate D：BlueStacks fresh screenshot + semantic review + user explicit visual acceptance。

## Anti-cheat Review

- 原C2 derived Pencil runtime reference與SHA保留，不重建。
- 沒有ignore region。
- 沒有crop change。
- 沒有新增parallel renderer。
- Gate A未放寬。
- Gate B的`0.10／4.0`在amendment execution前固定。
- 使用者人工P1仍可否決所有automation結果。

## Governance

此finding會supersede原Corrective Plan中「direct Pencil 360×640 diff <= 0.08為runtime硬PASS」的單一criterion，但不改寫C2歷史failure evidence。2026-08-08使用者在finding與calibrated direction呈現後明確回覆「已批准」，因此Design／Plan amendment可標記為accepted並繼續C3。
