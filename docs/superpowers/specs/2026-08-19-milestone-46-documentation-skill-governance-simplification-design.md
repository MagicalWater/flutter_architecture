---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-46-documentation-skill-governance-simplification-design
last_reviewed_baseline: 1.24.0
---

# Milestone 46 — Documentation & Skill Governance Complexity Audit / Simplification Design

## 1. Requirement Decision

- Request：審查 repository documentation、Skill、references、guides、ADR、roadmap 與 project context 是否已形成 governance bloat，若成立則簡化 current admission 與 authority ownership。
- Problem：current admission 入口、current snapshot、central Skill、human governance overview 與 reusable guides 之間存在重複摘要與歷史內容回流，造成 Agent 在 ordinary task 進入 repository 時讀取與判斷成本偏高。
- Current behavior：所有 fresh admission 固定讀取 `AGENTS.md`、`repository_identity.json`、`VERSION`、`docs/README.md`、`docs/project_context.md`、`docs/roadmap.md`；進入治理後再讀 central Skill 及至少 work-classification、artifact-routing、two-layer-task-governance 等 references。部分 fixed-read 文件又重複 routing、validation、history 或 architecture 摘要。
- Expected behavior：ordinary task 只讀極少 current entry authorities；中央 Skill 保持短小、只負責 decision/routing；詳細規則按需載入；historical milestone evidence 不參與 current admission；同一 current rule 只有一個 authoritative owner。
- Value：降低 Agent token/read latency、authority conflict surface、同步成本與「治理治理本身」的維護負擔，同時保留 machine safety、architecture decisions、release traceability 與必要 human guidance。
- Classification：Level 4 — repository-wide governance simplification。
- Decision：Accept。
- Scope：documentation routing、central governance Skill/references、human governance guides、project context/roadmap current-vs-history boundary、machine-vs-human authority ownership、archive/delete/merge disposition。
- Non-goals：刪除 Git history；為追求檔案數字任意刪除 ADR；移除必要 machine safety；重做 production architecture；建立新的 per-file audit bureaucracy。
- Behavioral requirements required：是，聚焦 fresh Agent admission 與 authority routing behavior。
- Design Spec required：是。
- Implementation Plan required：是；本 Design accepted 後才建立。
- ADR required：conditional；只有 stable documentation/agent authority contract 必須由 ADR 擁有時才更新既有 ADR-011，預設不新增 ADR。
- Task governance mode：formal-critical，但以 risk boundary 為單位，不建立 per-subtask audits。
- Worktree／branch：managed worktree；`milestone-46-documentation-skill-governance-simplification`。
- Regression level：documentation/governance focused validation；除非 machine routing/checker changed risk 證明必要，不跑 Flutter full regression。
- Release required：implementation 完成後 explicit disposition；不因 Milestone 名稱自動升版。
- Post-release validation：若 release，僅 identity/docs/tooling behavior 所需 evidence；same SHA 不重跑無關 source full regression。
- Required artifacts：本 Design、accepted 後的一份 Implementation Plan、一次 holistic final review/closure evidence；material finding 才補 evidence。

## 2. Audit conclusion

系統性問題成立，但問題不是「repository 只要文件多就錯」。歷史 evidence 的總量可以很大，只要它不進 ordinary admission、沒有 current authority 身分，也不要求每次同步更新。

真正需要修正的是 **active read surface 與 ownership duplication**：

1. fixed admission set 過大，而且其中多份文件再次複製 routing 與 current-state摘要；
2. `docs/project_context.md` 宣稱 current-only，卻仍保存大量已 closed Milestone chronology；
3. `AGENTS.md` 同時承載 agent policy、architecture摘要、validation procedure與操作命令，超過「入口policy」責任；
4. central Skill 同時保存 routing、approval、test lifecycle、domain routes、release/closure等大量正文，且與 references、人類 governance overview、guides 重複；
5. reusable guides 有一部分從「how-to」膨脹成 current workflow policy 摘要，導致同一規則需要多處同步；
6. historical specs/plans/audits數量本身不是 runtime 問題，但 current indexes 與 snapshot 不應反向把大量 closure detail帶回 active reading surface。

## 3. Current authority model — target

### 3.1 Mandatory fresh admission

目標收斂為：

```txt
AGENTS.md
repository_identity.json
VERSION
```

`AGENTS.md`只保存不可違反policy與 task-routing入口，直接告訴 Agent 何時按需讀 `docs/README.md`、central Skill、local README 或 machine manifest。

`docs/project_context.md`與`docs/roadmap.md`不再是所有 Level 0～2 ordinary task 的 unconditional read；只有需要 project-wide current capability、active initiative 或 roadmap disposition 時才載入。

### 3.2 Task-local authority

ordinary source task在完成 minimal admission後只載入：

```txt
central governance routing（最小必要）
+ affected local README / ADR / guide / source
+ machine authority when the task touches that domain
```

不得因 repository 曾有某 Milestone，就要求讀其 spec、plan、audit 或 closure evidence。

## 4. Skill simplification target

`governing-template-development/SKILL.md`應成為薄型 router，而不是第二份完整治理手冊。

Target responsibility：

```txt
identity admission
→ classify lowest sufficient Level
→ Requirement Decision
→ route only the references actually needed
→ route domain/workflow Skill when triggered
→ define stop conditions
```

詳細矩陣只在需要時載入：

- classification details → `work-classification.md`
- artifact/approval routing → `artifact-routing.md`
- task review semantics → `two-layer-task-governance.md`
- test authoring/retention → 只有 observable behavior/test decision in scope 時讀 `test-authoring.md`
- Skill adoption → 只有新增/修改 Skill 時讀 `skill-adoption-governance.md`
- pressure scenarios → 只有 Skill behavior/adoption validation 時讀

central Skill不得再次複製reference的完整規則。

## 5. Machine authority / human guide / history split

### Machine authority — retain strongly

- `repository_identity.json` / `repository_infrastructure.json`等 lifecycle/infrastructure manifest。
- `VERSION`。
- `tools/ci/validation_planner.py`等 deterministic validation selection。
- docs checker中真正保護 unique authority、metadata、link、manifest consistency 的規則。
- source/tests/runtime artifacts 對實際 behavior 的 truth。

Machine authority不應被 guide prose再次定義。

### Human current authority — keep narrow

- `AGENTS.md`：agent hard policy + routing入口。
- `docs/README.md`：documentation taxonomy/index；按需讀，不再 unconditional。
- `docs/project_context.md`：project-wide current snapshot；只保存 current facts。
- `docs/roadmap.md` + active/candidates：current roadmap disposition。
- canonical ADR：stable architecture decisions。
- Feature/Package/App README：local current responsibility contract。
- focused reusable Guides：operator procedure/how-to，不擁有 workflow classification。

### Historical evidence — keep but remove from admission

- completed specs/plans。
- phase/final reviews與runtime evidence。
- closed milestone routing。
- superseded/legacy docs。
- release chronology already owned by CHANGELOG/Git history。

History可以保留在原路徑或 archive/index route；目標不是大搬家，而是不參與 current admission。

## 6. Duplicate ownership disposition

### `AGENTS.md`

保留：hard policy、minimum admission、central Skill route、high-level architecture prohibitions、generated-file safety。

下沉/刪除重複：完整command cookbook、testing lifecycle正文、commit checklist細節、Pencil domain procedure、可由ADR/local README擁有的architecture全文摘要。

### `docs/project_context.md`

保留：purpose、current architecture/capabilities/support boundaries、current active work。

刪除：Milestone 34～45 closure chronology與歷史 evidence summary。歷史改由 milestone/audit/CHANGELOG index路由。

### `docs/roadmap.md`

目前相對健康；維持短 index。Closed section只需範圍與historical index link，不重述 current testing/governance contract。

### `docs/governance/development_workflow.md`

降為短 human overview。Skill registry若仍有 current operational value，可保留唯一 registry owner；source admission history、dated revalidation、長篇 adoption evidence應下沉到 historical/adoption evidence，不留在 current overview。

### Guides

Guide只保存 reusable operator procedure與user-facing examples。任何 classification、test retention、validation selection、architecture contract只摘要一小段並連 authority。

`agent_assisted_development_quick_start.md`應大幅縮短為入口/少量prompt patterns，不再維護整套治理摘要。

`how-to-add-feature.md`可保留 feature procedure，但重複的 architecture rule應轉成「decision point + authority link」，避免成為第二份 ADR/project-context。

## 7. File deletion / archive principle

不採「看到多就刪」；使用三個條件：

```txt
No unique current authority
+ No reusable operator value
+ Git/history/index already preserves traceability
→ delete or archive candidate
```

若文件只是 stable compatibility route，可保留小 stub；若 physical move成本高但已是history，先移出 current index/admission即可，不要求為了整潔大規模搬檔。

## 8. Quantitative guardrails

這次不以「刪除80%文件」作成功條件，避免複製Test portfolio reset的數字治理。

改用 admission/duplication metrics：

- Level 0 ordinary task：固定 fresh read目標 <= 3個repository authority files（不含 source/local task file）。
- Level 1/2：完成身份admission後，只額外載入 central routing + affected local authority；不得 unconditional讀 project_context/roadmap/history。
- central `SKILL.md`：目標 <= 約60行，且不複製reference完整矩陣；若無法達成，以單一responsibility而不是行數為最終判準。
- `docs/project_context.md`：0段 closed Milestone chronology。
- current workflow rule：只有1個 authoritative owner；其他位置最多一小段摘要+link。
- ordinary task不得因不存在 permanent tests而自動讀 testing history或跑full suite。

行數只作 drift signal，不作hard architecture oracle。

## 9. Validation strategy

本 Milestone主要是documentation/workflow governance；預設不新增 permanent tests。

最低充分驗證：

- docs checker / links / metadata。
- machine routing/checker若有修改，針對該tool執行focused fixture validation。
- fresh admission pressure：至少覆蓋 Level 0、Level 1、Level 2、architecture/milestone routing各一個案例，確認Agent只載入必要authority。
- duplicate-authority semantic review。
- holistic final review。

不得因本次是Level 4 governance就自動跑Flutter workspace full regression；只有production/tooling changed risk需要時才由planner選擇。

## 10. Non-goals / anti-regression

- 不建立新的「documentation inventory database」或龐大metadata schema來治理文件肥大。
- 不要求每份歷史文件補metadata、搬archive或重新review。
- 不建立per-file deletion manifest。
- 不把所有human guide轉machine rule。
- 不因縮短Skill而把必要security/release fail-closed gate刪除；應保留但按需route。
- 不把Project Context刪成無法理解project-wide current state；只移除history與duplicate workflow。

## 11. Design acceptance criteria

1. fresh ordinary admission不再固定讀取project_context與roadmap。
2. central Skill成為routing-first薄入口，references真正按需。
3. `docs/project_context.md`恢復current-only，不含closed Milestone journal。
4. workflow/test/validation/current-history規則各自只有一個current owner。
5. guides回到human procedure/examples，不成為parallel governance authority。
6. historical specs/plans/audits仍可追溯，但不參與ordinary admission。
7. docs checker/machine authority只保留可機械判定且有failure-prevention價值的規則。
8. implementation不新增per-task audit/test/document bureaucracy；Milestone只需要Plan + holistic final evidence。
