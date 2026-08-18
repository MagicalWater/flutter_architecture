---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-7-stable-authority-sync
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-7 Stable Authority Synchronization Review

## Scope

在Tasks 42-4～42-6已證明production ownership與visual/runtime truth成立後，才把Milestone 42 UI Design Ownership Architecture同步成repository stable authority。本Task不是只描述Write Precheck corrective，而是固定未來所有repository-local Pencil → Flutter工作都必須遵守的ownership route。

## Stable authority synchronized

### ADR-018 — Design System boundary

新增repository-wide UI Design Ownership Architecture：

```txt
shared semantic / Theme Identity / validated reusable component
→ packages/design_system public API

raster / vector / icon / font / texture
→ asset / representation provenance authority

canonical viewport / DPR / comparison metadata
→ visual-authority metadata

screen / section placement mechanics
→ layout owner

single-screen exact geometry / decoration
→ smallest correct component owner
```

Promotion依semantic identity、stable theme responsibility與consumer evidence，不依raw value相同；single-consumer exact value也不得污染Design System。

### ADR-028 — Pencil → Flutter mapping

Flutter mapping現在必須同時完成：

```txt
layout ownership
+ representation / provenance
+ UI design ownership
```

Risk-selected `ui_design_ownerships`使用closed owner vocabulary；unresolved fail closed。`pages/`只做Page/View orchestration，projection/render mechanics與bounded components有各自owner。

### implementing-pencil-flutter-design Skill

Domain Skill正式新增UI Design Ownership classification gate。下列情況是production hard stop：

- generic `*VisualSpec`／`*VisualTokens`／`*UiSpec`／`*StyleConfig`混合多種UI ownership；
- shared semantic owner unresolved；
- canonical viewport／DPR被放入Design System；
- asset provenance被塞進visual token/spec class。

### Representation / asset governance

`asset-and-typography-mapping.md`仍是asset identity、source、transformation、destination、content hash的唯一owner。UI ownership只能引用其evidence，不建立第二套asset registry。

### Human Guide

`docs/guides/pencil_to_flutter_workflow.md`現在提供可重複的human decision route，明確說明Design System、asset authority、visual authority、layout與smallest component ownership，並禁止generic feature UI Spec escape hatch。

### Local package/feature snapshots

- `packages/design_system/README.md`同步Design System non-responsibilities：不吸收single-screen exact geometry、canonical metadata或asset provenance。
- `pencil_compatibility/README.md`同步current source ownership，不再宣稱feature-local visual specification為預設結構。
- `docs/project_context.md`與active roadmap同步Milestone 42 current architecture與execution state。

## Behavioral contract expansion

Skill pressure scenarios新增PTF-30～34：

- PTF-30 shared semantic duplicated into FeatureVisualSpec → FAIL；
- PTF-31 single-screen token promotion污染Design System → FAIL；
- PTF-32 page/render/component responsibility dump → FAIL；
- PTF-33 generic FeatureUiSpec dumping → FAIL；
- PTF-34 asset paths inside VisualSpec → FAIL。

Static wording存在本身不構成behavioral acceptance；fresh isolated-agent evidence仍由Task 42-8執行。

## Focused review

- Finding：若只修改ADR而不修改Skill/Guide，future Agent仍可能沿舊`feature-local visual spec` route。Resolved：ADR、Skill、mapping references、Guide、Feature README與Design System README一起同步。
- Finding：asset governance可能被Milestone 42重新複製成第二套registry。Resolved：stable wording明確讓representation/provenance authority保持唯一owner，UI mapping只引用evidence。
- Finding：所有Pencil exact values都promotion進Design System會造成反向污染。Resolved：promotion與non-promotion條件同時固定。
- Finding：Presentation ownership可能被誤解為file-count lint。Resolved：ADR/Skill wording以responsibility判定，沒有line-count或one-widget-one-file hard rule。

## Fresh validation

Validation planner對本Task判定為`affected`，change classes為`docs_content / governance / app_feature / package`，要求App與Design System analyze/tests、`tools/docs`與`docs_check`。

Fresh results：

```txt
apps/flutter_architecture
  dart analyze
  → PASS
  flutter test test
  → 499 tests PASS

packages/design_system
  dart analyze
  → PASS
  flutter test test
  → 43 tests PASS

python -m unittest discover tools/docs
→ 94 tests PASS

dart run melos run docs_check
→ PASS

git diff --cached --check
→ PASS
```

App regression包含Pencil compatibility visual/runtime owners；Design System regression包含Theme、semantic colors、primitives與gallery goldens。沒有因stable governance同步產生runtime或package regression。

## Whole-Task disposition

Stable authority已對齊accepted Revised Design、machine contract與current production source；沒有文件宣稱新的parallel authority。

```txt
Task 42-7: PASS / ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Next: Task 42-8 fresh behavioral pressure acceptance
```
