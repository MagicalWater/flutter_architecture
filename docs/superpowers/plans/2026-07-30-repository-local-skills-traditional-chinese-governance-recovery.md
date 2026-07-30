---
document_type: implementation-plan
status: completed
authoritative_for:
  - repository-local-skills-traditional-chinese-governance-recovery-plan
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 繁體中文化治理恢復 Implementation Plan

> **給 agentic workers：**必須逐 Task 執行。每個 Task 都要完成 focused review、findings、fix、fresh re-review、whole-Task review、authority check、validation 與 independent commit；不得以最後 holistic review 取代中間 Task gate。

**Goal：**對 commit `c8a77a5` 的全部 Skill 中文化變更補做 Level 3 full two-layer Task governance，修正發現的 current-authority gap，最後完成跨 Task holistic review與 remote clean-checkout closure。

**Architecture：**既有中文化 implementation 保持在 `main` 歷史中，本 recovery 只新增 review evidence與必要的最小修正。Review oracle 由中文化前版本（`7418a60`）、current approved Skill evidence、Skill registry、pressure scenarios與 current source／tests共同構成。

**Tech Stack：**Markdown、Python `unittest`、repository docs checker、Git worktree、bridge-win Skill discovery。

## Global Constraints

- Skill `name`、路徑、source pin、status 與 responsibility 不得因 review 被任意改寫。
- 所有自然語言文件使用繁體中文；技術識別保留英文。
- 歷史 evidence 不回寫，只新增 supersession／recovery route。
- 任何 required validation failure 都保持目前 Task open，修正後 fresh rerun。
- 不修改 VERSION、CHANGELOG、roadmap、Milestone state或產品 runtime source。
- 每個 Task 使用精確 staging，禁止 `git add .`。

---

### Task 1：Central Governance Skill Review

**Files：**

- Review：`.agents/skills/governing-template-development/SKILL.md`
- Review：`.agents/skills/governing-template-development/references/work-classification.md`
- Review：`.agents/skills/governing-template-development/references/artifact-routing.md`
- Review：`.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- Review：`.agents/skills/governing-template-development/references/skill-adoption-governance.md`
- Review：`.agents/skills/governing-template-development/references/pressure-scenarios.md`
- Create：`docs/audits/repository_local_skills_zh_tw_task_1_central_governance_review.md`

**Consumes：**Design invariants、`7418a60` 英文版、current `AGENTS.md`。

**Produces：**中央 classification／routing／acceptance／stop／closure 語意等價證據。

- [ ] 對照 `7418a60..c8a77a5` 的六份檔案 diff。
- [ ] 驗證 Level 0～5、Design／Plan gate、Task automatic continuation、P0／P1 gate與 Skill adoption anchors。
- [ ] 檢查 UTF-8 replacement character、broken link與 frontmatter discovery。
- [ ] 記錄 findings；若有 wording drift，做最小修正。
- [ ] Fresh re-review 與 docs validation。
- [ ] 建立 independent commit：`docs(workflow): 完成中央治理 Skill 中文化審查`。

### Task 2：Product Identity Skill Review

**Files：**

- Review／Modify：`.agents/skills/adopting-template-product-identity/SKILL.md`
- Review／Modify：`.agents/skills/adopting-template-product-identity/references/pressure-scenarios.md`
- Create：`docs/audits/repository_local_skills_zh_tw_task_2_product_identity_review.md`

**Consumes：**Approved identity Skill Design、approval closure evidence、current registry status `Approved`。

**Produces：**trigger／non-trigger、input gate、manifest-first、secret hard stop、evidence state與 current status一致性證據。

- [ ] 對照翻譯前後 Skill 與 R1～R10／API-only control。
- [ ] 檢查 base identifier、display names、API domains、drift、signing、Store與iOS evidence wording。
- [ ] 修正任何已 superseded 的 Pilot／restricted status文字。
- [ ] Fresh contract scan、docs validation與 authority re-review。
- [ ] 建立 independent commit：`docs(workflow): 完成產品識別 Skill 中文化審查`。

### Task 3：Starting Feature Work Skill Review

**Files：**

- Review：`.agents/skills/starting-feature-work/SKILL.md`
- Review：`.agents/skills/starting-feature-work/references/pressure-scenarios.md`
- Create：`docs/audits/repository_local_skills_zh_tw_task_3_starting_feature_review.md`

**Consumes：**Starting Feature Work adoption review與 current central route。

**Produces：**短 brief、中央委派、discussion-only與 implementation pressure 語意等價證據。

- [ ] 對照翻譯前後兩份檔案。
- [ ] 驗證 Skill 仍不要求使用者重貼治理模板，且 Requirement Decision 先於 Design／implementation。
- [ ] 驗證 pressure scenarios 保留 short Figma、discussion-only、skip-governance controls。
- [ ] Fresh discovery／docs validation。
- [ ] 建立 independent commit：`docs(workflow): 完成功能入口 Skill 中文化審查`。

### Task 4：Karpathy Guidelines Skill Review

**Files：**

- Review：`.agents/skills/karpathy-guidelines/SKILL.md`
- Review：`.agents/skills/karpathy-guidelines/references/pressure-scenarios.md`
- Create：`docs/audits/repository_local_skills_zh_tw_task_4_karpathy_review.md`

**Consumes：**Pinned source evidence、primary-workflow final review、registry restricted Pilot status。

**Produces：**source pin、subordinate routing、anti-overengineering heuristics、non-trigger與 restriction語意等價證據。

- [ ] 對照翻譯前後兩份檔案。
- [ ] 驗證 source commit、minimum solution、surgical diff、safety evidence與禁止 workflow authority等 anchors。
- [ ] 確認 restricted status 未被中文化誤升級。
- [ ] Fresh discovery／docs validation。
- [ ] 建立 independent commit：`docs(workflow): 完成 Karpathy Skill 中文化審查`。

### Task 5：Language Governance and Mechanical Enforcement

**Files：**

- Modify：`tools/docs/check_docs.py`
- Modify：`tools/docs/test_check_docs.py`
- Modify：`.agents/skills/governing-template-development/references/skill-adoption-governance.md`（只有 finding需要時）
- Modify：`docs/governance/development_workflow.md`
- Modify：`docs/audits/repository_local_skills_traditional_chinese_review.md`
- Create：`docs/audits/repository_local_skills_zh_tw_task_5_language_governance_review.md`

**Consumes：**Language policy、placement rule、Skill registry、Task 1～4 evidence。

**Produces：**可機械執行的最小中文 contract、current registry revalidation route與歷史 review supersession。

- [ ] 先新增 failing tests：英文-only Skill description、英文-only reference body應產生明確 issue code。
- [ ] 執行 tests，確認 RED 來自缺少 language check。
- [ ] 在 docs checker 加入最小 CJK presence rule；不禁止必要英文或 code fences。
- [ ] 執行 focused GREEN 與全部 docs tests。
- [ ] 更新 registry validation evidence與原 Level 1 review的 supersession route。
- [ ] Fresh authority review與 docs_check。
- [ ] 建立 independent commit：`test(docs): 強制 repository-local Skill 中文規則`。

### Task 6：Holistic Final Review and Closure

**Files：**

- Create：`docs/audits/repository_local_skills_zh_tw_holistic_final_review.md`
- Modify：`docs/audits/README.md`
- Modify：`docs/superpowers/README.md`
- Modify：本 Plan status（`accepted → completed`）

**Consumes：**Task 1～5 reviews與 commits。

**Produces：**完整 cross-Task consistency、regression、push與 remote clean-checkout closure evidence。

- [ ] 審查原 15 個變更檔與 recovery diff 的完整範圍。
- [ ] 驗證四個 Skill names、descriptions、links、status、routing與 forbidden responsibilities。
- [ ] 執行 docs checker tests、docs_check、environment 40 tests、workspace analyze與全部 Flutter tests。
- [ ] 確認 Open P0／P1／P2 gate。
- [ ] 建立 final review commit。
- [ ] Fast-forward merge 至 `main`，fetch remote後 non-force push。
- [ ] 由 `origin/main` 建立 clean checkout，重新驗證四個 Skill discovery與核心 contracts。
- [ ] 清理 recovery worktrees／branch，核對 local／remote SHA與 clean status。

## Completion rule

只有 Task 1～5 全部有 independent commit，且 Task 6 holistic review、push、remote clean checkout 全部通過，才能宣稱繁體中文化 governance recovery 完成。

## Execution result

```txt
Task 1 — Central Governance Skill Review                  completed @ 68e7d38
Task 2 — Product Identity Skill Review                    completed @ a144c72
Task 3 — Starting Feature Work Skill Review               completed @ 8fcadea
Task 4 — Karpathy Guidelines Skill Review                 completed @ e4532a4
Task 5 — Language Governance and Mechanical Enforcement   completed @ a3fedc8
Task 6 — Holistic Final Review and Closure                 completed
Remote clean checkout                                     passed @ origin/main 060d2fd
```

Current final authority：`docs/audits/repository_local_skills_zh_tw_holistic_final_review.md`。
