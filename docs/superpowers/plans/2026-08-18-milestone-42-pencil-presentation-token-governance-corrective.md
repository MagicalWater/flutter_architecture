---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-42-pencil-presentation-token-governance-corrective-implementation-plan
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Pencil Presentation Ownership & Visual Token Governance Corrective Implementation Plan

## 1. Admission

```txt
Requirement: accepted
Design: accepted / revised Design user approved 2026-08-18
Plan: accepted / user approved 2026-08-18
Implementation: admitted
Plan state: rebuilt from revised Design / accepted after fresh Plan review PASS
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-79898d55
Branch: milestone-42-pencil-presentation-token-governance-corrective
Checkpoint before Plan: 91e17069064e428166d2331afc19a5728d0b5dd6
```

本Plan已依2026-08-18使用者重新核准的Revised Design重建，並於2026-08-18取得使用者明確Plan核准。它不只修正current reference，而是建立可重用的 **UI Design Ownership Architecture**：UI design values不得集中進generic `*VisualSpec`／`*VisualTokens`／`*UiSpec`／`*StyleConfig` catch-all；必須解析至Design System、asset／representation authority、visual-authority metadata、layout owner或smallest correct component owner。

## 2. Execution strategy

固定順序：

```txt
42-1 direct RED / UI ownership blind-spot evidence
→ 42-2 UI design ownership mapping contract GREEN
→ 42-3 presentation ownership architecture detector GREEN
→ 42-4 presentation source responsibility decomposition
→ 42-5 UI design ownership migration / catch-all retirement / asset integration
→ 42-6 visual/runtime fidelity recovery
→ 42-7 ADR / Skill / Guide / current-authority synchronization
→ 42-8 fresh behavioral pressure acceptance
→ 42-9 combined Milestone 41+42 holistic / 1.21.0 release candidate
→ 42-10 merge / push / published-main / post-release closure（經授權後）
```

每個implementation Task使用Level 4 full two-layer governance。每個Task完成focused review、fresh re-review、whole-Task review、authority check、planner-selected validation且Open P0=0、Open P1 without disposition=0後才可completion commit。

## 3. Task 42-1 — Direct RED：current ownership blind spots must be reproducible

### Goal

先建立direct regression evidence，證明current machine/review owners無法阻止：

1. custom RenderObject／projection infrastructure藏在`presentation/pages/`；
2. `PencilCompatibilityVisualSpec`作catch-all owner；
3. shared-looking visual values沒有promotion/non-promotion disposition；
4. asset paths／font asset refs／icon refs被塞進generic VisualSpec／UiSpec；
5. feature自行建立第二套colors／spacing／radius／typography系統，繞過Design System與既有asset authority。

### Primary files

- `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- `tools/visual/test_pencil_implementation_mapping.py`
- 必要的docs/Skill policy test owner（優先延伸existing Pencil policy tests，不建立generic AST framework）
- `docs/audits/milestone_42/42-1_ownership_red_review.md`

### Test Authoring Decision

**Required**。這是已確認的治理盲點；現有Milestone 41 tests曾對current structure給出PASS，因此需要direct regression owner。

### RED requirements

- current `pages/write_precheck_projected_canvas.dart`對page ownership contract為FAIL；
- bounded widget/layout helper放在正確owner時fixture可PASS；
- current mapping缺少risk-selected visual-token owner時FAIL；
- asset representation/provenance已resolved但ownership被重新塞進VisualSpec時FAIL；
- `FeatureVisualSpec`／`FeatureUiSpec`同時承擔colors + geometry + typography + asset refs時FAIL；
- 不以檔案行數、widget數量或所有numeric literal作oracle。

### Stop condition

若只能靠高false-positive的line-count／keyword-count lint才能建立owner，Task維持blocked並回Design。

## 4. Task 42-2 — UI design ownership mapping contract GREEN

### Goal

讓initiative-local `implementation_mapping.json`保存risk-selected UI design ownership disposition，並由existing validator fail closed。此mapping整合visual token ownership與existing representation/provenance evidence，但**不建立第二套asset registry**。

### Primary files

- `docs/visual_authority/pencil-compatibility-write-precheck/implementation_mapping.json`
- `tools/visual/pencil_implementation_mapping.py`
- `tools/visual/test_pencil_implementation_mapping.py`
- `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- `docs/audits/milestone_42/42-2_visual_token_mapping_review.md`

### Contract

Risk-selected visual values至少解析為：

```txt
owner: visual-authority | design-system | feature-local | component-local
disposition: exact | verified-equivalent | intentional-local | promoted
semantic_role
consumer_scope
evidence / public_owner_ref / local_scope_reason（依owner適用）
```

Rules：

- `unresolved`或missing owner fail closed；
- `design-system`只能指向public API，不得deep import `lib/src/`；
- `intentional-local`必須有scope/reason；
- canonical viewport/DPR只能是`visual-authority`；
- app/global semantic value不得用`feature-local + intentional-local`逃避promotion；
- raster/vector/icon/font等asset仍以existing representation/provenance contract為source authority；UI ownership record只能引用其evidence，不得把asset path變成VisualSpec token；
- generic `FeatureVisualSpec`／`FeatureUiSpec`不得成為resolved owner vocabulary；
- 不建立global every-token registry。

### Validation

Focused mapping unit tests + existing representation/layout mapping regression + planner-selected validation。

## 5. Task 42-3 — Presentation ownership architecture detector GREEN

### Goal

補強reference architecture contract，驗證`pages/`只負責Page/View orchestration，render/layout mechanics與bounded composition有獨立owner。

### Primary files

- `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- 必要時新增最小fixture/helper
- `docs/audits/milestone_42/42-3_presentation_ownership_detector_review.md`

### Detector contract

必須拒絕：

- `pages/`內custom `RenderObject` / `MultiChildRenderObjectWidget` implementation；
- projection/render calibration infrastructure由page owner持有；
- page file直接擁有大量bounded section implementations；
- shared visual token definitions放回page owner。

必須允許：

- Page/View使用`Scaffold`、`LayoutBuilder`、`ScrollView`與screen-level composition；
- `layout/`內bounded local projection/render mechanics；
- `widgets/`內screen-specific bounded composition；
- 合理的小component共檔。

不以line-count作hard fail，Milestone 41 whole-screen coordinate detector繼續獨立生效。

## 6. Task 42-4 — Presentation source responsibility decomposition

### Goal

把current `pages/write_precheck_projected_canvas.dart`依responsibility拆回正確Presentation owners，不改screen semantics或accepted visual authority。

### Target ownership

```txt
presentation/pages/
  write_precheck_page.dart
  write_precheck_view.dart

presentation/layout/
  write_precheck_projection.dart
  projected_visual_primitives.dart（若實際責任需要）

presentation/widgets/write_precheck/
  bounded section/component owners

presentation/visual_authority/
  comparison/source metadata only（若feature-local Dart owner實際需要）

presentation/widgets/write_precheck/<component>/
  component-only geometry / decoration / exact local values
```

Exact file count不是contract。拆分依responsibility與dependency，不得把單一monolith機械切成大量無邊界碎檔。

### Required invariants

- Milestone 41 `constraint-relationship` screen root保持成立；
- bounded local projection可存在，但只在`layout/`／component owner內；
- whole-screen canonical coordinate ownership不得復活；
- Page/View只委派content/layout owners；
- 不建立Domain/Data/Bloc假層來包Presentation-only proof。

### Test Authoring Decision

Task 42-1 direct owner為primary；若實際拆分揭露新的public behavior failure mode才新增最小widget test，否則`no-new-test justified`。

## 7. Task 42-5 — UI design ownership migration, catch-all retirement and asset integration

### Goal

逐類處置`PencilCompatibilityVisualSpec`，並**刪除該catch-all class**，不得rename成等價mega-class。完成後repository reference必須證明：尺寸、顏色、typography、assets、gradients、geometry、canonical metadata各自有正確owner，而不是重新集中到另一個Spec。

### Primary files

- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart`（retire）
- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/visual_authority/`（若需要feature-local canonical comparison metadata owner）
- Task 42-4建立的component owners
- `packages/design_system` public APIs（**只有promotion evidence成立的項目才修改**）
- existing repository-local asset/font/vector/raster destinations與其mapping evidence（只做ownership integration，不發明新registry）
- `docs/visual_authority/pencil-compatibility-write-precheck/implementation_mapping.json`
- `docs/audits/milestone_42/42-5_visual_token_migration_review.md`

### Token-by-token disposition

- `canonicalSize` / DPR / comparison assumptions → `visual-authority`；
- existing DS-equivalent semantic values → public Design System owner，前提是不破壞fidelity；
- proof-screen accepted local palette/typography → 只有在確實不是shared theme semantic時才保留最小feature/component owner，需mapping reason；不得建立feature-wide第二套theme object；
- shared semantic/theme identity成立者 → Design System promotion；
- component-only radius/gap/gradient/geometry → component-local；
- one-off local geometry → local constants，不放catch-all token class。
- raster/vector/icon/font/texture/illustration → existing asset／representation authority；Flutter consumer只引用typed asset owner或repository-approved path owner，不把asset refs塞回VisualSpec。

### Generic Spec prohibition

以下不是合法最終owner：

```txt
FeatureVisualSpec
FeatureVisualTokens
FeatureUiSpec
FeatureStyleConfig
ScreenDesignSpec
```

名稱本身不是唯一oracle；若任一class/object同時集中多種無共同semantic responsibility的colors、spacing、radius、typography、asset refs、gradients、geometry或canonical metadata，即視為catch-all並FAIL。允許語意單一、bounded且有明確owner責任的小型typed contract。

### Design System guardrails

- 不因raw value相同就promotion；
- 不建立`DsWritePrecheck*`；
- 不把canonical viewport/DPR放進Design System；
- 不把single-consumer decorative token提升為global primitive；
- 不deep import Design System implementation。
- 不建立parallel feature palette／typography／spacing system取代Design System；
- 不把asset provenance authority複製成feature token constants。

## 8. Task 42-6 — Visual/runtime fidelity recovery

### Goal

證明責任拆分與token ownership修正沒有以降低accepted visual fidelity換取architecture GREEN。

### Immutable visual authority

不得修改：

- accepted `.pen`；
- canonical/runtime golden；
- diff threshold；
- crop／ignore regions；
- semantics/copy expectation來迎合refactor。

### Required validation

- canonical Pencil/Flutter golden/diff；
- supported runtime golden/diff；
- critical geometry/local fidelity；
- responsive/layout health；
- semantics/copy；
- architecture/token owner regressions；
- planner-selected analyze/build/tests。

若只能靠修改accepted visual authority才能PASS，Task BLOCKED並回Design。

## 9. Task 42-7 — Stable authority synchronization

### Goal

Runtime truth成立後才同步stable governance，不先用文件宣稱未實作contract。

### Primary files

- `docs/adr/adr-018-design-system-theme-boundaries.md`
- `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- `.agents/skills/implementing-pencil-flutter-design/SKILL.md`（若routing wording需要）
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- `docs/guides/pencil_to_flutter_workflow.md`
- `docs/project_context.md`
- related Feature/Design System README if current ownership changed
- `docs/audits/milestone_42/42-7_authority_sync_review.md`

### Stable wording

至少固定：

- page/view、layout/render mechanics、bounded widgets responsibility；
- feature-local exact tokens是例外owner，不是second theme system；
- visual-authority metadata與Design System分離；
- promotion依semantic identity/stability/consumer evidence，不依raw-value equality；
- unresolved shared-looking visual value fail closed。
- UI design values必須走Design System / asset-representation authority / visual-authority / layout / component ownership routing；generic VisualSpec不是合法escape hatch；
- assets的source/hash/transformation/destination仍由existing provenance contract擁有，UI architecture只整合consumer ownership，不另建registry。

## 10. Task 42-8 — Fresh behavioral pressure acceptance

### Goal

驗證fresh Agent在未依賴本對話口頭記憶下做出正確ownership decision。

### Required scenarios

- PTF-30：Login/Home/Settings共用background/text/brand colors各自塞FeatureVisualSpec → **FAIL / redirect Design System semantic mapping**；
- PTF-31：single-screen Hero `radius=17`與decorative gradient升成global DS token → **FAIL / keep local**；
- PTF-32：Page + custom RenderObject + projection +多section全塞`pages/screen_canvas.dart` → **FAIL / presentation cohesion**；
- PTF-33：Login/Home/Settings各自建立`FeatureUiSpec`，同時塞colors / padding / radius / typography / icon paths / image paths → **FAIL / classify to DS, asset authority, component/local owner**；
- PTF-34：`heroImagePath`／`warningIconPath`／`backgroundTexturePath`／`fontAssetPath`塞進VisualSpec → **FAIL / route existing representation-provenance authority**；
- negative/edge variant：相同hex但語意不同不得因值相同強制promotion；
- positive variant：真正Theme Identity semantic有跨consumer evidence時必須promotion。

Evidence保存於`docs/audits/milestone_42/42-8_behavioral_pressure_review.md`。

## 11. Task 42-9 — Combined Milestone 41+42 holistic / release candidate

### Goal

Milestone 41沒有獨立publication，因此以combined 1.21.0 candidate重新做完整release gate。

### Required review

- Requirement → accepted Design → accepted Plan → Tasks traceability；
- Milestone 41 constraint-layout contract仍PASS；
- Milestone 42 presentation/token ownership contract PASS；
- accepted visual authority hash/integrity unchanged；
- ADR/Skill/Guide/machine/source一致；
- Open P0=0；Open P1 without disposition=0；
- validation planner + fresh full regression；
- `dart run melos run analyze`；
- `dart run melos exec -- flutter test`；
- repository Python regression；
- `dart run melos run docs_check`；
- `flutter build bundle`；
- release metadata/current docs consistency。

若release identity仍為1.21.0，維持單一combined release，不新增無意義版本churn。

## 12. Task 42-10 — Publication / post-release closure

只有Task 42-9 PASS且取得merge/push授權後執行：

```txt
completion commits
→ merge to main
→ push
→ fresh published-main identity
→ clean-checkout full/post-release validation
→ required macOS/iOS production verification
→ fresh PTF-30～34 behavioral acceptance
→ Milestone 41 + 42 formal closure
```

Publication前不得宣稱Milestone 41或42 closed。

## 13. Plan success criteria

Plan只有在以下全部成立時可宣稱執行完成：

1. `pages/`不再擁有render/layout infrastructure或bounded section implementation dump；
2. `PencilCompatibilityVisualSpec`已retired且沒有等價mega-class replacement；
3. risk-selected visual values全部有resolved owner；
4. shared semantic不能用「Pencil exact」逃避Design System，single-screen exact values也不污染Design System；
5. ADR-018、ADR-028、Skill、Guide、mapping、source/tests一致；
6. PTF-30～34 fresh pressure與edge variants符合expected disposition；
7. accepted `.pen`與visual/runtime fidelity未改；
8. combined release holistic Open P0=0、Open P1 without disposition=0；
9. publication與post-release gate完成後才formal closure。

