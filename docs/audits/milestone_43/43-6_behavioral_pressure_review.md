---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-43-task-43-6-consumer-governance
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Task 43-6 Consumer Governance & Behavioral Pressure Review

## Scope

把ADR-032接入future feature與Pencil implementation入口，並建立anti-monolith／anti-formalism雙向pressure。

## Test Authoring Decision

**Required**。本Task修改repository-local Skills與human routing；`tools/docs/test_presentation_responsibility_policy.py`作minimum direct owner，避免future drift移除ADR-032 routing或12個behavioral controls。

## Intended changes

- `starting-feature-work`在feature planning時顯式檢查Presentation responsibility。
- `implementing-pencil-flutter-design`在UI ownership後增加ADR-032 responsibility/state classification。
- Pencil `flutter-mapping.md`不再用`pages/`固定folder措辭冒充generic architecture。
- human `how-to-add-feature.md`補change reason/lifecycle/state escalation讀法。
- PTF-35～46覆蓋one-widget-one-file、Cubit inflation、local state、Shell/Dialog、ScrollController、AnimationController、`part`假拆、Design System over-promotion、private helpers、小Feature、新Skill膨脹與bounded extraction。

## Layer 1 — Focused review

### F-43-6-01 — 是否把ADR-032複製成新Skill

- Severity：P1 governance sprawl。
- Review：沒有新增`presentation-architecture` Skill；existing consumer Skills只保存entry/routing摘要並引用ADR-032。
- Result：PASS。

### F-43-6-02 — Pencil mapping是否仍綁死`pages/`／`widgets/`資料夾

- Severity：P1 formalism。
- Review：舊「`pages/`只做Page/View orchestration」已改為role-based contract；folder/class tree明確不是mandatory。
- Result：PASS。

### F-43-6-03 — 是否把UI state全部推進Cubit

- Severity：P1 state inflation。
- Review：State/Hook/Controller保留controller/focus/scroll/animation/expand-collapse/countdown；只有workflow transition、ordering、retry/failure/concurrency才升Cubit/Bloc。
- Result：PASS。

### F-43-6-04 — 是否只防monolith卻沒防碎檔

- Severity：P1 anti-formalism gap。
- Review：PTF-35、43、44、46明確保護cohesive private helpers、小Feature與related widgets共檔。
- Result：PASS。

## Behavioral pressure matrix

| Scenario | Expected disposition | Fresh review |
|---|---|---|
| PTF-35 one-widget-one-file | FAIL formalism | PASS |
| PTF-36 static screen Cubit | FAIL inflation | PASS |
| PTF-37 local expand/collapse | State/Hook local | PASS |
| PTF-38 Shell launcher/Dialog owner | split invocation vs surface owner | PASS |
| PTF-39 ScrollController + pagination Bloc | controller local / workflow Bloc | PASS |
| PTF-40 decorative AnimationController | component-local | PASS |
| PTF-41 handwritten `part` false split | FAIL | PASS |
| PTF-42 single-consumer DS promotion | FAIL | PASS |
| PTF-43 cohesive private helpers | same source allowed | PASS |
| PTF-44 small feature no standard folders | PASS without skeleton | PASS |
| PTF-45 new Presentation governance Skill | FAIL sprawl | PASS |
| PTF-46 bounded related status surfaces | feature-local shared file allowed | PASS |

## Machine policy validation

Fresh commands：

```txt
python -m unittest \
  tools.docs.test_presentation_responsibility_policy \
  tools.docs.test_pencil_representation_mapping_policy
→ 14 tests PASS

dart run melos run docs_check
→ PASS
```

第一輪direct test只有fixture wording mismatch：test期待literal`not mandatory`，authority使用「不是mandatory」。修正test assertion後fresh rerun 14/14 PASS；沒有為了測試改寫policy語意。

Completion commit range machine plan：

```txt
python tools/ci/validation_planner.py \
  --event push \
  --base fbcb3e322ef5a595194078add0c0e52f349f3434 \
  --head 3440d645c1456572787dfecb18e3a53c8d9b8e5f \
  --stdout-json

validation_level = focused
change_classes = docs_content, governance, test_only
fail_safe = false
python_test_scopes = tools/docs, tools/docs/test_presentation_responsibility_policy.py
```

`unittest discover -s tools/docs`因`tools/docs`不是importable start package而無法discover；沒有把0 tests當PASS。改以planner scope中所有`tools.docs.test_*` modules明確執行：

```txt
97 tests PASS
docs_check PASS
```

## Layer 2 — Whole-Task review

ADR-032現在能由一般feature入口、Pencil入口與human guide discover；12個pressure scenarios同時覆蓋monolith與formalism兩端。Central `governing-template-development`沒有修改，因fresh routing證明existing Level 4 admission已能找到ADR/consumer authority，不需要增加中央Skill負擔。

```txt
Task 43-6: accepted
Open P0: 0
Open P1 without disposition: 0
```

