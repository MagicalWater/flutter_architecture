---
document_type: guide
status: accepted
authoritative_for:
  - repository-testing-governance
last_reviewed_baseline: 1.16.0
---

# Testing Governance

## Purpose

本指南是repository test ownership、Test Authoring／Retention human policy、production／historical boundary、cleanup disposition與execution tier的current authority。測試數量、LOC、case count與coverage percentage都不是品質KPI；永久test採**test-by-exception**，只有critical failure protection值得長期存在。

Central executable authoring policy由`.agents/skills/governing-template-development/references/test-authoring.md`擁有；本Guide提供人類可讀語意，不建立第二套machine routing engine。

## Foundation tests and Product Feature tests

Foundation不享有test-density exemption。Foundation與產品Feature都使用相同permanent-test admission：只有failure成本高、人工不易可靠發現、再發機率合理、deterministic且automation長期成本較低的critical protection才保留。Foundation只是較常包含security、migration、CI fail-safe、platform與shared persistence critical risks。

Auth／Catalog／Profile等reference feature可用來理解architecture、boundary與owner placement，**不是test-density reference**。不得把既有Feature的test files／cases數當成新Feature的最低門檻。

## Test Authoring Decision

Authoring／Retention順序固定為：

```txt
changed behavior / risk / failure mode
→ existing owner是否已充分覆蓋
→ authoring disposition
→ 若新增test，先作temporary evidence並選最接近failure source的primary owner
→ implementation GREEN
→ retention disposition
→ 再由Milestone 35 validation planner決定執行哪些validation
```

### Required

新增或改變failure cost高且人工難穩定發現的business invariant、security／authorization、credential lifecycle、persistence write／migration、destructive operation、concurrency／race／stale completion、retry／idempotency、資料遺失／錯序型pagination或critical failure classification時，必須建立或明確指出direct regression owner。普通UI／copy／style／wiring bug即使可穩定重現，也不自動取得permanent owner。

### Recommended

有實質observable branch且temporary automation能加速開發時可以新增，例如多分支state transition、feature-specific interaction／navigation、非平凡mapper、cache policy、cross-feature coordination。是否永久保留由後續Retention Decision獨立決定。

### no-new-test justified

允許本Task新增0個test，但必須記錄reason與existing owner／risk rationale，例如沒有新failure mode、既有owner已直接覆蓋、presentation-only copy／style或trivial forwarding。

`no-new-test justified`不等於跳過validation。`tools/ci/validation_planner.py`仍選擇最低充分validation；Required critical mutation若沒有direct owner，不得使用此disposition逃避必要regression evidence。

### Should-not-add

以下情況預設反而不應新增test：

- getter／setter、語言本身或framework已保證的behavior；
- 沒有policy／mapping／branch的passthrough UseCase只驗證repository method called once；
- 為了Domain／Data／Bloc／Widget每層都有test而重複同一invariant；
- 只因新增class就建立同名test file；
- 每個畫面機械式新增golden；
- mock implementation detail而不是observable contract；
- 為了coverage percentage、test case count或file count quota而新增test。

## Test taxonomy and primary owner

- Business invariant：由最接近決策的Repository、UseCase或Domain owner驗證。
- Architecture boundary：只有會造成實際runtime／build／security failure且不容易由compiler/analyzer捕捉時才考慮permanent test；一般source-shape／file ownership／prose contract不保留。
- Implementation contract：只驗證adapter、DAO、serializer等實作邊界。
- Migration compatibility／Historical-only：保存舊資料、rollback、fixture與expected oracle。
- Platform／CI：只保留critical fail-safe／security／supported-build contract。Documentation／Visual預設使用checker或人工／visual acceptance，不建立大量permanent regression tests。

同一概念跨層出現時預設視為可能重複；只有不同failure source各自達到critical retention門檻才分層保留。不能因DAO／Repository／Bloc／Widget各自存在就機械保留四層tests。

## Production and historical boundary

- Current behavior tests必須使用current production adapter或明確narrow fake。
- Historical sqflite helpers只可出現在migration、rollback、fixture integrity與expected oracle。
- 不得用historical implementation當current Repository或feature integration fixture。
- 不得因檔名包含legacy、sqflite或migration就直接刪除。

## Add, move, merge, delete and archive

### Add

1. 先完成Test Authoring Decision；test可作temporary驗證工具，不等於永久資產。
2. 指定primary owner與taxonomy。
3. 優先放在最接近failure source的suite。
4. 只在需要真實boundary時使用integration fixture。
5. 執行focused驗證；Task closure前完成Retention Decision。

### Move／Merge

只有critical protection仍需保留時，才要求證明新owner能捕捉相同failure。低價值matrix可直接退休，不需要為了case preservation而搬移。

### Delete

Deletion採兩類：

```txt
critical protection still required
→ replacement / merged owner evidence required

protection intentionally retired
→ replacement = NONE
```

普通UI／copy／style、framework behavior、architecture/docs prose、source-shape、mechanical golden、duplicate layer coverage與temporary RED完成後可直接退休。Portfolio-scale cleanup只需bucket-level disposition、critical keep matrix與before／after metrics，不要求逐case deletion manifest。

### Archive

Historical executable tests不享有preservation priority。只有仍保護critical migration／rollback／compatibility risk時保留；其他historical regression可轉成non-executable evidence或直接退休。

## Large test files

不得只因LOC超過任意門檻拆分。只有owner混合、scenario導航困難、fixture變更互相干擾或runtime隔離需求明確時才拆分。

## Shared fixtures

只有同一typed fixture在至少兩個owner files穩定同步演進，且抽取後不隱藏domain language時才共享。禁止generic fake store、generic persistence contract或YAML DSL掩蓋scenario。

## Execution tiers

- Tier 1：快速unit、Python contracts、docs與inventory。
- Tier 2：package／feature Flutter regression與current integration。
- Tier 3：generated、schema export、migration／rollback、Web assets。
- Tier 4：native scaffold、Android／iOS build contracts。
- Tier 5：physical device、remote hosted與post-release acceptance。

Execution tier描述test／artifact自身的執行特性；**validation level**描述「本次change需要驗證到哪個boundary」。兩者不得混為同一欄位。

## Minimum Sufficient Validation

Test Authoring、Retention與Validation Execution是三個不同決策。可以合法出現`0 permanent tests`甚至`0 automated tests`；但仍要有與changed risk相稱的最低充分validation／runtime／manual acceptance。

Repository以`tools/ci/validation_planner.py`作為validation selection唯一machine authority：

```txt
focused
→ affected-critical
→ explicit-full
→ release
```

- Focused：direct changed owner與必要critical tests。
- Affected-critical：跨boundary change只擴到受影響critical owners，不因Feature存在就掃完整suite。
- Explicit-full：major dependency／validation-engine、自身fail-safe或真正高風險cross-cutting才使用；release intent本身不再自動等於full。
- Release：同一candidate SHA只做一次fresh planner-selected evidence；scope仍依candidate changed risk決定。Publish後驗SHA／artifact identity，不再重跑相同source suite。

同一exact SHA與selected inputs未變時應reuse既有GREEN evidence。Phase名稱改變、publish同SHA或post-release本身不構成fresh source regression理由。

Change-aware routing必須fail-safe；unknown path、invalid range、dependency graph parse failure與planner／classifier failure不得靜默跳過重要gate。

## Commands

```bash
python3 tools/testing/inventory.py
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
python3 -m unittest discover -s tools/ci -p 'test_*.py'
python3 -m unittest discover -s tools/docs -p 'test_*.py'
dart run melos run docs_check
```

`tools/testing/inventory.py`預設只輸出current metrics，不寫入repository；需要一次性CSV evidence時才明確傳入`--output <path>`。Milestone 30／35 inventory CSV都是historical evidence，不得當成current retention authority或被預設覆寫。
