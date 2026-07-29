---
document_type: planning-review
status: completed
authoritative_for:
  - adopting-template-product-identity-design-task-review
last_reviewed_baseline: 1.13.0
---

# Adopting Template Product Identity Skill Design Review

## Review purpose

本文件補齊`adopting-template-product-identity` Design Spec的Level 3 Full two-layer Task gate。原始Spec已完成四段互動式Design section approval與文件自我審查，但在focused review、findings disposition、fresh re-review與whole-Task review完成前即標記為`accepted`並提交，因此不能視為完整Design Task通過。

本review保留原commit歷史，不改寫當時狀態；current artifacts以本次修正與後續使用者明確核准為準。

## Review scope

- `docs/superpowers/specs/2026-07-29-adopting-template-product-identity-skill-design.md`
- `AGENTS.md`
- `.agents/skills/governing-template-development/SKILL.md`
- `.agents/skills/governing-template-development/references/work-classification.md`
- `.agents/skills/governing-template-development/references/artifact-routing.md`
- `.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- `.agents/skills/governing-template-development/references/skill-adoption-governance.md`
- `docs/governance/development_workflow.md`
- `docs/guides/native_environment_adoption.md`
- ADR-014與ADR-025
- `apps/flutter_architecture/config/environments.json`
- `tools/ci/verify_environment_contract.py`
- `tools/ci/test_environment_contract.py`

## Classification review

Level 3維持合理。

- 此工作新增一個跨Android、iOS、Dart environment、verification與文件路由的repository-local Skill，並需要中央治理的narrow routing與registry同步，因此高於單一文件或局部helper。
- Skill是optional domain shortcut，不改變`AGENTS.md`強制入口、Level matrix、artifact ownership、approval、Task、release或closure authority，因此尚不足以升為Level 4 repository-wide governance replacement。
- Worktree、formal Design／Plan、Full Task governance與affected validation均為必要。

## Focused review findings

### P1 — Design status prematurely marked accepted

- Finding：Spec在完整Design Task gate與使用者對落檔版本明確核准前，frontmatter已標記`status: accepted`。
- Impact：違反`Design proposed → full Design Task gate → user approval → Design accepted`的唯一合法狀態轉換，並可能錯誤允許`writing-plans`提前開始。
- Fix：frontmatter降回`proposed`；Approval段落明確區分Section approval、書面Task review與最終user approval。
- Fresh re-review：Current Spec不再宣稱Design已正式接受，Implementation Plan仍被禁止。

### P1 — Full-mutation input gate under-specified

- Finding：Spec只將base identifier列為不可推導的必要輸入，但完整產品identity mutation同樣需要明確確認三環境display names；若acceptance包含staging／production real API build或runtime evidence，也需要有效API domains。
- Impact：Agent可能在display name未確認時先修改projection，或以template placeholder執行real API驗證並錯誤宣稱完成。
- Fix：新增full-mutation gate。Display names必須由使用者明確確認；產品名稱只能產生候選值。缺少API domains時，只允許identity projection與static verification，相關build／runtime evidence標記`Pending`。
- Fresh re-review：Input contract現在能區分只讀盤點、identity mutation與real API runtime closure。

### P1 — Validation matrix could be mistaken for the full native adoption suite

- Finding：Spec列出的contract tests比`native_environment_adoption.md`的完整command authority更短，但未明示這只是Skill adoption最低驗證。
- Impact：Agent可能跳過environment workflow matrix、local build command、iOS workflow與shell portability contract tests，形成Spec取代Guide的第二份縮減版authority。
- Fix：明示Spec清單只屬Skill adoption與文件治理最低驗證；真正產品identity mutation必須使用Guide current command authority，Skill與Spec不得複製或縮減。
- Fresh re-review：Guide保持完整procedure與command authority；Spec只保存routing與acceptance boundary。

## Focused re-review

修正後逐項重驗：

- Requirement Decision欄位完整，Level 3、Pilot／Approved with restrictions與non-goals一致。
- Thin Skill不複製Guide、ADR、manifest或verification mapping。
- Positive trigger、non-trigger與scope escalation可區分完整採用、bounded repair與architecture change。
- Base identifier、display names與API domains的mutation／evidence gate明確。
- Secret、signing、Store distribution、environment contract與platform evidence邊界明確。
- `governing-template-development`仍是唯一classification、approval與Task owner。
- `AGENTS.md`、root README、VERSION、CHANGELOG、roadmap與Milestone artifacts維持不變。
- Design仍為`proposed`，不允許Implementation Plan或implementation提前開始。

## Whole-Task holistic review

### Architecture and authority

- ADR-014仍擁有Dart-level environment與API mode authority。
- ADR-025與`environments.json`仍擁有cross-platform identity mapping contract。
- `native_environment_adoption.md`仍擁有完整adoption procedure與exact verification commands。
- 新Skill只負責trigger、input boundary、required reading、manifest-first routing、安全停止條件與evidence classification。
- Audit只保存finding與review evidence，不成為current architecture或workflow authority。

### Workflow ordering

```txt
Requirement Decision accepted
→ interactive Design sections approved
→ written Spec proposed
→ focused review and fixes
→ fresh re-review
→ whole-Task review
→ explicit user approval
→ Design accepted
→ writing-plans
```

此ordering與Full two-layer Task governance一致。Current next gate是使用者對修正後書面Spec的明確核准。

### Scope and rollback

- 不建立新Milestone。
- 不建立automation script。
- 不修改`AGENTS.md`。
- Implementation預計只新增thin Skill、pressure scenarios、narrow central routing、registry與Guide entry。
- Rollback可移除Skill及wiring，不影響ADR、manifest、Guide或中央治理。

### Pressure and evidence

Design已要求discovery、explicit shortcut、discussion-only、missing input、secret、contract conflict、scope escalation、existing drift、Windows-only platform evidence與authority conflict案例。Static scenario presence不等於GREEN；Plan必須先做RED baseline並保存runtime evidence。

## Documentation authority check

- Spec擁有proposed behavioral與technical design。
- 本Audit擁有Design Task findings、fix與review evidence。
- Guide擁有adoption操作與current commands。
- ADR與manifest擁有stable architecture與mapping authority。
- Source、tests與build artifacts擁有runtime truth。
- 未新增重複current-state或release authority。

## Validation evidence

Windows Flutter toolchain已依repository SDK constraint升級：

```txt
Flutter 3.44.8 stable
Dart 3.12.2
```

Fresh validation：

```txt
python tools/ci/verify_environment_contract.py              passed
python -m unittest tools.ci.test_environment_contract      9 passed
dart run melos run docs_check                         passed
python -m unittest tools.docs.test_check_docs         17 passed
git diff --check                                      passed
```

`flutter doctor`唯一warning是Windows desktop的Visual Studio C++ components不足；本Design Task是文件與Skill治理工作，不宣稱Windows desktop build evidence，因此此warning不阻塞本Task。Android toolchain、Chrome、connected devices與network resources均通過doctor檢查。

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。
- Design status：`proposed`，等待使用者對修正後書面Spec明確核准。
- Implementation Plan：forbidden until Design becomes `accepted`。
- Implementation：not started。

## Conclusion

Design內容已完成focused review、findings修正、fresh re-review、whole-Task holistic review、authority check與fresh validation。雙層Task治理的repository review層已補齊；最後的user-owned acceptance gate仍未完成。使用者明確核准本次修正後書面Spec後，才可將Design轉為`accepted`並進入Implementation Plan Task。
