---
document_type: audit-index
status: active
authoritative_for:
  - audit-and-review-evidence-routing
last_reviewed_baseline: 1.5.1
---

# Audits and Review Evidence

`docs/audits/` 保存規劃審查、implementation review、final review、findings 與 runtime evidence。

## Authority

Audit 是「當時審查了什麼、發現什麼、用什麼證據得到結論」的 authoritative artifact。

Audit 不是下列資訊的 authority：

- Current project state。
- Architecture contract。
- Active roadmap priority。
- Release version。

上述資訊分別由 `docs/project_context.md`、Architecture Decision、`docs/roadmap.md`、`VERSION` 與 `CHANGELOG.md` 擁有。

## 文件類型

```txt
Planning Review
  設計與 implementation 前的 scope、risk、finding 與 disposition

Phase Review
  某一實作階段完成後的 source、test 與 contract review

Runtime Evidence
  Build artifact、manifest、database、emulator 或 device 的可重現觀察

Final / Holistic Review
  整個 Milestone 的跨階段完成判定
```

## Reading rule

開始 review 前先讀 current contract 與相關 Decision，再讀 plan 與 phase evidence。不得只依 audit 中的歷史 current-tense 敘述判斷目前狀態。

## Current indexes

- `docs/audits/milestone_22_planning_review.md`：Documentation Governance Planning Review。
- `docs/audits/milestone_22/`：Milestone 22 各小階段 review evidence。
- `docs/audits/milestone_18/`：Template Baseline holistic audit phases。
- `docs/audits/milestone_19/`：Secure credential storage phase reviews。
- `docs/audits/milestone_20/`：OTP Step-Up Authentication phase reviews。
- `docs/audits/milestone_21/`：Biometric-gated Local Session Unlock phase reviews。

其他位於 `docs/audits/` root 的 planning 或 holistic review 仍保留原路徑。Milestone 22 不在沒有 migration manifest 的情況下批量搬移它們。
