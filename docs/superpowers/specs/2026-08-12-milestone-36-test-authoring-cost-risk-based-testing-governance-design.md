---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-36-test-authoring-governance-design
last_reviewed_baseline: 1.16.0
---

# Milestone 36 — Test Authoring Cost & Risk-Based Testing Governance Corrective Design

## 1. Purpose

本Design補上Milestone 30與Milestone 35之間缺失的治理層：**Test Authoring Decision**。

Milestone 30回答「既有test的primary owner與cleanup disposition是什麼」；Milestone 35回答「一次change要執行哪些既有validation」。本Milestone回答：

> 一個新行為、Task、class或layer發生變更時，是否值得新增test？若需要，最小充分test應由哪個owner負責？

目標不是追求更少tests，而是使新增tests只服務具有實際regression value的risk／invariant／failure mode。

## 2. Design principles

Canonical authoring flow：

```txt
Changed behavior / risk / failure mode
        ↓
Does existing evidence already own it?
        ↓
Authoring disposition
        ↓
Required | Recommended | No-new-test justified | Should-not-add
        ↓
If adding: choose the nearest single primary owner
        ↓
Run Milestone 35 Minimum Sufficient Validation plan
```

禁止反向使用：

```txt
Task / class / layer exists
        ↓
therefore add a test
```

## 3. Stable authority model

### 3.1 New stable testing-authoring ADR

ADR-023只擁有CI／validation selection與execution authority，不應擴張成test authoring policy。

Implementation需建立新的canonical ADR，擁有：

- Risk-Based Test Authoring原則。
- TDD與new-test authoring的關係。
- authoring dispositions與minimum evidence。
- Foundation reference tests與Product Feature authoring boundary。
- Task／layer／class不得自動形成test quota。

Exact ADR number在Implementation Plan建立前依current ADR index配置，不在Design中硬編號。

### 3.2 Human policy authority

`docs/guides/testing_governance.md`繼續是testing governance的人類操作authority，新增Test Authoring Decision章節，但不得複製完整ADR rationale。

### 3.3 Workflow routing authority

`.agents/skills/governing-template-development/`負責把TDD route改成「依authoring disposition決定是否需要new RED test」，並新增pressure scenarios防止AI回到mandatory test-per-task。

`starting-feature-work`保持薄入口，不建立第二套testing policy。

## 4. Authoring dispositions

每個會改變production behavior的implementation Task，在開始寫新test前先取得一個authoring disposition。它不是獨立formal artifact；可以記錄在Design／Plan Task或Task review evidence內。

### 4.1 Required

新增或修改下列behavior時，預設必須有直接、deterministic regression owner；若已有test完整擁有，可不重複新增，但必須指出existing owner：

- security／authentication／authorization／credential boundary；
- money、pricing、tax、points或其他高成本business calculation；
- persistence write、migration、destructive operation、rollback／compatibility；
- concurrency、race、stale completion、idempotency、deduplication、retry ordering；
- state machine、non-trivial validation policy、quota／limit policy；
- pagination／cursor／ordering／cache consistency；
- protocol／serializer／mapper存在非平凡translation、redaction或failure classification；
- bug fix存在可重現且deterministic regression scenario；
- irreversible或高成本failure；
- framework不替repository保證的critical integration／platform boundary。

若Required risk沒有new test，唯一合法理由是existing test已直接擁有相同failure mode，並且Task evidence指出其owner與affected validation。

### 4.2 Recommended

下列情況通常有test value，但需比較maintenance cost：

- Bloc／controller具有多個真正不同state transitions；
- loading／empty／error／content有產品語意差異；
- user interaction會觸發重要intent或navigation branch；
- feature-specific accessibility／localization behavior；
- non-trivial mapper／formatting／normalization；
- cross-feature coordination；
- cache policy、offline fallback、conditional navigation；
- custom visual behavior容易發生functional regression且無更穩定owner。

Recommended不是quota。若existing higher-value owner已覆蓋，應選`no-new-test justified`而不是再建一層duplicate test。

### 4.3 No-new-test justified

允許Task不新增test，但必須同時滿足：

1. 沒有新的Required risk／failure mode，或Required risk已有直接existing owner。
2. 沒有新增值得獨立鎖定的business branch／state transition。
3. 變更可由existing affected tests、static analysis、generated contract、visual acceptance或其他canonical evidence充分驗證。
4. Task review記錄簡短reason與existing validation owner／evidence。

標準evidence格式：

```txt
Test Authoring Disposition: no-new-test justified
Reason: <why no new failure mode / why existing owner is sufficient>
Existing owner/evidence: <test or canonical validation, if applicable>
Affected validation: <planner-selected scope>
```

`no-new-test justified`不等於`no testing`；Milestone 35 planner仍必須選擇並執行affected validation。

### 4.4 Should-not-add

除非Design明確證明額外risk，以下test預設不應新增：

- trivial getter／setter／constructor forwarding；
- 驗證Dart語言或Flutter framework本身的既定行為；
- pure passthrough UseCase只為驗證repository method「called once」；
- 一對一無轉換field mapping，且generated／typed contract已有owner；
- 只為class／layer／Task存在而建立的test file；
- 在多層重複同一business invariant，沒有新增failure source；
- mock private implementation detail而非observable behavior；
- 每個Widget機械式新增golden；
- 已由shared Design System owner驗證的generic responsive／semantics contract，在每個Feature重複建立相同matrix；
- 只為coverage percentage、case count或「每層有綠勾」而新增的tests。

## 5. TDD routing redesign

TDD保持repository標準方法，但其RED gate重新定義為：

```txt
Need a new regression owner?
  YES → write the smallest failing test first
  NO  → record no-new-test justified, then preserve behavior with existing affected validation
```

Bug fix若可deterministically重現，通常仍為Required regression test。若bug只存在於不可自動化external／visual／platform condition，必須記錄替代evidence，不可為了滿足TDD形式創造低價值mock test。

因此：

```txt
TDD ≠ one new test per Task
TDD ≠ one test file per class
TDD ≠ one suite per architecture layer
```

## 6. Foundation vs Product Feature boundary

### Template / Foundation reference tests

Auth、Catalog與部分App／package suites證明模板本身的foundation contracts，例如security、session lifecycle、migration、cache、concurrency、CI fail-safe、platform、Design System與architecture boundaries。

這些tests可以保留高密度，因為其failure surface確實高。

### Product Feature tests

採用模板後新增的普通Feature只依自身risk建立tests，不繼承foundation suite的case數、layer數、test file數或matrix density。

Feature Guide中的Auth／Catalog／Profile reference role必須改成：

- 可參考architecture／ownership pattern；
- 只在新Feature具有相同risk時參考對應test pattern；
- 不得把reference Feature的test density當最低標準。

## 7. Layer ownership rule

保留Milestone 30「同一概念跨層不必然duplicate」的正確原則，但新增authoring guard：

> 跨層test只有在各層具有不同observable failure source時才成立。

例如：

- DAO transaction constraint與Repository cache policy是不同failure source，可各自測。
- Repository把result原樣交給passthrough UseCase，而UseCase沒有policy時，不因存在UseCase layer就再測一次。
- Bloc ordering與Widget rendering是不同failure source，可各自測；但Widget不應重演Bloc的完整state-machine matrix。

## 8. Two-layer Task Governance integration

雙層Task治理保留，但每個implementation Task的evidence chain拆成兩個正交問題：

```txt
Authoring decision:
  Does this Task need a new test owner?

Validation decision:
  Which existing/new evidence must run for this changed range?
```

第一個由Risk-Based Test Authoring governance決定；第二個仍完全由Milestone 35 `validation_planner.py`決定。

Formal Task review不得以「沒有新增test」直接判定失敗；也不得以`no-new-test justified`跳過planner-selected validation。

## 9. Feature Guide redesign

`how-to-add-feature.md`的「Add Tests by Boundary」需改為「Decide Tests by Risk and Boundary」。

原本Domain／Data／Presentation／App integration列表保留作**possible owner examples**，但移除「至少逐層覆蓋」語意，改成：

1. 列出新business invariants／failure modes。
2. 找existing owner。
3. 只有缺少owner時新增最接近failure source的test。
4. 明確檢查Should-not-add anti-pattern。
5. 記錄authoring disposition。

Completion checklist新增：

```txt
[ ] Tests由risk／failure mode驅動，不由layer／class／Task數量驅動
[ ] 沒有建立trivial／structure-only／duplicate-invariant tests
[ ] 若未新增test，已有no-new-test justified與affected validation evidence
```

## 10. Quick Start and Agent examples

`agent_assisted_development_quick_start.md`不得再在普通Feature範例中無條件要求「必須補測試」。改為要求：

> 依Risk-Based Test Authoring判定必要tests；低風險或existing owner充分時允許`no-new-test justified`。

Bug範例保留TDD，但補充「deterministic regression owner」語意。

## 11. Pressure scenarios

治理實作至少新增以下pressure controls：

1. **Trivial passthrough Feature**：新增只有repository passthrough的UseCase，AI不得因UseCase存在自動建立mock-called-once test。
2. **High-risk calculation**：新增價格／折扣規則，AI必須要求deterministic business invariant test。
3. **Existing-owner mutation**：UI copy／composition變更已由existing widget/visual owner覆蓋，允許`no-new-test justified`但仍執行affected validation。
4. **Layer pressure**：同一business invariant跨Repository／UseCase／Bloc；AI必須找不同failure source，不能每層複製同一assertion。
5. **Bug regression**：deterministic stale-response bug必須先建立failing regression test。
6. **Reference imitation**：普通CRUD Feature被要求「照Auth/Catalog完整測試」，AI應拒絕test-density imitation，只採相同risk所需patterns。
7. **Escape pressure**：高風險persistence mutation聲稱`no-new-test justified`但沒有existing direct owner，必須拒絕。

Behavioral execution仍依current `pressure-scenarios.md` protocol執行RED／DISCOVERY／EXPLICIT GREEN／REFACTOR。

## 12. Existing tests and cleanup boundary

本Milestone不預設刪除任何existing tests。

Implementation可在更新authoring policy時辨識明顯trivial／structure-only案例，但除非Plan明確建立narrow cleanup Task且符合Milestone 30 deletion manifest／replacement evidence，否則不在本Corrective順便刪除。

這可避免把「未來不要繼續過量新增」錯誤擴張成「現在大量砍既有coverage」。

## 13. Metrics and acceptance

成功指標不使用coverage percentage或test count quota。

至少以固定scenario corpus驗證：

- Required authoring正確觸發；
- Recommended不被誤當mandatory；
- legitimate `no-new-test justified`可被接受；
- high-risk escape被阻擋；
- trivial／structure-only tests被拒絕；
- reference Feature不再形成test-density imitation；
- planner-selected validation仍完整執行。

可以記錄scenario中的新增test數作觀察值，但不得設定「每Feature最多N個tests」之類quota。

## 14. Documentation synchronization

Implementation至少review／同步：

- `.agents/skills/governing-template-development/SKILL.md`
- `.agents/skills/governing-template-development/references/artifact-routing.md`
- `.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- `.agents/skills/governing-template-development/references/pressure-scenarios.md`
- `.agents/skills/starting-feature-work/SKILL.md`（只需確認薄入口沒有第二套policy；非必要不改）
- `docs/guides/testing_governance.md`
- `docs/guides/how-to-add-feature.md`
- `docs/guides/agent_assisted_development_quick_start.md`
- `docs/governance/development_workflow.md`
- new canonical Test Authoring ADR＋ADR index
- 必要的docs checker／Skill behavioral validation evidence

不修改Milestone 35 planner selection semantics，除非Implementation發現authoring disposition需要machine schema；目前Design預設**不需要**修改`validation_planner.py`。

## 15. Compatibility

Current existing tests保持有效；本Design只改變未來test authoring決策與Agent／human workflow。

Milestone 35的Minimum Sufficient Validation保持唯一execution selection authority。本Milestone不得建立第二個test runner、coverage target或test-impact engine。

## 16. Acceptance criteria

Design implementation完成後必須同時滿足：

1. Repository有stable Risk-Based Test Authoring authority。
2. TDD不再被定義成每個Feature／bug Task無條件新增test，而是依new regression owner需要決定。
3. Required／Recommended／No-new-test justified／Should-not-add四種disposition有明確條件。
4. `no-new-test justified`不能跳過Milestone 35 affected validation，也不能用於沒有existing owner的高風險mutation。
5. Feature Guide不再暗示Domain／Data／Presentation／Integration逐層最低測試配額。
6. Auth／Catalog／Profile繼續作architecture reference，但明確不是test-density quota。
7. 雙層Task把authoring decision與validation selection分離。
8. Pressure scenarios可阻擋trivial testing、layer-for-layer imitation與high-risk no-test escape。
9. Existing security／migration／persistence／concurrency／platform coverage沒有因本Corrective被削弱。
10. Holistic／release／post-release validation依Milestone 35 planner與Level 4 closure保持fresh。

## 17. Implementation boundary

本Design已於2026-08-12取得使用者明確核准，status由`proposed`轉為`accepted`。

Implementation Plan現在可以建立，但在Plan完成完整Task review並取得使用者明確核准前：

- 不建立managed worktree；
- 不修改Skill、Guide、ADR、tests、production source或validation tooling；
- 不開始implementation。
