---
document_type: milestone-index
status: active
authoritative_for:
  - milestone-artifact-routing
last_reviewed_baseline: 1.26.0
---

# Milestone Routing

本目錄只提供 closed milestone 的最低充分歷史入口，不保存完整 task journal。Current state 以 `docs/roadmap/active.md`、canonical ADR、source/runtime、`VERSION` 與 `CHANGELOG.md` 為準。

```txt
Active Milestone: none
Template Baseline: 1.26.0
```

## Retention rule

- Closed Design / Plan、intermediate review、checkpoint、handoff、temporary admission 與 per-task review 已完成 retention cleanup；需要時由 Git history 追溯。
- 下表只保留每個 milestone 最高資訊密度的 closure evidence；少數 security / platform runtime evidence 另保留於 `docs/audits/`。
- Release identity 以 `CHANGELOG.md`、`VERSION`、Git tag / commit history 為準，不由 historical review 覆蓋。

## Closed routing

| Milestone | Primary retained evidence |
|---|---|
| 1–17 | `docs/archive/`、canonical ADR、`CHANGELOG.md`、Git history |
| 18 | `docs/audits/milestone_18_holistic_audit.md` |
| 19 | `docs/audits/milestone_19_holistic_final_review.md` |
| 20 | `docs/audits/milestone_20/milestone_20_final_review.md` |
| 21 | `docs/audits/milestone_21/milestone_21_final_review.md` |
| 22 | `docs/audits/milestone_22/22-7_final_review.md` |
| 23 | `docs/audits/milestone_23/23-9_final_review.md` |
| 24 | `docs/audits/milestone_24/24-6_final_review.md` |
| 25 | `docs/audits/milestone_25/25-10_final_review.md` |
| 26 | `docs/audits/milestone_26/26-8_final_review.md` |
| 27 | `docs/audits/milestone_27/27-8_final_review.md` |
| 28 | `docs/audits/milestone_28/28-9_final_review.md` |
| 29 | `docs/audits/milestone_29/29-10_final_review.md`；migration rationale / rollback：`docs/archive/milestone_29_drift_persistence_migration_design.md` |
| 30 | `docs/audits/milestone_30/30-11_final_review.md` |
| 31 | `docs/audits/milestone_31/31-r10_local_final_review.md` |
| 32 | `docs/audits/milestone_32/32-11_final_review.md` |
| 33 | `docs/audits/milestone_33/33-c5_corrective_holistic_final_review.md` |
| 34 | `docs/audits/milestone_34/34-5_holistic_final_review.md` |
| 35 | `docs/audits/milestone_35/35-8_holistic_final_review.md` |
| 36 | `docs/audits/milestone_36/36-8_holistic_final_review.md` |
| 37 | `docs/audits/milestone_37/37-8_holistic_final_review.md` |
| 38 | `docs/audits/milestone_38/38-11_holistic_final_review.md` |
| 39 | `docs/audits/milestone_39/39-7_holistic_final_review.md` |
| 40 | `docs/audits/milestone_40/40-10_final_comprehensive_review.md` |
| 41 | `docs/audits/milestone_41/41-8_holistic_final_review.md` |
| 42 | `docs/audits/milestone_42/42-9_combined_holistic_final_review.md` |
| 43 | `docs/audits/milestone_43/43-7_holistic_final_review.md` |
| 44 | `docs/audits/milestone_44/44-post-closure-project-code-convergence-holistic-review.md` |
| 45 | `docs/audits/milestone_45/45-1_holistic_final_review.md` |
| 46 | `docs/audits/milestone_46/46-1_holistic_final_review.md` |

Additional retained evidence 可由 `docs/audits/README.md` 或 repository search 定位。Historical artifact 未列於本表時，以 Git history 為正式追溯方式。
