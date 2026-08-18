---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-2-ui-design-ownership-mapping
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-2 UI Design Ownership Mapping Review

## Scope

將Milestone 42 Task 42-1確認的mapping blind spot轉為minimum-sufficient machine contract。Initiative-local `implementation_mapping.json`現在除了screen layout與critical representation外，也必須保存risk-selected `ui_design_ownerships`，但不建立global token registry或第二套asset registry。

## Contract

Resolved UI design owner vocabulary：

```txt
visual-authority
design-system
feature-local
component-local
```

Risk-selected record需要`id`、`kind`、`semantic_role`、`owner`、`disposition`與`consumer_scope`。Supported kinds刻意保持有界：visual-authority metadata、semantic color、typography、geometry、decoration、asset-reference。

Machine rules：

- missing／empty `ui_design_ownerships` fail closed；
- unresolved ownership在production acceptance fail closed；
- Design System owner需要public owner ref，deep `lib/src/` owner拒絕；
- `intentional-local`需要`local_scope_reason`；
- canonical visual-authority metadata只能由`visual-authority`擁有；
- owner vocabulary不接受`FeatureVisualSpec`／`UiSpec`等generic catch-all；
- `asset-reference`只能引用existing representation/provenance evidence，不得重複保存asset path、source identity、transformation、destination或content hash。

## Reference mapping disposition

Current Write Precheck proof的risk-selected values已解析：

- canonical viewport/DPR → visual-authority；
- proof-screen palette → feature-local intentional-local，原因是accepted proof art direction不是template-wide Theme Identity；
- proof typography → feature-local intentional-local，原因是accepted proof typography不是current template-global typography；
- bounded component geometry → component-local；
- screen-specific decorative gradients → component-local。

此Task沒有宣告任何新的Design System promotion；真正source owner migration留給Task 42-5。

## Focused validation

```txt
python -m unittest tools.visual.test_pencil_implementation_mapping
→ 20 tests PASS

python tools/visual/pencil_implementation_mapping.py \
  docs/visual_authority/pencil-compatibility-write-precheck/implementation_mapping.json \
  --authority-sha256 bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc
→ PASS

python -m unittest \
  tools.visual.test_verify_visual_authority \
  tools.visual.test_pencil_implementation_mapping \
  tools.docs.test_pencil_representation_mapping_policy \
  tools.docs.test_pencil_single_renderer_policy
→ 50 tests PASS
```

## Review findings

- P1 concern：asset ownership若在新section重複source/hash會形成第二套asset registry。Resolved：validator明確禁止asset provenance fields，僅允許`evidence_ref`。
- P1 concern：generic FeatureVisualSpec可否以字串當resolved owner。Resolved：owner使用closed vocabulary，unknown owner fail。
- P1 concern：canonical metadata可能被promotion到DS。Resolved：`visual-authority-metadata` owner mismatch直接fail。
- 沒有引入every-number lint、global registry或raw-value-equality promotion rule。

## Whole-Task disposition

```txt
Task 42-2: PASS / ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Task 42-1 mapping RED: GREEN
Task 42-1 Flutter source ownership RED: intentionally remains RED until Tasks 42-3/42-4/42-5
```
