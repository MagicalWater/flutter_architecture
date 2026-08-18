---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-41-design-spec-review
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Design Spec Review

## Review target

`docs/superpowers/specs/2026-08-18-milestone-41-pencil-layout-architecture-corrective-design.md`

Requirement authority：`docs/audits/milestone_41/41-r_requirement_decision.md`。

## Focused review

### F-41-0-01 — 不得把`Stack`／`Positioned`全面列為禁止

- Severity：P1 false-positive architecture regression。
- Review：Design以coordinate ownership區分whole-screen reconstruction與bounded local overlay；Hero／badge／decorative overlay仍可合法使用local Stack。
- Result：PASS。

### F-41-0-02 — 不得用「one renderer」替fixed-coordinate reconstruction背書

- Severity：P1 confirmed root cause。
- Review：Design新增`one tree → constraints/relationships own screen layout`，明確指出single renderer、真Flutter widgets、無FittedBox仍不足以使whole-screen canonical coordinate projection合法。
- Result：PASS。

### F-41-0-03 — Machine enforcement不得只靠Positioned count或脆弱關鍵字

- Severity：P1 maintainability／false-positive risk。
- Review：Design拒絕generic Dart linter；採screen layout mapping contract + current reference direct source owner。Generic validator處理future admission，reference test直接鎖confirmed mechanism。
- Result：PASS。

### F-41-0-04 — Machine mapping不能成為第二份design authority

- Severity：P1 authority duplication risk。
- Review：沿用initiative-local`implementation_mapping.json`並僅加入layout disposition；`.pen`與visual manifest仍擁有design／visual authority。
- Result：PASS。

### F-41-0-05 — Genuine spatial canvas不能被誤殺

- Severity：P1 product capability risk。
- Review：Design允許`intentional-spatial-canvas`，但要求accepted Design/ADR approval_ref；implementation Agent不得自行升級一般App screen。
- Result：PASS。

### F-41-0-06 — Reference corrective不得以視覺退化交換responsive architecture

- Severity：P1 fidelity regression。
- Review：Design維持architecture + canonical + runtime + critical-local + semantic AND gate，禁止threshold／crop／ignore／`.pen` silent mutation。
- Result：PASS。

### F-41-0-07 — 不得重新走回test hell

- Severity：P1 test-cost governance risk。
- Review：Required owners限於mapping validator、reference architecture contract、visual owners與pressure；every-Positioned／every-section tests明確Should-not-add。
- Result：PASS。

### F-41-0-08 — Stable decision owner

- Severity：P1 authority fragmentation risk。
- Review：ADR disposition為amend ADR-028；本corrective只是釐清既有Pencil-to-Flutter responsive geometry boundary，不新增第二layout ADR。
- Result：PASS。

## Whole-Task review

Design完整覆蓋Requirement confirmed gaps：

```txt
authority ambiguity
→ geometry classification
→ constraint-owned screen layout
→ bounded overlay exception
→ intentional spatial canvas exception
→ machine mapping contract
→ reference direct source enforcement
→ production proof migration
→ visual fidelity preservation
→ behavioral pressure
```

沒有擴張到`.pen` redesign、generic layout DSL、global AST framework、全禁Stack、第二Pencil domain Skill或every-node testing。

## Approval gate

```txt
Open P0: 0
Open P1 without disposition: 0
Design review: PASS
Design artifact status: accepted
User approval: accepted on 2026-08-18
Implementation Plan: forbidden until explicit approval
Production implementation: forbidden
```

使用者明確核准後，才可把Design改為`accepted`並建立formal Implementation Plan。
