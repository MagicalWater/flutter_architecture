---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-corrective-c1-single-renderer-governance-review
last_reviewed_baseline: 1.15.0
---

# Milestone 33 Corrective — C1 Single-Renderer Governance Contract Review

## Scope

本review涵蓋ADR-028、`implementing-pencil-flutter-design`的Flutter mapping／visual validation／pressure scenarios，以及人類Pencil-to-Flutter Guide。目標是把2026-08-07 runtime人工P1正式轉成stable治理規則；本Task不修改Flutter production source、visual reference或`.pen`。

## Superseding Finding

使用者直接驗收BlueStacks runtime後判定畫面與accepted `.pen`差異過大。該finding撤銷舊`visual_validation/review.md`中的`Android renderer differences: PASS`與33-12依賴該結論的完整workflow capability disposition。歷史文件與1.15.0 release evidence保留，不改寫Git history；current workflow進入corrective remediation。

Root cause已確認為：

```txt
941 × 1672 canonical branch
→ exact WritePrecheckCanonicalCanvas

360 × 640 runtime branch
→ separate responsive whole-screen tree
```

`941`被錯誤當成Flutter logical breakpoint，使canonical fidelity與runtime layout health各自GREEN，但使用者真正看到的renderer沒有受同一fidelity contract約束。

## TDD Evidence

先新增`tools/docs/test_pencil_single_renderer_policy.py`，只讀既有policy owners並要求五項semantic markers：

1. canonical viewport是design/comparison space，不是Flutter logical breakpoint。
2. parallel whole-screen visual renderer禁止。
3. runtime no-overflow是layout health，不是fidelity。
4. supported runtime需要visual fidelity evidence。
5. top-level `FittedBox`／`Transform.scale`仍禁止。

Fresh RED：

```txt
python -m unittest tools.docs.test_pencil_single_renderer_policy
→ 5 tests, 5 failures

dart run melos run docs_check
→ PASS
```

Failures全部來自current owners缺少corrective semantics，不是test fixture或docs結構錯誤。

## Focused Findings

### F-33-C1-01 — Canonical export size沒有明確design-space語意

- Severity：P1。
- Status：Resolved。
- Fix：ADR與mapping明定canonical viewport是design/comparison space，禁止解讀為Flutter logical breakpoint。

### F-33-C1-02 — Parallel renderer沒有被治理層禁止

- Severity：P1。
- Status：Resolved。
- Fix：一個accepted screen只允許一套whole-screen visual tree；breakpoint只能改component-level policy。

### F-33-C1-03 — Layout health被錯當runtime fidelity

- Severity：P1。
- Status：Resolved。
- Fix：scroll／no-overflow／semantics／touch target降回layout-health責任；supported runtime新增visual fidelity evidence hard rule。

### F-33-C1-04 — 「等比例」可能被合理化成整頁縮放

- Severity：P1。
- Status：Resolved。
- Fix：允許真Flutter widget geometry使用shared design scale；top-level `FittedBox`／`Transform.scale`／raster embedding仍明確禁止。

## Focused Re-review

- ADR、Skill references與Guide使用同一stable boundary，沒有建立第二policy owner。
- Design System／Theme／asset mapping order保持不變；corrective只要求canonical/runtime共享相同owners與components。
- Derived runtime reference只作evidence，不升格為`.pen` authority。
- Semantic P1可以撤銷automated PASS；automation不能再次自行接受使用者看不到的renderer。
- Pressure scenarios新增parallel renderer與layout-health substitution兩個shortcut case。

## Validation

C1完成後fresh執行：

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
python -m unittest tools.docs.test_pencil_single_renderer_policy
dart run melos run docs_check
git diff --check
```

Fresh final results：

```txt
python -m unittest \
  tools.docs.test_skill_lock \
  tools.docs.test_check_docs \
  tools.docs.test_pencil_single_renderer_policy
→ 41 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed
```

Focused re-review確認：policy regression test只讀既有owners，沒有建立平行policy authority；ADR／Skill／Guide對single renderer、design-space、runtime fidelity與anti-cheat wording一致。

## Disposition

```txt
Focused review: PASSED
Fresh focused re-review: PASSED
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
Next after independent commit: C2 fixed runtime projection reference + intentional RED gates
```
