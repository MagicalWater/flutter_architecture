---
document_type: guide
status: accepted
authoritative_for:
  - repository-testing-governance
last_reviewed_baseline: 1.16.0
---

# Testing Governance

## Purpose

本指南是repository test ownership、Test Authoring human policy、production／historical boundary、cleanup disposition與execution tier的current authority。測試數量、LOC、case count與coverage percentage都不是單獨品質指標；優先確保真正的risk／failure mode有清楚primary owner且沒有coverage hole，同時避免沒有regression value的測試膨脹。

Central executable authoring policy由`.agents/skills/governing-template-development/references/test-authoring.md`擁有；本Guide提供人類可讀語意，不建立第二套machine routing engine。

## Foundation tests and Product Feature tests

Template foundation tests與一般產品Feature tests的目的不同：

- Foundation tests：保護template shared contracts，例如security、migration、CI fail-safe、platform、architecture、shared persistence與Design System infrastructure，因此可以合理具有較高test density。
- Product Feature tests：只依該Feature自己的business risk、state complexity、integration failure mode與regression value決定，不繼承Foundation的test數量或layer密度。

Auth／Catalog／Profile等reference feature可用來理解architecture、boundary與owner placement，**不是test-density reference**。不得把既有Feature的test files／cases數當成新Feature的最低門檻。

## Test Authoring Decision

Authoring順序固定為：

```txt
changed behavior / risk / failure mode
→ existing owner是否已充分覆蓋
→ authoring disposition
→ 若新增test，選最接近failure source的primary owner
→ 再由Milestone 35 validation planner決定執行哪些validation
```

### Required

新增或改變business invariant、security／authorization、credential lifecycle、persistence write／migration、destructive operation、concurrency／race／stale completion、retry／idempotency、pagination／ordering、狀態機、非平凡validation／failure classification，或可穩定重現的bug regression時，必須建立或明確指出direct regression owner。

### Recommended

有實質observable branch且test能明顯降低維護風險時建議新增，例如多分支state transition、feature-specific interaction／navigation、非平凡mapper、cache policy、cross-feature coordination。若fixture／mock／maintenance成本高於regression detection value，不應機械新增。

### no-new-test justified

允許本Task新增0個test，但必須記錄reason與existing owner／risk rationale，例如沒有新failure mode、既有owner已直接覆蓋、presentation-only copy／style或trivial forwarding。

`no-new-test justified` **不等於不執行validation**。Milestone 35 `tools/ci/validation_planner.py`仍決定本Task必須執行的focused／affected／workspace validation；Required高風險mutation若沒有direct owner，不得使用此disposition逃避新增regression evidence。

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
- Architecture boundary：驗證依賴方向、DI、package與Composition Root。
- Implementation contract：只驗證adapter、DAO、serializer等實作邊界。
- Migration compatibility／Historical-only：保存舊資料、rollback、fixture與expected oracle。
- Platform／CI／Documentation／Visual：各由對應native、workflow、docs checker或Widget owner負責。

同一概念跨層出現不等於重複。DAO擁有transaction與constraint；Repository擁有policy與emission ordering；Bloc擁有generation／cancellation；Widget擁有rendering與interaction。

## Production and historical boundary

- Current behavior tests必須使用current production adapter或明確narrow fake。
- Historical sqflite helpers只可出現在migration、rollback、fixture integrity與expected oracle。
- 不得用historical implementation當current Repository或feature integration fixture。
- 不得因檔名包含legacy、sqflite或migration就直接刪除。

## Add, move, merge, delete and archive

### Add

1. 先完成Test Authoring Decision；只有`Required`或經成本判斷後的`Recommended`才新增test。
2. 指定primary owner與taxonomy。
3. 優先放在最接近failure source的suite。
4. 只在需要真實boundary時使用integration fixture。
5. 更新inventory並執行focused tests。

### Move／Merge

必須保留scenario名稱、assertion與failure source，並先證明新owner可捕捉相同回歸。不要為降低LOC把不同domain語意合併成generic contract。

### Delete

刪除前需在deletion manifest記錄：舊coverage、原因、replacement owner、replacement test與validation。沒有replacement evidence不得刪除security、migration、concurrency、platform或fail-safe gates。

### Archive

Historical executable tests預設保持可執行，不以文件取代。只有外部環境永久不可重現且已有正式disposition時，才可轉成manual evidence。

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

Test Authoring與Validation Execution是兩個不同決策。前者回答「是否新增test」，後者回答「本次change必須執行哪些validation」。即使authoring disposition為`no-new-test justified`或`Should-not-add`，後者仍然必須執行。

Repository以`tools/ci/validation_planner.py`作為validation selection唯一machine authority：

```txt
focused
→ affected
→ workspace
→ full
→ release
```

- Focused：直接owner或changed test／tool contract。
- Affected：owner加真實reverse dependents。
- Workspace：shared App／cross-owner boundary的受影響workspace regression。
- Full：validation engine、dependency ambiguity、unknown／invalid range、holistic等完整驗證。
- Release：fresh full加required platform／artifact／post-release evidence。

同一Task內只有plan identity與selected inputs未變時才能reuse既有GREEN evidence；selected boundary有mutation、failure後fix、planner contract改變、Milestone holistic、release與post-release都必須fresh rerun。

Change-aware routing必須fail-safe；unknown path、invalid range、dependency graph parse failure與planner／classifier failure不得靜默跳過重要gate。

## Commands

```bash
python3 -m unittest tools.testing.test_test_inventory
python3 tools/testing/inventory.py --output docs/audits/milestone_35/35-3_current_test_inventory.csv
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
python3 -m unittest discover -s tools/ci -p 'test_*.py'
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
```

Current inventory evidence位於`docs/audits/milestone_35/35-3_current_test_inventory.csv`。`docs/audits/milestone_30/30-2_test_inventory.csv`是Template Baseline 1.12.0 historical evidence，不得覆寫。受控刪除／搬移證據保存於對應Milestone deletion manifest。
