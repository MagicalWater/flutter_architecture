---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-35-corrective-design
last_reviewed_baseline: 1.15.2
---

# Milestone 35 — Test Execution Cost & Change-Aware Validation Governance Corrective Design

## 1. Purpose

本Design修正repository目前的over-validation，而不是縮減coverage。

目標是建立一個由repository擁有、machine-readable、deterministic、reviewable且fail-safe的Minimum Sufficient Validation模型，使一次變更依風險由小到大選擇：

```txt
focused
→ affected
→ boundary / affected workspace
→ full
→ release
```

雙層Task治理、Clean Architecture、unknown-path fail-safe與release full regression全部保留。

## 2. Requirement authority

Formal Requirement Decision：

- `docs/audits/milestone_35/35-r_requirement_decision.md`

Admission evidence：

- `docs/audits/milestone_35/35-0_test_execution_cost_admission_audit.md`

Classification：Level 4 — Architecture／Milestone。

## 3. Problem statement

Current repository存在三個互相放大的drift：

1. `tools/ci/change_classifier.py`主要只區分documentation-only與其他change，導致普通App／package source接近full CI，並常直接要求Android＋iOS build。
2. `tools/testing/inventory.py`對絕大多數current tests輸出Tier 1，與Testing Governance的Tier 1～5語意失配，因此execution tier沒有足夠routing value。
3. `AGENTS.md`與部分Guides把full workspace Flutter tests寫成一般commit／feature固定步驟，讓Agent傾向把「required validation」保守解讀為full regression。

雙層Task治理會重複觸發review與validation gate，因此會放大錯誤selection，但不是root cause。

## 4. Design options considered

### Option A — Shared deterministic validation planner（採用）

建立單一repository-owned machine routing core：changed paths先被分類為穩定change classes，再由validation planner產生validation profile與exact affected scopes。Local Agent、manual-local、self-hosted與github-hosted都消費同一plan contract。

優點：

- Selection authority只有一份。
- 可測試change classes、dependency propagation與fail-safe。
- Agent不用自行猜命令。
- CI不用把`full_ci`當成唯一heavy-work開關。
- 可逐步擴充，而不需一次建立大型test orchestration framework。

成本：需要調整classifier schema、workflow wiring、testing inventory metadata與Guides。

### Option B — 只擴充現有`change_classifier.py`

直接增加更多boolean，例如`run_app_tests`、`run_package_tests`、`run_generated`。

優點是改動較小；缺點是classifier同時承擔path classification、dependency reasoning與execution policy，boolean數量會快速膨脹，local Agent與CI仍容易形成不同解讀。

不採用。

### Option C — 建立完整test graph／impact-analysis framework

解析Dart imports、test-to-source links、coverage mapping並動態推導exact tests。

理論上粒度最高，但會新增高維護成本與新的correctness authority；目前163個test files、約34秒full Flutter regression不足以支持此複雜度。

不採用。

## 5. Authority model

### 5.1 Stable decision authority

既有ADR-023已擁有repository CI quality gates與change classification authority。本Milestone**修訂ADR-023，不新增平行ADR**。

ADR-023需補充：

- Minimum Sufficient Validation原則。
- change classes與validation profile的stable ownership。
- unknown／ambiguous fail-safe。
- full／release escalation不可被focused routing取代。
- local與CI必須共用machine planner contract。

### 5.2 Human policy authority

`docs/guides/testing_governance.md`繼續擁有test ownership、taxonomy、execution semantics與cleanup policy，但不再保存會與machine planner平行的硬編碼routing表。

`AGENTS.md`與操作Guides只能指向planner／validation level，不再無條件宣告每個commit都要full Flutter workspace regression。

### 5.3 Machine authority

Machine selection由兩層組成：

```txt
Changed paths
  ↓
Change classification
  ↓
Validation planning
  ↓
Exact validation profile / scopes / escalation reason
```

`change_classifier.py`只負責「變更是什麼」。新的validation planner負責「因此必須驗證什麼」。

不得讓GitHub workflow YAML、Guide或Agent prompt成為第二份selection engine。

## 6. Canonical change classes

Planner至少辨識以下classes；一個change set可同時具有多個class，最後採union並依最高風險升級：

| Change class | 例子 | Default validation intent |
|---|---|---|
| `docs_content` | 一般README、audit文字 | docs checks |
| `governance` | `AGENTS.md`、governance Skill／references、testing／CI Guide | docs checks＋對應governance／policy contracts |
| `tooling` | 非classifier的一般`tools/` | focused tool tests＋受影響contract |
| `test_only` | leaf test file | changed tests＋該owner必要fixture／contract |
| `app_feature` | `apps/.../lib/features/<feature>/` | feature tests＋App affected validation |
| `app_shared` | App router、DI、localization、shared app composition | affected App workspace regression |
| `package` | `packages/<name>/lib/` | package tests＋reverse-dependent affected workspaces |
| `generated` | generator inputs／tracked generated contract | generator consistency＋affected owner |
| `database` | Drift schema、DAO、migration、schema snapshots／DB tooling | database-focused＋affected App＋generated；platform escalation依artifact contract |
| `android_native` | Android runner／Gradle／manifest | Android native contracts＋Android build |
| `ios_native` | iOS runner／Pod／plist／Xcode config | iOS native contracts＋iOS build |
| `dependency` | root／workspace／package dependency manifest、lockfile | full affected dependency graph；不確定時full |
| `validation_engine` | classifier、planner、workflow wiring | planner contracts＋fail-safe full verification |
| `release` | `VERSION`、release identity | fresh full＋required platform／release gates |
| `unknown` | 未知path、invalid range、classification failure | fail-safe full matrix |

不能只依副檔名判斷風險；例如`AGENTS.md`不是一般docs-only，classifier本身也不是一般tooling。

## 7. Canonical validation levels

Validation level是風險語意，不是固定command alias。

### Focused

驗證直接被修改的owner或contract，例如changed test file、單一tool unit test、單一feature的narrow tests。

### Affected

驗證直接owner與明確受其影響的consumer。例如package source變更需要package tests，並依workspace dependency graph加入reverse dependents。

### Boundary / affected workspace

當變更碰到Composition Root、shared app infrastructure、cross-package contract、database lifecycle或其他跨owner boundary時，執行受影響workspace的完整regression，而不是整個repository自動full。

### Full

所有Flutter workspace tests、必要Python／docs／generated checks及由change class要求的平台驗證。適用於validation engine自身、dependency graph ambiguity、unknown path、holistic closure等。

### Release

Fresh full regression加release-required platform／artifact／post-release evidence。Release不得reuse中間Task的full evidence冒充fresh release gate。

## 8. Affected-scope resolution

### 8.1 Feature mapping

遵循既有Feature First目錄：

```txt
apps/flutter_architecture/lib/features/<feature>/...
→ apps/flutter_architecture/test/features/<feature>/...
```

若feature同時修改App router／DI／shared navigation等boundary，plan自動union至`app_shared`。

### 8.2 Package mapping

Planner使用repository workspace的pubspec dependency graph推導reverse dependents，不維護手寫「package A永遠影響package B」清單。

例如leaf package只跑自身與實際consumer；若`core`之類foundation package的reverse dependency closure涵蓋整個workspace，affected結果自然可等價full workspace，但理由是dependency graph，而不是package path一律full。

### 8.3 Test-only mapping

一般leaf test-only change先執行changed test file。若修改shared test helper、fixture authority、golden baseline infrastructure或test harness，必須提升至對應owner／workspace，而不是只跑單檔。

### 8.4 Tooling mapping

Tooling change優先跑其Python contract；只有validation engine、generated、database、artifact或platform tooling依自身class升級。`tools/`不再整體等價full CI。

## 9. Machine-readable plan contract

Validation planner輸出必須可供CLI、Agent與GitHub Actions一致消費，至少包含：

```txt
change_classes
validation_level
flutter_test_scopes
python_test_scopes
analyze_scopes
docs_check
generated_check
android_build
ios_build
full_regression
release_full
reason
fail_safe
```

Exact serialization格式可在Plan階段決定，但需符合：

- deterministic ordering；
- 同一changed path set產生同一plan；
- 不依network；
- 不依Agent自然語言判斷；
- unknown key／unknown path／planner exception fail closed；
- workflow只執行plan，不自行重寫routing logic。

## 10. Testing inventory alignment

`tools/testing/inventory.py`不再把幾乎所有Flutter tests標為Tier 1。

Execution tier需與Testing Governance一致：

- Tier 1：quick unit／Python／docs／inventory。
- Tier 2：feature／package Flutter regression與current integration。
- Tier 3：generated／schema／migration／rollback／Web asset consistency。
- Tier 4：native scaffold／platform build contract。
- Tier 5：device／remote hosted／post-release acceptance。

Inventory的tier是test／artifact自身的execution characteristic；validation planner的level是「本次變更需要升級到哪裡」。兩者相關但不可混成同一欄位。

若某test無法deterministically分類，inventory應標記`Unclassified`／issue並由governance test阻止靜默落入Tier 1。

## 11. CI routing

`.github/workflows/ci.yml`保留stable job names與execution-mode contract，但改為消費validation plan。

### Quality

只執行plan要求的docs／Python／analyze scope。Docs-only仍維持stable required check並做明確no-op／lightweight gate。

### Tests

不再只有`full_ci=true`才有兩種狀態。Tests job依plan執行focused／affected／workspace／full Flutter scopes。

### Generated Consistency

只在plan要求時執行；validation-engine fail-safe、dependency／database／generated classes可強制啟用。

### Android / iOS

普通Dart feature或package change不再自動雙平台build。Native、database artifact contract、dependency ambiguity、release或fail-safe才依plan要求平台build。

Stable check名稱與manual-local／self-hosted／github-hosted execution-mode boundary不得改壞。

## 12. Agent and local-development routing

Agent在每個Task不得自行從「我覺得這次改很小」推測tests。

正式流程改為：

```txt
Task mutation
→ planner on current diff / Task range
→ execute returned minimum sufficient validation
→ record exact plan + evidence
→ review / re-review
→ only rerun invalidated evidence
```

`AGENTS.md`與Feature／Quick Start Guide應描述這個流程；full workspace command仍保留作manual／holistic／release入口，不再是所有commit的固定minimum。

## 13. Evidence reuse and fresh rerun rules

### 13.1 Reuse allowed

同一formal Task內，一份GREEN evidence可在後續review gate重用，前提是：

1. plan identity相同；
2. 自該validation通過後，沒有修改其selected owner／boundary的source、tests、tooling、dependency、generated或native inputs；
3. review沒有新增會改變selection的P0／P1 finding。

只做不影響該validation boundary的review evidence文字同步，不自動使Flutter test evidence失效。

### 13.2 Fresh rerun required

以下情況必須fresh：

- selected boundary有新mutation；
- change classes或plan identity改變；
- failure後完成fix；
- validation engine本身改變且其結果尚未被新engine驗證；
- whole-Milestone holistic full regression；
- release gate；
- published main／release SHA post-release validation。

### 13.3 No duplicate full suite rule

同一Task若full regression已在目前plan identity與未變更selected inputs上GREEN，focused re-review、whole-Task review與commit gate不得只因「到了下一個review步驟」再次重跑同一full suite。

此規則只消除無新資訊的重跑，不允許跨Task、跨commit、跨release gate永久reuse。

## 14. Fail-safe and escalation rules

下列情況一律升級full matrix：

- unknown path；
- invalid／missing Git range；
- classifier或planner exception；
- dependency graph無法解析；
- validation plan schema不完整或unknown enum；
- validation engine自身變更尚未通過fresh contract；
- release／manual full request。

Mixed changes採union後取最高風險；不得因同時包含docs-only而降低其他class。

## 15. Measurement design

Corrective不以「test數下降」作成功指標。

### Before baseline

保留admission：

```txt
163 test files
27,781 LOC
961 static cases
full Flutter regression ≈ 34.42s
single 6-case Widget file ≈ 14.02s
```

### After metrics

對固定scenario corpus至少記錄：

- planner輸出的change classes；
- validation level；
- command count；
- Flutter process invocation count；
- selected test scopes；
- wall-clock；
- platform build flags；
- fail-safe result。

Scenario至少包含docs-only、single feature source、single leaf test、package source、shared App boundary、tooling、database、Android native、iOS native、dependency、validation engine、unknown與release。

成功不是所有scenario都更快；成功是低風險scenario明顯少執行不相關工作，而高風險scenario仍正確升級。

## 16. Coverage-hole proof

速度改善必須同時有以下證據：

1. 每個change class都有至少一個明確primary validation owner；除docs-only外不得得到空plan。
2. Reverse dependency tests證明package影響可向consumer傳播。
3. Feature／test-only／tooling mapping有positive與negative contract tests，證明既不漏跑也不無條件full。
4. Unknown／invalid／planner failure持續full fail-safe。
5. Database／generated／native／dependency／release class保留專屬升級測試。
6. Implementation完成後執行fresh full regression，證明新selection engine沒有破壞current suite。
7. Release與post-release再執行fresh full regression；focused routing不能取代這兩個gate。

不得用刪除assertion、刪test或把重要suite移出所有required gates來換取wall-clock改善。

## 17. Documentation synchronization

Implementation時至少review／同步：

- `AGENTS.md`
- `docs/guides/testing_governance.md`
- `docs/guides/how-to-add-feature.md`
- `docs/guides/agent_assisted_development_quick_start.md`
- `docs/guides/ci_cd_operations.md`
- `docs/governance/development_workflow.md`（只在human overview需要反映新machine authority時）
- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- ADR index／documentation indexes（按authority需要）

Guides只描述如何使用planner與level semantics，不複製完整path routing matrix。

## 18. Compatibility and migration

這是governance／CI contract migration，不是production app runtime migration。

Implementation必須在cutover前以tests鎖定現有fail-safe，再新增新plan schema與routing；workflow最後切換。不得先移除`full_ci`舊contract再補新consumer。

若需要短期compatibility projection，可由新planner輸出legacy booleans供舊workflow過渡；但final state不得同時保留兩套獨立selection engines。

## 19. Release and post-release

本Milestone implementation若按本Design完成，發布新的Template Baseline。

Holistic final review必須fresh full regression；release SHA需驗證：

- low-risk scenario不再無條件full；
- high-risk／unknown scenario仍full fail-safe；
- stable CI checks與execution modes未被破壞；
- Android／iOS build只按plan escalation；
- full Flutter suite仍PASS。

Published main／release SHA再做post-release focused routing matrix＋fresh full regression，才可formal closure。

## 20. Non-goals

- 不建立coverage-guided dynamic test selection。
- 不解析Dart AST建立source-to-test dependency graph。
- 不導入第三方test impact analysis service。
- 不做test sharding／random sampling／nightly-only替代。
- 不為了速度刪除existing deterministic tests。
- 不改變Clean Architecture boundary。
- 不移除雙層Task治理。
- 不讓CI workflow或Agent prompt各自維護path-selection邏輯。

## 21. Acceptance criteria

Design implementation完成後必須同時滿足：

1. 一個repository-owned deterministic planner是validation selection唯一machine authority。
2. App feature、package、test-only、tooling、docs、generated、database與native changes有可測試的不同routing。
3. Package affected scope來自workspace dependency graph，而不是所有package一律full。
4. Unknown／invalid／planner failure仍full fail-safe。
5. Inventory tier與Testing Governance重新對齊，不再96%＋tests落在Tier 1。
6. AGENTS／Guides／CI不再互相矛盾。
7. 同一Task、無新相關mutation時，不重複執行相同full suite。
8. Holistic／release／post-release仍要求fresh full regression。
9. Before／after evidence同時呈現wall-clock、command count、Flutter process count與selected coverage boundary。
10. Fresh full regression與routing pressure tests證明沒有coverage hole。

## 22. Implementation boundary

目前只接受Design artifact與review。

在使用者書面核准本Design前：

- 不建立Implementation Plan；
- 不建立managed worktree；
- 不修改production source、tests、classifier、inventory、workflow、ADR或current governance rules；
- 不開始TDD implementation。

