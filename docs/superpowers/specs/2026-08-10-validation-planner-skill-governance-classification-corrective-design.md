---
document_type: design-spec
status: accepted
authoritative_for:
  - validation-planner-skill-governance-classification-corrective-design
last_reviewed_baseline: 1.16.0
---

# Validation Planner — Skill Governance Path Classification Corrective Design

## 1. Purpose

修正Milestone 35 canonical change classification的Skill governance coverage，使repository-owned validation planner對所有受管理Skill surface執行Minimum Sufficient Validation，而不改變既有change-class taxonomy、unknown fail-safe或Skill adoption authority。

本工作是既有validation governance的corrective，不是新的Milestone 35 redesign。

## 2. Existing authority

Current stable authority：

1. `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`：`change_classifier.py`擁有canonical change classes，`validation_planner.py`是唯一validation selection machine authority；unknown／invalid／engine failure必須full fail-safe。
2. Milestone 35 accepted Design：`governance` class的例子明確包含`AGENTS.md`、governance Skill／references、testing／CI Guide，default intent為docs checks＋對應governance／policy contracts。
3. `.agents/skills/governing-template-development/references/skill-adoption-governance.md`：repository-authored Skill、third-party-unmodified Skill、lock／registry、upgrade與pressure review皆屬repository governance surface。
4. `docs/governance/development_workflow.md`：Adopted Skill registry保存trigger、responsibility、forbidden responsibility、permissions、upgrade與rollback；`skills-lock.json`保存third-party provenance／integrity。

因此Design不得新增平行Skill authority，也不得讓classifier解析自然語言Skill semantics。

## 3. Confirmed gap

Current `_is_governance_path()`只辨識：

```text
AGENTS.md
.agents/skills/governing-template-development/**
selected governance/testing/CI Guides
```

但repository目前另有受管理Skills：

```text
.agents/skills/starting-feature-work/**
.agents/skills/adopting-template-product-identity/**
.agents/skills/karpathy-guidelines/**
.agents/skills/implementing-pencil-flutter-design/**
.agents/skills/brandkit/**
.agents/skills/high-end-visual-design/**
.agents/skills/imagegen-frontend-mobile/**
```

其中repository-authored Skills的trigger／workflow／managed paths變更依Skill adoption policy可能要求專屬machine contracts與fresh behavioral review；third-party-unmodified Skills又受exact hash／license lock約束。將它們只視為普通`docs_content`會漏掉`tools/docs` contract suite。

另一方面，`skills-lock.json`與`third_party/skills/**`目前是`unknown`，因此只要修改lock或vendored license就完整升級Flutter、generated、Android與iOS矩陣，與其實際治理風險不成比例。

## 4. Design decision

### 4.1 Reuse existing `governance` class

不新增`skill_governance`、`skill_lock`或其他change class。

以下repository-managed path families全部分類為既有`governance`：

```text
.agents/skills/**
skills-lock.json
third_party/skills/**
```

理由：三者共同影響Agent workflow／Skill provenance／governance contracts；existing `governance` validation intent已正確提供docs check＋`tools/docs` tests。

### 4.2 Preserve generic unknown fail-safe

只有上述明確managed roots取得known classification。其他新root、未辨識binary/config或classification failure仍必須：

```text
unknown
→ validation_level=full
→ fail_safe=true
→ full regression + generated + Android + iOS
```

不得以「所有hidden files」、「所有third_party」或「所有JSON」之類寬泛規則降低unknown protection。

### 4.3 Third-party integrity remains lock-owned

Classifier只判斷path risk class，不判斷third-party bytes是否正確。

當`.agents/skills/brandkit/SKILL.md`、其他locked Skill bytes、`skills-lock.json`或locked license改變時：

```text
governance classification
→ docs_check
→ tools/docs Skill lock contracts
→ inspect_skill_lock exact hash / license / install-path validation
```

Hash drift、missing file、path escape、duplicate install path、invalid commit、license drift等仍由`tools/docs/skill_lock.py`fail closed。Classifier不得重複實作hash／schema authority。

### 4.4 Machine validation does not replace behavioral pressure review

`governance` classification只保證machine contract selection。

若repository-authored Skill實際修改：

- trigger wording；
- permissions；
- managed files；
- workflow ordering；
- automatic loading／routing；
- review／commit behavior；
- representation／visual acceptance contract；

中央`governing-template-development`仍須依Skill adoption governance決定是否需要fresh pressure scenarios／isolated behavioral evidence。Planner不得嘗試從diff文字自行推斷這些語意。

## 5. Validation behavior

### Repository-authored Skill change

Example：

```text
.agents/skills/implementing-pencil-flutter-design/SKILL.md
```

Expected plan：

```text
change_classes = [governance]
validation_level = focused
docs_check = true
python_test_scopes = [tools/docs]
flutter_test_scopes = []
android_build = false
ios_build = false
full_regression = false
fail_safe = false
```

Semantic workflow review may still require fresh behavioral evidence outside planner machine execution.

### Third-party locked Skill change

Example：

```text
.agents/skills/brandkit/SKILL.md
```

Expected machine plan與上方一致；若bytes未同步lock，docs／lock validation必須FAIL，而不是透過full Flutter regression取得虛假安全感。

### Skill lock change

Example：

```text
skills-lock.json
```

Expected：`governance` focused machine validation，執行Skill lock tests；不自動Android／iOS build。

### Vendored Skill provenance change

Example：

```text
third_party/skills/taste-skill/LICENSE
```

Expected：`governance` focused machine validation；license/hash contract負責接受或拒絕。

### Mixed Skill + ordinary docs

Example：

```text
.agents/skills/implementing-pencil-flutter-design/SKILL.md
docs/guides/pencil_to_flutter_workflow.md
```

Expected ordered class set：

```text
[docs_content, governance]
```

Planner採union，仍執行governance machine contracts，不升級Flutter/platform validation。

### Unknown negative control

Example：

```text
.agent-runtime/new-policy.bin
```

Expected：`unknown → full fail-safe`。

## 6. Test contract

Implementation至少加入以下classifier／planner regression cases：

1. repository-authored Skill `SKILL.md` → `governance`。
2. repository-authored Skill `references/*.md` → `governance`。
3. third-party locked Skill → `governance`。
4. `skills-lock.json` → `governance`。
5. `third_party/skills/**` → `governance`。
6. Skill＋ordinary docs mixed set → deterministic `(docs_content, governance)`。
7. governance plan包含`tools/docs`且不包含Flutter/platform scopes。
8. locked Skill hash drift仍由docs/lock tests fail closed。
9. unknown negative control仍full fail-safe。
10. invalid range與validation-engine self-change semantics完全不變。

不得把expected tests改成「所有`.agents`都是known」；scope只接受`.agents/skills/**`。

## 7. Implementation boundary

Expected production mutation保持狹窄：

```text
tools/ci/change_classifier.py
tools/ci/test_change_classifier.py
tools/ci/test_validation_planner.py
```

只有測試證明runner／docs contract有缺口時才允許擴至：

```text
tools/ci/validation_planner.py
tools/ci/validation_runner.py
tools/docs/**
```

目前Design沒有證據要求修改上述consumer，因此Plan應先以classifier-only production fix為預設。

## 8. Documentation authority

ADR-023與Milestone 35 Design已擁有stable semantics，不新增ADR。

若implementation只讓current code符合既有文字，`docs/governance/development_workflow.md`與`docs/guides/testing_governance.md`不需重複增加path matrix；必要時只做最小authority clarification。Exact path routing仍只由classifier/tests擁有。

## 9. Acceptance criteria

Design成功條件：

1. `.agents/skills/**`、`skills-lock.json`與`third_party/skills/**`不再落入普通docs或unknown。
2. Skill governance變更會執行`tools/docs` machine contracts。
3. third-party integrity仍由existing lock contractfail closed。
4. ordinary Skill governance change不執行Flutter tests、generated或Android／iOS build，除非change set另含更高風險class。
5. unknown／invalid／validation-engine self-change full fail-safe完全保留。
6. Planner不承擔fresh behavioral pressure review的語意判斷。
7. 不新增change class、ADR、Milestone或平行selection engine。

## 10. Rollback

若implementation證明`governance` class無法安全承載Skill path，回退classifier/test mutation並維持current conservative behavior；重新開Requirement Decision評估新的change class。不得以移除unknown fail-safe作rollback shortcut。

## 11. Status

**ACCEPTED — 2026-08-10使用者明確核准。**

可建立Implementation Plan；Plan在完成完整Task governance並取得使用者核准前不得開始implementation或建立managed implementation worktree。
