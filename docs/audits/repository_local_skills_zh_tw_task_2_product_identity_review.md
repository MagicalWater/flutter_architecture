---
document_type: phase-review
status: completed
authoritative_for:
  - repository-local-skills-zh-tw-task-2-product-identity-review
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 中文化治理恢復 Task 2 — 產品識別 Skill Review

## Task scope

審查 `adopting-template-product-identity` 的 Skill core、R1～R10、API-only non-trigger與behavioral evidence rule，確認繁體中文化沒有改變trigger、input、authority、安全與evidence contract，並修正與current `Approved` status不一致的歷史文字。

## Review oracle

- 中文化前版本：`7418a60`。
- Approved Design／Plan與Task 1～6 evidence。
- Behavioral approval closure：`docs/audits/adopting_template_product_identity_behavioral_pressure_evidence.md`。
- Current registry：`docs/governance/development_workflow.md`，status `Approved`。

## Focused findings

### F-T2-01 — Pressure rule 固定輸出過期 restricted Pilot status

- Severity：P1。
- Finding：`pressure-scenarios.md`在「無獨立context」情況下固定要求記錄`Pilot status: Approved with restrictions`，但Skill已於後續fresh isolated evidence closure升級為`Approved`。
- Risk：未來單次runtime缺少fresh context時，Agent可能把current registry status錯誤降回restricted Pilot，形成pressure reference與registry平行authority。
- Fix：改為只記錄本次revalidation的evidence boundary；Skill status保留current registry value，且本次run不得宣稱新的behavioral evidence。加入正式approval evidence與closure review路由。
- Fresh re-review：pressure protocol不再寫死歷史status，registry仍是current status authority。

## Semantic equivalence review

### Trigger／non-trigger

- Positive trigger仍只包含完整跨Android／iOS product identity與三環境display-name mapping。
- Visual-only、API-only、bounded single-platform repair、environment architecture、signing與Store工作仍不是自動trigger。
- Skill仍要求先完成中央Requirement Decision。

### Input and mutation gates

- Discussion／inventory only不允許mutation。
- Identity mutation仍要求明確base identifier與三環境display names。
- Real API build／runtime scope仍要求有效staging／production domains。
- 缺少domains時evidence維持`Pending`，不得用template placeholder冒充。

### Safety and authority

- Tracked secrets、keystore、private key、Apple certificate、provisioning、service-account secret與API token仍禁止寫入repository。
- Manifest-first、pre-existing drift disposition與Guide exact-command authority保留。
- Windows-only仍不得宣稱iOS Xcode build通過。
- Skill不得自行分類、核准Design／Plan、接受Task、修改environment contract、承擔signing或宣稱Store readiness。

### Pressure coverage

- R1 Discovery。
- R2 explicit shortcut／skip-governance。
- R3 discussion-only。
- R4 missing base identifier。
- R5 secret safety。
- R6 environment collision。
- R7 scope escalation。
- R8 pre-existing drift。
- R9 platform honesty。
- R10 authority conflict。
- API-only non-trigger。

全部scenario的trigger、central behavior、Skill behavior、forbidden behavior與evidence intent均與中文化前版本等價。

## Whole-Task authority review

- `governing-template-development`仍是classification／approval owner。
- Native Adoption Guide仍是完整procedure與exact-command authority。
- ADR-014、ADR-025、manifest、source、tests與runtime evidence優先於Skill。
- Approval closure audits只保存evidence，不取代registry current status。

## Fresh validation

```txt
Skill name                                      unchanged
Positive trigger                               preserved
Non-trigger controls                           preserved
Pressure scenarios                             R1–R10 + API-only
Secret／signing hard stops                      preserved
Evidence states                                preserved
Current registry status                        Approved
Hard-coded restricted Pilot status             removed
Relative evidence links                        resolved
```

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。

## Task disposition

```txt
Task 2：Passed after fix and fresh re-review
Product identity Skill status：Approved
Next：Task 3 — Starting Feature Work Skill Review
```
