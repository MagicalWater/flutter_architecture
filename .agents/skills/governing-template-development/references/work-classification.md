# Work Classification

Classify by highest applicable risk. Ambiguous work moves upward until evidence supports a lower level.

| Level | Typical scope | Mandatory | Forbidden |
|---|---|---|---|
| 0 — Trivial | typo, comment, non-semantic formatting, obvious one-line metadata correction | current authority check, focused validation | formal Spec, Plan, ADR, Milestone, full regression unless release metadata changes |
| 1 — Small Fix | single bounded bug, local test correction, narrow refactor | problem confirmation, expected behavior, simplified Task cycle, affected tests | formal Milestone without evidence; unrelated refactor |
| 2 — Standard Feature | one feature capability with bounded integration | brainstorming, behavioral requirements, Design, Plan, standard Task governance | skipping Spec／Plan approval; generic framework without need |
| 3 — Cross-cutting | multiple features/packages, shared contracts, DI or integration boundary | formal Design／Plan, ADR gate, full Task governance, affected workspace regression | local-only validation; silent architecture change |
| 4 — Architecture／Milestone | stable ownership, framework adoption, repository-wide governance | feasibility／scope decision, Design／Plan, full two-layer governance, holistic review, release decision | implementation before approval; parallel authority |
| 5 — Critical | database/credential migration, security, platform, production release pipeline | Level 4 plus rollback, compatibility, failure injection, clean checkout, remote/platform evidence, release and post-release validation | downgrade to reduce cost; closure without runtime evidence |

## Upgrade signals

Upgrade when work changes dependency direction, public contract, persistence authority, security boundary, supported platform claim, release process, repository-wide governance or irreversible data state.

## Anti-over-governance

- Level 0 never creates a Milestone solely to fix wording.
- Level 1 uses an inline decision and simplified Task cycle unless behavior or architecture is uncertain.
- Test count or file count alone does not justify Level 3+.
- A tool or skill installation is Level 4 only when it changes repository workflow or authority; a local optional helper may be Level 1–2.
