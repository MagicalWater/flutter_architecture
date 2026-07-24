---
document_type: guide
status: accepted
authoritative_for:
  - repository-testing-governance
last_reviewed_baseline: 1.12.0
---

# Testing Governance

## Purpose

本指南是repository test ownership、production／historical boundary、cleanup disposition與execution tier的current authority。測試數量與LOC不是單獨品質指標；優先確保每個failure mode有清楚primary owner且沒有coverage hole。

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

1. 指定primary owner與taxonomy。
2. 優先放在最接近failure source的suite。
3. 只在需要真實boundary時使用integration fixture。
4. 更新inventory並執行focused tests。

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

Change-aware routing必須fail-safe；unknown path、invalid range與classifier failure不得靜默跳過重要gate。

## Commands

```bash
python3 -m unittest tools.testing.test_test_inventory
python3 tools/testing/inventory.py
python3 -m unittest discover -s tools/ci -p 'test_*.py'
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
bash tools/ci/verify_generated.sh
```

Inventory輸出位於`docs/audits/milestone_30/30-2_test_inventory.csv`。受控刪除／搬移證據保存於對應Milestone deletion manifest。
