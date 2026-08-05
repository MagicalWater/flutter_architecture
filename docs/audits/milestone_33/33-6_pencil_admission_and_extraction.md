---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-33-task-33-6-pencil-admission-and-extraction
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-6 Pencil Admission and Structural Extraction

## Scope

本evidence記錄repository-local `source.pen`的Pencil MCP admission、結構／variables extraction與canonical renderer export。

本Task沒有修改Pencil canvas、沒有native解析或直接編輯`.pen`、沒有修改Flutter production source。唯一Pencil寫入型外部動作是把accepted root frame匯出為PNG；匯出不改變canvas。

## Admission Evidence

| Gate | Fresh evidence | Result |
|---|---|---|
| Managed worktree | `C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8` | PASS |
| Branch | `milestone-33-pencil-to-flutter-workflow` | PASS |
| Executor | `executor v1.5.35` | PASS |
| Canonical Executor scope | `D:\Developer\gpt-computer-bridge` | PASS |
| Pencil integration | owner-scoped `pencil.user.desktop.*`, 7 tools | PASS |
| Pencil Desktop | Windows Pencil Desktop `1.2.3` | PASS |
| Active editor | worktree-local `docs/design_sources/pencil-compatibility-write-precheck/source.pen` | PASS |
| Source raw SHA-256 | `bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc` | PASS |
| Native parser fallback | not used | PASS |

Fresh `get_app_state` confirmed these top-level nodes:

```txt
gY9yA   Component / Data Row
H3co21  Component / Step Item
aZMKq   Component / Record Tile
h6mPw5  Component / Secondary Button
lAOay   Screen / Write Pre-check Reconstruction
```

The four component frames are marked `reusable: true`. The accepted screen root is `lAOay`.

## Guidelines Loaded

The current guideline catalog was queried first. Only these task-relevant guides were loaded:

- `Code`
- `Design System`

Framework-specific React／Tailwind examples in the generic Code guide are non-authoritative for this Flutter repository. Its structure extraction, component reuse, exact text/icon/spacing and screenshot verification requirements remain applicable. Repository architecture, ADR-028 and the accepted Design／Plan override incompatible framework examples.

## Root Frame

```txt
ID: lAOay
Name: Screen / Write Pre-check Reconstruction
Type: frame
Canonical width: 941
Canonical height: 1672
Clip: true
Layout mode: none
Canvas position: x=0, y=298
```

The root uses a three-stop dark vertical background gradient and two radial ambient glows. The screen is an absolute-positioned visual authority, not a responsive Flutter layout prescription.

## Structural Inventory

### Status, header and progress

- Static status row: time, Wi-Fi, cellular signal, battery and percentage.
- Header divider, back button, title `寫前檢查` and subtitle `安全寫入流程 · 步驟 3/4`.
- Four-step progress track using four instances of `Component / Step Item`.
- Steps 1 and 2 are completed, step 3 is active, step 4 is pending.
- Active step uses cyan／gold radial glow, gold stroke and outer shadow.

### Hero state

- `Hero / Pre-check Passed`, `853 × 254`, radius `24`, gold border and outer shadow.
- Shield halo, shield ring and `shield-check` icon.
- Title, explanatory paragraph and `可開始寫入` status pill.
- Decorative gold orbit rings and dots are non-interactive visual primitives.

### Transaction summary

Five `Data Row` instances:

1. 目標標籤 — `Type 2 Tag / MIFARE Ultralight`
2. 寫入內容 — `2 筆記錄`
3. 預估大小 — `186 bytes`
4. 寫入模式 — `覆寫既有 NDEF`
5. 備份狀態 — `將建立加密備份`

### Pre-check results

Five compact `Data Row` instances:

1. 標籤相容性 — `符合本次寫入格式`
2. 可用容量 — `仍有足夠空間`
3. 寫入權限 — `可寫入，未偵測鎖定`
4. 連線穩定性 — `已穩定偵測`
5. 目前判定 — `可以安全開始寫入`

The section includes a technical details bar: `UID 已確認、NDEF 會話已就緒`.

### Expected records

Two `Record Tile` instances:

- `文字記錄（zh-TW）` — `NFC Lab 測試內容` — `記錄 1`
- `網址連結` — `https://example.com/demo` — `記錄 2`

### Recommended next step

- Three guidance lines about keeping the tag near the device, not moving it and encrypted-backup recovery.
- A gold warning／commitment banner describing immediate write-and-verify behavior.

### Actions

- Primary action: `確認並開始寫入`.
- Secondary actions: `查看技術詳情`, `返回修改內容`.
- End-flow action: `結束此次流程`.

## Reusable Component Inventory

| ID | Component | Size | Reuse in screen | Important overrides |
|---|---|---:|---:|---|
| `gY9yA` | Data Row | `820 × 44` | 10 | icon, label, value, divider, compact row height |
| `H3co21` | Step Item | `205 × 88` | 4 | glow, circle, number/check, label, active/pending state |
| `aZMKq` | Record Tile | `820 × 66` | 2 | icon, title, subtitle, badge |
| `h6mPw5` | Secondary Button | `408 × 58` | 2 | width, icon, label and x offsets |

These Pencil components map to feature-local Flutter widgets. They are not promoted to `packages/design_system` because this proof has only one real consumer.

## Variable Inventory

| Variable | Type | Value |
|---|---|---|
| `nfc-bg` | color | `#020B14` |
| `nfc-bg-deep` | color | `#01070D` |
| `nfc-surface` | color | `#071522` |
| `nfc-surface-2` | color | `#0B1B2B` |
| `nfc-border` | color | `#536B7E` |
| `nfc-border-soft` | color | `#244056` |
| `nfc-text` | color | `#EAF2F8` |
| `nfc-muted` | color | `#B8C4CF` |
| `nfc-dim` | color | `#7F94A7` |
| `nfc-cyan` | color | `#3DAEFF` |
| `nfc-cyan-bright` | color | `#74D8FF` |
| `nfc-cyan-deep` | color | `#0A4A82` |
| `nfc-gold` | color | `#F5B941` |
| `nfc-gold-soft` | color | `#9A6A25` |
| `nfc-font` | string | `Noto Sans TC` |
| `nfc-radius-card` | number | `24` |
| `nfc-radius-row` | number | `12` |

No existing global theme token was proven to have exact value parity with the extracted NFC palette. Exact colors therefore remain feature-local under the accepted Design rather than being silently approximated or promoted globally.

## Typography, Spacing and Effects

- Font family authority: `Noto Sans TC`.
- Visible font sizes range from `15` to `34`; primary button label is `29`.
- Font weights include normal, `500`, `600` and `700`.
- Reusable spacing values that exactly match `DsSpace`: `4`, `8`, `12`, `16`, `24`, `32`.
- Card radius `24`, button radii `16`／`18`, pill radius `21`, record radius `14` and guidance radius `9` remain feature-local.
- Row radius `12` exactly matches `DsRadius.lg`.
- Effects include linear gradients, radial gradients, inner highlight lines, 1–3 px strokes and outer shadows with blur up to `22`.
- No shader fill, mesh gradient, image fill, external bitmap, script node or SVG path is present in the accepted screen subtree.

## Icon Inventory

All extracted icon nodes use the `phosphor` library with weight `300`. Visible identities include:

```txt
wifi-high, cell-signal-high, battery-full, arrow-left,
clipboard-text, checks, files, lightbulb, warning, info,
shield-check, check-circle, tag, database, arrows-clockwise,
lock-key, seal-check, hard-drives, lock-open, broadcast,
text-t, link, list-magnifying-glass, pencil-simple,
x-circle, caret-right
```

Material icon substitution is not accepted. Task 33-7 adopts `phosphoricons_flutter` and must verify exact exported names against that package API.

## Unsupported Constructs and Renderer Ambiguities

1. **Absolute layout authority** — The screen uses `layout: none` and fixed coordinates. Flutter must reconstruct hierarchy responsively; whole-screen `FittedBox` or fixed-canvas scaling is forbidden.
2. **Gradient rotation semantics** — Pencil and Flutter encode gradient direction differently. The feature-local visual spec must describe resolved begin/end alignment, not copy degree values blindly.
3. **Font availability** — `Noto Sans TC` is the design authority. Task 33-7／33-8 must verify the chosen Flutter font path and fallback behavior without inventing a global typography token.
4. **Static status bar** — Status indicators are part of the canonical visual proof. They are decorative fixture content, not an instruction to control real device status APIs.
5. **Phosphor naming parity** — Exact icon identities are known, but Dart symbol names must be verified against the pinned package version during TDD.

Each ambiguity has an accepted Flutter disposition in the mapping matrix. No ambiguity requires changing the accepted `.pen` or the Plan.

## Canonical Export

Pencil MCP `export_nodes` was called with:

```txt
file: worktree-local source.pen
nodeIds: [lAOay]
format: png
scale: 1
```

Fresh output verification:

```txt
Dimensions: 941 × 1672
Raw SHA-256: f453452316f0e390dbbf435a3f4c2433306fb3aa607287873e9905f00973eee8
Bytes: 676527
Destination: docs/design_sources/pencil-compatibility-write-precheck/pencil-preview.png
Source .pen SHA-256 after export: bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc
```

The destination hash exactly matches the Pencil MCP output hash. The primary `.pen` hash remained unchanged.
