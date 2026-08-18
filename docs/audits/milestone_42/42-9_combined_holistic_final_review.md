---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-9-combined-holistic-final-review
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-9 Combined Milestone 41+42 Holistic Final Review

## Scope

本Review重新形成Milestone 41 constraint-layout corrective + Milestone 42 presentation/UI ownership corrective的單一`1.21.0` release candidate。Milestone 41從未publication，因此不切成兩個獨立release。

## Authority traceability

Milestone 41：accepted Requirement → accepted Design → accepted Plan → Tasks 41-1～41-8 accepted → constraint/relationship screen layout contract → PTF-27～29 fresh behavioral PASS。

Milestone 42：accepted Requirement → accepted Revised Design → accepted rebuilt Plan → Tasks 42-1～42-8 accepted → 本Task combined holistic。

Approval chain沒有缺口；本Task沒有新增未經Design／Plan核准的architecture scope。

## Production architecture review

Current Pencil compatibility presentation ownership：

```txt
presentation/pages/
  write_precheck_page.dart
  write_precheck_view.dart

presentation/layout/
  write_precheck_projection.dart

presentation/widgets/write_precheck/
  write_precheck_content.dart
  write_precheck_palette.dart
  write_precheck_typography.dart
```

Fresh scan確認：

- `pages/`沒有`MultiChildRenderObjectWidget`、`RenderObject`、`RenderStack`、`StackParentData`或`performLayout` owner；
- feature source不存在`PencilCompatibilityVisualSpec`；
- 不存在generic `FeatureVisualSpec`／`FeatureUiSpec`／`FeatureVisualTokens`／`FeatureStyleConfig` replacement；
- projection/render mechanics位於`layout/`，bounded content位於`widgets/`；
- Milestone 41 whole-screen canonical-coordinate shortcut detector仍成立，沒有把fixed-canvas page flow藏回其他root helper。

## UI Design Ownership Architecture review

Stable routing：

```txt
shared semantic / Theme Identity / stable shared component
→ Design System public owner

raster / vector / icon / font / texture
→ existing representation + provenance authority

canonical viewport / DPR / comparison metadata
→ visual authority

screen / section placement mechanics
→ layout owner

one-off exact geometry / decoration
→ smallest correct component/local owner
```

`implementation_mapping.json`保存risk-selected `ui_design_ownerships`，validator會fail closed於missing/unresolved owner、Design System deep import、canonical metadata誤入DS、intentional-local缺理由，以及UI ownership section偷藏asset provenance。沒有建立global every-token registry或第二套asset registry。

ADR-018、ADR-028、`implementing-pencil-flutter-design` Skill、asset/typography mapping、Flutter mapping、human Guide、Feature README與Design System boundary一致。

## Behavioral review

Task 42-8 fresh isolated ChatGPT Web evidence：

- PTF-30 shared semantic hidden in FeatureVisualSpec：PASS；
- PTF-31 single-screen exact value promoted to DS：PASS；
- PTF-32 same-layer page responsibility dump：PASS；
- PTF-33 generic FeatureUiSpec dumping：PASS；
- PTF-34 asset paths inside VisualSpec：PASS；
- same-hex / different semantics negative edge：PASS；
- proven shared semantic positive control：PASS。

治理因此不是單向「全部promotion」或「全部local」，而是依semantic identity、stable ownership、consumer/change coupling與smallest-correct-owner routing決策。

## Visual authority integrity

Fresh SHA-256：

```txt
source.pen
bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc

pencil-preview.png
f453452316f0e390dbbf435a3f4c2433306fb3aa607287873e9905f00973eee8

pencil-runtime-360x640.png
8386e4fa6ad49d108b9887796eb3c02643aaae9ba0161afa10d0662ab4b2c275
```

均與accepted manifest相符。Milestone 42沒有修改`.pen`、golden master、visual threshold、crop或ignore region。

## Validation planner

Fresh command：

```txt
python tools/ci/validation_planner.py --event pull_request --base origin/main --head HEAD --stdout-json
```

Result：

```txt
validation_level=release
full_regression=true
generated_check=true
android_build=true
ios_build=true
change_classes=docs_content,governance,tooling,test_only,app_feature,package,release
fail_safe=false
```

因此本Task執行release/full gate，而不是只沿用affected tests。

## Fresh Windows release/full validation

### Analyze

`dart run melos run analyze`：5 packages **PASS**。

### Full Flutter regression

`dart run melos exec -- flutter test`：5 packages **PASS**。

Observed totals：

```txt
flutter_architecture: 499 PASS
design_system: 43 PASS
auth: 156 PASS
api_client: 59 PASS
core: 4 PASS
```

### Repository Python / machine policy

```txt
python -m unittest discover -s tools -p 'test_*.py'
→ 11 PASS

python -m unittest tools.visual.test_verify_visual_authority tools.visual.test_pencil_implementation_mapping tools.docs.test_pencil_representation_mapping_policy tools.docs.test_pencil_single_renderer_policy
→ 50 PASS
```

### Documentation

`dart run melos run docs_check`：**PASS**。

### Generated consistency

Canonical `tools/ci/verify_generated.sh`在Windows managed worktree被Git Bash cross-drive worktree path translation阻擋，錯誤發生在repository discovery而不是generated content。本Review沒有把該環境錯誤當PASS，而是按script逐步執行Windows等價流程：

```txt
dart run melos run build_runner
Drift v1～v6 + current schema dump
normalize_drift_schema_json.py
dart compile js web/drift_worker.dart -O4
python -m unittest tools.ci.test_drift_schema_governance
git diff --ignore-space-at-eol --exit-code
untracked-file check
```

Result：build_runner全部workspace成功；Drift governance 2 PASS；zero substantive generated diff；沒有untracked generated output。Windows LF/CRLF worktree-only changes在確認無substantive diff後還原至HEAD，working tree恢復clean。

### Bundle build

`apps/flutter_architecture: flutter build bundle`：**PASS**。

Planner列出的iOS production build只能在macOS執行；依accepted Plan，required macOS/iOS production verification屬Task 42-10 published candidate evidence。本Windows pre-merge Task 42-9不偽造iOS PASS。

## Release metadata consistency

Current candidate：

```txt
VERSION=1.21.0
repository_identity.json.template_origin.baseline=1.21.0
CHANGELOG [1.21.0]=Milestone 41 + Milestone 42 combined candidate
```

Milestone 42是1.21.0 publication前corrective，不另增1.22.0造成無語意version churn。Last published baseline仍是1.20.0，直到Task 42-10完成published-main closure。

## Layer 1 — Focused holistic review

- Presentation responsibility finding：resolved。
- VisualSpec catch-all finding：resolved。
- Design System over-promotion / under-promotion雙向治理：resolved。
- Asset ownership與provenance separation：resolved。
- Visual/runtime fidelity regression：none observed。
- Stable authority drift：none observed。
- Release metadata/current docs：本Task同步。

Open P0：0。

Open P1 without disposition：0。

Focused holistic review：**PASS**。

## Layer 2 — Combined whole-milestone review

Milestone 41與42形成單一可發布架構結果：

```txt
screen page flow由constraints/relationships擁有
+ presentation responsibilities有正確owner
+ UI design values有Design System/asset/visual-authority/layout/component routing
+ machine mapping fail closed
+ fresh behavioral pressure能拒絕兩側shortcut
+ accepted visual authority與runtime fidelity不變
```

沒有未處置finding要求推翻accepted Design／Plan，也沒有證據顯示新治理只能靠reference-specific hardcode成立。

Open P0：0。

Open P1 without disposition：0。

Combined whole-milestone review：**PASS**。

## Release / authorization decision

Task 42-9：**PASS / ACCEPTED**。

Combined Template Baseline candidate：**1.21.0 READY FOR MERGE/PUSH AUTHORIZATION**。

下一個合法gate只有使用者merge／push authorization。授權前：

- 不得merge到`main`；
- 不得push；
- 不得開始Task 42-10 published-main/post-release validation；
- 不得宣稱Milestone 41或42 closed。
