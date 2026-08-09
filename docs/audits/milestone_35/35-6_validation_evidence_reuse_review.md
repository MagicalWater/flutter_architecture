---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-6-validation-evidence-reuse
last_reviewed_baseline: 1.15.2
---

# Task 35-6 — Evidence Reuse and Duplicate Full-Run Guard Review

## Scope

本Task只建立deterministic evidence identity與reuse eligibility純函式；不建立cache database、daemon、background service或cross-task persistence。

Implementation位於：

- `tools/ci/validation_planner.py`
- `tools/ci/test_validation_planner.py`

## Evidence identity contract

`validation_evidence_identity()`綁定：

- planner contract version；
- validation phase；
- phase-relevant normalized changed paths；
- phase-relevant selected scopes／fail-safe state；
- tracked workspace dependency metadata。

Identity使用deterministic SHA-256；path ordering不影響結果。

Evidence以phase為單位。Quality／docs changes會使quality evidence fresh，但純`docs/audits/` review文字不會改變已選Flutter test phase identity。

## Reuse eligibility

`can_reuse_validation_evidence()`只有在以下全部成立時回傳true：

```txt
same formal Task
previous validation PASS
previous identity == current identity
not failure recovery
validation engine unchanged
gate is ordinary Task gate
```

以下永遠fresh：

- cross-Task；
- failure後fix；
- validation engine變更；
- holistic；
- release；
- post-release。

## Focused review findings

### F-35-6-01 — Whole-plan hash會讓review audit文字錯誤失效Flutter evidence

Severity：P1。

First RED把完整plan payload放入tests evidence identity；加入`docs/audits/...`後雖Flutter scopes未變，`docs_check`／reason／change classes改變仍造成hash不同。

Disposition：Resolved。Identity改為phase-specific payload；tests phase只綁phase-relevant paths/classes、Flutter scopes、full/release/fail-safe與workspace dependency metadata。Fresh test證明review-only audit text不使Flutter identity失效。

### F-35-6-02 — Dependency metadata必須參與identity

Severity：P1 coverage guard。

Disposition：Resolved。Workspace members與local dependency edges加入identity；fixture test實際修改member pubspec dependency後hash必須改變。

### F-35-6-03 — Review階段切換不得本身造成duplicate full rerun

Severity：P1 cost guard。

Disposition：Resolved。Reuse helper不接受review-stage名稱作invalidation；只有identity／mutation／failure／engine／gate boundary決定freshness。Holistic／release／post-release仍硬性禁止reuse。

## Fresh focused re-review

```powershell
python -m unittest tools.ci.test_validation_planner
```

Result：23 tests PASS。

Cases包含：

- review audit text reuse；
- selected source mutation invalidation；
- path order normalization；
- workspace dependency mutation invalidation；
- failure recovery fresh；
- validation engine fresh；
- cross-Task fresh；
- holistic／release／post-release fresh。

## Whole-Task regression

```powershell
python -m unittest discover -s tools/ci -p "test_*.py"
```

Result：233 tests PASS。

## Whole-Task review

- No persistent cache。
- No timestamp freshness heuristic。
- No Agent subjective reuse decision。
- Phase identity避免docs review誤傷Flutter evidence。
- Dependency metadata與selected source mutation可正確invalidate。
- Full regression沒有被移除；只消除同Task、同identity、無新mutation的duplicate rerun。

Open P0：0。

Open P1 without disposition：0。

## Required validation

```txt
python -m unittest tools.ci.test_validation_planner → PASS (23)
python -m unittest discover -s tools/ci -p "test_*.py" → PASS (233)
python tools/docs/check_docs.py . → required PASS
git diff --check → required PASS
```

## Disposition

```txt
Task 35-6: ACCEPTED after fresh validation
Persistent cache introduced: NO
Open P0: 0
Open P1 without disposition: 0
Next task: 35-7 Before/After Routing and Execution-Cost Acceptance
```

