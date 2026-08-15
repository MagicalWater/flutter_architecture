---
document_type: phase-review
status: active
authoritative_for:
  - milestone-39-task-39-1-critical-mapping-contract-red
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Task 39-1 Critical Mapping Contract RED

## Purpose

以fixture-driven machine RED證明current Template Baseline 1.19.0尚沒有`implementation_mapping.json` validator，因此critical-node mapping disposition、completeness與provenance目前仍只有policy／review contract，沒有direct machine owner。

本Task不修改`implementing-pencil-flutter-design`、不建立validator production module、不解析`.pen`。

## Test Authoring Decision

**Required。**

Milestone 39會新增非平凡mapping failure classification與fail-closed acceptance contract；目前沒有direct machine regression owner。Task 39-1只建立一個fixture-driven test module覆蓋confirmed failure modes，不依node／icon／section數量建立tests。

## RED cases

`tools/visual/test_pencil_implementation_mapping.py`鎖定：

1. mapping artifact missing；
2. duplicate critical node ID；
3. unknown representation class；
4. unknown disposition；
5. production acceptance仍有`unresolved`；
6. `verified-equivalent`缺`evidence_ref`；
7. `intentional-deviation`缺`approval_ref`；
8. Raster asset mapping缺完整provenance fields。

Test fixture只模擬「Pencil MCP extraction後的critical mapping handoff」，不讀或解析`.pen`。

## Expected RED

Current baseline沒有：

```txt
tools/visual/pencil_implementation_mapping.py
```

因此test harness會回傳：

```txt
mapping-validator-missing
```

而每個case預期的是對應specific machine issue code。這會形成可解釋的contract RED；Task 39-2建立validator後，相同tests必須逐項轉GREEN。

## Review gates

- RED必須來自validator contract缺失，不得是Python syntax／import crash／fixture path typo。
- Existing Pencil representation policy必須維持GREEN。
- Existing Pencil single-renderer policy必須維持GREEN。
- 不得為了RED先改Skill wording或新增production validator。

## Current disposition

```txt
Task: RED established / reviewed
Baseline before Task: ffa06b8
Original command: python tools/visual/test_pencil_implementation_mapping.py
Original command disposition: INVALID as final RED evidence; direct script execution does not put repository root on Python package import path
Recovered command: python -m unittest tools.visual.test_pencil_implementation_mapping
Recovered baseline: a300601 fresh detached worktree
Recovered result: FAILED (failures=8), expected RED
Recovered shared cause: mapping-validator-missing because production validator module is genuinely absent at a300601
Existing representation policy: 7/7 PASS
Existing single-renderer policy: 5/5 PASS
docs_check: PASS
git diff --check: PASS
Open P0: 0
Open P1 without disposition: 0
```

## Focused review

### F-39-1-01 — RED不得是假 import crash

- Severity：P1。
- Finding：若直接import尚不存在module造成test collection crash，無法證明各contract case已被正確鎖定。
- Initial resolution：test以明確`mapping-validator-missing` sentinel表示current machine owner不存在；8個assertion因此各自以預期specific code vs sentinel形成可解釋FAIL。
- Post-commit finding：原始direct-script command本身也會讓repository package import失敗，因此原始run不足以證明validator真的不存在。Severity維持P1，早期gate不得回寫成已通過。
- Recovery：在`a300601`建立fresh detached managed worktree，改用`python -m unittest tools.visual.test_pencil_implementation_mapping`。該baseline確實沒有`tools.visual.pencil_implementation_mapping`，8個cases再次以`mapping-validator-missing`穩定RED。
- Fresh re-review：PASS after recovery。

### F-39-1-02 — Fixture不得解析`.pen`

- Severity：P1 authority boundary。
- Finding：RED如果自行掃`.pen`會重建Milestone 33已禁止的native parser shortcut。
- Resolution：fixture只建立JSON mapping input；不讀`.pen`、不操作Pencil。
- Fresh re-review：PASS。

### F-39-1-03 — Test fixture temporary files需可回收

- Severity：P2 test hygiene。
- Finding：初版helper使用`mkdtemp()`但沒有cleanup owner。
- Resolution：每個test使用`TemporaryDirectory`並由`addCleanup`回收。
- Fresh re-review：PASS。

## Whole-Task review

Task 39-1只新增machine contract RED與evidence，沒有修改Skill、Guide、validator production module或Flutter source；Test Authoring維持單一fixture-driven direct owner，沒有every-node test expansion。

Expected RED必須保持8 failures直到Task 39-2建立production validator；因此Task 39-1的completion semantics是「RED穩定且existing authorities保持GREEN」，不是把新test強行變GREEN。

## Post-commit recovery note

Task 39-2第一次GREEN run揭露原始RED command的Python import-path缺陷。依雙層治理，此finding沒有被隱藏或把早期evidence改寫成PASS；以fresh `a300601` worktree補做正確module-mode RED後才允許39-2繼續。
