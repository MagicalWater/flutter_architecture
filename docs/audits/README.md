---
document_type: audit-index
status: active
authoritative_for:
  - audit-and-review-evidence-routing
last_reviewed_baseline: 1.8.0
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

## Evidence routes

### Recent platform and delivery milestones

- [`milestone_24/`](milestone_24/)：Repository CI/CD Foundation 的 planning、phase reviews、final review 與 post-release remote validation。
- [`milestone_25/`](milestone_25/)：iOS Platform Support Foundation 的 planning、native／runtime／security reviews、final review 與 remote validation。
- [`milestone_26/`](milestone_26/)：Native Flavor & Product Identity Foundation 的 planning、environment／platform／CI reviews、final review 與 post-release remote validation。

### Change-aware CI initiative

- [`change_aware_ci_spec_review.md`](change_aware_ci_spec_review.md)：Design spec scope 與 acceptance review。
- [`change_aware_ci_plan_review.md`](change_aware_ci_plan_review.md)：Implementation plan review。
- [`change_aware_ci_implementation_review.md`](change_aware_ci_implementation_review.md)：Whole implementation review routing。
- [`change_aware_ci_remote_validation.md`](change_aware_ci_remote_validation.md)：GitHub-hosted documentation-only 與 full-matrix evidence。
- [`change_aware_ci_holistic_final_review.md`](change_aware_ci_holistic_final_review.md)：Initiative holistic final disposition。
- `change_aware_ci_task_*_review.md`：各 implementation Task 的 focused review evidence。

### Documentation usability audit and hardening

- [`documentation_usability_coverage_audit.md`](documentation_usability_coverage_audit.md)：文件可用性與覆蓋的正式整體 audit。
- [`documentation_usability_coverage_audit_review.md`](documentation_usability_coverage_audit_review.md)：Audit evidence、severity 與 scope 的 formal review。
- [`documentation_usability_hardening_design_review.md`](documentation_usability_hardening_design_review.md)：小型 hardening design review。
- [`documentation_usability_hardening_plan_review.md`](documentation_usability_hardening_plan_review.md)：Implementation plan review。
- [`documentation_usability_hardening_task_1_review.md`](documentation_usability_hardening_task_1_review.md)：Feature Guide responsibility review。
- [`documentation_usability_hardening_task_2_review.md`](documentation_usability_hardening_task_2_review.md)：App database 與 integration routes review。
- [`documentation_usability_hardening_task_3_review.md`](documentation_usability_hardening_task_3_review.md)：API endpoint 與 external client route review。
- [`documentation_usability_hardening_task_4_review.md`](documentation_usability_hardening_task_4_review.md)：本 Audit navigation Task review。
- [`documentation_usability_hardening_task_5_review.md`](documentation_usability_hardening_task_5_review.md)：Roadmap candidate 與 Backlog disposition review。
- [`documentation_usability_hardening_final_review.md`](documentation_usability_hardening_final_review.md)：Documentation Usability Hardening holistic final disposition。

### Production observability planning

- [`production_observability_capability_audit.md`](production_observability_capability_audit.md)：Baseline 1.8.0 observability能力、缺口、provider策略與Milestone promotion依據。
- [`production_observability_design_review.md`](production_observability_design_review.md)：Architecture design formal review、findings、fix verification與Open P0／P1 closure。

### Earlier milestone groups

- [`milestone_23/`](milestone_23/)：ADR Extraction Planning Review、batch／cutover evidence與 final review。
- [`milestone_22_planning_review.md`](milestone_22_planning_review.md)：Documentation Governance Planning Review。
- [`milestone_22/`](milestone_22/)：Milestone 22 各階段 documentation governance review evidence。
- [`milestone_18/`](milestone_18/)：Template Baseline holistic audit phases。
- [`milestone_19/`](milestone_19/)：Secure credential storage phase reviews。
- [`milestone_20/`](milestone_20/)：OTP Step-Up Authentication phase reviews。
- [`milestone_21/`](milestone_21/)：Biometric-gated Local Session Unlock phase reviews。

其他位於 `docs/audits/` root 的 planning、runtime 或 holistic review 仍保留原 stable path。Index 只負責 routing，不複製 findings、test counts、commit hashes或 final gate內容。
