---
document_type: audit-index
status: active
authoritative_for:
  - audit-and-review-evidence-routing
last_reviewed_baseline: 1.13.0
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

### Persistence feasibility

- [`drift_adoption_feasibility_audit.md`](drift_adoption_feasibility_audit.md)：Template Baseline 1.10.0 的 SQLite capability inventory、sqflite／Drift repository-specific比較、migration go／no-go與重新評估條件。

### Recent platform and delivery milestones

- [`milestone_24/`](milestone_24/)：Repository CI/CD Foundation 的 planning、phase reviews、final review 與 post-release remote validation。
- [`milestone_25/`](milestone_25/)：iOS Platform Support Foundation 的 planning、native／runtime／security reviews、final review 與 remote validation。
- [`milestone_26/`](milestone_26/)：Native Flavor & Product Identity Foundation 的 planning、environment／platform／CI reviews、final review 與 post-release remote validation。
- [`milestone_27/`](milestone_27/)：Production Observability Foundation 的planning artifacts review、後續phase reviews、native／CI evidence與final review routing。
- [`milestone_27/27-0_planning_review.md`](milestone_27/27-0_planning_review.md)：Production Observability Foundation 的scope、ADR、provider策略與activation gate。
- [`milestone_27/27-1_release_identity_contract_review.md`](milestone_27/27-1_release_identity_contract_review.md)：Release identity、collection policy與provider-neutral lifecycle contract review。
- [`milestone_27/27-4_android_native_symbol_pipeline_review.md`](milestone_27/27-4_android_native_symbol_pipeline_review.md)：Android Firebase config、Gradle plugin、R8 mapping與Flutter symbols pipeline review。
- [`milestone_27/27-5_ios_native_dsym_pipeline_review.md`](milestone_27/27-5_ios_native_dsym_pipeline_review.md)：iOS Firebase config、Crashlytics build phase、iOS 15 baseline與dSYM pipeline review。
- [`milestone_27/27-6_ci_secrets_remote_acceptance_review.md`](milestone_27/27-6_ci_secrets_remote_acceptance_review.md)：CI secret boundary、兩平台symbol upload、Firebase Console ingestion與symbolication closure。
- [`milestone_27/27-7_self_hosted_ci_design_review.md`](milestone_27/27-7_self_hosted_ci_design_review.md)：三種CI execution mode、trusted self-hosted runner boundary與Task 27-7 design gate。
- [`milestone_27/27-7_self_hosted_ci_plan_review.md`](milestone_27/27-7_self_hosted_ci_plan_review.md)：Task 27-7 implementation順序、TDD、runtime acceptance與逐Task closure gate。
- [`milestone_27/27-7_self_hosted_ci_runtime_evidence.md`](milestone_27/27-7_self_hosted_ci_runtime_evidence.md)：Mac runner註冊、manual／main routing、PR denial與offline queue證據。
- [`milestone_27/27-7_self_hosted_ci_implementation_review.md`](milestone_27/27-7_self_hosted_ci_implementation_review.md)：Task 27-7各小Task findings與holistic closure。
- [`milestone_27/27-7_cross_task_final_revalidation.md`](milestone_27/27-7_cross_task_final_revalidation.md)：Task 27-6完成後的runner、secret、routing與authority跨Task重驗。
- [`milestone_27/27-8_final_review.md`](milestone_27/27-8_final_review.md)：Milestone 27整體holistic review、release decision與final claim boundary。
- [`milestone_27/27-9_post_release_remote_validation.md`](milestone_27/27-9_post_release_remote_validation.md)：Template Baseline 1.9.0 release-SHA self-hosted CI、Android與iOS完整驗證。
- [`milestone_27/27-7_task_1_activation_adr_review.md`](milestone_27/27-7_task_1_activation_adr_review.md)：Task 27-7 activation、ADR authority與current roadmap同步review。
- [`milestone_27/27-3_firebase_crashlytics_reference_adapter_review.md`](milestone_27/27-3_firebase_crashlytics_reference_adapter_review.md)：Firebase Core／Crashlytics App-owned reference adapter、collection policy與failure isolation review。
- [`milestone_27/27-2_reporting_routing_hardening_review.md`](milestone_27/27-2_reporting_routing_hardening_review.md)：Severity routing、closed metadata、recursive guard、degraded rate limiting與typed breadcrumb review。

### Change-aware CI initiative

- [`milestone_32/32-0_design_spec_review.md`](milestone_32/32-0_design_spec_review.md)：Milestone 32 promotion、Design focused findings、fixes、fresh re-review、whole-Design與使用者核准closure。
- [`milestone_32/32-1_implementation_plan_review.md`](milestone_32/32-1_implementation_plan_review.md)：Milestone 32 Implementation Plan的Task順序、TDD interfaces、runtime acceptance、cleanup雙重approval與release closure review。
- [`milestone_32/32-5_local_ci_integration_review.md`](milestone_32/32-5_local_ci_integration_review.md)：Manual-local managed job、跨平台artifact output、Windows portability與clean quality acceptance review。
- [`milestone_32/32-6_workflow_transport_review.md`](milestone_32/32-6_workflow_transport_review.md)：Workflow local-first transport matrix、self-hosted managed aggregation、bounded GitHub exception與summary evidence review。
- [`milestone_32/32-2_artifact_contract_review.md`](milestone_32/32-2_artifact_contract_review.md)：Tasks 1–2 durable authority、root／manifest contract、TDD findings與portability review。
- [`milestone_32/32-3_artifact_store_review.md`](milestone_32/32-3_artifact_store_review.md)：Task 3 job lock、staging、atomic publish、checksums與multi-job aggregation review。
- [`milestone_32/32-4_retention_cleanup_review.md`](milestone_32/32-4_retention_cleanup_review.md)：Task 4 retention、capacity、bounded pins、cleanup manifest、trash／restore／purge與concurrency review。
- [`ci_artifact_storage_cutover_candidate_handoff.md`](ci_artifact_storage_cutover_candidate_handoff.md)：Proposed Milestone 32的quota盤點、候選scope、Design待決事項、禁止提前cleanup邊界與跨對話handoff。
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

### Milestone 31 workflow follow-ups

- [`milestone_31/31-followup-karpathy-guidelines-source-review.md`](milestone_31/31-followup-karpathy-guidelines-source-review.md)：固定上游commit、來源hash與授權觀察。
- [`milestone_31/31-followup-karpathy-guidelines-red-validation.md`](milestone_31/31-followup-karpathy-guidelines-red-validation.md)：五個fresh RED controls與「無confirmed gap」拒絕證據。
- [`milestone_31/31-followup-karpathy-guidelines-final-review.md`](milestone_31/31-followup-karpathy-guidelines-final-review.md)：已superseded的Codex＋Ponytail環境Rejected歷史結論。
- [`milestone_31/31-followup-karpathy-primary-workflow-recovery-review.md`](milestone_31/31-followup-karpathy-primary-workflow-recovery-review.md)：ChatGPT＋bridge-mac主要工作流runtime mismatch finding與recovery authority。
- [`milestone_31/31-followup-karpathy-guidelines-pressure-validation.md`](milestone_31/31-followup-karpathy-guidelines-pressure-validation.md)：primary runtime Skill discovery、authority、trigger與non-trigger驗證。
- [`milestone_31/31-followup-karpathy-primary-workflow-final-review.md`](milestone_31/31-followup-karpathy-primary-workflow-final-review.md)：取代舊Rejected結論的restricted Pilot holistic disposition。

### Repository-local Skill adoption reviews

- [`agent_assisted_development_quick_start_review.md`](agent_assisted_development_quick_start_review.md)：AI Agent日常Quick Start Guide的場景覆蓋、Skill routing、authority boundary與remote closure review。
- [`repository_local_skills_traditional_chinese_review.md`](repository_local_skills_traditional_chinese_review.md)：commit `c8a77a5`當時的Level 1歷史審查；其classification與closure authority已被後續Level 3 recovery supersede。
- [`repository_local_skills_zh_tw_design_review.md`](repository_local_skills_zh_tw_design_review.md)：繁體中文化Level 3 governance recovery Design Task review。
- [`repository_local_skills_zh_tw_plan_review.md`](repository_local_skills_zh_tw_plan_review.md)：六Task review execution Plan的完整Task review。
- [`repository_local_skills_zh_tw_task_1_central_governance_review.md`](repository_local_skills_zh_tw_task_1_central_governance_review.md)：中央治理Skill與五份references的semantic equivalence、classification與gate review。
- [`repository_local_skills_zh_tw_task_2_product_identity_review.md`](repository_local_skills_zh_tw_task_2_product_identity_review.md)：產品識別Skill trigger、安全、pressure status與authority review。
- [`repository_local_skills_zh_tw_task_3_starting_feature_review.md`](repository_local_skills_zh_tw_task_3_starting_feature_review.md)：Starting Feature Work短入口、中央委派與pressure controls review。
- [`repository_local_skills_zh_tw_task_4_karpathy_review.md`](repository_local_skills_zh_tw_task_4_karpathy_review.md)：Karpathy source pin、subordinate routing與restricted boundary review。
- [`repository_local_skills_zh_tw_task_5_language_governance_review.md`](repository_local_skills_zh_tw_task_5_language_governance_review.md)：語言policy、歷史supersession與`agent-skill-language` RED／GREEN evidence。
- [`repository_local_skills_zh_tw_holistic_final_review.md`](repository_local_skills_zh_tw_holistic_final_review.md)：Tasks 1～5完成後，對全部中文化變更與recovery修正的holistic final review及remote closure authority。
- [`adopting_template_product_identity_design_review.md`](adopting_template_product_identity_design_review.md)：`adopting-template-product-identity`薄型Skill Design的Level 3 Full Task review、P1修正、authority check與user approval gate。
- [`adopting_template_product_identity_plan_review.md`](adopting_template_product_identity_plan_review.md)：對應Implementation Plan的六Task拆分、RED／GREEN、registry contract、authority與clean-checkout完整Plan Task review。
- [`adopting_template_product_identity_main_integration_holistic_review.md`](adopting_template_product_identity_main_integration_holistic_review.md)：合併後`main`的完整文件／Skill authority審查、Windows portability修正、full regression與remote push gate。
- [`adopting_template_product_identity_behavioral_pressure_evidence.md`](adopting_template_product_identity_behavioral_pressure_evidence.md)：三個fresh isolated對話的provenance、prompt、behavioral結果與Pilot upgrade criteria matrix。
- [`adopting_template_product_identity_approval_closure_review.md`](adopting_template_product_identity_approval_closure_review.md)：解除restricted Pilot、更新current registry為`Approved`的bounded evidence closure review。
- [`adopting_template_product_identity_task_1_red_discovery_review.md`](adopting_template_product_identity_task_1_red_discovery_review.md)：候選Skill不存在時的machine discovery RED與behavioral runtime限制。
- [`adopting_template_product_identity_task_2_skill_core_review.md`](adopting_template_product_identity_task_2_skill_core_review.md)：薄型Skill核心、trigger、input與authority boundary review。
- [`adopting_template_product_identity_task_3_pressure_validation.md`](adopting_template_product_identity_task_3_pressure_validation.md)：R1–R10 pressure protocol、machine discovery GREEN與restricted evidence disposition。
- [`adopting_template_product_identity_task_4_routing_registry_review.md`](adopting_template_product_identity_task_4_routing_registry_review.md)：中央narrow routing、entry-point matrix與Skill registry review。
- [`adopting_template_product_identity_task_5_guide_authority_review.md`](adopting_template_product_identity_task_5_guide_authority_review.md)：Guide入口、authority matrix、environment contract與Windows test portability review。
- [`adopting_template_product_identity_final_review.md`](adopting_template_product_identity_final_review.md)：跨Task consistency、clean-checkout discovery與`Pilot accepted with restrictions`最終結論。

其他位於 `docs/audits/` root 的 planning、runtime 或 holistic review 仍保留原 stable path。Index 只負責 routing，不複製 findings、test counts、commit hashes或 final gate內容。
