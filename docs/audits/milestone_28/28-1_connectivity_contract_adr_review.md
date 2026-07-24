---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-28-task-28-1-review
last_reviewed_baseline: 1.9.0
---

# Task 28-1 — Connectivity Contract and ADR Review

## Scope

- Provider-neutral `ConnectivityState`與`ConnectivityAdapter`。
- ADR-027與ADR index。
- Milestone 28 active promotion routing。

## Focused findings

### F1 — `online`命名可能被誤讀為internet/backend保證

Disposition：source documentation、ADR state semantics與non-goals均明確限制為本機介面／route訊號。

### F2 — Adapter contract可能過早包含reconnect或Feature callback

Disposition：contract只保留current snapshot、state stream與dispose；reconnect辨識由後續App controller負責。

### F3 — Candidate與active可能同時存在

Disposition：active promotion後已從`docs/roadmap/candidates.md`移除，`docs/roadmap.md`與`active.md`同步為Milestone 28。

## Re-review and holistic result

- Contract不依賴plugin、Dio、Catalog或reusable package。
- ADR-027沒有重寫ADR-015、017、018或020 authority。
- Active routing包含Spec、Plan、review與ADR。
- Generated files未手動修改。

## Validation

```txt
Focused contract tests: pass
Documentation check: pass
Analyze: pass
Open P0: 0
Open P1 without disposition: 0
```

Task 28-1 accepted，可進入Task 28-2。
