---
document_type: milestone-index
status: active
authoritative_for:
  - milestone-artifact-routing
last_reviewed_baseline: 1.26.1
---

# Milestone Routing

本目錄只提供 closed milestone 的最低充分歷史入口，不保存完整 task journal。Current state 以 `docs/roadmap/active.md`、canonical ADR、source/runtime、`VERSION` 與 `CHANGELOG.md` 為準。

```txt
Active Milestone: none
Template Baseline: 1.26.1
```

## Retention rule

- Closed Design / Plan、intermediate review、checkpoint、handoff、temporary admission 與 per-task review 已完成 retention cleanup；需要時由 Git history 追溯。
- 不再為每個 milestone 機械保留 final review。只有具有獨立長期價值的 security、不可逆 migration、platform/runtime 或重大 repository audit evidence 才保留於 `docs/audits/`。
- Release identity 以 `CHANGELOG.md`、`VERSION`、Git tag / commit history 為準，不由 historical review 覆蓋。

## Durable evidence routing

| Scope | Retained evidence |
|---|---|
| Architecture baseline audit | `docs/audits/milestone_18_holistic_audit.md` |
| Authentication / security | `docs/audits/milestone_19_holistic_final_review.md`、`docs/audits/milestone_19/19-5_security_android_smoke.md`、`docs/audits/milestone_21/21-5_android_security_runtime_review.md` |
| iOS / native platform acceptance | `docs/audits/milestone_25/25-10_final_review.md`、`docs/audits/milestone_26/26-8_final_review.md` |
| Production observability | `docs/audits/milestone_27/27-8_final_review.md` |
| Connectivity platform runtime | `docs/audits/milestone_28/28-7_platform_runtime_evidence.md` |
| Drift migration | `docs/audits/milestone_29/29-10_final_review.md`、`docs/audits/milestone_29/29-9_platform_runtime_regression.md`、`docs/archive/milestone_29_drift_persistence_migration_design.md` |
| GitHub artifact storage cutover | `docs/audits/milestone_32/32-11_final_review.md` |
| Pencil runtime / corrective acceptance | `docs/audits/milestone_33/33-c4_android_runtime_acceptance.md`、`docs/audits/milestone_33/33-c5_corrective_holistic_final_review.md` |
| Repository infrastructure / CI live acceptance | `docs/audits/milestone_38/38-11_holistic_final_review.md` |
| Public repository security | `docs/audits/public_repository_readiness/task_5_holistic_final_review.md` |
| Template holistic baseline audit | `docs/audits/template_baseline_1_14_project_holistic_audit/a9_holistic_final_review.md` |

Milestone 未列於本表不代表缺少歷史；其 release / completion chronology 由 `CHANGELOG.md` 與 Git history 追溯，stable decisions 由 canonical ADR / current docs 擁有。
