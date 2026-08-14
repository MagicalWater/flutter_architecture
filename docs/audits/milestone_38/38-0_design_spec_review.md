---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-38-design-spec-review
last_reviewed_baseline: 1.18.0
---

## Approval Gate

- 使用者於 2026-08-15 明確核准 Milestone 38 Design。
- Design status 已由 `proposed` 轉為 `accepted`。
- Implementation Plan 現可依中央治理建立；implementation 仍禁止在 Plan accepted 前開始。

# Milestone 38 — Design Spec Review

## Review Scope

Review proposed Design：

`docs/superpowers/specs/2026-08-15-milestone-38-template-product-infrastructure-ci-adoption-design.md`

對照：

- `AGENTS.md`
- `repository_identity.json`
- ADR-023／ADR-030
- `docs/guides/template_repository_adoption.md`
- `docs/guides/ci_cd_operations.md`
- `docs/guides/native_environment_adoption.md`
- `.github/workflows/*.yml`
- `tools/ci/artifact_contract.py`
- Public Repository Readiness Tasks 7～9 live-settings evidence

## Layer 1 — Focused Findings

### F1 — Bootstrap與live settings不能共用同一authority

Disposition：Covered。

Design把tracked desired/disposition state與GitHub live read-back分離，避免tracked manifest冒充GitHub current state。

### F2 — `repository_identity.json`不可膨脹

Disposition：Covered。

Design新增獨立`repository_infrastructure.json`候選，維持ADR-030 lifecycle/provenance ownership不變。

### F3 — CI profile不能由missing variable隱式推導

Disposition：Covered。

Design要求三種profile顯式selection，`CI_EXECUTION_MODE` missing不可當manual-local shorthand。

### F4 — self-hosted route有security與operational failure mode

Disposition：Covered。

Design要求runner registration／labels／external root／PR denial／offline behavior與runtime acceptance。

### F5 — secret-backed能力不能成為所有product bootstrap blocker

Disposition：Covered。

Design將optional capability分為configured／deferred／not-applicable，selected CI profile仍是blocking。

### F6 — Artifact default仍有template identity leakage

Disposition：Covered。

Design提出tracked product key作managed artifact default projection；explicit root與self-hosted fail-closed仍保留。

### F7 — Branch Protection不能盲目複製source template live policy

Disposition：Covered。

Design採profile／disposition模型，且required checks必須先有fresh product workflow evidence。

## Layer 2 — Whole-Design Holistic Review

### Requirement coverage

- CI execution mode bootstrap：Covered。
- Runner disposition：Covered。
- Product artifact identity：Covered。
- GitHub Actions security settings：Covered。
- Branch Protection：Covered。
- Environment／Secrets：Covered without secret-value custody。
- Fresh CI/runtime acceptance：Covered。
- Rollback／failure injection：Covered。
- Release/post-release：保留給Plan與Milestone closure。

### Architecture ownership

目前Design建議責任分離：

```txt
ADR-030
→ repository lifecycle / provenance / product version

ADR-023
→ CI runtime quality gates / execution / artifact security

ADR-031 (proposed)
→ Template → Product infrastructure adoption / profile / disposition / live read-back boundary
```

沒有發現需要把GitHub live object ID、secret value或native identity塞進新manifest的理由。

### Security review

- Secret values不進tracked authority：PASS by design。
- Public PR不進trusted runner：explicit required invariant。
- Live mutation需authorization + fresh read-back：explicit required invariant。
- No production signing／Store scope creep：PASS。

## Open Findings

- P0：0。
- Undisposed P1：0。

## Current Gate

Design內容已具備進入使用者review的完整度，但依中央治理：

- Design Spec仍為`proposed`；
- 本Review仍為`proposed`；
- 使用者尚未明確核准Design；
- Superpowers runtime discovery目前有plugin path missing warning，不能把這份artifact冒充已完成所有外部workflow-method gate的`accepted` Design。

因此：**READY FOR USER DESIGN APPROVAL / NOT ACCEPTED YET**。

