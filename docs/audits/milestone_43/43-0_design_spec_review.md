---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-43-presentation-component-architecture-design-review
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Design Spec Review

## Review scope

本Task review `docs/superpowers/specs/2026-08-18-milestone-43-presentation-component-architecture-design.md` 是否完整覆蓋Requirement提出的十五類Presentation architecture問題，並同時防止兩個相反失敗模式：

```txt
Presentation monolith
vs
one-class-one-file / Cubit-everything / fixed-folder formalism
```

Review以current production source、ADR-003／007／018／021／028、Milestone 42 closure evidence、`starting-feature-work`、Pencil workflow與current docs authority為基準。

## Layer 1 — Focused design review

### F-43-D-01 — Role model是否退化成class taxonomy

- Severity：P1 if violated。
- Review：Design明確把Page/View/Section/Component/Surface/Layout定義為responsibility roles，允許小型Page直接render、Page+View同檔、同responsibility private helpers同檔。
- Result：PASS。

### F-43-D-02 — `one file / compilation unit`措辭混淆Dart library boundary

- Severity：P1 architecture ambiguity。
- Finding：Initial draft把`one file / compilation unit`並列，容易誤解Dart `part` library與physical file是同一治理單位。
- Fix：改為`one handwritten source file = one coherent primary responsibility`，另要求跨`part`的整個library也不得混合independent architectural owners；generated source維持既有例外。
- Fresh re-review：PASS。

### F-43-D-03 — Machine rule是否偷偷要求`pages/`固定folder

- Severity：P1 formalism regression。
- Finding：Initial draft以`presentation/pages/`作general hard-rule wording，與「不固定folder skeleton」衝突。
- Fix：改成「已宣告為Page/View orchestration owner的source」不得直接宣告custom RenderObject infrastructure；`presentation/pages/`只作current reference evidence，repository-wide checker不得要求該folder存在。
- Fresh re-review：PASS。

### F-43-D-04 — 是否新增不必要的Presentation governance Skill

- Severity：P1 governance proliferation。
- Finding：Requirement要求評估governance Skill，但Initial draft只列consumer Skills，沒有明確回答是否新增Skill或修改central governance。
- Fix：Design明確決策不新增`presentation-architecture` Skill；`governing-template-development`既有Level 4 routing足夠，預設不修改其classification/approval contract。主要consumer是`starting-feature-work`與`implementing-pencil-flutter-design`；只有fresh discovery evidence證明central route無法找到authority時才做minimal routing amendment。
- Fresh re-review：PASS。

### F-43-D-05 — Page / View boundary是否過度薄型化

- Severity：P1 fragmentation risk。
- Review：Design允許小型Page直接render，也允許Page+View同檔；只有state binding/test seam/independent responsibility成立才需要拆。
- Result：PASS。

### F-43-D-06 — Dialog / BottomSheet / Overlay ownership是否完整

- Severity：P1 owner ambiguity。
- Review：Design分離invocation/orchestration owner與surface implementation owner；current Shell launch Theme/Locale/Auth surfaces作positive pattern，同時允許真正single-screen、同change-reason surface保留private helper，不強制`dialogs/`folder。
- Result：PASS。

### F-43-D-07 — Shell / navigation是否與ADR-007／021衝突

- Severity：P1 cross-feature dependency regression。
- Review：Shell可擁有tab route composition、chrome與shell-owned destination identity，但child feature不得import ShellTab/index；跨feature lifecycle/navigation仍由App coordinator/router/stable authority處理。
- Result：PASS。

### F-43-D-08 — Layout / RenderObject owner是否只是搬資料夾

- Severity：P1 false decomposition。
- Review：Design要求layout owner有scope/invariants/regression，並明確把handwritten `part`列為不能假拆owner的escape hatch。Current Pencil projection owner必須在implementation重新評估normal library boundary。
- Result：PASS。

### F-43-D-09 — Bloc / Cubit escalation是否造成Cubit-everything

- Severity：P1 over-state-management。
- Review：Design以workflow transitions、async ordering、failure/concurrency、shared lifecycle與deterministic behavior作升級訊號；TextEditing/Focus/Scroll/Animation/Tab controller、hover、expand/collapse與presentation countdown預設local。`OtpView`與Catalog ScrollController被列為positive no-escalation examples。
- Result：PASS。

### F-43-D-10 — Local controller是否變成新的`controllers/`垃圾桶

- Severity：P1 responsibility drift。
- Review：Local controller只處理複雜UI mechanics，不得持有Repository/UseCase side effects，owner必須靠近surface/section/layout；不要求`controllers/`folder。
- Result：PASS。

### F-43-D-11 — Private helper class界線是否可操作

- Severity：P1 ambiguity。
- Review：Design同時給出合法helpers條件與extract signals，且明確排除line/class count、future reuse與folder symmetry作唯一理由。
- Result：PASS。

### F-43-D-12 — Design System promotion是否重複Milestone 42

- Severity：P1 parallel authority。
- Review：Design只引用ADR-018/Milestone 42的semantic identity/stable API/consumer evidence；沒有重新發明token owner或asset provenance contract。
- Result：PASS。

### F-43-D-13 — 是否只修Pencil reference

- Severity：P1 scope miss。
- Review：Reference adoption同時選Pencil compatibility與ordinary Catalog；OTP/Shell則作positive no-refactor cases。Architecture authority本身不依賴Pencil。
- Result：PASS。

### F-43-D-14 — Machine enforcement是否承擔無法可靠判定的semantic cohesion

- Severity：P1 false-positive governance。
- Review：Machine只負責high-confidence invariants；change-reason、state escalation與cohesion edge cases由structured review + fresh pressure scenarios承擔。沒有line-count/class-count/folder/setState/Bloc-presence lint。
- Result：PASS。

### F-43-D-15 — Active current-state authority同步是否一致

- Severity：P1 documentation authority drift。
- Finding：Milestone promotion後`project_context.md`一度仍保留`Maintenance mode: Available for new Requirement Decision`。
- Fix：同步為active architecture planning，並明確production implementation仍被Design/Plan approval阻擋；roadmap index/active/candidates、audit/spec indexes均route Milestone 43 current artifacts。
- Fresh re-review：PASS。

## Layer 2 — Whole-Design traceability review

Requirement十五項與Design對應：

| Requirement | Design owner | Review |
|---|---|---|
| 1. Page/View/Section/Component | §3 | PASS |
| 2. Dialog/BottomSheet/Overlay | §3.5 | PASS |
| 3. shell/tab/navigation orchestration | §4 | PASS |
| 4. layout/projection/RenderObject/geometry | §5 | PASS |
| 5. Bloc/Cubit state責任 | §6.1 | PASS |
| 6. animation/scroll/tab/focus/expand ephemeral state | §6.2 | PASS |
| 7. local/Hook/controller vs Bloc/Cubit escalation | §6.3–6.4 | PASS |
| 8. compilation unit/file cohesion | §2.2、§7 | PASS |
| 9. one coherent primary responsibility | §2.2、§7 | PASS |
| 10. private helper class | §7.1–7.3 | PASS |
| 11. feature-local→Design System promotion | §8 | PASS |
| 12. Milestone 42銜接 | §10 | PASS |
| 13. machine/review detector/pressure | §13 | PASS |
| 14. ordinary Flutter feature applicability | §12.2–12.4 | PASS |
| 15. AGENTS/guide/ADR/Skills/checks | §11、§13 | PASS |

Cross-authority consistency：

```txt
ADR-003
→ business/workflow state vs UI-local lifecycle preserved

ADR-007 / ADR-021
→ cross-feature navigation/state boundary preserved

ADR-018 / Milestone 42
→ Design System / UI Design Ownership preserved

ADR-028
→ Pencil becomes a consumer of general Presentation authority, not its owner
```

Reference adoption scope也同時提供：

```txt
needs decomposition
→ Pencil content/projection
→ Catalog ordinary feature

must not be over-refactored
→ OTP local countdown
→ Shell launcher/surface-owner split
```

因此Design不只會攔「塞太多」，也能攔「拆太多／上太多Cubit」。

## Validation evidence

Design drafting期間fresh validation：

```txt
dart run melos run docs_check
```

Initial run曾因Requirement artifact使用unsupported `document_type: requirement-decision`失敗；已依current metadata contract改為`planning-review`。

第二次run在本review artifact尚未建立時，因`docs/audits/README.md`已先引用`43-0_design_spec_review.md`而報broken-link。此finding由建立本artifact收斂，final fresh run必須GREEN後本Design review才能完成。

`git diff --check`在Design/index/current-state changes上已PASS。

## Final design review disposition

Focused findings均已修正並fresh re-review。Whole-Design traceability沒有Open scope gap。

Open P0：0。

Open P1 without disposition：0。

Final fresh validation：

```txt
dart run melos run docs_check
→ PASS

git diff --check
→ PASS
```

Design Task review：**PASS**。

## Approval gate

2026-08-18 使用者已明確核准本Design。

- Design frontmatter已轉為`accepted`；
- Design approval gate：PASS；
- 現在允許進入Implementation Plan建立與Plan雙層治理；
- ADR-032、production source與machine detector仍不得在Plan核准前開始implementation。

