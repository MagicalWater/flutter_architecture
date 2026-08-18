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

## Revision 1 — UI Design Ownership Architecture strengthening

2026-08-18 Plan approval前，使用者補充本Milestone不可只修current reference，必須建立長期可重用UI design ownership architecture，特別禁止尺寸／顏色／資產／typography／gradient／geometry再被集中成generic `*VisualSpec` / `*VisualTokens`模板。

此補充判定為P1 material Design strengthening。原使用者Design approval不被偽裝成已覆蓋新scope；Design狀態暫回`proposed`並fresh re-review。

### Layer 1 — Revision focused review

#### F-42-D-R1-01 — 是否真正禁止generic UI Spec replacement

- Severity：P1。
- Review：Revision明確禁止以`*VisualSpec`、`*VisualTokens`、`*UiSpec`、`*StyleConfig`建立colors/dimensions/assets/typography/geometry catch-all；判定依responsibility mixture而非命名。
- Result：PASS。

#### F-42-D-R1-02 — 是否建立完整UI design ownership routing

- Severity：P1。
- Review：Color/typography/spacing/radius/elevation/assets/canonical metadata/layout/one-off geometry均有明確owner route，並以Design System、asset authority、visual authority、layout owner、smallest component owner作核心架構。
- Result：PASS。

#### F-42-D-R1-03 — Asset governance是否被重複發明

- Severity：P1 architecture duplication。
- Review：Revision重用既有asset/representation/provenance contract，不建立第二套asset registry；只把asset ownership納入統一UI ownership gate。
- Result：PASS。

#### F-42-D-R1-04 — 是否又把feature-local token全面消滅

- Severity：P1 fidelity/abstraction risk。
- Review：Revision仍允許真正local semantic或exact component values，但要求smallest correct owner；只有穩定feature semantic identity成立才建立窄責任feature owner。
- Result：PASS。

#### F-42-D-R1-05 — 是否具有future-agent enforcement

- Severity：P1 recurrence risk。
- Review：新增PTF-33 Feature UI Spec dumping與PTF-34 Asset path inside VisualSpec，並要求Skill/Guide提供repository-wide reusable decision route。
- Result：PASS。

### Layer 2 — Revision whole-design review

Revision後Design同時覆蓋：

```txt
current reference cleanup
+ Presentation responsibility architecture
+ Design System promotion/non-promotion
+ Asset / representation ownership integration
+ anti-generic-Spec governance
+ future Skill / Guide / machine enforcement
+ fresh PTF-30～34 behavioral pressure
```

Open P0：0。

Open P1 without disposition：0。

Revision Design review：**PASS**。

### Revised approval gate

因Revision materially擴充已核准Design，使用者需重新明確核准Revision Design。核准前existing proposed Implementation Plan視為**suspended / not approvable**，不得開始implementation。
