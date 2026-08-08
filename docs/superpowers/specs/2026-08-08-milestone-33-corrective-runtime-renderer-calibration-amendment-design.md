# Milestone 33 Corrective — Runtime Renderer Calibration Amendment Design

Status: accepted

## Requirement Decision

- Request（需求）：修正C2 runtime pixel gate的renderer calibration矛盾，繼續完成Milestone 33 single-renderer corrective。
- Problem（問題）：C2把Pencil `941 × 1672` canonical preview直接投影成`360 × 640` PNG後，要求Flutter runtime在`perChannelTolerance = 8`下`differentPixelRatio <= 0.08`。實測證明，即使把已通過canonical gate的Flutter canonical golden用完全相同`projectPng`演算法投影到`360 × 640`，仍會得到高於`0.08`的diff，因此runtime硬門檻混入了Pencil export raster與Flutter runtime rasterization差異。
- Current behavior（目前行為）：C2的direct Pencil runtime gate把「design fidelity」與「cross-renderer/downsample raster差異」綁成同一個8%數字；C3會被迫為測試插值／glyph rasterization微調UI，而非只修真正的layout／component drift。
- Expected behavior（預期行為）：canonical仍直接對Pencil authority做固定8%硬門檻；deterministic runtime則對「同一份已通過canonical gate的Flutter canonical golden之deterministic 360×640 projection」做固定same-renderer fidelity gate；Android實際renderer以fresh screenshot、semantic side-by-side與使用者人工P1 gate驗收。
- Value（價值）：保留自動化對parallel renderer與runtime drift的攔截能力，同時避免用不可攜的跨rendererpixel threshold驅動錯誤UI微調。
- Classification（分類）：Level 4 corrective architecture／acceptance-contract amendment。
- Decision（決策）：Accept。
- Scope（範圍）：C2/C3/C4 visual acceptance contract、runtime diff test、Skill/Guide wording與corrective reviews。
- Non-goals（非目標）：不放寬canonical Pencil fidelity；不新增第二套UI；不新增ignore region；不改`.pen`；不把Android人工驗收降級為optional。
- Behavioral requirements required（是否需要行為需求）：是。
- Design Spec required（是否需要 Design Spec）：是，本文件。
- Implementation Plan required（是否需要 Implementation Plan）：是，另有amendment Plan。
- ADR required（是否需要 ADR）：不新增ADR；此為已接受ADR-028 single-renderer方向的acceptance calibration修正。
- Task governance mode（Task 治理模式）：Corrective雙層Task治理。
- Worktree／branch：`milestone-33-corrective-single-renderer` managed worktree。
- Regression level（Regression 等級）：affected visual tests + full Milestone 33 visual/repository regression。
- Release required（是否需要發布）：仍依原Corrective Plan，預期1.15.1，需C4人工驗收與C5 Final Review後才可決定。
- Post-release validation（發布後驗證）：仍必須。
- Required Superpowers skills（必要 Superpowers Skills）：brainstorming、writing-plans、systematic-debugging、TDD、verification-before-completion。
- Required artifacts（必要 artifacts）：本Design amendment、Plan amendment、雙層review、更新後runtime visual test與fresh metrics。

## P1 Evidence

原C2固定契約：

```txt
Pencil canonical source: 941 × 1672
derived runtime reference: 360 × 640
per-channel tolerance: 8
differentPixelRatio max: 0.08
meanAbsoluteChannelDelta max: 8.0
```

已觀察到兩組candidate-independent calibration evidence：

```txt
Template 1.15.0 accepted Flutter canonical
→ same projectPng 360 × 640 projection
→ Pencil-derived 360 × 640 reference
differentPixelRatio ≈ 0.0890842

C3 improved Flutter canonical（仍通過原canonical ≤ 0.08 gate）
→ same projectPng 360 × 640 projection
→ Pencil-derived 360 × 640 reference
differentPixelRatio = 0.08782552083333334
meanAbsoluteChannelDelta = 2.5628602430555554
```

因此「runtime必須直接對Pencil-derived reference ≤ 0.08」不能作為same-renderer implementation correctness的唯一硬門檻。該值會把已存在於accepted canonical與Pencil renderer之間的raster差異再次放大／重採樣。

## Accepted Calibration Model

### Gate A — Canonical Design Fidelity（硬門檻）

保持既有contract，不變：

```txt
Pencil canonical 941 × 1672
↔ Flutter canonical 941 × 1672
perChannelTolerance = 8
differentPixelRatio <= 0.08
meanAbsoluteChannelDelta <= 8.0
```

這個gate直接證明Flutter visual model仍忠實於`.pen` authority。

### Gate B — Deterministic Runtime Projection Fidelity（硬門檻）

Runtime不直接拿Pencil export raster當同renderer pixel master，而是：

```txt
Flutter canonical golden（必須先通過Gate A）
→ projectPng(width: 360, height: 640)
→ projected Flutter canonical reference

Flutter WritePrecheckView at 360 × 640
↔ projected Flutter canonical reference
```

固定門檻：

```txt
perChannelTolerance = 8
differentPixelRatio <= 0.10
meanAbsoluteChannelDelta <= 4.0
ignore regions = none
```

規則：

- reference每次由tracked canonical Flutter golden fresh投影到temporary path，不建立第二個visual authority。
- canonical golden本身若未通過Gate A，Gate B無效且整體FAIL。
- Candidate runtime出現後不得修改`0.10`／`4.0`、target size、crop或ignore regions。
- Gate B只驗證same visual tree在runtime尺寸沒有產生額外重大drift；它不能取代Gate A。

### Gate C — Pencil-derived Runtime Diagnostic（非單獨PASS來源）

原`pencil-runtime-360x640.png`與其SHA保留，並繼續量：

```txt
Flutter runtime ↔ Pencil-derived runtime reference
```

該結果必須記錄於review，用於趨勢、debug與人工side-by-side；但不再以`<= 0.08`單獨決定runtime PASS。不得刪除、重建或事後更換原C2 reference以改善candidate數字。

### Gate D — Android Supported Runtime（硬人工門檻）

BlueStacks current acceptance environment：

```txt
physical = 540 × 960
DPR = 1.5
logical = 360 × 640
textScale = 1.0
```

必須：

1. fresh build/install production route；
2. fresh screenshot與hash；
3. 對Pencil reference做side-by-side semantic review；
4. 檢查hierarchy、spacing、typography、icons、card/action identity、state、content completeness、scroll reachability；
5. 使用者實際看BlueStacks並明確通過。

Android screenshot的direct pixel diff可記錄為diagnostic，但不同Skia／GPU／DPR renderer的單一numeric threshold不取代使用者P1 gate。

## Anti-cheat Rules

- 禁止為Gate B建立test-only renderer。
- 禁止runtime使用canonical screenshot／raster asset作production UI。
- 禁止parallel whole-screen widget tree。
- 禁止候選出現後調整Gate A/B thresholds。
- 禁止以Gate B PASS覆蓋Gate A FAIL或使用者semantic P1。
- 禁止刪除C2原始68.43% failure evidence；它仍是superseded dual-renderer regression baseline。

## Acceptance

本amendment於2026-08-08在P1 evidence呈現後取得使用者明確「已批准」。它只supersede原Corrective Design／Plan中「360×640 runtime直接對Pencil-derived reference也必須≤8%」的硬判定；其餘single-renderer、canonical fidelity、Android runtime與人工驗收規則維持有效。
