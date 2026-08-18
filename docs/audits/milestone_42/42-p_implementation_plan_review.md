---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-42-pencil-presentation-token-governance-plan-review
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Implementation Plan Review

## Review scope

Review proposed Implementation Plan是否完整落實accepted Design，是否維持Milestone 41已接受layout architecture與visual fidelity，並避免Plan在implementation前重新發明scope。

## Layer 1 — Focused plan review

### F-42-P-01 — 是否先有direct RED owner

- Severity：P1 if missing。
- Review：42-1先建立presentation ownership與visual-token mapping blind-spot RED，不直接從source搬檔開始。
- Result：PASS。

### F-42-P-02 — 是否把token governance做成global registry／every-value lint

- Severity：P1 governance overreach。
- Review：42-2只擴充initiative-local mapping的risk-selected values，明確禁止every numeric literal registry。
- Result：PASS。

### F-42-P-03 — 是否以line count取代responsibility review

- Severity：P1 false architecture rule。
- Review：42-3以RenderObject/projection/component ownership判定，明確不以file length hard fail。
- Result：PASS。

### F-42-P-04 — 是否保留Milestone 41 bounded projection legality

- Severity：P1 fidelity/architecture regression。
- Review：42-4允許bounded local projection移至layout/component owner，仍禁止whole-screen coordinate ownership。
- Result：PASS。

### F-42-P-05 — 是否只是rename `PencilCompatibilityVisualSpec`

- Severity：P1 corrective failure。
- Review：42-5要求retire old catch-all，按visual-authority / DS / feature-local / component-local逐類處置，禁止等價mega-class replacement。
- Result：PASS。

### F-42-P-06 — 是否機械promotion所有Pencil tokens

- Severity：P1 Design System pollution。
- Review：42-5要求semantic identity/stability/consumer evidence；single-consumer decorative/exact geometry留local。
- Result：PASS。

### F-42-P-07 — visual authority是否可被implementation改寫來過測試

- Severity：P0/P1 fidelity corruption。
- Review：42-6鎖定accepted `.pen`、golden、threshold、crop/ignore、semantics；若只能改authority才PASS則blocked回Design。
- Result：PASS。

### F-42-P-08 — governance文件是否在runtime truth前先更新

- Severity：P1 authority drift。
- Review：42-7明確排在source/token migration與fidelity recovery之後。
- Result：PASS。

### F-42-P-09 — fresh behavioral pressure是否覆蓋兩個相反失敗模式

- Severity：P1 future recurrence。
- Review：PTF-30抓FeatureVisualSpec逃生艙；PTF-31抓single-screen token污染DS；PTF-32抓presentation responsibility混放，另含raw-value-equality edge case與positive promotion variant。
- Result：PASS。

### F-42-P-10 — Milestone 41是否被錯誤獨立發布

- Severity：P1 release governance。
- Review：42-9／42-10維持single combined 1.21.0 candidate，先combined holistic，再經授權merge/push/published-main/post-release，最後才41+42 closure。
- Result：PASS。

## Layer 2 — Whole-plan review

Traceability：

```txt
Design: pages ownership
→ 42-1 RED → 42-3 detector → 42-4 source decomposition

Design: visual owner model / catch-all retirement
→ 42-1 RED → 42-2 mapping contract → 42-5 migration

Design: no fidelity regression
→ 42-6 immutable visual authority + runtime/canonical validation

Design: stable governance
→ 42-7 ADR/Skill/Guide sync → 42-8 fresh pressure

Milestone 41 publication suspended
→ 42-9 combined holistic → 42-10 single publication/post-release closure
```

Plan沒有超出accepted scope建立generic UI framework、global token registry、line-count architecture rule或新的Design System mega abstractions。

Open P0：0。

Open P1 without disposition：0。

Plan review：**PASS**。

## Approval gate

Implementation Plan目前維持`proposed`。取得使用者明確核准前：

- 不得將Plan改為`accepted`；
- 不得開始Task 42-1 implementation；
- 不得修改production source、Design System或machine policy；
- Milestone 41 publication維持suspended。

