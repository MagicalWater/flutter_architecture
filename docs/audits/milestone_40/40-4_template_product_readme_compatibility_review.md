---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-40-task-40-4-template-product-readme-compatibility
last_reviewed_baseline: 1.20.0
---

# Milestone 40 — Task 40-4 Template → Product README Compatibility Review

## Scope

驗證新的template landing README是否仍符合既有Template → Product bootstrap contract；本Task預設先read-only/prospective validation，不因Task存在而修改bootstrap Skill或Guide。

## Contract checks

| Check | Result | Evidence |
|---|---|---|
| Template README保留machine baseline marker | PASS | `Template Baseline Version：1.20.0`仍存在且`docs_check`可解析 |
| Product repository version marker仍受checker支援 | PASS | `tools/docs/test_check_docs.py::test_product_repository_uses_product_version_marker` |
| Prospective product docs可在canonical identity transition前驗證 | PASS | `test_prospective_product_manifest_validates_product_docs_before_canonical_transition` |
| Bootstrap仍要求README由template current authority轉成product current authority | PASS | `docs/guides/template_repository_adoption.md` section 4已列`README.md`且明確要求不再把current repository描述為template |
| Template provenance仍由machine manifest承擔 | PASS | `repository_identity.json.template_origin`；README不承擔provenance authority |
| Architecture visuals不阻止產品化 | PASS | visuals描述架構summary，並明示technical truth仍由current project context/ADR/source；產品bootstrap可保留或在產品需求中後續替換，不構成repository lifecycle field |
| Product newcomer不需template Milestone history | PASS | 新README已移除Milestone 1～39 journal |

## Focused review

未發現accepted Design要求以外的bootstrap incompatibility。既有`adopting-template-repository` Skill仍是thin orchestration，Guide已有README transition責任；若在本Task修改Skill只會製造不必要scope與parallel wording。

Disposition：**no implementation change required** for Skill／Guide／bootstrap tools。

## Validation

```txt
python -m unittest tools.docs.test_check_docs tools.docs.test_template_repository_bootstrap_routing tools.docs.test_template_repository_bootstrap_atomic_lifecycle
→ 34 tests PASS
```

```txt
Open P0: 0
Open P1 without disposition: 0
Task 40-4 status: accepted
```
