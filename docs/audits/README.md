---
document_type: audit-index
status: active
authoritative_for:
  - audit-and-review-evidence-routing
last_reviewed_baseline: 1.15.1
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

### Milestone 34 — Pencil Asset / Vector / Typography Mapping & Provenance

- [`milestone_34/34-0_asset_typography_mapping_design_review.md`](milestone_34/34-0_asset_typography_mapping_design_review.md)：proposed Level 3 Design的classification、scope、authority、over-design guards與focused findings disposition；書面Design仍等待使用者核准。

### Milestone 33 — Repository-local Pencil-to-Flutter Workflow Foundation

- [`milestone_33/33-0_design_spec_review.md`](milestone_33/33-0_design_spec_review.md)：accepted Design與ADR-028的Level 4分類、第三方Skill語言／integrity治理、visual authority、Pencil MCP、Flutter mapping、visual acceptance及使用者核准closure；Implementation尚未開始。
- [`milestone_33/33-p_implementation_plan_review.md`](milestone_33/33-p_implementation_plan_review.md)：accepted Plan的Design coverage、Tasks 33-1至33-13、TDD interfaces、visual threshold、release separation與使用者Plan approval closure review。
- [`milestone_33/33-execution-admission.md`](milestone_33/33-execution-admission.md)：managed worktree、branch、Plan／Design ancestry與execution boundary admission evidence。
- [`milestone_33/33-1_adr_028_canonicalization_review.md`](milestone_33/33-1_adr_028_canonicalization_review.md)：ADR coverage TDD、canonical ADR-028、draft authority cutover與Task review。
- [`milestone_33/33-2_skill_lock_governance_review.md`](milestone_33/33-2_skill_lock_governance_review.md)：ownership-aware third-party Skill lock、raw hash／license／path fail-closed與語言豁免review。
- [`milestone_33/33-3_taste_skill_source_admission.md`](milestone_33/33-3_taste_skill_source_admission.md)：Taste Skill immutable commit、Git blob／Windows EOL disposition、lock、license與restricted adoption review。
- [`milestone_33/33-3_taste_skill_discovery_pressure_evidence.md`](milestone_33/33-3_taste_skill_discovery_pressure_evidence.md)：same-name collision RED、temporary fixture cleanup與managed-worktree local discovery GREEN evidence。
- [`milestone_33/33-4_visual_authority_review.md`](milestone_33/33-4_visual_authority_review.md)：visual manifest TDD、repository-local `.pen`／references admission、source ranking、canonical viewport與Task 33-6 preview export gate review。
- [`milestone_33/33-5_orchestration_pressure_evidence.md`](milestone_33/33-5_orchestration_pressure_evidence.md)：Pencil-to-Flutter RED／DISCOVERY／EXPLICIT／REFACTOR behavioral pressure evidence。
- [`milestone_33/33-5_orchestration_skill_review.md`](milestone_33/33-5_orchestration_skill_review.md)：thin orchestration Skill、中央route、Taste boundary、permissions、rollback與whole-Task review。
- [`milestone_33/33-6_pencil_admission_and_extraction.md`](milestone_33/33-6_pencil_admission_and_extraction.md)：Executor／Pencil admission、accepted document identity、structure inventory與canonical Pencil export evidence。
- [`milestone_33/33-6_flutter_mapping_matrix.md`](milestone_33/33-6_flutter_mapping_matrix.md)：Pencil extracted items到Design System／feature-local visual spec／localization／icons／widgets的single-owner mapping。
- [`milestone_33/33-6_pencil_extraction_review.md`](milestone_33/33-6_pencil_extraction_review.md)：Pencil boundary、canonical export與mapping whole-Task review。
- [`milestone_33/33-6r_design_source_index_transition_review.md`](milestone_33/33-6r_design_source_index_transition_review.md)：Task 33-12發現的design-source index stale transition recovery；只修current preview row，不修改任何visual bytes／manifest／threshold。
- [`milestone_33/33-7_flutter_proof_foundation_review.md`](milestone_33/33-7_flutter_proof_foundation_review.md)：presentation-only feature、router／localization／visual spec foundation與TDD review。
- [`milestone_33/33-8_write_precheck_ui_review.md`](milestone_33/33-8_write_precheck_ui_review.md)：Write Pre-check responsive widget implementation與visual hierarchy review。
- [`milestone_33/33-9_flutter_validation_review.md`](milestone_33/33-9_flutter_validation_review.md)：architecture／semantics／localization／responsive與Windows canonical golden validation review。
- [`milestone_33/33-10_visual_acceptance_review.md`](milestone_33/33-10_visual_acceptance_review.md)：固定8% deterministic diff、historical relative gate、Android runtime screenshot與semantic visual acceptance review。
- [`milestone_33/33-10r_fontweight_api_compatibility_review.md`](milestone_33/33-10r_fontweight_api_compatibility_review.md)：Task 33-11 full analyze發現的`FontWeight.index`deprecation corrective recovery；visual gate不變且workspace analyze恢復GREEN。
- [`milestone_33/visual_validation/review.md`](milestone_33/visual_validation/review.md)：Task 33-10 canonical／Android runtime semantic visual review與evidence hashes。
- [`milestone_33/33-11_workflow_documentation_review.md`](milestone_33/33-11_workflow_documentation_review.md)：Reusable Guide、narrow routing、Skill registry／language ownership、current sync與Guide pressure disposition review。
- [`milestone_33/33-12_holistic_final_review.md`](milestone_33/33-12_holistic_final_review.md)：Tasks 33-1至33-11 cross-Task consistency、fresh full local regression、visual acceptance與disposition A release authorization boundary的Holistic Final Review。
- [`milestone_33/33-13_post_release_validation.md`](milestone_33/33-13_post_release_validation.md)：Template Baseline 1.15.0 release SHA的main publication、fresh clean-checkout full regression、Skill path／collision、Android artifact與fresh canonical visual acceptance closure evidence。
- [`milestone_33/33-c0_single_renderer_corrective_design_review.md`](milestone_33/33-c0_single_renderer_corrective_design_review.md)：使用者runtime P1後的single-renderer Corrective Design／ADR amendment與原visual closure supersession review。
- [`milestone_33/33-cp_corrective_implementation_plan_review.md`](milestone_33/33-cp_corrective_implementation_plan_review.md)：Corrective C1～C5雙層Task plan、runtime/user hard gate與release boundary review。
- [`milestone_33/33-c1_governance_contract_review.md`](milestone_33/33-c1_governance_contract_review.md)：single whole-screen tree、design-space與runtime fidelity治理契約review。
- [`milestone_33/33-c2_runtime_visual_contract_review.md`](milestone_33/33-c2_runtime_visual_contract_review.md)：360×640 reference、1.15.0 intentional RED reproduction與C3前locked contract review。
- [`milestone_33/33-cp2_runtime_renderer_calibration_amendment_review.md`](milestone_33/33-cp2_runtime_renderer_calibration_amendment_review.md)：修正direct Pencil runtime hard gate的cross-renderer calibration P1，建立Gate A/B/C/D current acceptance model。
- [`milestone_33/33-c3_cross_conversation_checkpoint.md`](milestone_33/33-c3_cross_conversation_checkpoint.md)：C3跨對話implementation checkpoint；只作歷史承接證據。
- [`milestone_33/33-c3_single_renderer_implementation_review.md`](milestone_33/33-c3_single_renderer_implementation_review.md)：C3 single production renderer focused／whole-Task review與fresh Gate A/B/C驗證。
- [`milestone_33/33-c4_android_runtime_acceptance.md`](milestone_33/33-c4_android_runtime_acceptance.md)：fresh Android runtime evidence與使用者人工visual acceptance。
- [`milestone_33/33-c5_corrective_holistic_final_review.md`](milestone_33/33-c5_corrective_holistic_final_review.md)：Corrective responsibility boundary、Clean Architecture、code/test architecture、anti-cheat與documentation reconciliation Holistic Final Review。
- [`milestone_33/33-c6_post_release_validation.md`](milestone_33/33-c6_post_release_validation.md)：Template Baseline 1.15.1 main publication、fresh full regression、Gate B continuity與Corrective final closure evidence。

### Template Baseline 1.14.0 project holistic audit

- [`template_baseline_1_14_project_holistic_audit/a13_remote_main_publication_closure.md`](template_baseline_1_14_project_holistic_audit/a13_remote_main_publication_closure.md)：使用者核准的`main`一般push、remote equality與最終publication closure；總審查及R1～R5已完整發布，沒有mandatory next milestone。
- [`template_baseline_1_14_project_holistic_audit/a12_local_main_integration_closure.md`](template_baseline_1_14_project_holistic_audit/a12_local_main_integration_closure.md)：使用者核准的local fast-forward integration、合併後generated／Python／docs／五package analyze／725項Flutter tests、App bundle與Audit worktree／local branch cleanup evidence；push與release均未執行。
- [`template_baseline_1_14_project_holistic_audit/a11_local_branch_completion_verification.md`](template_baseline_1_14_project_holistic_audit/a11_local_branch_completion_verification.md)：R1～R5與A10提交後的branch completion evidence；其integration decision前狀態已由A12接續。
- [`template_baseline_1_14_project_holistic_audit/a10_remediation_holistic_closure.md`](template_baseline_1_14_project_holistic_audit/a10_remediation_holistic_closure.md)：accepted R1～R5 finding closure、cross-remediation consistency、maintenance-mode decision與integration boundary；9個Audit findings已全部關閉。
- [`r5_milestone_32_local_worktree_branch_cleanup_review.md`](r5_milestone_32_local_worktree_branch_cleanup_review.md)：R5 fresh clean／ancestry proof、Windows long-path recovery與local worktree／branch cleanup review；remote branch明確保留。
- [`r4_test_inventory_external_output_bugfix/`](r4_test_inventory_external_output_bugfix/)：R4 TDD review與accepted holistic final review；external absolute output已支援，tracked M30 inventory baseline未變，`F-A6-01`已關閉。
- [`r4_test_inventory_external_output_bugfix_plan_review.md`](r4_test_inventory_external_output_bugfix_plan_review.md)：R4 accepted Plan的pure helper、subprocess RED、tracked baseline protection與single-finding closure review。
- [`r4_test_inventory_external_output_bugfix_design_review.md`](r4_test_inventory_external_output_bugfix_design_review.md)：R4 external output failure reproduction、pure path display helper、TDD與tracked baseline preservation Design review。
- [`r3_api_client_transport_neutral_error_boundary/`](r3_api_client_transport_neutral_error_boundary/)：R3 endpoint boundary、Auth migration、App composition與accepted holistic final review；`F-A2-01`已關閉，Auth不再依賴Dio。
- [`r3_api_client_transport_neutral_error_boundary_plan_review.md`](r3_api_client_transport_neutral_error_boundary_plan_review.md)：R3 accepted TDD Plan的endpoint-first sequencing、Mock parity、Auth coverage、generated DI與full workspace regression review。
- [`r3_api_client_transport_neutral_error_boundary_design_review.md`](r3_api_client_transport_neutral_error_boundary_design_review.md)：R3 endpoint interface、Dio adapter、neutral envelope、Auth ownership、public API cleanup與ADR-013 implementation recovery Design review。
- [`r2_project_context_current_only_rationalization/`](r2_project_context_current_only_rationalization/)：R2 preservation matrix、current-only rewrite review與accepted holistic final review；`F-A7-02`已關閉，Project Context不再保存Milestone chronology。
- [`r2_project_context_current_only_rationalization_plan_review.md`](r2_project_context_current_only_rationalization_plan_review.md)：R2 accepted Plan的matrix-before-rewrite、chronology／claim assertions、single-finding closure guard與standing authorization邊界review。
- [`r2_project_context_current_only_rationalization_design_review.md`](r2_project_context_current_only_rationalization_design_review.md)：R2 Project Context current-only rationalization的Level 3分類、preservation matrix、current fact re-home、chronology removal與standing authorization邊界review。
- [`r1_current_authority_contradiction_closure/`](r1_current_authority_contradiction_closure/)：R1-1～R1-3 focused／whole-Task review，以及使用者已核准的R1-4 cross-document holistic final review；五個allowlisted current authority findings均已關閉。
- [`r1_current_authority_contradiction_closure_plan_review.md`](r1_current_authority_contradiction_closure_plan_review.md)：R1 accepted Implementation Plan的Design coverage、R1-P／R1-1～R1-4 sequencing、semantic assertions、finding allowlist／denylist、commit boundaries與Plan approval closure；R1 Final Review user gate已完成。
- [`r1_current_authority_contradiction_closure_design_review.md`](r1_current_authority_contradiction_closure_design_review.md)：Audit核准後R1 current authority矛盾修復Design的Level 3分類、五Finding allowlist、scope／non-goals、雙層Task與使用者核准closure。
- [`template_baseline_1_14_project_holistic_audit_design_review.md`](template_baseline_1_14_project_holistic_audit_design_review.md)：Template Baseline 1.14.0 repository-wide整體總審查Design的Level 4分類、A0～A9 Task boundaries、Plan acceptance hard gate、focused finding修正與使用者核准證據。
- [`template_baseline_1_14_project_holistic_audit_plan_review.md`](template_baseline_1_14_project_holistic_audit_plan_review.md)：對應accepted Execution Plan的spec coverage、exact file／command、temporary evidence、commit boundaries與A1前使用者核准closure。
- [`template_baseline_1_14_project_holistic_audit/`](template_baseline_1_14_project_holistic_audit/)：A1～A9 repository baseline、architecture、capability、runtime、security／platform、testing／CI、documentation、future direction與holistic disposition evidence；`findings.md`為本Audit finding正文唯一owner。
- [`template_baseline_1_14_project_holistic_audit/a9_holistic_final_review.md`](template_baseline_1_14_project_holistic_audit/a9_holistic_final_review.md)：A1～A8 cross-Task consistency、9個frozen findings、fresh full regression與使用者已核准的B＋D最終方向；R1 remediation依獨立Requirement Decision執行，merge與push仍未進行。

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
- [`milestone_32/32-7_observability_failure_evidence_review.md`](milestone_32/32-7_observability_failure_evidence_review.md)：Controlled-event opt-in、Observability local-only raw evidence、secret leakage scanner與bounded failure evidence review。
- [`milestone_32/32-8_runtime_acceptance.md`](milestone_32/32-8_runtime_acceptance.md)：Operator guide、Windows shell LF portability、Task 8 static regression、managed quality evidence與Task 9 runtime acceptance入口；Task 8已完成。
- [`milestone_32/32-9_runtime_acceptance_review.md`](milestone_32/32-9_runtime_acceptance_review.md)：Task 9 Windows／Mac manual-local、controlled failure、Observability secret-safe、self-hosted offline／success、bounded iOS evidence與GitHub no-growth完整runtime acceptance。
- [`milestone_32/32-9_github_cleanup_manifest_review.md`](milestone_32/32-9_github_cleanup_manifest_review.md)：Task 10 fresh GitHub inventory、exact-ID deletion manifest、integrity／review／approval／drift gates與不可逆cleanup前停止點。
- [`milestone_32/32-10_github_cleanup_execution.md`](milestone_32/32-10_github_cleanup_execution.md)：Task 11 drift fail-closed歷史、final exact-ID execution、113個objects刪除、逐ID不存在與GitHub storage歸零證據。
- [`milestone_32/32-11_final_review.md`](milestone_32/32-11_final_review.md)：跨Tasks 1～11的artifact ownership、schema、secret、multi-job、retention、rollback、不可逆cleanup與1.14.0 release holistic review。
- [`milestone_32/32-12_post_release_validation.md`](milestone_32/32-12_post_release_validation.md)：1.14.0 release SHA的self-hosted CI／Android／iOS、Observability skipped、storage no-growth、clean-checkout與formal closure evidence。
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
