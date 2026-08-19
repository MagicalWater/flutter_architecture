---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-46-documentation-skill-governance-simplification-plan
last_reviewed_baseline: 1.24.0
---

# Milestone 46 — Documentation & Skill Governance Complexity Audit / Simplification Implementation Plan

## Execution principle

本 Plan 只處理會影響 current admission、authority ownership、Skill routing 與日常維護成本的文件/治理表面。歷史 audits、completed specs/plans 與 Git history 不因「檔案很多」而批量搬移或刪除；只要已退出 current admission，即不把其總量視為 ordinary development runtime 負擔。

本 Milestone 不建立 per-task audit、per-file deletion manifest、documentation inventory database 或新永久測試。Execution units 以真正的 authority boundary 劃分；最後只建立一次 holistic final review / closure evidence。

Admission-related修改必須視為**同一 consistency cutover boundary**：`AGENTS.md`、central governance Skill、domain Skill必讀清單、human entry/guide中的minimum-read摘要要在同一候選狀態完成後才可視為current authority。不得先發布「3-file admission」入口，卻讓下游Skill/Guide仍強制重新載入舊`project_context`／`roadmap`集合。

## Unit 46-1 — Fresh admission surface reduction

修改：

- `AGENTS.md`
- `docs/README.md`
- 必要時 `docs/governance/documentation_policy.md`
- `docs/roadmap.md` / `docs/roadmap/active.md`（Milestone 46進入implementation時同步active authority）

完成：

- fixed fresh admission 從目前 6 個 repository files 收斂至：

```txt
AGENTS.md
repository_identity.json
VERSION
```

- `docs/project_context.md`、`docs/roadmap.md`、`docs/README.md` 改為 task-triggered / project-wide context route，不再所有 Level 0～2 unconditional read。
- `AGENTS.md` 只保留 hard policy、minimum admission、central governance入口與少量不可違反 safety rules；architecture/procedure/testing正文改由 owner 按需提供。
- 保留 fail-closed repository identity admission，不從 README prose、remote URL 或路徑猜 lifecycle state。
- Milestone 46 Plan正式accepted並開始implementation後，current roadmap不得繼續宣稱`Active Milestone: none`；只記錄最小active routing，不新增逐Task journal。

## Unit 46-2 — Central governance Skill becomes a thin router

修改：

- `.agents/skills/governing-template-development/SKILL.md`
- `.agents/skills/governing-template-development/references/work-classification.md`
- `.agents/skills/governing-template-development/references/artifact-routing.md`
- `.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- `.agents/skills/governing-template-development/references/test-authoring.md`
- `.agents/skills/governing-template-development/references/skill-adoption-governance.md`
- `.agents/skills/governing-template-development/references/pressure-scenarios.md`
- `.agents/skills/adopting-template-repository/SKILL.md`
- `.agents/skills/adopting-template-product-identity/SKILL.md`
- 其他repository-authored domain/shortcut Skill僅在其「必讀authority」或delegation contract仍硬編碼舊admission時修改

完成：

- central `SKILL.md` 僅保留：identity admission → lowest-sufficient classification → Requirement Decision → conditional reference/domain routing → stop conditions。
- references 真正按需載入；不再讓 ordinary task 固定讀 classification + artifact + task-governance 全套正文。
- observable behavior / testing 不在 scope 時，不讀 test-authoring reference。
- Skill adoption / behavioral pressure 不在 scope 時，不讀 adoption / pressure references。
- 不把 reference 的完整 matrix 再複製回 `SKILL.md`。
- M45 test-by-exception、Minimum Sufficient Validation、same-SHA reuse 與 lowest-sufficient classification semantics 保持不變，只重新收斂 ownership / routing。
- Domain Skill可以擁有其domain-specific必讀集合，但不得重新宣告repository-wide fixed admission；例如Template→Product bootstrap可按需讀`repository_infrastructure.json`與adoption Guide，但不得因進入domain route無條件把`project_context`／`roadmap`重新加回所有工作的固定集合。

## Unit 46-3 — Current snapshot and roadmap history separation

修改：

- `docs/project_context.md`
- `docs/roadmap.md`
- `docs/roadmap/active.md`（若 routing 需要）
- `docs/milestones/README.md` / `docs/audits/README.md` 僅在需要補 history route 時調整

完成：

- `docs/project_context.md` 移除 closed Milestone 34～45 chronology、release/evidence journal與已完成initiative敘述，只留下 current architecture/capability/platform/security/active-work facts。
- `docs/roadmap.md` Closed section 只保存 closed range + historical routing，不重新維護 testing/governance current policy正文。
- historical detail 繼續由 Milestone/Audit/CHANGELOG/Git history 查詢；不做大量 physical archive move。
- current snapshot 不再自我違反「current-only」contract。

## Unit 46-4 — Human governance overview and guide collapse

修改：

- `docs/governance/development_workflow.md`
- `docs/guides/agent_assisted_development_quick_start.md`
- `docs/guides/how-to-add-feature.md`
- `docs/guides/testing_governance.md`（只處理重複 ownership，不改 M45 semantics）
- `docs/guides/template_repository_adoption.md`（若仍硬編碼舊minimum-read集合，改為domain-specific按需authority）
- `docs/guides/native_environment_adoption.md`（只在存在平行admission/policy摘要時調整）
- 其他 guide 僅在 semantic duplicate review 證明必要時修改

完成：

- `development_workflow.md` 回到短 human overview；不再承載 dated revalidation、adoption evidence、historical review journal。
- current Skill registry 若仍需 human current owner，保留最小 current status/trigger/responsibility/rollback；source admission history與dated evidence只連 historical evidence。
- quick-start guide 收斂為 entry selection + 少量 copyable prompts，不再平行維護 classification/testing/release policy。
- how-to-add-feature 將重複 architecture contract 改為 decision point + canonical ADR/local README link。
- guide 可以解釋「怎麼操作」，但不得擁有 Level、approval、test retention、validation selection 或 architecture contract 的第二份 authority。

## Unit 46-5 — Authority / checker / legacy cleanup review

審查：

- `docs/governance/documentation_policy.md`
- `docs/adr/adr-011-documentation-single-authority.md`
- `docs/adr/README.md`
- `tools/docs/check_docs.py`
- `tools/docs/test_check_docs.py`
- legacy compatibility stubs / indexes
- `docs/conversation_rules.md`

處置原則：

- 若 existing ADR-011 已足以擁有 stable single-authority contract，只更新必要 wording；預設不新增 ADR。
- docs checker 只保留 deterministic、能阻止實際 authority/link/metadata drift 的 rules；不新增 prose architecture scanners。
- 若 checker 中存在只服務於已退休 bureaucracy 的規則，可在有直接 evidence 時移除；無證據不為「簡化」而亂刪 safety net。
- compatibility stub 只有沒有 unique current authority、沒有 reusable value、且 routing 已被穩定 index/Git history取代時才刪除；否則縮成小 stub。
- `docs/conversation_rules.md`目前未被current入口引用但仍保存舊minimum-read與workflow policy，必須明確判定：若無unique current authority則archive/delete或縮成明確legacy stub；不得讓它以無metadata、current-tense形式繼續成為stale policy trap。

## Unit 46-6 — Fresh admission pressure and holistic closure

Fresh behavioral pressure 至少覆蓋：

1. Level 0 metadata / wording task：確認只需 3-file fixed admission + task-local source，不載入 project_context / roadmap / history。
2. Level 1 bounded bug：確認 central Skill只載入最低必要 classification/routing與 affected local authority，不自動進 formal Design/Plan。
3. Level 2 standard feature：確認 brief decision + local README/ADR/source route，不讀 closed Milestone evidence。
4. Architecture / repository governance：確認需要 project-wide context / ADR / formal routing時仍會正確升級，不因 admission 瘦身遺失 safety gate。

Holistic review 檢查：

- fixed fresh admission = 3 repository files。
- ordinary Level 0/1/2 不 unconditional讀 `docs/project_context.md` / `docs/roadmap.md` / historical audits。
- central Skill 是 router，不是 handbook；references conditional。
- `docs/project_context.md` closed Milestone chronology = 0。
- same current workflow rule 沒有 parallel authoritative owner。
- guides 不維護第二份 executable governance。
- machine authority / docs checker safety 沒被削弱。
- historical specs/plans/audits可追溯但不參與 ordinary admission。

Validation：

- `git diff --check`。
- `python tools/docs/check_docs.py`（或 repository canonical docs_check wrapper）。
- 若 `tools/docs/` 有 mutation，執行對應 focused checker tests；否則不為本 Milestone新增 tests。
- 使用 `tools/ci/validation_planner.py` 對 final changed range取得 Minimum Sufficient Validation plan；只執行 planner-selected relevant validations。
- 不因 Level 4 名稱自動執行 Flutter full regression。

## Release / closure disposition

Implementation + holistic review 完成後才決定是否需要 baseline release：

- 若只改 documentation/Skill routing且沒有 template consumer-visible release necessity，可 formal close without version bump。
- 若 fresh Agent bootstrap / template adoption current contract屬於應隨 template baseline 發布的治理能力變更，則做 explicit release disposition、VERSION/CHANGELOG/current authority sync。
- 同一 exact SHA 的 post-release 只驗 identity / relevant artifact / routing evidence，不重跑無關 Flutter source regression。

## Stop conditions

只有下列情況停止要求使用者決策：

1. 必須改變已核准 Design 的核心 admission / authority model。
2. 某個看似重複文件實際擁有無法安全搬移的唯一 current authority，且 disposition 需要產品/架構選擇。
3. P0/P1 finding 證明瘦身會削弱 security、release、migration 或 lifecycle fail-closed gate。
4. 本 Implementation Plan 的正式 approval gate。
