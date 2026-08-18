---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-42-pencil-presentation-token-governance-design-review
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Design Spec Review

## Review scope

Review proposed Design是否完整處理Requirement的兩條P1：Presentation responsibility與visual token governance，並確認不會因corrective反向污染Design System或破壞Pencil fidelity。

## Layer 1 — Focused design review

### F-42-D-01 — 是否把「大檔案」誤當架構問題

- Severity：P1 if violated。
- Review：Design明確拒絕line-count lint；以page/view、component、layout/render mechanics responsibility判定。
- Result：PASS。

### F-42-D-02 — 是否全面把Pencil tokens搬進Design System

- Severity：P1 shared-contract pollution。
- Review：Design建立五類owner，只有shared semantic/theme或validated reusable consumer才promotion；single-screen exact values保留local。
- Result：PASS。

### F-42-D-03 — 是否允許FeatureVisualSpec繼續作逃生艙

- Severity：P1 governance bypass。
- Review：old catch-all必須retire；risk-selected shared-looking values需mapping disposition，global semantic不能以intentional-local逃避。
- Result：PASS。

### F-42-D-04 — canonical metadata是否誤進Design System

- Severity：P1 authority confusion。
- Review：canonical viewport/DPR明確歸visual-authority，不屬theme/token package。
- Result：PASS。

### F-42-D-05 — Template proof palette是否會污染產品Design System

- Severity：P1 abstraction risk。
- Review：Design辨識Pencil compatibility為template proof；只有真正template/global semantic才promotion，proof-specific accepted art direction可feature-local。產品master `.pen`若把palette定為global，則在產品Design中promotion。
- Result：PASS。

### F-42-D-06 — 是否破壞Milestone 41 bounded projection必要性

- Severity：P1 fidelity risk。
- Review：projection helper可保留，但移至layout owner，仍禁止whole-screen coordinate ownership；不把「拆檔」誤解成刪除renderer calibration。
- Result：PASS。

### F-42-D-07 — machine enforcement是否過度

- Severity：P1 governance cost。
- Review：只鎖reference responsibility與risk-selected token mapping，不做every-number/every-file lint。
- Result：PASS。

## Layer 2 — Whole-design review

Requirement → Design traceability：

```txt
pages responsibility drift
→ explicit presentation ownership model

PencilCompatibilityVisualSpec catch-all
→ five-class visual value ownership + retirement

Design System bypass risk
→ promotion decision + mapping evidence

Design System pollution risk
→ consumer/semantic/stability gate

Pencil fidelity risk
→ no .pen/golden/threshold changes + existing visual gates

future Agent behavior
→ PTF-30～32
```

No P0 finding。

Open P0：0。

Open P1 without disposition：0。

Design review：**PASS**。

## Approval gate

Design目前維持`proposed`。取得使用者明確核准前：

- 不得建立Implementation Plan為accepted；
- 不得修改production source、Design System或machine policy；
- Milestone 41 publication維持suspended。
