---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-44-post-closure-color-ownership-adoption-corrective-design
last_reviewed_baseline: 1.23.0
---

# Milestone 44 Post-closure Corrective C1 — Color Ownership Adoption — Design

## Status

**Accepted — 2026-08-19 使用者明確核准。**

Requirement authority：`docs/audits/milestone_44/44-c1_color_ownership_adoption_requirement_decision.md`。

## Problem statement

M44已建立正確的stable color ownership rule，但current Write Precheck reference production沒有完整採用。最明確的例子是`WritePrecheckPalette.dim`已擁有`0xFF7F94A7`，`WritePrecheckStep`仍直接重寫相同raw literal。另一方面，current source共有110個`Color(0x...)` occurrences，其中大量是gradient/glow/artwork exact values；若直接用「raw literal存在即FAIL」修正，會違反M44已接受的component-local decoration與anti-formalism邊界。

本Corrective因此只修正**shared semantic / shared feature visual role已成立但consumer ownership沒有收斂**的部分，並建立能防止owner bypass的direct machine regression。

## Design principles

### 1. Ownership先於literal形式

`Color(0x...)`不是天然違規。判定順序維持ADR-018：

```txt
representation noise?
→ semantic / stable feature visual role?
→ intentional contextual variant?
→ component-local decoration / artwork exact value?
```

只有shared owner成立後，consumer再重寫同semantic raw value才是本Corrective的direct failure。

### 2. `WritePrecheckPalette`維持窄責任feature-local owner

它只擁有跨多個Write Precheck bounded owners穩定共用的solid visual roles，不接管：

- gradient stop sequences；
- glow alpha variants；
- shadow alpha variants；
- component-specific surface fills；
- artwork geometry或representation provenance；
- canonical viewport／projection metadata。

Fresh usage audit支持把下列solid roles收斂至既有feature-local palette：

```txt
goldAccent     = 0xFFF5B941
blueAccent     = 0xFF3DAEFF
cyanAccent     = 0xFF74D8FF
subtleOutline  = 0xFF244056
dim            = 0xFF7F94A7   // already owned
```

命名表達visual role而不是假造domain semantics。`goldAccent`可同時服務active/highlight/warning-like visual treatment，前提是accepted proof確實使用同一stable visual accent；不把它錯命名為`warning`。`blueAccent`、`cyanAccent`同理。

### 3. Component-local exact values繼續合法

例如`0xFF0C1A2A`若只屬record badge surface，沒有第二consumer或stable shared role，保留smallest correct component owner。`0x30F5B941`、`0x663DAEFF`等alpha/gradient/glow values也不因base RGB相同就自動promotion。

這是必要positive control，防止corrective退化成mega palette。

### 4. Direct machine rule只拒絕palette bypass

在Write Precheck focused architecture test中建立source-level owner check：

1. 解析`write_precheck_palette.dart`中`static const Color <name> = Color(<value>)`。
2. 掃描Write Precheck consumer Dart sources。
3. 若consumer直接出現與palette已宣告值完全相同的`Color(<value>)`，回報`shared palette literal bypass`。
4. Palette owner source本身排除。
5. 其他未在palette宣告的raw colors不因本rule自動失敗。

此rule不使用raw literal count、file count或RGB相似度作oracle，因此不與PTF-56／57衝突。

### 5. Risk-selected inventory不是永久manifest

本Corrective會在review evidence記錄repeated solid values及其disposition，但不新增一份production color manifest或第二套token registry。Stable owner仍是Dart palette／Design System；audit只保存「為何這次promotion或保留local」的證據。

### 6. Visual identity零變更

這次只重定向ownership，不改color bytes。所有promotion必須保持exact ARGB value；不修改accepted `.pen`、golden、threshold、crop、ignore regions。

## Production ownership disposition

### Promote to existing feature-local palette

| Value | Current evidence | Disposition |
|---|---|---|
| `0xFFF5B941` | 16 occurrences / 5 files；active/highlight/gold accent跨bounded owners | `WritePrecheckPalette.goldAccent` |
| `0xFF3DAEFF` | 7 occurrences / 3 files；completed/info/blue accent跨bounded owners | `WritePrecheckPalette.blueAccent` |
| `0xFF74D8FF` | 3 occurrences / 2 files；cyan accent/content跨owners | `WritePrecheckPalette.cyanAccent` |
| `0xFF244056` | 3 occurrences / 2 files；hairline/border subdued outline role | `WritePrecheckPalette.subtleOutline` |
| `0xFF7F94A7` | existing `WritePrecheckPalette.dim` + consumer literal bypass | replace consumer literal with `WritePrecheckPalette.dim` |

### Keep component / decorative local

- Unique component surface fills／borders whose change reason is local to that component.
- Gradient stop colors whose ordered sequence is part of one visual primitive.
- Glow／shadow alpha variants even when base RGB matches a shared accent.
- Artwork-specific exact colors without a stable multi-consumer role.

## Machine and test design

### RED

Before production migration, add a focused test proving current source fails because`0xFF7F94A7` is declared in`WritePrecheckPalette` and also directly hard-coded in a consumer.

The RED may additionally expose newly promoted shared values once palette declarations are staged, but implementation ordering must keep the failure source clear.

### GREEN

- Replace shared solid raw literals with palette references.
- Preserve exact visual bytes.
- Keep local decorative literals untouched unless semantic audit proves they belong to one of the shared roles.

### Positive control

Focused policy helper must accept a consumer containing a local exact color not declared by the palette, proving the test does not ban all raw colors.

## Documentation / consumer governance

ADR-018 does not change. `implementing-pencil-flutter-design` already expresses the correct owner classification, so no new Skill or broad Skill rewrite is required unless implementation review finds a wording gap.

M44 post-closure audit evidence must explicitly correct the earlier closure overclaim: primary layout closure remains valid；color stable governance remains valid；production color adoption had a bounded omission now corrected by C1.

## Validation design

Minimum direct owners：

- Write Precheck architecture contract RED/GREEN.
- Write Precheck copy/palette contract.
- Pencil canonical/runtime golden because exact palette references touch rendered production source.
- Presentation architecture contract to ensure no unrelated M44 layout regression.
- docs policy/checker for governance evidence.

Final exact validation由`tools/ci/validation_planner.py`對implementation range決定；Design不預先把full regression當成固定儀式。

## Success criteria

- 已宣告shared palette value不再被Write Precheck consumer raw literal繞過。
- `goldAccent`／`blueAccent`／`cyanAccent`／`subtleOutline`的跨owner consumers改用同一feature-local owner。
- Intentional component-local／gradient／glow／artwork colors仍可保留raw exact values，沒有mega palette。
- Machine test能對palette bypass先RED後GREEN，並有local-decoration positive control。
- Canonical/runtime visual acceptance不變。
- M44 layout主責與accepted visual authority不被修改。
- Open P0 = 0；Open P1 without disposition = 0。

## Non-goals

- 不重構`packages/design_system`或Theme。
- 不新增generic color-governance Skill。
- 不禁止所有raw colors。
- 不把所有ARGB alpha variants變成tokens。
- 不處理asset／l10n／general magic code。
- 不重開M44 layout corrective。
- 不修改`.pen`或golden acceptance contract。

## Approval gate

本Design已完成focused review、fresh re-review與whole-Design review，並於2026-08-19取得使用者明確核准。Implementation Plan現在允許建立；Plan完成雙層Task治理並取得使用者明確核准前，仍不得修改production source。

